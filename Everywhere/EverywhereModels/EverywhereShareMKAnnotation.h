//
//  EverywhereShareMKAnnotation.h
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface EverywhereShareMKAnnotation : NSObject <MKAnnotation,NSCoding>

/**
 必需，该Annotation的coordinate - EverywhereShareMKAnnotation
 */
@property (assign,nonatomic) CLLocationCoordinate2D annotationCoordinate;

/**
 该Annotation的时间 - EverywhereShareMKAnnotation
 */
@property (strong,nonatomic) NSDate *annotationDate;

@end
