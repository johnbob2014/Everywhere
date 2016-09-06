//
//  EverywhereCoreDataManager.m
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereCoreDataManager.h"
#import "EverywhereCoreDataHeader.h"
#import "EverywhereAppDelegate.h"

#import "EverywhereSettingManager.h"

#import "EverywhereFootprintsRepository.h"

#import "GCPhotoManager.h"


@implementation EverywhereCoreDataManager

+ (NSManagedObjectContext *)appDelegateMOC{
    EverywhereAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

+ (NSDate *)lastUpdateDate{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateDate"];
}

+ (void)setLastUpdateDate:(NSDate *)lastUpdateDate{
    [[NSUserDefaults standardUserDefaults] setValue:lastUpdateDate forKey:@"lastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDate *)secondLastUpdateDate{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"secondLastUpdateDate"];
}

+ (void)setSecondLastUpdateDate:(NSDate *)secondLastUpdateDate{
    [[NSUserDefaults standardUserDefaults] setValue:secondLastUpdateDate forKey:@"secondLastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - PHAssetInfo Data

+ (NSInteger)updatePHAssetInfoFromPhotoLibrary{
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) return 0;
    
    NSInteger addedPHAssetInfoCount = 0;
    
    if (!self.lastUpdateDate) {
        // 首次加载照片数据
        addedPHAssetInfoCount = [self updateCoreDataFormStartDate:nil toEndDate:nil];
    }else{
        // 更新照片数据
        addedPHAssetInfoCount = [self updateCoreDataFormStartDate:[EverywhereCoreDataManager lastUpdateDate] toEndDate:nil];
        self.secondLastUpdateDate = self.lastUpdateDate;
    }
    
    // 更新刷新时间
    self.lastUpdateDate = [NSDate date];
    
    return addedPHAssetInfoCount;
}

+ (NSInteger)updateCoreDataFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    NSDate *timeTest = [NSDate date];
    __block NSInteger addedPHAssetInfoCount = 0;
    
    NSString *userLibraryAssetCollectionID = [GCPhotoManager GCAssetCollectionID_UserLibrary];
    NSDictionary *dic = [GCPhotoManager fetchAssetsFormStartDate:startDate toEndDate:endDate fromAssetCollectionIDs:@[userLibraryAssetCollectionID]];
    NSArray <PHAsset *> *assetArray = dic[userLibraryAssetCollectionID];
    
    [assetArray enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.location){
            if ([self checkCoordinate:obj.location.coordinate]) {
                
                PHAssetInfo *info = [PHAssetInfo newAssetInfoWithPHAsset:obj inManagedObjectContext:self.appDelegateMOC];
                addedPHAssetInfoCount++;
                if(DEBUGMODE) NSLog(@"%@",info.localIdentifier);
            }
        }
    }];
    if(DEBUGMODE) NSLog(@"从照片库更新照片数据 :\nAdd PHAssetInfo Count : %ld\n耗时 : %.3fs",(long)addedPHAssetInfoCount,[[NSDate date] timeIntervalSinceDate:timeTest]);
    return addedPHAssetInfoCount;
}

