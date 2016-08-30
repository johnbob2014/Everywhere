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

@property (strong,nonatomic) EverywhereFootprintsRepository *footprintsRepository;

@property (strong,nonatomic) UIImage *thumbImage;

@property (copy,nonatomic) UserDidSelectedPurchaseShareFunctionHandler userDidSelectedPurchaseShareFunctionHandler;

@end
