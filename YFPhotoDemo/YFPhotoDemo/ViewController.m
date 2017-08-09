//
//  ViewController.m
//  YFPhotoDemo
//
//  Created by Bager on 2017/8/8.
//  Copyright © 2017年 Bager. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+YFPhoto.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *imgNameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)selectImg:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    
    [self getYFPhotoInfoWithImgType:YFSelectImgTypeEdited photoInfo:^(id photoInfo) {
        NSArray *photoInfos = photoInfo;
        [weakSelf.imgView setImage:photoInfos[0]];
    }];
    
//    [self getYFPhotoInfoWithImgType:YFSelectImgTypeEditedInfo photoInfo:^(id photoInfo) {
//        NSArray *photoInfos = photoInfo;
//        [weakSelf.imgView setImage:photoInfos[0]];
//        weakSelf.imgNameLabel.text = photoInfo[1];
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
