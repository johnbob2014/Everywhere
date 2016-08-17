//
//  UITextField+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/8/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UITextFieldStyle) {
    UITextFieldStyleWhiteBold,
    UITextFieldStyleBrownBold
};

@interface UITextField (Assistant)
- (void)setStyle:(enum UITextFieldStyle)aStyle;
@end
