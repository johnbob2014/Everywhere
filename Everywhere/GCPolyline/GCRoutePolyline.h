//
//  GCRoutePolyline.h
//  Everywhere
//
//  Created by BobZhang on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;
@import CoreLocation;

@interface GCRoutePolyline : NSObject <NSCoding>
@property (assign,nonatomic) CLLocationCoordinate2D source;
@property (assign,nonatomic) CLLocationCoordinate2D destination;
@property (strong,nonatomic,readonly) MKPolyline *polyline;
@property (assign,nonatomic) CLLocationDistance routeDistance;

+ (instancetype)newRoutePolyline:(MKPolyline *)polyline source:(CLLocationCoordinate2D)sourceCoord destination:(CLLocationCoordinate2D)destinationCoord;
- (instancetype)initWithPolyline:(MKPolyline *)polyline source:(CLLocationCoordinate2D)sourceCoord destination:(CLLocationCoordinate2D)destinationCoord;
@end
