//
//  FootprintAnnotationPickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWFRInfo.h"


//typedef void(^FootprintsRepositoryDidChangeHandler)(EverywhereFootprintsRepository *changedFootprintsRepository);

@interface FootprintAnnotationPickerVC : UIViewController
@property (strong,nonatomic) EWFRInfo *ewfrInfo;
//@property (copy,nonatomic) FootprintsRepositoryDidChangeHandler footprintsRepositoryDidChangeHandler;
@end