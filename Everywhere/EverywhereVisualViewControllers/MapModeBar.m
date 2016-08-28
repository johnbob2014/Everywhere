//
//  MapModeBar.m
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "MapModeBar.h"
#import "EverywhereSettingManager.h"

@interface MapModeBar ()
@property (strong,nonatomic) UISegmentedControl *modeSeg;
@property (strong,nonatomic) UILabel *infoLabel;
@property (strong,nonatomic) UIButton *leftButton;
@property (strong,nonatomic) UIButton *rightButton;
@end

@implementation MapModeBar{
    UIView *leftView,*middleView,*rightView;
    NSArray *modeSegItems;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithModeSegItems:(NSArray *)segItems selectedSegIndex:(NSInteger)selectedSegIndex leftButtonImage:(UIImage *)leftImage rightButtonImage:(UIImage *)rightImage{
    self = [super init];
    if (self) {
        modeSegItems = segItems;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        
        middleView = [UIView newAutoLayoutView];
        [self addSubview:middleView];
        
        self.modeSeg = [[UISegmentedControl alloc] initWithItems:segItems];
        self.modeSeg.tintColor = [UIColor whiteColor];
        self.modeSeg.translatesAutoresizingMaskIntoConstraints = NO;
        [self.modeSeg addTarget:self action:@selector(modeValueChanged:) forControlEvents:UIControlEventValueChanged];
        [middleView addSubview:self.modeSeg];
        self.modeSeg.selectedSegmentIndex = selectedSegIndex;
        
        self.infoLabel = [UILabel newAutoLayoutView];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.text = modeSegItems[selectedSegIndex];
        [middleView addSubview:self.infoLabel];
        
        leftView = [UIView newAutoLayoutView];
        
        [self addSubview:leftView];
        
        self.leftButton = [UIButton newAutoLayoutView];
        self.leftButton.enabled = selectedSegIndex == 0 ? YES : NO;
        [self.leftButton setImage:leftImage forState:UIControlStateNormal];
        [self.leftButton setImage:[UIImage imageNamed:@"IcoMoon_Unlink"] forState:UIControlStateDisabled];
        [self.leftButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Background"] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(leftButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [leftView addSubview:self.leftButton];
        
        rightView = [UIView newAutoLayoutView];
        
        [self addSubview:rightView];
        
        self.rightButton = [UIButton newAutoLayoutView];
        self.rightButton.enabled = selectedSegIndex == 1 ? YES : NO;
        [self.rightButton setImage:rightImage forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"IcoMoon_Unlink"] forState:UIControlStateDisabled];
        [self.rightButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Background"] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(rightButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [rightView addSubview:self.rightButton];
        
        self.leftButtonEnabled = selectedSegIndex == 0 ? YES : NO;
        self.rightButtonEnabled = !self.leftButtonEnabled;

    }
    return self;
}

- (void)modeValueChanged:(UISegmentedControl *)sender{
    
    if (self.modeChangedHandler) self.modeChangedHandler(sender);
    self.infoLabel.text = modeSegItems[sender.selectedSegmentIndex];
    
    if (sender.selectedSegmentIndex == 0) {
        self.leftButton.enabled = YES;
        self.rightButton.enabled = NO;
    }else{
        self.leftButton.enabled = NO;
        self.rightButton.enabled = YES;
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    self.modeSeg.selectedSegmentIndex = selectedSegmentIndex;
}

- (void)leftButtonTouchDown:(UIButton *)sender{
    if (self.leftButtonTouchDownHandler) self.leftButtonTouchDownHandler(sender);
}

- (void)rightButtonTouchDown:(UIButton *)sender{
    if (self.rightButtonTouchDownHandler) self.rightButtonTouchDownHandler(sender);
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
    
    [self.leftButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [self.leftButton autoCenterInSuperview];
    [self.rightButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [self.rightButton autoCenterInSuperview];
    [self.modeSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [self.infoLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
}

- (void)setContentViewBackgroundColor:(UIColor *)contentViewBackgroundColor{
    middleView.backgroundColor = contentViewBackgroundColor;
    leftView.backgroundColor = contentViewBackgroundColor;
    rightView.backgroundColor = contentViewBackgroundColor;
}

- (void)setModeSegEnabled:(BOOL)modeSegEnabled{
    _modeSegEnabled = modeSegEnabled;
    self.modeSeg.enabled = modeSegEnabled;
}

- (void)setLeftButtonEnabled:(BOOL)leftButtonEnabled{
    _leftButtonEnabled = leftButtonEnabled;
    self.leftButton.enabled = leftButtonEnabled;
}

- (void)setRightButtonEnabled:(BOOL)rightButtonEnabled{
    _rightButtonEnabled = rightButtonEnabled;
    self.rightButton.enabled = rightButtonEnabled;
}

- (void)setInfo:(NSString *)info{
    _info = info;
    self.infoLabel.text = info;
}

@end
