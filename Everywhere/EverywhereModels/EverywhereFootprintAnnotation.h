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
 *  必需，coordinateWGS84
 */
@property (assign,nonatomic) CLLocationCoordinate2D coordinateWGS84;

/**
 *  必需，开始时间
 */
@property (strong,nonatomic) NSDate *startDate;

/**
 *  结束时间
 */
@property (strong,nonatomic) NSDate *endDate;

/**
 *  高度
 */
@property (assign,nonatomic) CLLocationDistance altitude;

/**
 *  速度
 */
@property (assign,nonatomic) CLLocationSpeed speed;

/**
 *  自定义标题，如果为空，则返回title
 */
@property (strong,nonatomic) NSString *customTitle;

/**
 *  标记该FootprintAnnotation是否为用户手动添加，主要用于记录和编辑
 */
@property (assign,nonatomic) BOOL isUserManuallyAdded;

/**
 *  只读，根据座标信息生成的CLLocation
 */
@property (strong,nonatomic,readonly) CLLocation *location;

/**
 *  缩略图数组
 */
@property (strong,nonatomic) NSMutableArray <UIImage *> *thumbnailArray;

#pragma mark - 导入和导出为GPX方法

/**
 *  从 GPX文件 点字典 生成新实例
 */
+ (EverywhereFootprintAnnotation *)footprintAnnotationFromGPXPointDictionary:(NSDictionary *)pointDictionary isUserManuallyAdded:(BOOL)isUserManuallyAdded;

/**
 *  生成 wpt 字符串
 */
- (NSString *)gpx_wpt_String;

/**
 *  生成 trkpt 字符串
 */
- (NSString *)gpx_trk_trkseg_trkpt_String;

@end
