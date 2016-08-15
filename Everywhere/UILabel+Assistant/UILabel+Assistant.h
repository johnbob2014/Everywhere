//
//  UILabel+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/8/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, UILabelStyle) {
    UILabelStyleBrownBold,
    UILabelStyleSystem,
    UILabelStyleGreen
};

@interface UILabel (Assistant)

- (void)setStyle:(enum UILabelStyle)aStyle;

@end
