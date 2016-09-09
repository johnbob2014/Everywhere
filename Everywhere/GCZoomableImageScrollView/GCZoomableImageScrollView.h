//
//  GCZoomableImageScrollView.h
//  Everywhere
//
//  Created by BobZhang on 16/9/8.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SDWebImageOperation.h"

@interface GCZoomableImageScrollView : UIScrollView

@property (nonatomic, strong) UIImageView                   *imageView;

@property (nonatomic, strong) NSString                      *imageURLString;

//@property (nonatomic, weak) id <SDWebImageOperation>        webImageOperation;

@property (nonatomic, strong) UIProgressView                *progressView;

@property (nonatomic) BOOL                                  isLoaded;

@property (nonatomic, assign) BOOL fullScreen;

- (void)configImageByURL:(NSURL *)url;

- (void)configImage:(UIImage *)image;

@end
