//
//  UITextField+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/8/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define GCCOLOR_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1] /*#665b53*/
#define GCCOLOR_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/

#define GCCOLOR_COUNTER [UIColor colorWithRed:0.608 green:0.376 blue:0.251 alpha:1] /*#9b6040*/
#define GCCOLOR_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35] /*#ffffff*/

#define GCCOLOR_SUBTITLE [UIColor colorWithRed:0.694 green:0.639 blue:0.6 alpha:1] /*#b1a399*/
#define GCCOLOR_SUBTITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/

#define GCCOLOR_SUBTITLE_VALUE [UIColor colorWithRed:0.694 green:0.639 blue:0.6 alpha:1] /*#b1a399*/
#define GCCOLOR_SUBTITLE_VALUE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/

#define GCFONT_TITLE [UIFont fontWithName:@"HelveticaNeue" size:(ScreenWidth > 375 ? 18.0f : 14.0f)]

#define GCFONT_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]

#define GCFONT_SUBTITLE [UIFont fontWithName:@"HelveticaNeue-Bold" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]
#define GCFONT_SUBTITLE_VALUE [UIFont fontWithName:@"HelveticaNeue" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]


#import "UITextField+Assistant.h"

@implementation UITextField (Assistant)

- (void)setStyle:(enum UITextFieldStyle)aStyle{
    switch (aStyle) {
        case UITextFieldStyleWhiteBold:
            [self setFont:GCFONT_TITLE];
            [self setTextColor:GCCOLOR_TITLE];
            [self.layer setShadowColor:GCCOLOR_TITLE_SHADOW.CGColor];
            [self.layer setShadowOffset:CGSizeMake(0, 1)];
            [self.layer setShadowOpacity:1.0f];
            [self.layer setShadowRadius:0.0f];
            break;
        case UITextFieldStyleBrownBold:
            [self setFont:GCFONT_TITLE];
            [self setTextColor:GCCOLOR_TITLE];
            [self.layer setShadowColor:GCCOLOR_TITLE_SHADOW.CGColor];
            [self.layer setShadowOffset:CGSizeMake(0, 1)];
            [self.layer setShadowOpacity:1.0f];
            [self.layer setShadowRadius:0.0f];
            break;
        default:
            break;
    }
}

@end
