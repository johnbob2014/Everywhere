//
//  GCRoutePolyline.m
//  Everywhere
//
//  Created by BobZhang on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCRoutePolyline.h"
#import "GCPolyline.h"

@interface GCRoutePolyline ()
@property (strong,nonatomic) GCPolyline *gcPolyline;
@end

@implementation GCRoutePolyline

+ (instancetype)newRoutePolyline:(MKPolyline *)polyline source:(CLLocationCoordinate2D)sourceCoord destination:(CLLocationCoordinate2D)destinationCoord{
    return [[GCRoutePolyline alloc]initWithPolyline:polyline source:sourceCoord destination:destinationCoord];
}

- (instancetype)initWithPolyline:(MKPolyline *)polyline source:(CLLocationCoordinate2D)sourceCoord destination:(CLLocationCoordinate2D)destinationCoord{
    self = [super init];
    if (self) {
        _gcPolyline = [GCPolyline newPolyline:polyline];
        _source = sourceCoord;
        _destination = destinationCoord;
    }
    return self;
}

- (MKPolyline *)polyline{
    return self.gcPolyline.polyline;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    CGPoint sourcePoint = [aDecoder decodeCGPointForKey:@"sourcePoint"];
    CGPoint destinationPoint = [aDecoder decodeCGPointForKey:@"destinationPoint"];
    CLLocationDistance routeDistance = [aDecoder decodeDoubleForKey:@"routeDistance"];
    GCPolyline *gcPolyline = [aDecoder decodeObjectForKey:@"gcPolyline"];
    GCRoutePolyline *routePolyline = [[GCRoutePolyline alloc] initWithPolyline:gcPolyline.polyline source:CLLocationCoordinate2DMake(sourcePoint.x, sourcePoint.y) destination:CLLocationCoordinate2DMake(destinationPoint.x, destinationPoint.y)];
    routePolyline.routeDistance = routeDistance;
    return routePolyline;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    CGPoint sourcePoint = CGPointMake(self.source.latitude, self.source.longitude);
    [aCoder encodeCGPoint:sourcePoint forKey:@"sourcePoint"];
    CGPoint destinationPoint = CGPointMake(self.destination.latitude, self.destination.longitude);
    [aCoder encodeCGPoint:destinationPoint forKey:@"destinationPoint"];
    
    [aCoder encodeDouble:self.routeDistance forKey:@"routeDistance"];
    
    [aCoder encodeObject:self.gcPolyline forKey:@"gcPolyline"];
}

@end
