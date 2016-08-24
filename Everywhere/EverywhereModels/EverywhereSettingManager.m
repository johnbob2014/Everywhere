//
//  EverywhereSettingManager.m
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define AppID @"1136142337"

#define WXAppID @"wxa1b9c5632d24039a"
#define AppURLString @"https://itunes.apple.com/app/id1136142337"
#define AppProductIDArray @[@"com.ZhangBaoGuo.AlbumMaps.ShareAndBrowse",@"com.ZhangBaoGuo.AlbumMaps.RecordAndEdit",@"com.ZhangBaoGuo.AlbumMaps.ImportAndExport",@"com.ZhangBaoGuo.AlbumMaps.AllFunctionsSuit"]
#define AppQRCodeImage @"AlbumMapsAppQRCodeImage.png"



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

- (instancetype)init{
    self = [super init];
    if (self) {
        if (!self.appInfoLastUpdateDate || [[NSDate date] timeIntervalSinceDate:self.appInfoLastUpdateDate] > 60 * 60){
            [self updateAppInfoAndAppQRCodeImage];
        }
    }
    return self;
}

#pragma mark - App Info
- (void)updateAppInfoAndAppQRCodeImage{
    if(DEBUGMODE) NSLog(@"正在更新AppInfo...\n");
    // 更新下载链接
    NSString *appInfoURLString = @"http://www.7xpt9o.com1.z0.glb.clouddn.com/AppInfo.json";
    
    NSError *readDataError;
    NSData *appInfoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appInfoURLString] options:NSDataReadingMapped error:&readDataError];
    if (!appInfoData){
        if(DEBUGMODE) NSLog(@"从网络获取AppInfo数据出错 : %@",readDataError.localizedDescription);
        return;
    }
    
    NSError *parseJSONError;
    NSArray *appInfoDictionaryArray = [NSJSONSerialization JSONObjectWithData:appInfoData options:NSJSONReadingMutableContainers error:&parseJSONError];
    if (!appInfoDictionaryArray){
        if(DEBUGMODE) NSLog(@"解析AppInfo数据出错 : %@",parseJSONError.localizedDescription);
        return;
    }
    
    NSDictionary *appInfoDictionary = nil;
    
    for (NSDictionary *dic in appInfoDictionaryArray) {
        
        if ([dic.allKeys containsObject:@"AppID"]){
            if ([dic[@"AppID"] isEqualToString:AppID]) {
                appInfoDictionary = dic;
                break;
            }
        }
    }
    
    if (!appInfoDictionary){
        if(DEBUGMODE) NSLog(@"更新AppInfo失败！");
        return;
    }
    
    if(DEBUGMODE) NSLog(@"\n%@",appInfoDictionary);
    if(DEBUGMODE) NSLog(@"更新AppInfo成功");
    
    // 更新信息数组
    [[NSUserDefaults standardUserDefaults] setValue:appInfoDictionary forKey:@"appInfoDictionary"];
    
    // 更新最后更新时间
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"appInfoLastUpdateDate"];
    
    // 更新下载链接
    if ([appInfoDictionary.allKeys containsObject:@"AppURLString"]){
        NSString *appURLString = appInfoDictionary[@"AppURLString"];
        if(DEBUGMODE) NSLog(@"\nappURLString : %@",appURLString);
        [[NSUserDefaults standardUserDefaults] setValue:appURLString forKey:@"appURLString"];
    }
    
    // 更新二维码图片
    if ([appInfoDictionary.allKeys containsObject:@"AppQRCodeImageURLString"]){
        NSString *appQRCodeImageURLString = appInfoDictionary[@"AppQRCodeImageURLString"];
        
        NSError *readImageDataError;
        NSData *appQRCodeImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:appQRCodeImageURLString] options:NSDataReadingMapped error:&readImageDataError];
        
        if (appQRCodeImageData){
            [[NSUserDefaults standardUserDefaults] setValue:appQRCodeImageData forKey:@"appQRCodeImageData"];
            if(DEBUGMODE) NSLog(@"更新AppQRCodeImage成功");
            
        }else{
            if(DEBUGMODE) NSLog(@"从网络获取AppQRCodeImage数据出错 : %@",readImageDataError.localizedDescription);
            if(DEBUGMODE) NSLog(@"更新AppQRCodeImage失败！");
        }
    }else{
        if(DEBUGMODE) NSLog(@"未找到AppQRCodeImage！");
    }
    
    // 更新内购项目数组
    if ([appInfoDictionary.allKeys containsObject:@"AppProductIDArray"]){
        NSArray <NSString *> *appProductIDArray = appInfoDictionary[@"AppProductIDArray"];
        if(DEBUGMODE) NSLog(@"\nappProductIDArray :\n%@",appProductIDArray);
        [[NSUserDefaults standardUserDefaults] setValue:appProductIDArray forKey:@"appProductIDArray"];
    }
    
    // 更新微信ID
    if ([appInfoDictionary.allKeys containsObject:@"WXAppID"]){
        NSString *wxAppID = appInfoDictionary[@"WXAppID"];
        if(DEBUGMODE) NSLog(@"wxAppID : %@",wxAppID);
        [[NSUserDefaults standardUserDefaults] setValue:wxAppID forKey:@"wxAppID"];
    }

    // 保存数据！！！
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

