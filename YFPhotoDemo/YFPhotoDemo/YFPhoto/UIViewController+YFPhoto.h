//
//  UIViewController+YFPhoto.h
//  YFPhotoDemo
//
//  Created by Bager on 2017/8/8.
//  Copyright © 2017年 Bager. All rights reserved.
//  

#import <UIKit/UIKit.h>

enum YFSelectImgType
{
    YFSelectImgTypeNormal = 1, // 未裁剪图片 & 返回图片 -> block返回 UIImage
    YFSelectImgTypeEdited,  // 裁剪后图片 & 返回图片 -> block返回 UIImage
    YFSelectImgTypeNormalInfo, // 未裁剪图片 & 返回图片和图片名 -> block返回 -> 数组 @[图片, 图片名] -> NSArray @[UIImage, NSString]
    YFSelectImgTypeEditedInfo  // 裁剪后图片 & 返回图片和图片名 -> block返回 -> 数组 @[图片, 图片名] -> NSArray @[UIImage, NSString]
};

typedef void(^photoInfoBlock)(id photoInfo);

@interface UIViewController (YFPhoto)

/**
 *  照片选择 -> 图库/相机
 *
 *  @param imgType   照片是否需要裁剪,默认NO
 *  @param photoInfo switch YFSelectImgType
 *  case 1 : YFSelectImgTypeNormal || YFSelectImgTypeEdited 照片回调类型 UIImage
 *  case 2 : YFSelectImgTypeNormalInfo || YFSelectImgTypeEditedInfo 照片回调类型 NSArray @[图片,图片地址] / @[UIImage, NSString]
 */
- (void)getYFPhotoInfoWithImgType:(enum YFSelectImgType)imgType photoInfo:(photoInfoBlock)photoInfo;

@end
