//
//  MapModeBar.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SegmentedControlValueChangedHandler)(UISegmentedControl *sender);
typedef void(^ButtonTouchDownHandler)(UIButton *sender);

@interface MapModeBar : UIView

@property (strong,nonatomic) NSString *info;

@property (assign,nonatomic) BOOL modeSegEnabled;
@property (assign,nonatomic) BOOL leftButtonEnabled;
@property (assign,nonatomic) BOOL rightButtonEnabled;

- (instancetype)initWithModeSegItems:(NSArray *)segItems selectedSegIndex:(NSInteger)selectedSegIndex leftButtonImage:(UIImage *)leftImage rightButtonImage:(UIImage *)rightImage;

@property (copy,nonatomic) SegmentedControlValueChangedHandler mapMainModeChangedHandler;
@property (copy,nonatomic) ButtonTouchDownHandler leftButtonTouchDownHandler;
@property (copy,nonatomic) ButtonTouchDownHandler rightButtonTouchDownHandler;

@property (copy,nonatomic) UIColor *contentViewBackgroundColor;

@end
