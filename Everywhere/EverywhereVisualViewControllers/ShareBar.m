//
//  ShareBar.m
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareBar.h"

@interface ShareBar ()

@end

@implementation ShareBar{
    UILabel *titleLabel;
    UIView *leftView,*middleView,*rightView;
    UIImageView *leftIV,*rightIV;
    UILabel *leftLabel,*middleLabel,*rightLabel;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)init{
    self = [super init];
    if (self) {
        leftView = [UIView newAutoLayoutView];
        [self addSubview:leftView];
        leftIV = [UIImageView newAutoLayoutView];
        leftIV.contentMode = UIViewContentModeScaleAspectFit;
        [leftView addSubview:leftIV];
        leftLabel = [UILabel newAutoLayoutView];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        [leftView addSubview:leftLabel];
        
        rightView = [UIView newAutoLayoutView];
        [self addSubview:rightView];
        rightIV = [UIImageView newAutoLayoutView];
        rightIV.contentMode = UIViewContentModeScaleAspectFit;
        [rightView addSubview:rightIV];
        rightLabel = [UILabel newAutoLayoutView];
        rightLabel.textAlignment = NSTextAlignmentCenter;
        [rightView addSubview:rightLabel];

        middleView = [UIView newAutoLayoutView];
        [self addSubview:middleView];
        /*
        middleIV = [UIImageView newAutoLayoutView];
        middleIV.contentMode = UIViewContentModeScaleAspectFit;
        [middleView addSubview:middleIV];
         */
        middleLabel = [UILabel newAutoLayoutView];
        middleLabel.textAlignment = NSTextAlignmentLeft;
        middleLabel.numberOfLines = 0;
        [middleView addSubview:middleLabel];
        
        titleLabel = [UILabel newAutoLayoutView];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)layoutSubviews{
    float fixNumber = self.bounds.size.height * (1 - self.sideViewShrinkRate);
    UIEdgeInsets leftFixEdgeInsets = UIEdgeInsetsMake(fixNumber, 0, fixNumber, fixNumber);
    UIEdgeInsets rightFixEdgeInsets = UIEdgeInsetsMake(fixNumber, fixNumber, fixNumber, 0);
    
    [leftView autoPinEdgesToSuperviewEdgesWithInsets:leftFixEdgeInsets excludingEdge:ALEdgeRight];
    [leftView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:leftView];
    [leftLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [leftIV autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [leftIV autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:leftLabel withOffset:0];
    
    [rightView autoPinEdgesToSuperviewEdgesWithInsets:rightFixEdgeInsets excludingEdge:ALEdgeLeft];
    [rightView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:rightView];
    [rightLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [rightIV autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [rightIV autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:rightLabel withOffset:0];
    
    [middleView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:leftView withOffset:0];
    [middleView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [middleView autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:leftView];
    [middleView autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:rightView];
    [middleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    // 距父视图顶部3
    [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(3, 0, 0, 0) excludingEdge:ALEdgeBottom];
}

- (void)setSideViewShrinkRate:(float)sideViewShrinkRate{
    if (sideViewShrinkRate < 1 && sideViewShrinkRate > 0) {
        _sideViewShrinkRate = sideViewShrinkRate;
        leftLabel.font = [UIFont bodyFontWithSizeMultiplier:sideViewShrinkRate];
        rightLabel.font = [UIFont bodyFontWithSizeMultiplier:sideViewShrinkRate];
        [self setNeedsLayout];
    }
}

- (void)setLeftImage:(UIImage *)leftImage{
    _leftImage = leftImage;
    leftIV.image = leftImage;
}

- (void)setLeftText:(NSString *)leftText{
    _leftText = leftText;
    leftLabel.text = leftText;
}

- (void)setRightImage:(UIImage *)rightImage{
    _rightImage = rightImage;
    rightIV.image = rightImage;
}

- (void)setRightText:(NSString *)rightText{
    _rightText = rightText;
    rightLabel.text = rightText;
}

- (void)setMiddleText:(NSString *)middleText{
    _middleText = middleText;
    middleLabel.text = middleText;
}

- (void)setMiddleFont:(UIFont *)middleFont{
    _middleFont = middleFont;
    middleLabel.font = middleFont;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    titleLabel.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    titleLabel.font = titleFont;
}
@end
