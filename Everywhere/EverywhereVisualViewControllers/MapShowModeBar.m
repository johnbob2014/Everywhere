//
//  MapShowModeBar.m
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "MapShowModeBar.h"
#import "EverywhereSettingManager.h"

@interface MapShowModeBar ()
@property (strong,nonatomic) UISegmentedControl *modeSeg;
@property (strong,nonatomic) UILabel *infoLabel;
@property (strong,nonatomic) UIButton *datePickerBtn;
@property (strong,nonatomic) UIButton *locationPickerBtn;

@end

@implementation MapShowModeBar{
    UIView *leftView,*middleView,*rightView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setMapShowMode:(MapShowMode)mapShowMode{
    _mapShowMode = mapShowMode;
    self.modeSeg.selectedSegmentIndex = mapShowMode;
    [self mapShowModeValueChanged:self.modeSeg];
}

- (void)setInfo:(NSString *)info{
    _info = info;
    self.infoLabel.text = info;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        middleView = [UIView newAutoLayoutView];
        
        [self addSubview:middleView];
        
        self.modeSeg = [[UISegmentedControl alloc] initWithItems:[NSLocalizedString(@"MomentMode LocationMode",@"") componentsSeparatedByString:@" "]];
        self.modeSeg.translatesAutoresizingMaskIntoConstraints = NO;
        [self.modeSeg addTarget:self action:@selector(mapShowModeValueChanged:) forControlEvents:UIControlEventValueChanged];
        [middleView addSubview:self.modeSeg];
        
        self.infoLabel = [UILabel newAutoLayoutView];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.textColor = [UIColor whiteColor];
        [middleView addSubview:self.infoLabel];
        
        leftView = [UIView newAutoLayoutView];
        
        [self addSubview:leftView];
        
        self.datePickerBtn = [UIButton newAutoLayoutView];
        self.datePickerBtn.enabled = self.mapShowMode == MapShowModeMoment ? YES : NO;
        [self.datePickerBtn setImage:[UIImage imageNamed:@"IcoMoon_Calendar"] forState:UIControlStateNormal];
        [self.datePickerBtn setImage:[UIImage imageNamed:@"IcoMoon_Unlink"] forState:UIControlStateDisabled];
        [self.datePickerBtn setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Background"] forState:UIControlStateNormal];
        [self.datePickerBtn addTarget:self action:@selector(datePickerBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [leftView addSubview:self.datePickerBtn];
        
        rightView = [UIView newAutoLayoutView];
        
        [self addSubview:rightView];
        
        self.locationPickerBtn = [UIButton newAutoLayoutView];
        self.locationPickerBtn.enabled = self.mapShowMode == MapShowModeLocation ? YES : NO;
        [self.locationPickerBtn setImage:[UIImage imageNamed:@"IcoMoon_Dribble3"] forState:UIControlStateNormal];
        [self.locationPickerBtn setImage:[UIImage imageNamed:@"IcoMoon_Unlink"] forState:UIControlStateDisabled];
        [self.locationPickerBtn setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Background"] forState:UIControlStateNormal];
        [self.locationPickerBtn addTarget:self action:@selector(locationPickerBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [rightView addSubview:self.locationPickerBtn];
    }
    return self;
}

- (void)mapShowModeValueChanged:(UISegmentedControl *)sender{
    if (self.mapShowModeChangedHandler) self.mapShowModeChangedHandler(sender);
    if (sender.selectedSegmentIndex == 0) {
        self.datePickerBtn.enabled = YES;
        self.locationPickerBtn.enabled = NO;
    }else{
        self.datePickerBtn.enabled = NO;
        self.locationPickerBtn.enabled = YES;
    }
    //self.infoLabel.text = [NSLocalizedString(@"MomentMode LocationMode",@"") componentsSeparatedByString:@" "][sender.selectedSegmentIndex];
}

- (void)datePickerBtnTouchDown:(UIButton *)sender{
    if (self.datePickerTouchDownHandler) self.datePickerTouchDownHandler(sender);
}

- (void)locationPickerBtnTouchDown:(UIButton *)sender{
    if (self.locaitonPickerTouchDownHandler) self.locaitonPickerTouchDownHandler(sender);
}

- (void)layoutSubviews{
    [leftView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeRight];
    [leftView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self];
    
    [rightView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeLeft];
    [rightView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self];
    
    [middleView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [middleView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [middleView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:leftView withOffset:10];
    [middleView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:rightView withOffset:-10];
    
    [self.datePickerBtn autoSetDimensionsToSize:CGSizeMake(40, 40)];
    [self.datePickerBtn autoCenterInSuperview];
    [self.locationPickerBtn autoSetDimensionsToSize:CGSizeMake(40, 40)];
    [self.locationPickerBtn autoCenterInSuperview];
    [self.modeSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [self.infoLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
}

- (void)setContentViewBackgroundColor:(UIColor *)contentViewBackgroundColor{
    middleView.backgroundColor = contentViewBackgroundColor;
    leftView.backgroundColor = contentViewBackgroundColor;
    rightView.backgroundColor = contentViewBackgroundColor;
}
@end
