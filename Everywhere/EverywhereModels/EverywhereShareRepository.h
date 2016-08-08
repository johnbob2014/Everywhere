//
//  EverywhereShareRepository.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EverywhereShareAnnotation.h"

@interface EverywhereShareRepository : NSObject <NSCoding,NSCopying>

/**
 必须，包含的足迹点数组 - EverywhereShareRepository
 */
@property (strong,nonatomic) NSArray <EverywhereShareAnnotation *> *shareAnnos;

/**
 范围半径 - EverywhereShareRepository
 */
@property (assign,nonatomic) double radius;

/**
 标题 - EverywhereShareRepository
 */
@property (strong,nonatomic) NSString *title;

/**
 地点统计信息字符串 - EverywhereShareRepository
 */
@property (strong,nonatomic) NSString *placemarkInfo;

/**
 必须，创建日期 - EverywhereShareRepository
 */
@property (strong,nonatomic) NSDate *creationDate;

/**
 修改日期 - EverywhereShareRepository
 */
@property (strong,nonatomic) NSDate *modificatonDate;

/**
 类型 - EverywhereShareRepository
 */
@property (assign,nonatomic) ShareRepositoryType shareRepositoryType;

@end
