//
//  EverywhereShareAnnotation.h
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface EverywhereShareAnnotation : NSObject <MKAnnotation,NSCoding>

/**
 必需，该Annotation的coordinate - EverywhereShareAnnotation
 */
@property (assign,nonatomic) CLLocationCoordinate2D annotationCoordinate;

/**
 该Annotation的开始时间 - EverywhereShareAnnotation
 */
@property (strong,nonatomic) NSDate *startDate;

/**
 该Annotation的结束时间 - EverywhereShareAnnotation
 */
@property (strong,nonatomic) NSDate *endDate;

/**
 可选，生成该Annotation时所处的地图模式 - EverywhereShareAnnotation
 */
//@property (assign,nonatomic) MapMainMode *mapMainMode;

/**
 可选，该Annotation的结束时间 - EverywhereShareAnnotation
 */
//@property (strong,nonatomic) NSDate *endDate;

/**
 可选，该Annotation的半径 - EverywhereShareAnnotation
 */
//@property (assign,nonatomic) CLLocationDistance radius;

@end
