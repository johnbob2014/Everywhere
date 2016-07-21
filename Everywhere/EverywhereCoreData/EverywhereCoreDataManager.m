//
//  EverywhereCoreDataManager.m
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereCoreDataManager.h"
#import "EverywhereAppDelegate.h"

#import "GCPhotoManager.h"

@interface EverywhereCoreDataManager()
@property (strong,nonatomic) GCPhotoManager *photoManager;
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

- (GCPhotoManager *)photoManager{
    if(!_photoManager){
        _photoManager = [GCPhotoManager defaultManager];
    }
    return _photoManager;
}

- (NSManagedObjectContext *)appMOC{
    if (!_appMOC){
        EverywhereAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _appMOC = appDelegate.managedObjectContext;
    }
    return _appMOC;
}

//@synthesize lastUpdateDate;

- (NSDate *)lastUpdateDate{
    NSDate *aDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateDate"];
    return aDate;
}

- (void)setLastUpdateDate:(NSDate *)aDate{
    //lastUpdateDate = aDate;
    [[NSUserDefaults standardUserDefaults] setValue:aDate forKey:@"lastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - PHAssetInfo Data

- (NSInteger)updatePHAssetInfoFromPhotoLibrary{
    if (!self.photoManager) return 0;
    
    NSInteger addedPHAssetInfoCount = 0;
    
    if (!self.lastUpdateDate) {
        // 首次加载照片数据
        addedPHAssetInfoCount = [self updateCoreDataFormStartDate:nil toEndDate:nil];
    }else{
        // 更新照片数据
        addedPHAssetInfoCount = [self updateCoreDataFormStartDate:self.lastUpdateDate toEndDate:nil];
    }
    
    // 更新刷新时间
    self.lastUpdateDate = [NSDate date];
    
    return addedPHAssetInfoCount;
}

- (NSInteger)updateCoreDataFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    NSDate *timeTest = [NSDate date];
    __block NSInteger addedPHAssetInfoCount = 0;
    
    NSDictionary *dic = [self.photoManager fetchAssetsFormStartDate:startDate toEndDate:endDate fromAssetCollectionIDs:@[self.photoManager.GCAssetCollectionID_UserLibrary]];
    NSArray <PHAsset *> *assetArray = dic[self.photoManager.GCAssetCollectionID_UserLibrary];
    
    [assetArray enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.location){
            if ([self checkCoordinate:obj.location.coordinate]) {
                
                PHAssetInfo *info = [PHAssetInfo newAssetInfoWithPHAsset:obj inManagedObjectContext:self.appMOC];
                addedPHAssetInfoCount++;
                NSLog(@"%@",info.localIdentifier);
            }
        }
    }];
    NSLog(@"从照片库更新照片数据 :\nAdd PHAssetInfo Count : %ld\n耗时 : %.3fs",(long)addedPHAssetInfoCount,[[NSDate date] timeIntervalSinceDate:timeTest]);
    return addedPHAssetInfoCount;
}

- (BOOL)checkCoordinate:(CLLocationCoordinate2D)aCoord{
    
    if (aCoord.latitude > -90 && aCoord.latitude < 90) {
        if (aCoord.longitude > - 180 && aCoord.longitude < 180) {
            return YES;
        }
    }
    
    return NO;
}

- (void)asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:(UpdatePlacemarkForPHAssetInfoCompletionBlock)completionBlock{
    @synchronized (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:self.appMOC];
            
            __block NSInteger reverseGeocodeFailedCountBeforeUpdate = 0;
            [allAssetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.reverseGeocodeSucceed boolValue]) {
                    reverseGeocodeFailedCountBeforeUpdate++;
                    [PHAssetInfo updatePlacemarkForAssetInfo:obj];
                    //NSLog(@"%@",NSStringFromCGPoint(CGPointMake([obj.latitude_Coordinate_Location doubleValue], [obj.longitude_Coordinate_Location doubleValue])));
                    [NSThread sleepForTimeInterval:1.0];
                }
            }];
            
            
            __block NSInteger reverseGeocodeFailedCountAfterUpdate = 0;
            [allAssetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj.reverseGeocodeSucceed boolValue]) {
                    reverseGeocodeFailedCountAfterUpdate++;
                    [PHAssetInfo updatePlacemarkForAssetInfo:obj];
                    //NSLog(@"%@",NSStringFromCGPoint(CGPointMake([obj.latitude_Coordinate_Location doubleValue], [obj.longitude_Coordinate_Location doubleValue])));
                    [NSThread sleepForTimeInterval:1.0];
                }
            }];
            
            NSInteger totalPHAssetInfoCount = allAssetInfoArray.count;
            NSInteger reverseGeocodeSucceedCountForThisTime = reverseGeocodeFailedCountBeforeUpdate - reverseGeocodeFailedCountAfterUpdate;
            NSInteger reverseGeocodeSucceedCountForTotal = totalPHAssetInfoCount - reverseGeocodeFailedCountAfterUpdate;
            
            NSLog(@"解析照片信息 :\n本次解析成功 : %lu\n总成功数 : %lu\n总照片数 : %lu",(long)reverseGeocodeSucceedCountForThisTime,(long)reverseGeocodeSucceedCountForTotal,(long)totalPHAssetInfoCount);
            
            if(completionBlock) completionBlock(reverseGeocodeSucceedCountForThisTime,reverseGeocodeSucceedCountForTotal,totalPHAssetInfoCount);
        });
    }
}

#pragma mark - CoordInfo Data

@end