// 以下4个属性只有获取方法，更新在上面方法中完成
- (NSDate *)appInfoLastUpdateDate{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"appInfoLastUpdateDate"];
}

- (NSDictionary *)appInfoDictionary{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"appInfoDictionary"];
}

- (NSString *)appURLString{
    NSString *appURLString = [[NSUserDefaults standardUserDefaults] objectForKey:@"appURLString"];
    if (appURLString) return appURLString;
    else return AppURLString;
}

- (UIImage *)appQRCodeImage{
    NSData *appQRCodeImageData = [[NSUserDefaults standardUserDefaults] valueForKey:@"appQRCodeImageData"];
    if (appQRCodeImageData) return [UIImage imageWithData:appQRCodeImageData];
    else return [UIImage imageNamed:AppQRCodeImage];
}

- (NSArray<NSString *> *)appProductIDArray{
    NSArray<NSString *> *appProductIDArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"appProductIDArray"];
    if (appProductIDArray) return appProductIDArray;
    else return AppProductIDArray;
}

- (NSString *)wxAppID{
    NSString *wxAppID = [[NSUserDefaults standardUserDefaults] objectForKey:@"wxAppID"];
    if (wxAppID) return wxAppID;
    else return WXAppID;
}

#pragma mark - Items

- (UIColor *)backgroundColor{
    return [UIColor groupTableViewBackgroundColor];
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
    if (!distance || distance == 0) distance = 100;
    return distance;
}

- (void)setMergeDistanceForMoment:(CLLocationDistance)mergeDistanceForMoment{
    [[NSUserDefaults standardUserDefaults] setDouble:mergeDistanceForMoment forKey:@"mergeDistanceForMoment"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)mergeDistanceForLocation{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"mergeDistanceForLocation"];
    if (!distance || distance == 0) distance = 200;
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
    if (!placemark) placemark = @",";
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
        case BaseColorSchemeSkyBlue:
            resultColor = [[UIColor flatSkyBlueColor] colorWithAlphaComponent:0.6];
            break;
        case BaseColorSchemeSakuraPink:
            resultColor = [[UIColor flatPinkColor] colorWithAlphaComponent:0.6];
            break;
        case BaseColorSchemeClassicGray:
            resultColor = [[UIColor flatGrayColor] colorWithAlphaComponent:0.6];
            break;
        case BaseColorSchemeFreshPlum:
            resultColor = [[UIColor flatPlumColor] colorWithAlphaComponent:0.6];
            break;
        case BaseColorSchemeDeepBrown:
            resultColor = [[UIColor flatBrownColor] colorWithAlphaComponent:0.6];
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
        case ExtendedColorSchemeForestGreen:
            resultColor = [[UIColor flatForestGreenColor] colorWithAlphaComponent:0.6];
            break;
        case ExtendedColorSchemeBrightOrange:
            resultColor = [[UIColor flatOrangeColor] colorWithAlphaComponent:0.6];
            break;
        case ExtendedColorSchemeWatermelon:
            resultColor = [[UIColor flatWatermelonColor] colorWithAlphaComponent:0.6];
            break;
        default:
            break;
    }
    return resultColor;
}

- (BOOL)hasPurchasedShareAndBrowse{
    BOOL hasPurchasedShareAndBrowse = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedShareAndBrowse"];
    return hasPurchasedShareAndBrowse;
}

