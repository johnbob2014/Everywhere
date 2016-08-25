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

/*
@property (strong,nonatomic,readonly) NSManagedObjectContext *appDelegateMOC;

@property (strong,nonatomic,readonly) NSDate *lastUpdateDate;

@property (strong,nonatomic,readonly) NSDate *secondLastUpdateDate;

+ (instancetype)defaultManager;
*/

+ (NSManagedObjectContext *)appDelegateMOC;

+ (NSDate *)lastUpdateDate;

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

+ (BOOL)addEWFR:(EverywhereFootprintsRepository *)ewfr;
+ (BOOL)removeEWFRInfo:(EWFRInfo *)ewfrInfo;

+ (NSArray <EWFRInfo *> *)allEWFRs;
+ (NSInteger)removeAllEWFRInfos;

+ (NSUInteger)exportFootprintsRepositoryToMFRFilesAtPath:(NSString *)directoryPath;
+ (NSUInteger)exportFootprintsRepositoryToGPXFilesAtPath:(NSString *)directoryPath;

+ (NSUInteger)importFootprintsRepositoryFromFilesAtPath:(NSString *)directoryPath moveAddedFilesToPath:(NSString *)moveDirectoryPath;

@end
