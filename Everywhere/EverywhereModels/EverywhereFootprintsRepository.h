//
//  EverywhereFootprintsRepository.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EverywhereFootprintAnnotation.h"

@interface EverywhereFootprintsRepository : NSObject <NSCoding,NSCopying>

#pragma mark - 属性
/**
 *  必须，包含的足迹点数组
 */
@property (strong,nonatomic) NSMutableArray <EverywhereFootprintAnnotation *> *footprintAnnotations;

/**
 *  必须，创建日期
 */
@property (strong,nonatomic) NSDate *creationDate;

/**
 *  范围半径
 */
@property (assign,nonatomic) double radius;

/**
 *  类型
 */
@property (assign,nonatomic) FootprintsRepositoryType footprintsRepositoryType;

/**
 *  标题
 */
@property (strong,nonatomic) NSString *title;

/**
 *  地点统计信息字符串
 */
@property (strong,nonatomic) NSString *placemarkStatisticalInfo;

/**
 *  修改日期
 */
@property (strong,nonatomic) NSDate *modificatonDate;

/**
 *  只读，唯一标识符
 */
@property (strong,nonatomic,readonly) NSString *identifier;

/**
 *  只读，缩略图数量
 */
@property (assign,nonatomic,readonly) NSInteger thumbnailCount;


#pragma mark - 属性，仅 radius == 0 时有才有意义
/**
 *  只读，长度(m)
 */
@property (assign,nonatomic,readonly) double distance;

/**
 *  只读，足迹开始时间
 */
@property (strong,nonatomic,readonly) NSDate *startDate;

/**
 *  只读，足迹结束时间
 */
@property (strong,nonatomic,readonly) NSDate *endDate;

/**
 *  只读，持续时间(s)
 */
@property (assign,nonatomic,readonly) NSTimeInterval duration;

/**
 *  只读，平均速度(m/s)
 */
@property (assign,nonatomic,readonly) double averageSpeed;

#pragma mark - 导入和导出方法
/**
 *  写入MFR文件
 */
- (BOOL)exportToMFRFile:(NSString *)filePath;

/**
 *  从MFR文件生成新实例
 */
+ (EverywhereFootprintsRepository *)importFromMFRFile:(NSString *)filePath;

/**
 *  写入GPX文件
 */
- (BOOL)exportToGPXFile:(NSString *)filePath;

/**
 *  从GPX文件生成新实例
 */
+ (EverywhereFootprintsRepository *)importFromGPXFile:(NSString *)filePath;

@end
