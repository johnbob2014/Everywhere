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

#pragma mark - 类方法

/**
 *  通用设置管理器
 */
+ (instancetype)defaultManager;

/**
 *  从网络更新AppInfo信息，完成后调用指定块
 *
 *  @param completionBlock 更新完成后调用的块
 */
+ (void)updateAppInfoWithCompletionBlock:(void(^)())completionBlock;

#pragma mark - AppInfo

/**
 * appInfo上次更新时间
 */
@property (strong,nonatomic) NSDate *appInfoLastUpdateDate;

/**
 * appInfo字典
 */
@property (strong,nonatomic) NSDictionary *appInfoDictionary;

/**
 * app下载地址
 */
@property (strong,nonatomic) NSString *appURLString;

/**
 * app二维码图片
 */
@property (strong,nonatomic) UIImage *appQRCodeImage;

/**
 * app内购产品ID数组
 */
@property (strong,nonatomic) NSArray <NSString *> *appProductIDArray;

/**
 * app微信ID
 */
@property (strong,nonatomic) NSString *appWXID;

/**
 * app调试码
 */
@property (strong,nonatomic) NSString *appDebugCode;

#pragma mark - 各项设置

/**
 * 是否处于调试模式
 */
@property (assign,nonatomic) BOOL debugMode;

/**
 * 路线颜色，0为彩色（默认），1为单色
 */
@property (assign,nonatomic) NSInteger routeColorIsMonochrome;

/**
 * 地图基础模式
 */
@property (assign,nonatomic) MapBaseMode mapBaseMode;

/**
 * 地图扩展模式
 */
@property (assign,nonatomic) MapExtendedMode mapExtendedMode;

/**
 * 时刻模式分组距离
 */
@property (assign,nonatomic) CLLocationDistance mergeDistanceForMoment;

/**
 * 地点模式分组距离
 */
@property (assign,nonatomic) CLLocationDistance mergeDistanceForLocation;

/**
 * 日期模式，日、周、月、年、自定义5种
 */
@property (assign,nonatomic) DateMode dateMode;

/**
 * 地点模式，村镇街道、县区、市、省、国家5种
 */
@property (assign,nonatomic) LocationMode locationMode;

/**
 * 最后一次选择的地点
 */
@property (strong,nonatomic) NSString *lastPlacemark;

/**
 * 导航栏播放时间间隔，默认2.0秒
 */
@property (assign,nonatomic) NSTimeInterval playTimeInterval;

/**
 * 地图绽放比例，默认每次放大或缩小2.0倍
 */
@property (assign,nonatomic) float mapViewScaleRate;

/**
 * 基础模式颜色方案
 */
@property (assign,nonatomic) BaseColorScheme baseColorScheme;

/**
 * 基础模式颜色
 */
@property (strong,nonatomic,readonly) UIColor *baseTintColor;

/**
 * 扩展模式颜色方案
 */
@property (assign,nonatomic) ExtendedColorScheme extendedColorScheme;

/**
 * 扩展模式颜色
 */
@property (strong,nonatomic,readonly) UIColor *extendedTintColor;

/**
 * 视图背景颜色
 */
@property (strong,nonatomic,readonly) UIColor *backgroundColor;

/**
 * 是否已购买 分享和浏览 功能
 */
@property (assign,nonatomic) BOOL hasPurchasedShareAndBrowse;

/**
 * 是否已购买 记录和编辑 功能
 */
@property (assign,nonatomic) BOOL hasPurchasedRecordAndEdit;

/**
 * 是否已购买 导入和导出 功能
 */
@property (assign,nonatomic) BOOL hasPurchasedImportAndExport;

/**
 *  自定义记录距离，默认30米
 */
@property (assign,nonatomic) CLLocationDistance minDistanceForRecord;

/**
 *  自定义记录间隔，默认4秒
 */
@property (assign,nonatomic) NSTimeInterval minTimeIntervalForRecord;

/**
 *  步行记录距离，默认20米
 */
@property (assign,nonatomic) CLLocationDistance minDistanceWalkForRecord;

/**
 *  骑行记录距离，默认50米
 */
@property (assign,nonatomic) CLLocationDistance minDistanceRideForRecord;

/**
 *  驾车记录距离，默认150米
 */
@property (assign,nonatomic) CLLocationDistance minDistanceDriveForRecord;

/**
 *  高速记录距离，默认1000米
 */
@property (assign,nonatomic) CLLocationDistance minDistanceHighSpeedForRecord;

/**
 * 单条轨迹最大记录点数，默认1000点
 */
@property (assign,nonatomic) NSInteger maxFootprintsCountForRecord;

/**
 * 求赞统计数据
 */
@property (assign,nonatomic) NSInteger praiseCount;

/**
 * 默认交通方式，总是不存储数据，不知何故
 */
@property (assign,nonatomic) DefaultTransportType defaultTransportType;

/**
 *  是否自动以第一张图片作为分享缩略图，默认为否
 */
@property (assign,nonatomic) BOOL autoUseFirstAssetAsThumbnail;

/**
 *  是否自动以全部图片作为分享缩略图，默认为否
 */
@property (assign,nonatomic) BOOL autoUseAllAssetsAsThumbnail;

/**
 *  缩略图大小比值（缩略图边长 除以 原图边长），默认0.15
 */
@property (assign,nonatomic) float thumbnailScaleRate;

/**
 *  缩略图质量（0最差 1最好），默认1.0
 */
@property (assign,nonatomic) float thumbnailCompressionQuality;

/**
 *  每周第一天是星期天还是星期一，默认星期天
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
