//
//  CoordinateInfo+Assistant.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CoordinateInfo.h"

#define EntityName_CoordinateInfo @"CoordinateInfo"

@interface CoordinateInfo (Assistant)

+ (CoordinateInfo *)coordinateInfoWithLatitude:(double)latitude longitude:(double)longitude inManagedObjectContext:(NSManagedObjectContext *)context;
+ (CoordinateInfo *)coordinateInfoWithPHAssetInfo:(PHAssetInfo *)assetInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)updatePlacemarkForCoordinateInfo:(CoordinateInfo *)coordinateInfo;
+ (NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkInfoFromCoordinateInfos:(NSArray <CoordinateInfo *> *)coordinateInfoArray;

@end
