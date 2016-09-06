//
//  ShareBar.h
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareBar : UIView

/**
 *  标题
 */
@property (strong,nonatomic) NSString *title;

/**
 *  标题字体
 */
@property (strong,nonatomic) UIFont *titleFont;

/**
 *  左侧图片
 */
@property (strong,nonatomic) UIImage *leftImage;

/**
 *  左侧图片说明
 */
@property (strong,nonatomic) NSString *leftText;

/**
 *  右侧图片
 */
@property (strong,nonatomic) UIImage *rightImage;

/**
 *  右侧图片说明
 */
@property (strong,nonatomic) NSString *rightText;

/**
 *  图片缩放比例（默认值为1.0，即不缩放）
 */
@property (assign,nonatomic) float sideViewShrinkRate;

/**
 *  中间文字
 */
@property (strong,nonatomic) NSString *middleText;

/**
 *  中间文字字体
 */
@property (strong,nonatomic) UIFont *middleFont;

@end
