//
//  PHAssetInfo+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "PHAssetInfo+Assistant.h"
#import "NSDate+Assistant.h"
#import "CLPlacemark+Assistant.h"
#import "EverywhereCoreDataHeader.h"

@import CoreLocation;

@implementation PHAssetInfo (Assistant)

+ (PHAssetInfo *)newAssetInfoWithLocalIdentifier:(NSString *)localID inManagedObjectContext:(NSManagedObjectContext *)context{
    // The instance has its entity description set and is inserted it into context.
    PHAssetInfo *info = [NSEntityDescription insertNewObjectForEntityForName:EntityName_PHAssetInfo inManagedObjectContext:context];
    
    info.localIdentifier = localID;
    // 保存修改后的信息
    [context save:NULL];
    
    return info;
}

+ (PHAssetInfo *)newAssetInfoWithPHAsset:(PHAsset *)asset inManagedObjectContext:(NSManagedObjectContext *)context{
    // The instance has its entity description set and is inserted it into context.
    PHAssetInfo *info = [NSEntityDescription insertNewObjectForEntityForName:EntityName_PHAssetInfo inManagedObjectContext:context];
    
    info.localIdentifier = asset.localIdentifier;
    
    info.altitude_Location = @(asset.location.altitude);
    info.burstIdentifier = asset.burstIdentifier;
    info.burstSelectionTypes = @(asset.burstSelectionTypes);
    info.course_Location = @(asset.location.course);
    info.creationDate = asset.creationDate;
    info.duration = @(asset.duration);
    info.favorite = @(asset.favorite);
    info.level_floor_Location = @(asset.location.floor.level);
    info.hidden = @(asset.hidden);
    info.horizontalAccuracy_Location = @(asset.location.horizontalAccuracy);
    info.latitude_Coordinate_Location = @(asset.location.coordinate.latitude);
    
    info.longitude_Coordinate_Location = @(asset.location.coordinate.longitude);
    info.mediaSubtypes = @(asset.mediaSubtypes);
    info.mediaType = @(asset.mediaType);
    info.modificationDate = asset.modificationDate;
    info.pixelHeight = @(asset.pixelHeight);
    info.pixelWidth = @(asset.pixelWidth);
    info.representsBurst = @(asset.representsBurst);
    info.speed_Location = @(asset.location.speed);
    info.verticalAccuracy_Location = @(asset.location.verticalAccuracy);
    
    // 保存修改后的信息
    [context save:NULL];

    return info;
}

+ (PHAssetInfo *)fetchAssetInfoWithLocalIdentifier:(NSString *)localID inManagedObjectContext:(NSManagedObjectContext *)context{
    PHAssetInfo *info = nil;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_PHAssetInfo];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localIdentifier = %@",localID];
    NSError *fetchError;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    if(matches.count == 1){
        info = matches.firstObject;
    }else if (!matches || fetchError || [matches count]>1) {
        if(!matches) NSLog(@"Fetch PHAssetInfo Result : Not Found.");
        if(fetchError) NSLog(@"Fetch PHAssetInfo Result : %@",fetchError.localizedDescription);
        if(matches.count > 1) {
            NSLog(@"Fetch PHAssetInfo Result : More than 1 result.");
            info = matches.firstObject;
        }
    }
    
    return info;
}

+ (NSArray <PHAssetInfo *> *)fetchAssetInfosFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_PHAssetInfo];
    
    //startDate = [startDate dateAtStartOfToday];
    //endDate = [endDate dateAtEndOfToday];
    
    if (startDate && endDate) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@" (creationDate >= %@) && (creationDate <= %@)",startDate,endDate];
    }else if (startDate) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@",startDate];
    }else if (endDate){
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"creationDate <= %@",endDate];
    }

    //fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    NSError *fetchError;
    NSArray <PHAssetInfo *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch PHAssetInfos By Date Error : %@",fetchError.localizedDescription);

    return matches;
}

+ (NSArray <PHAssetInfo *> *)fetchAssetInfosContainsPlacemark:(NSString *)subPlacemark inManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_PHAssetInfo];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"localizedPlaceString_Placemark CONTAINS %@",subPlacemark];
    NSError *fetchError;
    NSArray <PHAssetInfo *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch PHAssetInfos Contains Placemark Error : %@",fetchError.localizedDescription);
    return matches;
}


+ (NSArray <PHAssetInfo *> *)fetchAllAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_PHAssetInfo];
    //fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    NSError *fetchError;
    NSArray <PHAssetInfo *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch All PHAssetInfos Error : %@",fetchError.localizedDescription);
    return matches;
}

+ (NSArray <PHAssetInfo *> *)fetchEliminatedAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_PHAssetInfo];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"eliminateThisAsset = %@",[NSNumber numberWithBool:YES]];
    NSError *fetchError;
    NSArray <PHAssetInfo *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch Eliminated PHAssetInfos Error : %@",fetchError.localizedDescription);
    return matches;
}

+ (NSArray <PHAssetInfo *> *)fetchThumbnailAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_PHAssetInfo];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"actAsThumbnail = %@",[NSNumber numberWithBool:YES]];
    NSError *fetchError;
    NSArray <PHAssetInfo *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch Thumbnail PHAssetInfos Error : %@",fetchError.localizedDescription);
    return matches;
}

