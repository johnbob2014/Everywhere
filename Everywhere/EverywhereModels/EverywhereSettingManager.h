//
//  EverywhereSettingManager.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EverywhereSettingManager : NSObject

+ (instancetype)defaultManager;

@property (assign,nonatomic) MapShowMode mapShowMode;
@property (assign,nonatomic) CLLocationDistance nearestDistanceForMoment;
@property (assign,nonatomic) CLLocationDistance nearestDistanceForLocation;

@property (assign,nonatomic) DateMode dateMode;

@property (assign,nonatomic) LocationMode locationMode;
@property (strong,nonatomic) NSString *defaultPlacemark;

@property (assign,nonatomic) NSTimeInterval playTimeInterval;

@property (assign,nonatomic) float mapViewScaleRate;

@end
