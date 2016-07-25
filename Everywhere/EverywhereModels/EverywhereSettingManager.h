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

@property (assign,nonatomic) MapBaseMode mapBaseMode;
@property (assign,nonatomic) MapExtendedMode mapExtendedMode;

@property (assign,nonatomic) CLLocationDistance mergeDistanceForMoment;
@property (assign,nonatomic) CLLocationDistance mergeDistanceForLocation;

@property (assign,nonatomic) DateMode dateMode;

@property (assign,nonatomic) LocationMode locationMode;
@property (strong,nonatomic) NSString *lastPlacemark;

@property (assign,nonatomic) NSTimeInterval playTimeInterval;

@property (assign,nonatomic) float mapViewScaleRate;

@property (assign,nonatomic) BaseColorScheme baseColorScheme;
@property (strong,nonatomic,readonly) UIColor *baseTintColor;

@property (assign,nonatomic) ExtendedColorScheme extendedColorScheme;
@property (strong,nonatomic,readonly) UIColor *extendedTintColor;

@property (assign,nonatomic) BOOL hasPurchasedShare;
@property (assign,nonatomic) BOOL hasPurchasedRecord;

@property (assign,nonatomic) CLLocationDistance minDistanceForRecord;
@property (assign,nonatomic) NSTimeInterval minTimeIntervalForRecord;
@property (assign,nonatomic) NSInteger maxFootprintsCountForRecord;

@property (assign,nonatomic) NSInteger praiseCount;

@end
