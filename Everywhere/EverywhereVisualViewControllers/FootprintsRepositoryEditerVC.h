//
//  FootprintsRepositoryEditerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereFootprintsRepository.h"

typedef void(^FootprintsRepositoryDidChangeHandler)(EverywhereFootprintsRepository *changedFootprintsRepository);

@interface FootprintsRepositoryEditerVC : UIViewController
@property (copy,nonatomic) EverywhereFootprintsRepository *footprintsRepository;
@property (copy,nonatomic) FootprintsRepositoryDidChangeHandler footprintsRepositoryDidChangeHandler;
@end
