//
//  WGS84TOGCJ02.h
//  Everywhere
//
//  Created by 张保国 on 16/6/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface WGS84TOGCJ02 : NSObject

//判断是否已经超出中国范围
//+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;

/**
 判断是否在中国
 */
+ (BOOL)isLocationInChina:(CLLocationCoordinate2D)location;

/**
 WGS-84 转 GCJ-02，转换后可以在MKMapView上显示正确位置
 */
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end