+ (BOOL)checkCoordinate:(CLLocationCoordinate2D)aCoord{
    
    if (aCoord.latitude > -90 && aCoord.latitude < 90) {
        if (aCoord.longitude > - 180 && aCoord.longitude < 180) {
            if (aCoord.latitude != 0 && aCoord.longitude != 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (void)asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:(UpdatePlacemarkForPHAssetInfoCompletionBlock)completionBlock{
    NSManagedObjectContext *context = [EverywhereCoreDataManager appDelegateMOC];
    @synchronized (context) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:context];
            
            __block NSInteger reverseGeocodeFailedCountBeforeUpdate = 0;
            [allAssetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.reverseGeocodeSucceed boolValue]) {
                    reverseGeocodeFailedCountBeforeUpdate++;
                    [PHAssetInfo updatePlacemarkForAssetInfo:obj];
                    //if(DEBUGMODE) NSLog(@"%@",NSStringFromCGPoint(CGPointMake([obj.latitude_Coordinate_Location doubleValue], [obj.longitude_Coordinate_Location doubleValue])));
                    [NSThread sleepForTimeInterval:1.0];
                }
            }];
            
            
            __block NSInteger reverseGeocodeFailedCountAfterUpdate = 0;
            [allAssetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.reverseGeocodeSucceed boolValue]) {
                    reverseGeocodeFailedCountAfterUpdate++;
                    [PHAssetInfo updatePlacemarkForAssetInfo:obj];
                    //if(DEBUGMODE) NSLog(@"%@",NSStringFromCGPoint(CGPointMake([obj.latitude_Coordinate_Location doubleValue], [obj.longitude_Coordinate_Location doubleValue])));
                    [NSThread sleepForTimeInterval:1.0];
                }
            }];
            
            NSInteger totalPHAssetInfoCount = allAssetInfoArray.count;
            NSInteger reverseGeocodeSucceedCountForThisTime = reverseGeocodeFailedCountBeforeUpdate - reverseGeocodeFailedCountAfterUpdate;
            NSInteger reverseGeocodeSucceedCountForTotal = totalPHAssetInfoCount - reverseGeocodeFailedCountAfterUpdate;
            
            if(DEBUGMODE) NSLog(@"解析照片信息 :\n本次解析成功 : %lu\n总成功数 : %lu\n总照片数 : %lu",(long)reverseGeocodeSucceedCountForThisTime,(long)reverseGeocodeSucceedCountForTotal,(long)totalPHAssetInfoCount);
            
            if(completionBlock) completionBlock(reverseGeocodeSucceedCountForThisTime,reverseGeocodeSucceedCountForTotal,totalPHAssetInfoCount);
        });
    }
}

#pragma mark - PlacemarkInfo String

+ (NSString *)placemarkInfoStringForPlacemarkDictionary:(NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkDictionary{
    NSMutableString *ms = [NSMutableString new];
    
    BOOL hasAddedPlacemarkForMoment = NO;
    NSString *placemarkStringForMoment = NSLocalizedString(@"the world's", @"全球的");
    
    if (placemarkDictionary[kCountryArray].count > 1) {
        [ms appendFormat:@"%ld",(long)placemarkDictionary[kCountryArray].count];
        [ms appendString:NSLocalizedString(@" States,", @"个国家,")];
        
        hasAddedPlacemarkForMoment = YES;
    }else if (placemarkDictionary[kCountryArray].count == 1){
        placemarkStringForMoment = placemarkDictionary[kCountryArray].firstObject;
    }
    
    if (placemarkDictionary[kAdministrativeAreaArray].count > 1) {
        if (!hasAddedPlacemarkForMoment) [ms appendFormat:@"%@%@ ",placemarkStringForMoment,NSLocalizedString(@"'s", " 的")];
        hasAddedPlacemarkForMoment = YES;
        
        [ms appendFormat:@"%ld",(long)placemarkDictionary[kAdministrativeAreaArray].count];
        [ms appendString:NSLocalizedString(@" Prov.s,", @"个省,")];//AdministrativeAreas
    }else if (placemarkDictionary[kAdministrativeAreaArray].count == 1){
        placemarkStringForMoment = placemarkDictionary[kAdministrativeAreaArray].firstObject;
    }
    
    
    if (placemarkDictionary[kLocalityArray].count > 1){
        if (!hasAddedPlacemarkForMoment) [ms appendFormat:@"%@%@ ",placemarkStringForMoment,NSLocalizedString(@"'s", " 的")];
        hasAddedPlacemarkForMoment = YES;
        
        [ms appendFormat:@"%ld",(long)placemarkDictionary[kLocalityArray].count];
        [ms appendString:NSLocalizedString(@" Cities,", @"个市,")];
    }else if (placemarkDictionary[kLocalityArray].count == 1){
        placemarkStringForMoment = placemarkDictionary[kLocalityArray].firstObject;
    }
    
    if (placemarkDictionary[kSubLocalityArray].count > 1) {
        if (!hasAddedPlacemarkForMoment) [ms appendFormat:@"%@%@ ",placemarkStringForMoment,NSLocalizedString(@"'s", " 的")];
        hasAddedPlacemarkForMoment = YES;
        
        [ms appendFormat:@"%ld",(long)placemarkDictionary[kSubLocalityArray].count];
        [ms appendString:NSLocalizedString(@" Dist.s,", @"个县区,")];//SubLocalities
    }else if (placemarkDictionary[kSubLocalityArray].count == 1){
        placemarkStringForMoment = placemarkDictionary[kSubLocalityArray].firstObject;
    }
    
    if (placemarkDictionary[kThoroughfareArray].count > 1) {
        if (!hasAddedPlacemarkForMoment) [ms appendFormat:@"%@%@ ",placemarkStringForMoment,NSLocalizedString(@"'s", " 的")];
        hasAddedPlacemarkForMoment = YES;
        
        [ms appendFormat:@"%ld",(long)placemarkDictionary[kThoroughfareArray].count];
        [ms appendString:NSLocalizedString(@" St.s", @"个村镇街道")];//Thoroughfares
    }
    
    return [NSString stringWithString:ms];
}

#pragma mark - EWFRInfo Data

+ (BOOL)addEWFR:(EverywhereFootprintsRepository *)ewfr{
    if (![NSFileManager directoryExistsAtPath:EWFRStorageDirectoryPath autoCreate:YES]){
        NSLog(@"无法创建存储文件夹，添加失败！");
        return NO;
    }
    
    EWFRInfo *existsInfo = [EWFRInfo fetchEWFRInfoWithIdentifier:ewfr.identifier inManagedObjectContext:self.appDelegateMOC];
    if (!existsInfo){
        EWFRInfo *newInfo = [EWFRInfo newEWFRInfoWithEWFR:ewfr inManagedObjectContext:self.appDelegateMOC];
        
        if (!newInfo){
            NSLog(@"创建EWFRInfo失败！");
            return NO;
        }
        
        if ([ewfr exportToMFRFile:[newInfo filePath]]){
            NSLog(@"足迹包 %@ 添加成功：\n%@",newInfo.title,[newInfo filePath]);
            return YES;
        }else{
             NSLog(@"足迹包 %@ 添加失败！",newInfo.title);
            [[EverywhereCoreDataManager appDelegateMOC] deleteObject:newInfo];
            [[EverywhereCoreDataManager appDelegateMOC] save:NULL];
            return NO;
        }
    }else{
        // 已经存在数据
        NSLog(@"已经存在相同的足迹包，添加失败！");
        return NO;
    }
}

+ (BOOL)removeEWFRInfo:(EWFRInfo *)ewfrInfo{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[ewfrInfo filePath]]){
        [self.appDelegateMOC deleteObject:ewfrInfo];
        [self.appDelegateMOC save:NULL];
        NSLog(@"足迹包文件不存在！");
        return YES;
    }
    
    NSError *removeError;
    if ([[NSFileManager defaultManager] removeItemAtPath:[ewfrInfo filePath] error:&removeError]){
        [self.appDelegateMOC deleteObject:ewfrInfo];
        [self.appDelegateMOC save:NULL];
        NSLog(@"足迹包移除成功");
        return YES;
    }else{
        NSLog(@"移除足迹包文件失败！");
        return NO;
    }
}

