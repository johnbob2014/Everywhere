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

//+ (void)updateAppInfoAndAppQRCodeImage;
@property (strong,nonatomic) NSDate *appInfoLastUpdateDate;
@property (strong,nonatomic) NSDictionary *appInfoDictionary;
@property (strong,nonatomic) NSString *appURLString;
@property (strong,nonatomic) UIImage *appQRCodeImage;
@property (strong,nonatomic) NSArray <NSString *> *appProductIDArray;
@property (strong,nonatomic) NSString *wxAppID;


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

//@property (strong,nonatomic,readonly) UIColor *currentTintColor;

@property (assign,nonatomic) BOOL hasPurchasedShareAndBrowse;
@property (assign,nonatomic) BOOL hasPurchasedRecordAndEdit;
@property (assign,nonatomic) BOOL hasPurchasedImportAndExport;

/**
 *  自定义记录距离
 */
@property (assign,nonatomic) CLLocationDistance minDistanceForRecord;

/**
 *  自定义记录间隔
 */
@property (assign,nonatomic) NSTimeInterval minTimeIntervalForRecord;

/**
 *  步行记录距离
 */
@property (assign,nonatomic) CLLocationDistance minDistanceWalkForRecord;

/**
 *  骑行记录距离
 */
@property (assign,nonatomic) CLLocationDistance minDistanceRideForRecord;

/**
 *  驾车记录距离
 */
@property (assign,nonatomic) CLLocationDistance minDistanceDriveForRecord;

/**
 *  高速记录距离
 */
@property (assign,nonatomic) CLLocationDistance minDistanceHighSpeedForRecord;


@property (assign,nonatomic) NSInteger maxFootprintsCountForRecord;

@property (assign,nonatomic) NSInteger praiseCount;

@property (assign,nonatomic) DefaultTransport defaultTransport;

@end
