//
//  AssetsMapVC.h
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetsMapVC : UIViewController
@property (assign,nonatomic) double nearestAnnotationDistance;

@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;
@end
