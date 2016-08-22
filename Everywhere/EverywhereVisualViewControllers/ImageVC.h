//
//  ImageVC.h
//  Everywhere
//
//  Created by BobZhang on 16/8/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageVC : UIViewController
- (instancetype)initWithImage:(UIImage *)image;
@property (strong,nonatomic) UIImage *image;
@end
