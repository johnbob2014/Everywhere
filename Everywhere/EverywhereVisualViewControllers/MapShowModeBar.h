//
//  MapShowModeBar.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SegmentedControlValueChangedHandler)(UISegmentedControl *sender);
typedef void(^ButtonTouchDownHandler)(UIButton *sender);

@interface MapShowModeBar : UIView

@property (assign,nonatomic) MapShowMode mapShowMode;
@property (strong,nonatomic) NSString *info;

@property (copy,nonatomic) SegmentedControlValueChangedHandler mapShowModeChangedHandler;
@property (copy,nonatomic) ButtonTouchDownHandler datePickerTouchDownHandler;
@property (copy,nonatomic) ButtonTouchDownHandler locaitonPickerTouchDownHandler;

@end
