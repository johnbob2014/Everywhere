//
//  UIImage+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/7/29.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Assistant)
+ (UIImage *)thumbImageFromImage:(UIImage *)sourceImage limitSize:(CGSize)limitSize;
@end
