//
//  ShareBar.h
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareBar : UIView

@property (strong,nonatomic) UIImage *leftImage;
@property (strong,nonatomic) NSString *leftText;

@property (strong,nonatomic) UIImage *rightImage;
@property (strong,nonatomic) NSString *rightText;

@property (strong,nonatomic) NSString *middleText;

@property (assign,nonatomic) float sideViewShrinkRate;

@end
