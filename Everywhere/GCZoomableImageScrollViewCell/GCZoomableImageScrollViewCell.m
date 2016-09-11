//
//  GCZoomableImageScrollViewCell.m
//  Everywhere
//
//  Created by 张保国 on 16/9/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCZoomableImageScrollViewCell.h"

@implementation GCZoomableImageScrollViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.zoomableImageScrollView = [GCZoomableImageScrollView newAutoLayoutView];
        [self.contentView addSubview:self.zoomableImageScrollView];
        [self.zoomableImageScrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
        [self.contentView layoutIfNeeded];
    }
    return self;
}

@end
