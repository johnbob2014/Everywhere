//
//  BaiduMap.h
//  Everywhere
//
//  Created by BobZhang on 16/7/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BaiduMapCompanyName NSLocalizedString(@"CTP", @"CTP Technology Co.,Ltd")
#define BaiduMapAppName NSLocalizedString(@"AlbumMaps", @"相册地图")

#define BaiduMapDirectionModeWalking @"walking"
#define BaiduMapDirectionModeTransit @"transit"
#define BaiduMapDirectionModeDriving @"driving"

@interface BaiduMap : NSObject

+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionMode:(NSString *)directionMode;
+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionMode:(NSString *)directionMode companyName:(NSString *)companyName appName:(NSString *)appName;

@end
