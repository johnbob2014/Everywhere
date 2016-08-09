//
//  EverywhereFootprintAnnotation.h
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCLocationAnalyser.h"

@import MapKit;

@interface EverywhereFootprintAnnotation : NSObject <MKAnnotation,NSCoding,GCLocationAnalyserProtocol>

/**
 必需，coordinateWGS84 - EverywhereFootprintAnnotation
 */
@property (assign,nonatomic) CLLocationCoordinate2D coordinateWGS84;

/**
 必需，开始时间 - EverywhereFootprintAnnotation
 */
@property (strong,nonatomic) NSDate *startDate;

/**
 结束时间 - EverywhereFootprintAnnotation
 */
@property (strong,nonatomic) NSDate *endDate;

/**
 自定义标题，如果为空，则返回title - EverywhereFootprintAnnotation
 */
@property (strong,nonatomic) NSString *customTitle;

/**
 标记该FootprintAnnotation是否为用户手动添加，主要用于记录和编辑 - EverywhereFootprintAnnotation
 */
@property (assign,nonatomic) BOOL isUserManuallyAdded;

/**
 只读，仅用于GCLocationAnalyser进行分组 - EverywhereFootprintAnnotation
 */
@property (strong,nonatomic,readonly) CLLocation *location;

@end
