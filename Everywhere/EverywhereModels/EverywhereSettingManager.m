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

+ (void)updateAppInfoAndAppQRCodeImageData{
    // 更新下载链接
    NSString *appInfoURLString = @"http://www.7xpt9o.com1.z0.glb.clouddn.com/AppInfo.json";
    
    NSError *readDataError;
    NSData *appInfoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoURLString] options:NSDataReadingMapped error:&readDataError];
    if (!appInfoData){
        NSLog(@"从网络获取AppInfo数据出错 : %@",readDataError.localizedDescription);
        return;
    }
    
    NSError *parseJSONError;
    NSArray *appInfoDictionaryArray = [NSJSONSerialization JSONObjectWithData:appInfoData options:NSJSONReadingMutableContainers error:&parseJSONError];
    if (!appInfoDictionaryArray){
        NSLog(@"解析AppInfo数据出错 : %@",parseJSONError.localizedDescription);
        return;
    }
    
    NSDictionary *appInfoDictionary = nil;
    
    for (NSDictionary *dic in appInfoDictionaryArray) {
        if ([dic[@"AppID"] isEqualToString:AppID]) {
            appInfoDictionary = dic;
            break;
        }
    }
    
    NSLog(@"\n%@",appInfoDictionary);
    
    [[NSUserDefaults standardUserDefaults] setValue:appInfoDictionary[@"AppURLString"] forKey:@"AppURLString"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 更新二维码图片
    NSString *appQRCodeImageURLString = @"http://www.7xpt9o.com1.z0.glb.clouddn.com/AlbumMapsQRCodeImage.png";
    NSError *readImageDataError;
    NSData *appQRCodeImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appQRCodeImageURLString] options:NSDataReadingMapped error:&readImageDataError];
    if (!appQRCodeImageData){
        NSLog(@"从网络获取appQRCodeImage数据出错 : %@",readImageDataError.localizedDescription);
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:appQRCodeImageData forKey:@"appQRCodeImageData"];
    
}

- (NSString *)appURLString{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"AppURLString"];
}

- (UIImage *)appQRCodeImage{
    NSData *appQRCodeImageData = [[NSUserDefaults standardUserDefaults] valueForKey:@"appQRCodeImageData"];
    return [UIImage imageWithData:appQRCodeImageData];
    return nil;
}

- (MapBaseMode)mapBaseMode{
    MapBaseMode mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"mapBaseMode"];
    return mode;
}

- (void)setMapBaseMode:(MapBaseMode)mapBaseMode{
    [[NSUserDefaults standardUserDefaults] setInteger:mapBaseMode forKey:@"mapBaseMode"];
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

- (CLLocationDistance)mergeDistanceForMoment{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"mergeDistanceForMoment"];
    if (!distance || distance == 0) distance = 200;
    return distance;
}

- (void)setMergeDistanceForMoment:(CLLocationDistance)mergeDistanceForMoment{
    [[NSUserDefaults standardUserDefaults] setDouble:mergeDistanceForMoment forKey:@"mergeDistanceForMoment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)mergeDistanceForLocation{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"mergeDistanceForLocation"];
    if (!distance || distance == 0) distance = 1000;
    return distance;
}

- (void)setMergeDistanceForLocation:(CLLocationDistance)mergeDistanceForLocation{
    [[NSUserDefaults standardUserDefaults] setDouble:mergeDistanceForLocation forKey:@"mergeDistanceForLocation"];
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
    if (!playTI || playTI == 0) playTI = 2.0;
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

- (BaseColorScheme)baseColorScheme{
    BaseColorScheme aCS = [[NSUserDefaults standardUserDefaults] integerForKey:@"baseColorScheme"];
    return aCS;
}

- (void)setBaseColorScheme:(BaseColorScheme)baseColorScheme{
    [[NSUserDefaults standardUserDefaults] setInteger:baseColorScheme forKey:@"baseColorScheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(UIColor *)baseTintColor{
    UIColor *resultColor = nil;
    switch (self.baseColorScheme) {
        case BaseColorSchemeClassicGray:
            resultColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
            break;
        case BaseColorSchemeFreshBlue:
            resultColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
            break;
        case BaseColorSchemeDeepBrown:
            resultColor = [[UIColor brownColor] colorWithAlphaComponent:0.6];
            break;
        default:
            break;
    }
    return resultColor;
}

- (ExtendedColorScheme)extendedColorScheme{
    ExtendedColorScheme aCS = [[NSUserDefaults standardUserDefaults] integerForKey:@"extendedColorScheme"];
    return aCS;
}

- (void)setExtendedColorScheme:(ExtendedColorScheme)extendedColorScheme{
    [[NSUserDefaults standardUserDefaults] setInteger:extendedColorScheme forKey:@"extendedColorScheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIColor *)extendedTintColor{
    UIColor *resultColor = nil;
    switch (self.extendedColorScheme) {
        case ExtendedColorSchemeBrightRed:
            resultColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
            break;
        case ExtendedColorSchemeGrassGreen:
            resultColor = [[UIColor greenColor] colorWithAlphaComponent:0.6];
            break;
        default:
            break;
    }
    return resultColor;
}

- (BOOL)hasPurchasedShare{
    BOOL hasPurchasedShare = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedShare"];
    return hasPurchasedShare;
}

- (void)setHasPurchasedShare:(BOOL)hasPurchasedShare{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedShare forKey:@"hasPurchasedShare"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasPurchasedRecord{
    BOOL hasPurchasedRecord = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedRecord"];
    return hasPurchasedRecord;
}

- (void)setHasPurchasedRecord:(BOOL)hasPurchasedRecord{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedRecord forKey:@"hasPurchasedRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (CLLocationDistance)minDistanceForRecord{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"minDistanceForRecord"];
    if (!distance || distance == 0) distance = 30;
    return distance;
}

- (void)setMinDistanceForRecord:(CLLocationDistance)minDistanceForRecord{
    [[NSUserDefaults standardUserDefaults] setDouble:minDistanceForRecord forKey:@"minDistanceForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSTimeInterval)minTimeIntervalForRecord{
    NSTimeInterval minTI = [[NSUserDefaults standardUserDefaults] doubleForKey:@"minTimeIntervalForRecord"];
    if (!minTI || minTI == 0) minTI = 2;
    return minTI;
}

- (void)setMinTimeIntervalForRecord:(NSTimeInterval)minTimeIntervalForRecord{
    [[NSUserDefaults standardUserDefaults] setDouble:minTimeIntervalForRecord forKey:@"minTimeIntervalForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)maxFootprintsCountForRecord{
    NSInteger maxFootprintsCountForRecord = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxFootprintsCountForRecord"];
    if (!maxFootprintsCountForRecord || maxFootprintsCountForRecord == 0) maxFootprintsCountForRecord = 1000;
    return maxFootprintsCountForRecord;
}

- (void)setMaxFootprintsCountForRecord:(NSInteger)maxFootprintsCountForRecord{
    [[NSUserDefaults standardUserDefaults] setInteger:maxFootprintsCountForRecord forKey:@"maxFootprintsCountForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)praiseCount{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"praiseCount"];
}

- (void)setPraiseCount:(NSInteger)praiseCount{
    [[NSUserDefaults standardUserDefaults] setInteger:praiseCount forKey:@"praiseCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (DefaultTransport)defaultTransport{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultTransport"];
}

- (void)setDefaultTransport:(DefaultTransport)defaultTransport{
    //NSLog(@"%ld",(long)defaultTransport);
    [[NSUserDefaults standardUserDefaults] setInteger:defaultTransport forKey:@"defaultTransport"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