/*
+ (BOOL)removeEWFR:(EverywhereFootprintsRepository *)ewfr{
    EWFRInfo *ewfrInfo = [EWFRInfo fetchEWFRInfoWithIdentifier:ewfr.identifier inManagedObjectContext:self.appDelegateMOC];
    if (ewfrInfo){
        NSError *removeError;
        if ([[NSFileManager defaultManager] removeItemAtPath:[ewfrInfo filePath] error:&removeError]){
            [self.appDelegateMOC deleteObject:ewfrInfo];
            [self.appDelegateMOC save:NULL];
            NSLog(@"足迹包移除成功");
            return YES;
        }else{
            NSLog(@"移除足迹包文件失败！");
            return NO;
        }
    }else{
        NSLog(@"指定的足迹包不存在，移除失败！");
        return NO;
    }
}
*/

+ (NSArray <EWFRInfo *> *)allEWFRs{
    return [EWFRInfo fetchAllEWFRInfosInManagedObjectContext:self.appDelegateMOC];
}

+ (NSInteger)removeAllEWFRInfos{
    NSInteger succeededCount = 0;
    NSArray <EWFRInfo *> *allEWFRs = [self allEWFRs];
    
    for (int i = 0; i < allEWFRs.count; i++) {
        if ([self removeEWFRInfo:allEWFRs[i]]) succeededCount++;
    }
    
    return succeededCount;
}

