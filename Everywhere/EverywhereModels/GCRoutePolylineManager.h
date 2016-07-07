//
//  GCRoutePolylineManager.h
//  Everywhere
//
//  Created by BobZhang on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCRoutePolyline.h"

@interface GCRoutePolylineManager : NSObject
+ (instancetype)defaultManager;
- (void)addRoutePolyline:(GCRoutePolyline *)routePolyline;
- (GCRoutePolyline *)fetchRoutePolylineWithSource:(CLLocationCoordinate2D)sourceCoord destination:(CLLocationCoordinate2D)destinationCoord;
@end