+ (BOOL)deleteAllAssetInfosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSArray <PHAssetInfo *> *allAssets = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:context];
    [allAssets enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [context deleteObject:obj];
    }];
    
    BOOL success = [context save:NULL];
    if (success){
        NSLog(@"Delete All PHAssetInfos Succeed.");
    }
    else{
        NSLog(@"Delete All PHAssetInfos Failed!");
    }
    
    return success;
}

+ (CLGeocoder *)defaultGeocoder{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CLGeocoder new];
    });
    return instance;
}

+ (void)updatePlacemarkForAssetInfo:(PHAssetInfo *)assetInfo{
    if (!assetInfo) return;
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetInfo.localIdentifier] options:nil].firstObject;
    
    [[PHAssetInfo defaultGeocoder] reverseGeocodeLocation:asset.location
                                        completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                            NSString *placeInfo;
                                            
                                            if (!error) {
                                                // 解析成功
                                                CLPlacemark *placemark = placemarks.lastObject;
                                                assetInfo.name_Placemark = placemark.name;
                                                assetInfo.ccISOcountryCode_Placemark = placemark.ISOcountryCode;
                                                assetInfo.country_Placemark = placemark.country;
                                                assetInfo.postalCode_Placemark = placemark.postalCode;
                                                assetInfo.administrativeArea_Placemark = placemark.administrativeArea;
                                                assetInfo.subAdministrativeArea_Placemark = placemark.subAdministrativeArea;
                                                assetInfo.locality_Placemark = placemark.locality;
                                                assetInfo.subLocality_Placemark = placemark.subLocality;
                                                assetInfo.thoroughfare_Placemark = placemark.thoroughfare;
                                                assetInfo.subThoroughfare_Placemark = placemark.subThoroughfare;
                                                assetInfo.inlandWater_Placemark = placemark.inlandWater;
                                                assetInfo.ocean_Placemark = placemark.ocean;
                                                
                                                assetInfo.localizedPlaceString_Placemark = [placemark localizedPlaceStringInReverseOrder:NO withInlandWaterAndOcean:NO];
                                                
                                                assetInfo.reverseGeocodeSucceed = @(YES);
                                                
                                            }else{
                                                // 解析失败
                                                placeInfo = error.localizedDescription;
                                                assetInfo.reverseGeocodeSucceed = @(NO);
                                            }
                                            
                                            NSLog(@"PHAssetInfo : %@",assetInfo.localizedPlaceString_Placemark);
                                            
                                            // 保存修改后的信息
                                            [assetInfo.managedObjectContext save:NULL];
                                        }];
    
    
}

+ (NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkInfoFromAssetInfos:(NSArray <PHAssetInfo *> *)assetInfoArray{
    NSMutableArray <NSString *> *country_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *administrativeArea_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *subAdministrativeArea_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *locality_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *subLocality_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *thoroughfare_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *subThoroughfare_Placemark = [NSMutableArray new];

    [assetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 不排除的照片，才统计信息
        if (![obj.eliminateThisAsset boolValue]){
            if (obj.country_Placemark) {
                if (![country_Placemark containsObject:obj.country_Placemark]) [country_Placemark addObject:obj.country_Placemark];
            }
            if (obj.administrativeArea_Placemark){
                if (![administrativeArea_Placemark containsObject:obj.administrativeArea_Placemark]) [administrativeArea_Placemark addObject:obj.administrativeArea_Placemark];
            }
            if (obj.subAdministrativeArea_Placemark){
                if (![subAdministrativeArea_Placemark containsObject:obj.subAdministrativeArea_Placemark]) [subAdministrativeArea_Placemark addObject:obj.subAdministrativeArea_Placemark];
            }
            if (obj.locality_Placemark){
                if (![locality_Placemark containsObject:obj.locality_Placemark]) [locality_Placemark addObject:obj.locality_Placemark];
            }
            if (obj.subLocality_Placemark){
                if (![subLocality_Placemark containsObject:obj.subLocality_Placemark]) [subLocality_Placemark addObject:obj.subLocality_Placemark];
            }
            if (obj.thoroughfare_Placemark){
                if (![thoroughfare_Placemark containsObject:obj.thoroughfare_Placemark]) [thoroughfare_Placemark addObject:obj.thoroughfare_Placemark];
            }
            if (obj.subThoroughfare_Placemark){
                if (![subThoroughfare_Placemark containsObject:obj.subThoroughfare_Placemark]) [subThoroughfare_Placemark addObject:obj.subThoroughfare_Placemark];
            }
        }
    }];
    
    return @{kCountryArray:country_Placemark,
             kAdministrativeAreaArray:administrativeArea_Placemark,
             kSubAdministrativeAreaArray:subAdministrativeArea_Placemark,
             kLocalityArray:locality_Placemark,
             kSubLocalityArray:subLocality_Placemark,
             kThoroughfareArray:thoroughfare_Placemark,
             kSubThoroughfareArray:subThoroughfare_Placemark};
}

@end
