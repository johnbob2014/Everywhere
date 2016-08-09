//
//  EverywhereFootprintAnnotation.m
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereFootprintAnnotation.h"
#import "WGS84TOGCJ02.h"

@implementation EverywhereFootprintAnnotation

- (CLLocation *)location{
    return [[CLLocation alloc] initWithLatitude:self.coordinateWGS84.latitude longitude:self.coordinateWGS84.longitude];
}

- (CLLocationCoordinate2D)coordinate{
    return [WGS84TOGCJ02 transformFromWGSToGCJ:self.coordinateWGS84];
}

- (NSString *)title{
    if (self.endDate) return [NSString stringWithFormat:@"%@ ~ %@",[self.startDate stringWithFormat:@"yyyy-MM-dd"],[self.endDate stringWithFormat:@"yyyy-MM-dd"]];
    else return [self.startDate stringWithDefaultFormat];
}

- (NSString *)customTitle{
    if (_customTitle) return _customTitle;
    else return self.title;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    CGPoint coordinateWGS84Point = [aDecoder decodeCGPointForKey:@"coordinateWGS84Point"];
    
    EverywhereFootprintAnnotation *shareAnno = [EverywhereFootprintAnnotation new];
    shareAnno.coordinateWGS84 = CLLocationCoordinate2DMake(coordinateWGS84Point.x, coordinateWGS84Point.y);
    shareAnno.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    shareAnno.endDate = [aDecoder decodeObjectForKey:@"endDate"];
    shareAnno.customTitle = [aDecoder decodeObjectForKey:@"customTitle"];
    shareAnno.isUserManuallyAdded = [aDecoder decodeBoolForKey:@"isUserManuallyAdded"];
    
    return shareAnno;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    CGPoint coordinateWGS84Point = CGPointMake(self.coordinateWGS84.latitude, self.coordinateWGS84.longitude);
    [aCoder encodeCGPoint:coordinateWGS84Point forKey:@"coordinateWGS84Point"];
    
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    
    if (self.endDate) {
        [aCoder encodeObject:self.endDate forKey:@"endDate"];
    }
    
    if (self.customTitle){
        [aCoder encodeObject:self.customTitle forKey:@"customTitle"];
    }
    
    if (self.isUserManuallyAdded){
        [aCoder encodeBool:self.isUserManuallyAdded forKey:@"isUserManuallyAdded"];
    }
}
@end
