//
//  EverywhereSettingManager.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define UTI_MFR @"com.ZhangBaoGuo.AlbumMaps.mfr"
#define UTI_GPX @"com.ZhangBaoGuo.AlbumMaps.gpx"

#import <Foundation/Foundation.h>

@interface EverywhereSettingManager : NSObject

+ (instancetype)defaultManager;
+ (void)updateAppInfoWithCompletionBlock:(void(^)())completionBlock;

@property (strong,nonatomic) NSDate *appInfoLastUpdateDate;
@property (strong,nonatomic) NSDictionary *appInfoDictionary;
@property (strong,nonatomic) NSString *appURLString;
@property (strong,nonatomic) UIImage *appQRCodeImage;
@property (strong,nonatomic) NSArray <NSString *> *appProductIDArray;
@property (strong,nonatomic) NSString *appWXID;
@property (strong,nonatomic) NSString *appDebugCode;


@property (assign,nonatomic) BOOL debugMode;

/**
 *  路线颜色，0为彩色（默认），1为单色
 */
@property (assign,nonatomic) NSInteger routeColorIsMonochrome;

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

@property (strong,nonatomic,readonly) UIColor *backgroundColor;

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

@property (assign,nonatomic) DefaultTransportType defaultTransportType;

/**
 *  是否自动以第一张图片作为分享缩略图
 */
@property (assign,nonatomic) BOOL autoUseFirstAssetAsThumbnail;

/**
 *  是否自动以第一张图片作为分享缩略图
 */
@property (assign,nonatomic) BOOL autoUseAllAssetsAsThumbnail;

/**
 *  缩略图大小比值（缩略图边长 除以 原图边长）
 */
@property (assign,nonatomic) float thumbnailScaleRate;

/**
 *  缩略图质量（0最差 1最好）
 */
@property (assign,nonatomic) float thumbnailCompressionQuality;

/**
 *  每周第一天是星期天还是星期一
 */
@property (assign,nonatomic) FirstDayOfWeek firstDayOfWeek;

/**
 *  是否曾经登陆
 */
@property (assign,nonatomic) BOOL everLaunched;

/**
 *  分享和浏览试用次数
 */
@property (assign,nonatomic) NSInteger trialCountForShareAndBrowse;

/**
 *  记录和编辑试用次数
 */
@property (assign,nonatomic) NSInteger trialCountForRecordAndEdit;


@end
