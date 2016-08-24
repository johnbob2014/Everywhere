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
@property (strong,nonatomic) NSArray <EverywhereFootprintAnnotation *> *footprintAnnotations;

/**
 *  必须，创建日期
 */
@property (strong,nonatomic) NSDate *creationDate;

/**
 *  范围半径
 */
@property (assign,nonatomic) double radius;

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
 *  类型
 */
@property (assign,nonatomic) FootprintsRepositoryType footprintsRepositoryType;

/**
 *  长度
 */
@property (assign,nonatomic,readonly) double distance;

#pragma mark - 方法
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
