//
//  EverywhereShareAnnotation.m
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereShareAnnotation.h"
#import "WGS84TOGCJ02.h"

@implementation EverywhereShareAnnotation

- (CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D originalCoordinate = self.annotationCoordinate;
    return [WGS84TOGCJ02 transformFromWGSToGCJ:originalCoordinate];
}

- (NSString *)title{
    if (self.endDate) return [NSString stringWithFormat:@"%@ ~ %@",[self.startDate stringWithFormat:@"yyyy-MM-dd"],[self.endDate stringWithFormat:@"yyyy-MM-dd"]];
    else return [self.startDate stringWithDefaultFormat];
}

- (NSString *)customTitle{
    if (_customTitle) return _customTitle;
    else return @"customTitle";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    CGPoint annotationCoordinatePoint = [aDecoder decodeCGPointForKey:@"annotationCoordinatePoint"];
    //NSTimeInterval startDateTimeInterval = [aDecoder decodeDoubleForKey:@"startDateTimeInterval"];
    NSTimeInterval endDateTimeInterval = [aDecoder decodeDoubleForKey:@"endDateTimeInterval"];
    
    EverywhereShareAnnotation *shareAnno = [EverywhereShareAnnotation new];
    shareAnno.annotationCoordinate = CLLocationCoordinate2DMake(annotationCoordinatePoint.x, annotationCoordinatePoint.y);
    //shareAnno.startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:startDateTimeInterval];
    shareAnno.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    shareAnno.customTitle = [aDecoder decodeObjectForKey:@"customTitle"];
    
    if (endDateTimeInterval != 0) shareAnno.endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:endDateTimeInterval];
    else shareAnno.endDate = nil;
    
    return shareAnno;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    CGPoint annotationCoordinatePoint = CGPointMake(self.annotationCoordinate.latitude, self.annotationCoordinate.longitude);
    [aCoder encodeCGPoint:annotationCoordinatePoint forKey:@"annotationCoordinatePoint"];
    
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    /*
    NSTimeInterval startDateTimeInterval = [self.startDate timeIntervalSinceReferenceDate];
    [aCoder encodeDouble:startDateTimeInterval forKey:@"startDateTimeInterval"];
    */
    
    if (self.endDate) {
        NSTimeInterval endDateTimeInterval = [self.endDate timeIntervalSinceReferenceDate];
        [aCoder encodeDouble:endDateTimeInterval forKey:@"endDateTimeInterval"];
    }
    
    if (self.customTitle){
        [aCoder encodeObject:self.customTitle forKey:@"customTitle"];
    }
}
@end
