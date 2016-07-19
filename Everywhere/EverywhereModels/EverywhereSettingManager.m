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

- (MapMainMode)mapMainMode{
    MapMainMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapMainMode"];
    return mode;
}

- (void)setMapMainMode:(MapMainMode)mapMainMode{
    [[NSUserDefaults standardUserDefaults] setInteger:mapMainMode forKey:@"mapMainMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (MapExtendedMode)mapExtendedMode{
    MapExtendedMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapExtendedMode"];
    return mode;
}

- (void)setMapExtendedMode:(MapExtendedMode)mapExtendedMode{
    [[NSUserDefaults standardUserDefaults] setInteger:mapExtendedMode forKey:@"mapExtendedMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)mergedDistanceForMoment{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"mergedDistanceForMoment"];
    if (!distance || distance == 0) distance = 200;
    return distance;
}

- (void)setMergedDistanceForMoment:(CLLocationDistance)mergedDistanceForMoment{
    [[NSUserDefaults standardUserDefaults] setDouble:mergedDistanceForMoment forKey:@"mergedDistanceForMoment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)mergedDistanceForLocation{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"mergedDistanceForLocation"];
    if (!distance || distance == 0) distance = 1000;
    return distance;
}

- (void)setMergedDistanceForLocation:(CLLocationDistance)mergedDistanceForLocation{
    [[NSUserDefaults standardUserDefaults] setDouble:mergedDistanceForLocation forKey:@"mergedDistanceForLocation"];
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

- (NSString *)lastPlacemark{
    NSString *placemark = [[NSUserDefaults standardUserDefaults] stringForKey:@"lastPlacemark"];
    if (!placemark) placemark = @"中国";
    return placemark;
}

- (void)setLasttPlacemark:(NSString *)lastPlacemark{
    [[NSUserDefaults standardUserDefaults] setValue:lastPlacemark forKey:@"lastPlacemark"];
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

- (ColorScheme)colorScheme{
    ColorScheme aCS = [[NSUserDefaults standardUserDefaults] integerForKey:@"colorScheme"];
    return aCS;
}

- (void)setColorScheme:(ColorScheme)colorScheme{
    [[NSUserDefaults standardUserDefaults] setInteger:colorScheme forKey:@"colorScheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIColor *)color{
    UIColor *resultColor = nil;
    switch (self.colorScheme) {
        case ColorSchemeClassicGray:
            resultColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
            break;
        case ColorSchemeFreshBlue:
            resultColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
            break;
        case ColorSchemeDeepBrown:
            resultColor = [[UIColor brownColor] colorWithAlphaComponent:0.6];
            break;
        default:
            break;
    }
    return resultColor;
}

- (BOOL)hasPurchasedShare{
    BOOL ahasPurchasedShare = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedShare"];
//#warning here
    //return YES;
    return ahasPurchasedShare;
}

- (void)setHasPurchasedShare:(BOOL)hasPurchasedShare{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedShare forKey:@"hasPurchasedShare"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasPurchasedRecord{
    BOOL ahasPurchasedRecord = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedRecord"];
//#warning here
    //return YES;
    return ahasPurchasedRecord;
}

- (void)setHasPurchasedRecord:(BOOL)hasPurchasedRecord{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedRecord forKey:@"hasPurchasedRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
