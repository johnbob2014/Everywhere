//
//  ImageVC.m
//  Everywhere
//
//  Created by BobZhang on 16/8/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ImageVC.h"

@implementation ImageVC{
    UIScrollView *scrollView;
    UIImageView *imageView;
}

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGFloat showWidth = self.image.size.width < ScreenWidth ? self.image.size.width : ScreenWidth - 20;
    CGFloat showHeight = self.image.size.height < ScreenHeight ? self.image.size.height : ScreenHeight - 80;
    self.contentSizeInPopup = CGSizeMake(showWidth, showHeight);
    self.landscapeContentSizeInPopup = CGSizeMake(showHeight, showWidth);
    
    scrollView = [UIScrollView newAutoLayoutView];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.contentSize = self.image.size;
    [self.view addSubview:scrollView];
    [scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    imageView = [UIImageView newAutoLayoutView];
    imageView.backgroundColor = [UIColor blackColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = self.image;
    [scrollView addSubview:imageView];
    [imageView autoSetDimensionsToSize:self.image.size];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
}

@end
