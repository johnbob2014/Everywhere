//
//  FootprintsRepositoryPickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereFootprintsRepository.h"

typedef void(^FootprintsRepositoryDidChangeHandler)(EverywhereFootprintsRepository *choosedFootprintsRepository);

@interface FootprintsRepositoryPickerVC : UIViewController

/**
 *  要显示的足迹包类型
 */
@property (assign,nonatomic) NSUInteger showFootprintsRepositoryType;

/**
 *  传输用户选择的足迹包
 */
@property (copy,nonatomic) FootprintsRepositoryDidChangeHandler footprintsRepositoryDidChangeHandler;

@end
