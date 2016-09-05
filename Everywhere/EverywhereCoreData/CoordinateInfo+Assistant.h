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

+ (CoordinateInfo *)coordinateInfoWithCLLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)context;
+ (CoordinateInfo *)coordinateInfoWithPHAssetInfo:(PHAssetInfo *)assetInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)updatePlacemarkForCoordinateInfo:(CoordinateInfo *)coordinateInfo completionBlock:(void(^)(NSString *localizedPlaceString))completionBlock;
+ (NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkInfoFromCoordinateInfos:(NSArray <CoordinateInfo *> *)coordinateInfoArray;
+ (NSArray <CoordinateInfo *> *)fetchFavoriteCoordinateInfosInManagedObjectContext:(NSManagedObjectContext *)context;
@end
