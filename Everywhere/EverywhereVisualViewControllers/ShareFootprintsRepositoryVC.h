//
//  ShareFootprintsRepositoryVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereFootprintsRepository.h"

typedef void(^UserDidSelectedPurchaseShareFunctionHandler)();

@interface ShareFootprintsRepositoryVC : UIViewController

/**
 *  分享足迹包
 */
@property (strong,nonatomic) EverywhereFootprintsRepository *footprintsRepository;

/**
 *  分享缩略图
 */
@property (strong,nonatomic) UIImage *thumbImage;

/**
 *  用户选择定购
 */
@property (copy,nonatomic) UserDidSelectedPurchaseShareFunctionHandler userDidSelectedPurchaseShareFunctionHandler;

@end
