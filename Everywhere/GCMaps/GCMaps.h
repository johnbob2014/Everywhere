//
//  GCMaps.h
//  Everywhere
//
//  Created by 张保国 on 16/8/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GCMapsCompanyName @"CTP Technology Co.,Ltd"
#define GCMapsAppName @"AlbumMaps"

#define BaiduMapDirectionsModeWalking @"walking"
#define BaiduMapDirectionsModeTransit @"transit"
#define BaiduMapDirectionsModeDriving @"driving"

/**
 *  高德地图交通方式
 */
typedef NS_ENUM(NSUInteger, AMapTMode) {
    /**
     *  驾车
     */
    AMapTModeDriving = 0,
    /**
     *  公交
     */
    AMapTModeTransit,
    /**
     *  步行
     */
    AMapTModeWalking,
};

/**
 *  高德地图驾车选项
 */
typedef NS_ENUM(NSUInteger, AMapDrivingMOption) {
    /**
     *  速度最快
     */
    AMapDrivingMOption0 = 0,
    /**
     *  费用最少
     */
    AMapDrivingMOption1,
    /**
     *  距离最短
     */
    AMapDrivingMOption2,
    /**
     *  不走高速
     */
    AMapDrivingMOption3,
    /**
     *  躲避拥堵
     */
    AMapDrivingMOption4,
    /**
     *  不走高速且避免收费
     */
    AMapDrivingMOption5,
    /**
     *  不走高速且躲避拥堵
     */
    AMapDrivingMOption6,
    /**
     *  躲避收费和拥堵
     */
    AMapDrivingMOption7,
    /**
     *  不走高速躲避收费和拥堵
     */
    AMapDrivingMOption8
};

/**
 *  高德地图公交选项
 */
typedef NS_ENUM(NSUInteger, AMapTransitMOption) {
    /**
     *  最快捷
     */
    AMapTransitMOption0 = 0,
    /**
     *  最少换乘
     */
    AMapTransitMOption2 = 2,
    /**
     *  最少步行
     */
    AMapTransitMOption3 = 3,
    /**
     *  不乘地铁
     */
    AMapTransitMOption5 = 5,
    /**
     *  只坐地铁
     */
    AMapTransitMOption7 = 7,
    /**
     *  时间短
     */
    AMapTransitMOption8 = 8
};

/**
 *  iOS调用外部地图导航
 */
@interface GCMaps : NSObject

/**
 *  调用百度地图导航
 *
 *  @param origin        起点座标（需要使用百度地图座标）
 *  @param destination   终点座标（需要使用百度地图座标）
 *  @param directionsMode 交通方式
 */
+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionsMode:(NSString *)directionsMode;

/**
 *  调用百度地图导航
 *
 *  @param origin        起点座标（需要使用百度地图座标）
 *  @param destination   终点座标（需要使用百度地图座标）
 *  @param directionsMode 交通方式
 *  @param companyName   可留空，调用百度地图的公司名称
 *  @param appName       可留空，调用百度地图的应用名称
 */
+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionsMode:(NSString *)directionsMode companyName:(NSString *)companyName appName:(NSString *)appName;

/**
 *  调用高德地图导航
 *
 *  @param source      起点座标（需要使用GCJ02基准座标）
 *  @param destination 终点座标（需要使用GCJ02基准座标）
 *  @param t           交通方式
 *  @param m           导航选项（依据交通方式不同选项不同）
 */
+ (void)iosamapPathFromSource:(CLLocationCoordinate2D)source toDestination:(CLLocationCoordinate2D)destination tMode:(enum AMapTransitMOption)t mOption:(enum AMapDrivingMOption)m;

/**
 *  调用高德地图导航
 *
 *  @param source      起点座标（需要使用GCJ02基准座标）
 *  @param destination 终点座标（需要使用GCJ02基准座标）
 *  @param t           交通方式
 *  @param m           导航选项（依据交通方式不同选项不同）
 *  @param appName     可留空，调用高德地图的应用名称
 */
+ (void)iosamapPathFromSource:(CLLocationCoordinate2D)source toDestination:(CLLocationCoordinate2D)destination tMode:(enum AMapTransitMOption)t mOption:(enum AMapDrivingMOption)m appName:(NSString *)appName;

/**
 *  调用iOS系统地图导航
 *
 *  @param source         起点座标（需要使用GCJ02基准座标
 *  @param destination    终点座标（需要使用GCJ02基准座标）
 *  @param directionsMode 交通方式（三选一 MKLaunchOptionsDirectionsModeDriving MKLaunchOptionsDirectionsModeTransit MKLaunchOptionsDirectionsModeWalking）
 */
+ (void)mkmapFromSource:(CLLocationCoordinate2D)source toDestination:(CLLocationCoordinate2D)destination directionsMode:(NSString *)directionsMode;
@end
