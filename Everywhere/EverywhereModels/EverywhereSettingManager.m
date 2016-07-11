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
    if (!mode) mode = MapShowModeLocation;
    return mode;
}

- (void)setMapShowMode:(MapShowMode)mapShowMode{
    [[NSUserDefaults standardUserDefaults] setInteger:mapShowMode forKey:@"mapShowMode"];
}

- (CLLocationDistance)nearestDistanceForMoment{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"nearestDistanceForMoment"];
    if (!distance || distance == 0) distance = 200;
    return distance;
}

- (void)setNearestDistanceForMoment:(CLLocationDistance)nearestDistanceForMoment{
    [[NSUserDefaults standardUserDefaults] setDouble:nearestDistanceForMoment forKey:@"nearestDistanceForMoment"];
}

- (CLLocationDistance)nearestDistanceForLocation{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"nearestDistanceForLocation"];
    if (!distance || distance == 0) distance = 20000;
    return distance;
}

- (void)setNearestDistanceForLocation:(CLLocationDistance)nearestDistanceForLocation{
    [[NSUserDefaults standardUserDefaults] setDouble:nearestDistanceForLocation forKey:@"nearestDistanceForLocation"];
}

- (DateMode)dateMode{
    DateMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"dateMode"];
    if (!mode) mode = DateModeMonth;
    return mode;
}

- (void)setDateMode:(DateMode)dateMode{
    [[NSUserDefaults standardUserDefaults] setInteger:dateMode forKey:@"dateMode"];
}

- (NSString *)defaultPlacemark{
    NSString *placemark = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultPlacemark"];
    if (!placemark) placemark = @"中国";
    return placemark;
}

- (void)setDefaultPlacemark:(NSString *)defaultPlacemark{
    [[NSUserDefaults standardUserDefaults] setValue:defaultPlacemark forKey:@"defaultPlacemark"];
}

@end
