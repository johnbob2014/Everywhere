//
//  EverywhereShareMKAnnotation.m
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereShareMKAnnotation.h"
#import "WGS84TOGCJ02.h"

@implementation EverywhereShareMKAnnotation

- (CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D originalCoordinate = self.annotationCoordinate;
    return [WGS84TOGCJ02 transformFromWGSToGCJ:originalCoordinate];
}

- (NSString *)title{
    return [self.annotationDate stringWithDefaultFormat];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    CGPoint annotationCoordinatePoint = [aDecoder decodeCGPointForKey:@"annotationCoordinatePoint"];
    NSTimeInterval timeInterval = [aDecoder decodeDoubleForKey:@"timeInterval"];
    EverywhereShareMKAnnotation *shareAnno = [EverywhereShareMKAnnotation new];
    shareAnno.annotationCoordinate = CLLocationCoordinate2DMake(annotationCoordinatePoint.x, annotationCoordinatePoint.y);
    shareAnno.annotationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    return shareAnno;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    CGPoint annotationCoordinatePoint = CGPointMake(self.annotationCoordinate.latitude, self.annotationCoordinate.longitude);
    [aCoder encodeCGPoint:annotationCoordinatePoint forKey:@"annotationCoordinatePoint"];
    
    NSTimeInterval timeInterval = [self.annotationDate timeIntervalSinceReferenceDate];
    [aCoder encodeDouble:timeInterval forKey:@"timeInterval"];
}
@end
