//
//  UILabel+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/8/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "UILabel+Assistant.h"

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

@implementation UILabel (Assistant)

- (void)setStyle:(enum UILabelStyle)aStyle{
    switch (aStyle) {
        case UILabelStyleBrownBold:
            self.font = GCFONT_COUNTER;
            self.textColor = GCCOLOR_COUNTER;
            self.shadowColor = GCCOLOR_COUNTER_SHADOW;
            self.shadowOffset = CGSizeMake(0, 1);
            break;
        case UILabelStyleWhiteFontBlackBackground:
            //self.font = [UIFont bo]
            self.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor blackColor];
            self.shadowColor = GCCOLOR_COUNTER_SHADOW;
            self.shadowOffset = CGSizeMake(0, 1);
            break;
        default:
            break;
    }
}

@end
