//
//  EverywhereSettingManager.m
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereSettingManager.h"

@implementation EverywhereSettingManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (MapShowMode)mapShowMode{
    MapShowMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapShowMode"];
    return mode;
}

- (void)setMapShowMode:(MapShowMode)mapShowMode{
    [[NSUserDefaults standardUserDefaults] setInteger:mapShowMode forKey:@"mapShowMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)nearestDistanceForMoment{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"nearestDistanceForMoment"];
    if (!distance || distance == 0) distance = 200;
    return distance;
}

- (void)setNearestDistanceForMoment:(CLLocationDistance)nearestDistanceForMoment{
    [[NSUserDefaults standardUserDefaults] setDouble:nearestDistanceForMoment forKey:@"nearestDistanceForMoment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)nearestDistanceForLocation{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"nearestDistanceForLocation"];
    if (!distance || distance == 0) distance = 20000;
    return distance;
}

- (void)setNearestDistanceForLocation:(CLLocationDistance)nearestDistanceForLocation{
    [[NSUserDefaults standardUserDefaults] setDouble:nearestDistanceForLocation forKey:@"nearestDistanceForLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DateMode)dateMode{
    DateMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"dateMode"];
    return mode;
}

- (void)setDateMode:(DateMode)dateMode{
    [[NSUserDefaults standardUserDefaults] setInteger:dateMode forKey:@"dateMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (LocationMode)locationMode{
    LocationMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"locationMode"];
    return mode;
}

- (void)setLocationMode:(LocationMode)locationMode{
    [[NSUserDefaults standardUserDefaults] setInteger:locationMode forKey:@"locationMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)defaultPlacemark{
    NSString *placemark = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultPlacemark"];
    if (!placemark) placemark = @",";
    return placemark;
}

- (void)setDefaultPlacemark:(NSString *)defaultPlacemark{
    [[NSUserDefaults standardUserDefaults] setValue:defaultPlacemark forKey:@"defaultPlacemark"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)playTimeInterval{
    NSTimeInterval playTI = [[NSUserDefaults standardUserDefaults] doubleForKey:@"playTimeInterval"];
    if (!playTI || playTI == 0) playTI = 2;
    return playTI;
}

- (void)setPlayTimeInterval:(NSTimeInterval)playTimeInterval{
    [[NSUserDefaults standardUserDefaults] setDouble:playTimeInterval forKey:@"playTimeInterval"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)mapViewScaleRate{
    float mapViewScaleRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"mapViewScaleRate"];
    if (mapViewScaleRate == 0) mapViewScaleRate = 2.0;
    return mapViewScaleRate;
}

- (void)setMapViewScaleRate:(float)mapViewScaleRate{
    [[NSUserDefaults standardUserDefaults] setFloat:mapViewScaleRate forKey:@"mapViewScaleRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
