//
//  UIImage+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/7/29.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "UIImage+Assistant.h"

@implementation UIImage (Assistant)

+ (UIImage *)thumbImageFromImage:(UIImage *)sourceImage limitSize:(CGSize)limitSize {
    if (sourceImage.size.width <= limitSize.width && sourceImage.size.height <= limitSize.height) {
        return sourceImage;
    }
    CGSize thumbSize;
    if (sourceImage.size.width / sourceImage.size.height > limitSize.width / limitSize.height){
        thumbSize.width = limitSize.width;
        thumbSize.height = limitSize.width / sourceImage.size.width * sourceImage.size.height;
    }
    else {
        thumbSize.height = limitSize.height;
        thumbSize.width = limitSize.height / sourceImage.size.height * sourceImage.size.width;
    }
    UIGraphicsBeginImageContext(thumbSize);
    [sourceImage drawInRect:(CGRect){CGPointZero,thumbSize}];
    UIImage *thumbImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbImg;
}


@end
