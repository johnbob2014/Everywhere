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

/**
 必须，包含的足迹点数组 - EverywhereFootprintsRepository
 */
@property (strong,nonatomic) NSArray <EverywhereFootprintAnnotation *> *footprintAnnotations;

/**
 范围半径 - EverywhereFootprintsRepository
 */
@property (assign,nonatomic) double radius;

/**
 标题 - EverywhereFootprintsRepository
 */
@property (strong,nonatomic) NSString *title;

/**
 地点统计信息字符串 - EverywhereFootprintsRepository
 */
@property (strong,nonatomic) NSString *placemarkInfo;

/**
 必须，创建日期 - EverywhereFootprintsRepository
 */
@property (strong,nonatomic) NSDate *creationDate;

/**
 修改日期 - EverywhereFootprintsRepository
 */
@property (strong,nonatomic) NSDate *modificatonDate;

/**
 类型 - EverywhereFootprintsRepository
 */
@property (assign,nonatomic) FootprintsRepositoryType footprintsRepositoryType;

/**
 写入ABFR文件 - EverywhereFootprintsRepository
 */
- (BOOL)exportToABFRFile:(NSString *)filePath;

/**
 从ABFR文件生成新实例 - EverywhereFootprintsRepository
 */
+ (EverywhereFootprintsRepository *)importFromABFRFile:(NSString *)filePath;

/**
 写入GPX文件 - EverywhereFootprintsRepository
 */
- (BOOL)exportToGPXFile:(NSString *)filePath;

/**
 从GPX文件生成新实例 - EverywhereFootprintsRepository
 */
+ (EverywhereFootprintsRepository *)importFromGPXFile:(NSString *)filePath;

@end
