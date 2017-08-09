//
//  UIViewController+YFPhoto.m
//  YFPhotoDemo
//
//  Created by Bager on 2017/8/8.
//  Copyright © 2017年 Bager. All rights reserved.
//

#import "UIViewController+YFPhoto.h"
#import "objc/runtime.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

static char blockKey;
static enum YFSelectImgType imageType = YFSelectImgTypeNormal;

@interface UIViewController()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>

@property (nonatomic, copy) photoInfoBlock photoInfoBlock;

@end


@implementation UIViewController (YFPhoto)

- (void)getYFPhotoInfoWithImgType:(enum YFSelectImgType)imgType photoInfo:(photoInfoBlock)photoInfo
{
    imageType = imgType;
    
    self.photoInfoBlock = [photoInfo copy];
    
    [self showActionSheet];
}

- (void)setPhotoInfoBlock:(photoInfoBlock)photoInfoBlock
{
    objc_setAssociatedObject(self, &blockKey, photoInfoBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (photoInfoBlock)photoInfoBlock
{
    return objc_getAssociatedObject(self, &blockKey);
}

#pragma mark - 选择照片

- (void)showActionSheet
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请选择照片来源" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImageFromCamera];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImageFromAlbum];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil]];
    
    [self.view.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 从相机获取

- (void)pickImageFromCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied)
    {
        [self showTipAlertWithMessage:@"无法使用相机\n请在iPhone的\"设置-隐私-相机\"中允许访问相机."];
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (imageType == YFSelectImgTypeEdited || imageType == YFSelectImgTypeEditedInfo)
    {
        imagePicker.allowsEditing = YES;
    }
    else
    {
        imagePicker.allowsEditing = NO;
    }
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 从相册获取

- (void)pickImageFromAlbum
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied)
    {
        [self showTipAlertWithMessage:@"无法使用照片\n请在iPhone的\"设置-隐私-照片\"中允许访问照片."];
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    if (imageType == YFSelectImgTypeEdited || imageType == YFSelectImgTypeEditedInfo)
    {
        imagePicker.allowsEditing = YES;
    }
    else
    {
        imagePicker.allowsEditing = NO;
    }
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 选择图片回调代理

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image;
    //是否要裁剪
    if ([picker allowsEditing]){
        
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else {
        
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        NSString *imgUrl = [representation filename];
        
        NSData *dataImage;
        if(UIImagePNGRepresentation(image))
        {
            dataImage = UIImagePNGRepresentation(image);
        }
        else
        {
            dataImage = UIImageJPEGRepresentation(image, 1);
        }
        
        if (imageType == YFSelectImgTypeEdited || imageType == YFSelectImgTypeNormal)
        {
            self.photoInfoBlock(image);
        }
        else if (self.photoInfoBlock)
        {
            self.photoInfoBlock(@[image, imgUrl]);
        }
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [assetslibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error) {
                NSLog(@"error");
            } else {
                [assetslibrary assetForURL:assetURL
                               resultBlock:resultblock
                              failureBlock:nil];
            }
        }];
    }
    else
    {
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        
        [assetslibrary assetForURL:imageURL
                       resultBlock:resultblock
                      failureBlock:nil];
    }
}

#pragma mark - 权限提示框

- (void)showTipAlertWithMessage:(NSString *)message
{
    UIAlertController *alertShow = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *other = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        CGFloat kSystemMainVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (kSystemMainVersion >= 8.0)
        {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alertShow addAction:cancel];
    [alertShow addAction:other];
    [self presentViewController:alertShow animated:YES completion:nil];
}

@end