- (void)setHasPurchasedShareAndBrowse:(BOOL)hasPurchasedShareAndBrowse{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedShareAndBrowse forKey:@"hasPurchasedShareAndBrowse"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasPurchasedRecordAndEdit{
    BOOL hasPurchasedRecordAndEdit = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedRecordAndEdit"];
    return hasPurchasedRecordAndEdit;
}

- (void)setHasPurchasedRecordAndEdit:(BOOL)hasPurchasedRecordAndEdit{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedRecordAndEdit forKey:@"hasPurchasedRecordAndEdit"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasPurchasedImportAndExport{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hasPurchasedImportAndExport"];
}

- (void)setHasPurchasedImportAndExport:(BOOL)hasPurchasedImportAndExport{
    [[NSUserDefaults standardUserDefaults] setBool:hasPurchasedImportAndExport forKey:@"hasPurchasedImportAndExport"];
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

- (CLLocationDistance)minDistanceWalkForRecord{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"minDistanceWalkForRecord"];
    if (!distance || distance == 0) distance = 20;
    return distance;
}

- (void)setMinDistanceWalkForRecord:(CLLocationDistance)minDistanceWalkForRecord{
    [[NSUserDefaults standardUserDefaults] setDouble:minDistanceWalkForRecord forKey:@"minDistanceWalkForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)minDistanceRideForRecord{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"minDistanceRideForRecord"];
    if (!distance || distance == 0) distance = 50;
    return distance;
}

- (void)setMinDistanceRideForRecord:(CLLocationDistance)minDistanceRideForRecord{
    [[NSUserDefaults standardUserDefaults] setDouble:minDistanceRideForRecord forKey:@"minDistanceRideForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)minDistanceDriveForRecord{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"minDistanceDriveForRecord"];
    if (!distance || distance == 0) distance = 150;
    return distance;
}

- (void)setMinDistanceDriveForRecord:(CLLocationDistance)minDistanceDriveForRecord{
    [[NSUserDefaults standardUserDefaults] setDouble:minDistanceDriveForRecord forKey:@"minDistanceDriveForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (CLLocationDistance)minDistanceHighSpeedForRecord{
    CLLocationDistance distance = [[NSUserDefaults standardUserDefaults] doubleForKey:@"minDistanceHighSpeedForRecord"];
    if (!distance || distance == 0) distance = 1000;
    return distance;
}

- (void)setMinDistanceHighSpeedForRecord:(CLLocationDistance)minDistanceHighSpeedForRecord{
    [[NSUserDefaults standardUserDefaults] setDouble:minDistanceHighSpeedForRecord forKey:@"minDistanceHighSpeedForRecord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    //if(DEBUGMODE) NSLog(@"%ld",(long)defaultTransport);
    [[NSUserDefaults standardUserDefaults] setInteger:defaultTransport forKey:@"defaultTransport"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)thumbnailScaleRate{
    float thumbnailScaleRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"thumbnailScaleRate"];
    if (thumbnailScaleRate == 0) thumbnailScaleRate = 0.15;
    return thumbnailScaleRate;
}

- (void)setThumbnailScaleRate:(float)thumbnailScaleRate{
    [[NSUserDefaults standardUserDefaults] setFloat:thumbnailScaleRate forKey:@"thumbnailScaleRate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)thumbnailCompressionQuality{
    float thumbnailCompressionQuality = [[NSUserDefaults standardUserDefaults] floatForKey:@"thumbnailCompressionQuality"];
    if (thumbnailCompressionQuality == 0) thumbnailCompressionQuality = 0.5;
    return thumbnailCompressionQuality;
}

- (void)setThumbnailCompressionQuality:(float)thumbnailCompressionQuality{
    [[NSUserDefaults standardUserDefaults] setFloat:thumbnailCompressionQuality forKey:@"thumbnailCompressionQuality"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (FirstDayOfWeek)firstDayOfWeek{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"firstDayOfWeek"];
}

- (void)setFirstDayOfWeek:(FirstDayOfWeek)firstDayOfWeek{
    [[NSUserDefaults standardUserDefaults] setInteger:firstDayOfWeek forKey:@"firstDayOfWeek"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)everLaunched{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"];
}

- (void)setEverLaunched:(BOOL)everLaunched{
    [[NSUserDefaults standardUserDefaults] setBool:everLaunched forKey:@"everLaunched"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)trialCountForMFR{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"trialCountForMFR"];
}

- (void)setTrialCountForMFR:(NSInteger)trialCountForMFR{
    [[NSUserDefaults standardUserDefaults] setInteger:trialCountForMFR forKey:@"trialCountForMFR"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)trialCountForGPX{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"trialCountForGPX"];
}

- (void)setTrialCountForGPX:(NSInteger)trialCountForGPX{
    [[NSUserDefaults standardUserDefaults] setInteger:trialCountForGPX forKey:@"trialCountForGPX"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
