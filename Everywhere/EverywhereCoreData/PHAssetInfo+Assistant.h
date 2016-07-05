//
//  PHAssetInfo+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "PHAssetInfo.h"
@import Photos;

#define EntityName_PHAssetInfo @"PHAssetInfo"

@interface PHAssetInfo (Assistant)

+ (PHAssetInfo *)newAssetInfoWithLocalIdentifier:(NSString *)localID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (PHAssetInfo *)newAssetInfoWithPHAsset:(PHAsset *)asset inManagedObjectContext:(NSManagedObjectContext *)context;
+ (PHAssetInfo *)fetchAssetInfoWithLocalIdentifier:(NSString *)localID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray <PHAssetInfo *> *)fetchAssetInfosFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray <PHAssetInfo *> *)fetchAllAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteAllAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)updatePlacemarkForAssetInfo:(PHAssetInfo *)assetInfo;

@end
