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

@property (assign,nonatomic) NSUInteger showFootprintsRepositoryType;

//@property (strong,nonatomic) NSArray <EverywhereFootprintsRepository *> *footprintsRepositoryArray;
@property (copy,nonatomic) FootprintsRepositoryDidChangeHandler footprintsRepositoryDidChangeHandler;

//@property (assign,nonatomic) BOOL isRecording;

@end
