//
//  UIColor+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/8/12.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "UIColor+Assistant.h"

@implementation UIColor (Assistant)

+ (UIColor *)randomColor{
    CGFloat randomRed=MIN((CGFloat)(arc4random()%11)/10, 1.0);
    CGFloat randomGreen=MIN((CGFloat)(arc4random()%11)/10, 1.0);
    CGFloat randomBlue=MIN((CGFloat)(arc4random()%11)/10, 1.0);
    CGFloat randomAlpha=MIN((CGFloat)(arc4random()%11)/10, 1.0);
    return [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:randomAlpha];
}

@end
