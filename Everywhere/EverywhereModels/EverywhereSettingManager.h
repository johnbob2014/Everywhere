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

@property (assign,nonatomic) MapMainMode mapMainMode;
@property (assign,nonatomic) MapExtendedMode mapExtendedMode;

@property (assign,nonatomic) CLLocationDistance mergedDistanceForMoment;
@property (assign,nonatomic) CLLocationDistance mergedDistanceForLocation;

@property (assign,nonatomic) DateMode dateMode;

@property (assign,nonatomic) LocationMode locationMode;
@property (strong,nonatomic) NSString *lastPlacemark;

@property (assign,nonatomic) NSTimeInterval playTimeInterval;

@property (assign,nonatomic) float mapViewScaleRate;

@property (assign,nonatomic) ColorScheme colorScheme;
@property (strong,nonatomic,readonly) UIColor *color;

@property (assign,nonatomic) BOOL hasPurchasedShare;
@property (assign,nonatomic) BOOL hasPurchasedRecord;

@end
