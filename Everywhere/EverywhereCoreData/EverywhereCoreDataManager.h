//
//  EverywhereCoreDataManager.h
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EverywhereFootprintsRepository;

#import "PHAssetInfo.h"
#import "EWFRInfo.h"

typedef void(^UpdatePlacemarkForPHAssetInfoCompletionBlock)(NSInteger reverseGeocodeSucceedCountForThisTime,NSInteger reverseGeocodeSucceedCountForTotal, NSInteger totalPHAssetInfoCount);

@import CoreData;

@interface EverywhereCoreDataManager : NSObject

/**
 *  CoreData全局上下文
 */
+ (NSManagedObjectContext *)appDelegateMOC;

/**
 *  上次更新日期
 */
+ (NSDate *)lastUpdateDate;

/**
 *  设置上次更新日期
 */
+ (void)setLastUpdateDate:(NSDate *)lastUpdateDate;

/**
 *  倒数第二次更新日期
 */
+ (NSDate *)secondLastUpdateDate;

/**
 * 从照片库智能更新PHAssetInfo数据，返回本次更新的数据；如果照片库无法访问，直接返回0 - EverywhereCoreDataManager
 */
+ (NSInteger)updatePHAssetInfoFromPhotoLibrary;

/**
 * 异步更新PHAssetInfo的Placemark信息，提供更新完成Block - EverywhereCoreDataManager
 */
+ (void)asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:(UpdatePlacemarkForPHAssetInfoCompletionBlock)completionBlock;

/**
 * 为 PlacemarkDictionary 生成 地址统计信息 字符串
 */
+ (NSString *)placemarkInfoStringForPlacemarkDictionary:(NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkDictionary;

/**
 *  添加足迹包并存储
 */
+ (BOOL)addEWFR:(EverywhereFootprintsRepository *)ewfr;

/**
 *  移除足迹包
 */
+ (BOOL)removeEWFRInfo:(EWFRInfo *)ewfrInfo;

/**
 *  获取所有EWFRInfo实例
 */
+ (NSArray <EWFRInfo *> *)allEWFRs;

/**
 *  移除所有EWFRInfo实例
 */
+ (NSInteger)removeAllEWFRInfos;

/**
 *  将 所有足迹包 导出为MFR文件，返回导出成功的数量
 */
+ (NSUInteger)exportFootprintsRepositoryToMFRFilesAtPath:(NSString *)directoryPath;

/**
 *  将 所有足迹包 导出为GPX文件，返回导出成功的数量
 */
+ (NSUInteger)exportFootprintsRepositoryToGPXFilesAtPath:(NSString *)directoryPath;

/**
 *  从指定文件夹导入足迹包，并将导入成功的文件移入指定文件夹（如果为空，则删除），返回导入成功的数量
 */
+ (NSUInteger)importFootprintsRepositoryFromFilesAtPath:(NSString *)directoryPath moveAddedFilesToPath:(NSString *)moveDirectoryPath;

@end
