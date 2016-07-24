//
//  EverywhereShareAnnotation.h
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCLocationAnalyser.h"

@import MapKit;

@interface EverywhereShareAnnotation : NSObject <MKAnnotation,NSCoding,GCLocationAnalyserProtocol>

/**
 必需，coordinate - EverywhereShareAnnotation
 */
@property (assign,nonatomic) CLLocationCoordinate2D annotationCoordinate;

/**
 开始时间 - EverywhereShareAnnotation
 */
@property (strong,nonatomic) NSDate *startDate;

/**
 结束时间 - EverywhereShareAnnotation
 */
@property (strong,nonatomic) NSDate *endDate;

/**
 自定义标题 - EverywhereShareAnnotation
 */
@property (strong,nonatomic) NSString *customTitle;

/**
 标记该ShareAnnotation是否为用户手动添加，主要用于记录模式 - EverywhereShareAnnotation
 */
@property (assign,nonatomic) BOOL isUserManuallyAdded;


/**
 利用GCLocationAnalyser进行分组时使用 - EverywhereShareAnnotation
 */
@property (strong,nonatomic) CLLocation *location;
/**
 可选，生成该Annotation时所处的地图模式 - EverywhereShareAnnotation
 */
//@property (assign,nonatomic) MapBaseMode *mapBaseMode;

/**
 可选，该Annotation的结束时间 - EverywhereShareAnnotation
 */
//@property (strong,nonatomic) NSDate *endDate;

/**
 可选，该Annotation的半径 - EverywhereShareAnnotation
 */
//@property (assign,nonatomic) CLLocationDistance radius;

@end
