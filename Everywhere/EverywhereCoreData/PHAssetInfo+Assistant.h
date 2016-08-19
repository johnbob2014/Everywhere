//
//  PHAssetInfo+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "PHAssetInfo.h"
@import Photos;

#pragma mark
#define EntityName_PHAssetInfo @"PHAssetInfo"
@interface PHAssetInfo (Assistant)

#pragma mark - 生成

/**
 * 生成新实例，使用localIdentifier
 */
+ (PHAssetInfo *)newAssetInfoWithLocalIdentifier:(NSString *)localID inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 * 生成新实例，使用PHAsset，同时获取并复制PHAsset的信息
 */
+ (PHAssetInfo *)newAssetInfoWithPHAsset:(PHAsset *)asset inManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - 查找

/**
 * 获取指定 localIdentifier 的实例，如果没有找到，返回 nil
 */
+ (PHAssetInfo *)fetchAssetInfoWithLocalIdentifier:(NSString *)localID inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 * 获取全部实例
 */
+ (NSArray <PHAssetInfo *> *)fetchAllAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context;


/**
 * 获取 指定的开始、结束日期之内的 全部实例，开始、结束日期均可为空
 */
+ (NSArray <PHAssetInfo *> *)fetchAssetInfosFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 * 获取 包含指定Placemark信息的 全部实例- PHAssetInfo+Assistant
 */
+ (NSArray <PHAssetInfo *> *)fetchAssetInfosContainsPlacemark:(NSString *)subPlacemark inManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - 删除

/**
 * 删除全部实例
 */
+ (BOOL)deleteAllAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context;

#pragma mark - 工具

/**
 * 为指定的实例 更新Placemark (注意：需要联网，所以在副线程进行更新，因而无法立即获取数据)
 */
+ (void)updatePlacemarkForAssetInfo:(PHAssetInfo *)assetInfo;


/**
 * 统计 指定实例集合的 Placemark信息
 */
+ (NSDictionary <NSString *,NSArray <NSString *> *> *)placemarkInfoFromAssetInfos:(NSArray <PHAssetInfo *> *)assetInfoArray;

@end
