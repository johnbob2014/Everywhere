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

#import "PHAssetInfo.h"

#import "GCPhotoManager.h"

@interface EverywhereCoreDataManager()
@property (strong,nonatomic,readwrite) NSManagedObjectContext *appDelegateMOC;
@property (strong,nonatomic,readwrite) NSDate *lastUpdateDate;
@property (strong,nonatomic,readwrite) NSDate *secondLastUpdateDate;
@end

@implementation EverywhereCoreDataManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (NSManagedObjectContext *)appDelegateMOC{
    if (!_appDelegateMOC){
        EverywhereAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _appDelegateMOC = appDelegate.managedObjectContext;
    }
    return _appDelegateMOC;
}

- (NSDate *)lastUpdateDate{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateDate"];
}

- (void)setLastUpdateDate:(NSDate *)lastUpdateDate{
    [[NSUserDefaults standardUserDefaults] setValue:lastUpdateDate forKey:@"lastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)secondLastUpdateDate{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"secondLastUpdateDate"];
}

- (void)setSecondLastUpdateDate:(NSDate *)secondLastUpdateDate{
    [[NSUserDefaults standardUserDefaults] setValue:secondLastUpdateDate forKey:@"secondLastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - PHAssetInfo Data

- (NSInteger)updatePHAssetInfoFromPhotoLibrary{
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) return 0;
    
    NSInteger addedPHAssetInfoCount = 0;
    
    if (!self.lastUpdateDate) {
        // 首次加载照片数据
        addedPHAssetInfoCount = [self updateCoreDataFormStartDate:nil toEndDate:nil];
    }else{
        // 更新照片数据
        addedPHAssetInfoCount = [self updateCoreDataFormStartDate:self.lastUpdateDate toEndDate:nil];
        self.secondLastUpdateDate = self.lastUpdateDate;
    }
    
    // 更新刷新时间
    self.lastUpdateDate = [NSDate date];
    
    return addedPHAssetInfoCount;
}

- (NSInteger)updateCoreDataFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
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

- (BOOL)checkCoordinate:(CLLocationCoordinate2D)aCoord{
    
    if (aCoord.latitude > -90 && aCoord.latitude < 90) {
        if (aCoord.longitude > - 180 && aCoord.longitude < 180) {
            if (aCoord.latitude != 0 && aCoord.longitude != 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:(UpdatePlacemarkForPHAssetInfoCompletionBlock)completionBlock{
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:self.appDelegateMOC];
            
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

@end
