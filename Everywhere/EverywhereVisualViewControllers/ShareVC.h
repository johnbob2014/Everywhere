//
//  ShareVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareVC : UIViewController

@property (strong,nonatomic) UIImage *shareImage;
@property (strong,nonatomic) NSString *shareWebpageUrl;

@property (strong,nonatomic) NSString *shareTitle;
@property (strong,nonatomic) NSString *shareDescription;

@property (strong,nonatomic) NSData *shareThumbData;

@end
