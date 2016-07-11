//
//  EverywhereSettingManager.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetsMapProVC.h"

@interface EverywhereSettingManager : NSObject

+ (instancetype)defaultManager;

@property (assign,nonatomic) MapShowMode mapShowMode;
@property (assign,nonatomic) CLLocationDistance nearestDistanceForMoment;
@property (assign,nonatomic) CLLocationDistance nearestDistanceForLocation;

@property (assign,nonatomic) DateMode dateMode;
@property (strong,nonatomic) NSString *defaultPlacemark;

@end
