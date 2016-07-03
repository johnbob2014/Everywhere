//
//  UIFont+Assistant.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "UIFont+Assistant.h"

@implementation UIFont (Assistant)

+(UIFont *)bodyFontWithSizeMultiplier:(CGFloat)multiplier{
    UIFont *bodyFont=[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    return [UIFont fontWithName:bodyFont.fontName size:bodyFont.pointSize*multiplier];
}

@end
