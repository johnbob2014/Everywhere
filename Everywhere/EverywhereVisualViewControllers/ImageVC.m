//
//  ImageVC.m
//  Everywhere
//
//  Created by BobZhang on 16/8/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ImageVC.h"

@interface ImageVC() <UIScrollViewDelegate>
@property (strong,nonatomic) NSArray <UIImage *> *imageArray;
@end

@implementation ImageVC{
    UIScrollView *scrollView;
}

- (instancetype)initWithImageArray:(NSArray<UIImage *> *)imageArray{
    self = [super init];
    if (self) {
        self.imageArray = imageArray;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    /*
    CGFloat showWidth = self.image.size.width < ScreenWidth ? self.image.size.width : ScreenWidth - 20;
    CGFloat showHeight = self.image.size.height < ScreenHeight ? self.image.size.height : ScreenHeight - 80;
    self.contentSizeInPopup = CGSizeMake(showWidth, showHeight);
    self.landscapeContentSizeInPopup = CGSizeMake(showHeight, showWidth);
    */
    
    self.title = [NSString stringWithFormat:@"%@ - %lu",self.title,self.imageArray.count];
    
    CGFloat imageWidth = self.view.frame.size.width;
    CGFloat imageOffset = 20;
    
    scrollView = [UIScrollView newAutoLayoutView];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.contentSize = CGSizeMake((imageWidth + imageOffset) * self.imageArray.count - imageOffset, self.view.frame.size.height - 10);
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    [scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.imageArray enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView;
        imageView = [[UIImageView alloc] initWithImage:obj];
        imageView.backgroundColor = ClearColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake((imageWidth + imageOffset) * idx, 0, imageWidth, self.view.frame.size.height - 10);
        [scrollView addSubview:imageView];
    }];
    
}

@end
