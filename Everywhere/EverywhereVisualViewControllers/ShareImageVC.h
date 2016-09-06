//
//  ShareImageVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  图片分享控制器
 */
@interface ShareImageVC : UIViewController

/**
 *  分享图片
 */
@property (strong,nonatomic) UIImage *shareImage;

/**
 *  分享缩略图
 */
@property (strong,nonatomic) NSData *shareThumbData;

/**
 *  分享标题
 */
@property (strong,nonatomic) NSString *shareTitle;

/**
 *  分享描述内容
 */
@property (strong,nonatomic) NSString *shareDescription;

@end
