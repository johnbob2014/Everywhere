//
//  GCZoomableImageScrollView.h
//  Everywhere
//
//  Created by 张保国 on 16/9/9.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCZoomableImageScrollView : UIScrollView

@property (strong,nonatomic) UIImage *image;

@property (strong,nonatomic) NSURL *imageURL;

@property (assign,nonatomic) float imageMaximumZoomScale;

@end
