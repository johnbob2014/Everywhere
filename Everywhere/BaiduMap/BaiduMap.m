//
//  BaiduMap.m
//  Everywhere
//
//  Created by BobZhang on 16/7/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "BaiduMap.h"

@implementation BaiduMap

+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionMode:(NSString *)directionMode{
    [BaiduMap baidumapDirectionFromOrigin:origin toDestination:destination directionMode:directionMode companyName:BaiduMapCompanyName appName:BaiduMapAppName];
}

+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionMode:(NSString *)directionMode companyName:(NSString *)companyName appName:(NSString *)appName{
    //@"baidumap://map/direction?origin=34.26,108.95&destination=40.00,116.36&mode=driving&src=yourCompanyName|yourAppName";
    NSString *requestString = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.10f,%.10f&destination=%.10f,%.10f&mode=%@&src=%@|%@",origin.latitude,origin.longitude,destination.latitude,destination.longitude,directionMode,companyName,appName];
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",requestString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestString]];
}

@end
