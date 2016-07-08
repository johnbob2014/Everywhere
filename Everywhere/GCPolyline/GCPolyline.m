//
//  GCPolyline.m
//  Everywhere
//
//  Created by BobZhang on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCPolyline.h"
#import "limits.h"

@interface GCPolyline ()
@property (strong,nonatomic,readwrite) MKPolyline *polyline;
@end

@implementation GCPolyline

+ (instancetype)newPolyline:(MKPolyline *)polyline{
    return [[GCPolyline alloc] initWithPolyline:polyline];
}

- (instancetype)initWithPolyline:(MKPolyline *)polyline{
    self = [super init];
    if (self) {
        _polyline = polyline;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    NSUInteger pointCount = [aDecoder decodeIntegerForKey:@"pointCount"];
    MKMapPoint mapPoints[pointCount];
    for (NSUInteger i = 0 ; i < pointCount; i++) {
        CGPoint point = [aDecoder decodeCGPointForKey:[NSString stringWithFormat:@"CGPoint%lu",(unsigned long)i]];
        MKMapPoint mapPoint = MKMapPointMake(point.x, point.y);
        mapPoints[i] = mapPoint;
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithPoints:mapPoints count:pointCount];
    
    return [[GCPolyline alloc] initWithPolyline:polyline];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    // NSCoder operates on objects, scalars, C arrays, structures, and strings, and on pointers to these types.
    
    NSUInteger pointCount = self.polyline.pointCount;
    [aCoder encodeInteger:pointCount forKey:@"pointCount"];
    for (NSUInteger i = 0 ; i < pointCount; i++) {
        MKMapPoint mapPoint = self.polyline.points[i];
        CGPoint point = CGPointMake(mapPoint.x, mapPoint.y);
        [aCoder encodeCGPoint:point forKey:[NSString stringWithFormat:@"CGPoint%lu",(unsigned long)i]];
    }
    
}

@end
