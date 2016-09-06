//
//  CoordinateInfo+Assistant.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CoordinateInfo.h"
#import "PHAssetInfo.h"
@import MapKit;

@interface CoordinateInfo (Assistant) <MKAnnotation>

/**
 *  获取 指定CLLocation 的 CoordinateInfo实例，如果没有，则新创建一个
 */
+ (CoordinateInfo *)coordinateInfoWithCLLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 *  获取 指定PHAssetInfo 的 CoordinateInfo实例，如果没有，则新创建一个
 */
+ (CoordinateInfo *)coordinateInfoWithPHAssetInfo:(PHAssetInfo *)assetInfo inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 *  更新 指定CoordinateInfo 的 placemark，完成后调用指定block
 */
+ (void)updatePlacemarkForCoordinateInfo:(CoordinateInfo *)coordinateInfo completionBlock:(void(^)(NSString *localizedPlaceString))completionBlock;

/**
 *  获取 指定CoordinateInfo数组 的 地址统计信息
 */
+ (NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkInfoFromCoordinateInfos:(NSArray <CoordinateInfo *> *)coordinateInfoArray;

/**
 *  获取 全部 CoordinateInfo数组
 */
+ (NSArray <CoordinateInfo *> *)fetchAllCoordinateInfosInManagedObjectContext:(NSManagedObjectContext *)context;

/**
 *  获取 收藏属性为真的 CoordinateInfo数组
 */
+ (NSArray <CoordinateInfo *> *)fetchFavoriteCoordinateInfosInManagedObjectContext:(NSManagedObjectContext *)context;

@end