+ (NSUInteger)exportFootprintsRepositoryToMFRFilesAtPath:(NSString *)directoryPath{
    /*
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:NULL]){
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    */
    
    if (![NSFileManager directoryExistsAtPath:directoryPath autoCreate:YES]) return 0;
    
    __block NSUInteger count = 0;
    
    for (EWFRInfo *ewfrInfo in [EverywhereCoreDataManager allEWFRs]) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:ewfrInfo.title];
        filePath = [filePath stringByAppendingString:@".mfr"];
        
        // 如果有重名文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            
            // 如果已经存在这个足迹包，跳出本次循环
            EverywhereFootprintsRepository *footprintsRepositoryFromExistsFile = [EverywhereFootprintsRepository importFromMFRFile:filePath];
            if ([EWFRInfo fetchEWFRInfoWithIdentifier:footprintsRepositoryFromExistsFile.identifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]]) continue;
            
            // 如果不存在，更改一个名称来存储
            NSString *newName = [NSString stringWithFormat:@"%@-%.0f",ewfrInfo.title,[[NSDate date] timeIntervalSinceReferenceDate]*1000];
            filePath = [directoryPath stringByAppendingPathComponent:newName];
            filePath = [filePath stringByAppendingString:@".mfr"];
        }
        
        if ([[NSFileManager defaultManager] copyItemAtPath:[ewfrInfo filePath] toPath:filePath error:NULL]){
            count++;
        }
        
    }
    
    return  count;
}

+ (NSUInteger)exportFootprintsRepositoryToGPXFilesAtPath:(NSString *)directoryPath{
    
    if (![NSFileManager directoryExistsAtPath:directoryPath autoCreate:YES]) return 0;
    
    __block NSUInteger count = 0;
    for (EWFRInfo *ewfrInfo in [EverywhereCoreDataManager allEWFRs]) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:ewfrInfo.title];
        filePath = [filePath stringByAppendingString:@".gpx"];
        
        // 如果有重名文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            
            // 如果已经存在这个足迹包，跳出本次循环
            EverywhereFootprintsRepository *footprintsRepositoryFromExistsFile = [EverywhereFootprintsRepository importFromGPXFile:filePath];
            if ([EWFRInfo fetchEWFRInfoWithIdentifier:footprintsRepositoryFromExistsFile.identifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]]) continue;
            
            // 如果不存在，更改一个名称来存储
            NSString *newName = [NSString stringWithFormat:@"%@-%.0f",ewfrInfo.title,[[NSDate date] timeIntervalSinceReferenceDate]*1000];
            filePath = [directoryPath stringByAppendingPathComponent:newName];
            filePath = [filePath stringByAppendingString:@".gpx"];
        }
        
        EverywhereFootprintsRepository *footprintsRepository = [EverywhereFootprintsRepository importFromMFRFile:[ewfrInfo filePath]];
        footprintsRepository.title = ewfrInfo.title;
        if ([footprintsRepository exportToGPXFile:filePath]){
            count++;
        }
        
    }
    
    return  count;
}

+ (NSUInteger)importFootprintsRepositoryFromFilesAtPath:(NSString *)directoryPath moveAddedFilesToPath:(NSString *)moveDirectoryPath{
    NSError *error;
    NSArray *fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    if (!fileNameArray){
        if(DEBUGMODE) NSLog(@"Error reading contents at path : %@\n%@",directoryPath,error.localizedFailureReason);
        return 0;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:moveDirectoryPath]){
        if (![[NSFileManager defaultManager] createDirectoryAtPath:moveDirectoryPath withIntermediateDirectories:NO attributes:nil error:NULL])
            moveDirectoryPath = nil;
    }
    
    NSUInteger count = 0;
    
    for (NSString *fileName in fileNameArray) {
        
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        NSString *pathExtension = [fileName pathExtension].lowercaseString;
        
        EverywhereFootprintsRepository *footprintsRepository;
        
        if ([pathExtension isEqualToString:@"mfr"])
            footprintsRepository = [EverywhereFootprintsRepository importFromMFRFile:filePath];
        else if ([pathExtension isEqualToString:@"gpx"])
            footprintsRepository = [EverywhereFootprintsRepository importFromGPXFile:filePath];
        
        if (footprintsRepository){
            
            if ([EverywhereCoreDataManager addEWFR:footprintsRepository]){
                count++;
            }
            
            if (moveDirectoryPath){
                // 移动已经导入的文件到指定文件夹
                NSString *moveFilePath = [moveDirectoryPath stringByAppendingPathComponent:fileName];
                NSError *moveError;
                [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:moveFilePath error:&moveError];
            }else{
                // 删除已经导入的文件
                NSError *removeError;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
                
            }
        }
    }
    
    return count;
}

@end
