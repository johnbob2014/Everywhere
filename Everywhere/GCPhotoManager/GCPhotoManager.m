//
//  GCPhotoManager.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCPhotoManager.h"
#import "NSDate+Assistant.h"

#define Authorized [PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized

@import Photos;

@interface GCPhotoManager()

@end

@implementation GCPhotoManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            
            //__block BOOL authorized = NO;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                //authorized = status == PHAuthorizationStatusAuthorized;
            }];
            /*
            while (!authorized) {
                [NSThread sleepForTimeInterval:1.0];
            }
             */
            instance = nil;
        }else if (authorizationStatus == PHAuthorizationStatusDenied || authorizationStatus == PHAuthorizationStatusRestricted){
            NSLog(@"无法访问相册");
            instance = nil;
        }
    });
    return instance;
}

-(instancetype)init{
    self=[super init];
    if (self) {
        //code here
    }
    return self;
}

- (NSString *)GCAssetCollectionID_UserLibrary{
    if (Authorized == NO) return nil;
    
    if (!_GCAssetCollectionID_UserLibrary) {
        PHFetchResult <PHAssetCollection *> *fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        _GCAssetCollectionID_UserLibrary = fetchResultArray.firstObject.localIdentifier;
    }
    return _GCAssetCollectionID_UserLibrary;
}

- (NSArray <NSString *> *)GCAssetCollectionIDs_Album{
    if (Authorized == NO) return nil;
    if (!_GCAssetCollectionIDs_Album) {
        NSMutableArray <NSString *> *ma = [NSMutableArray new];
        PHFetchResult <PHAssetCollection *> *fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [fetchResultArray enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.localIdentifier) [ma addObject:obj.localIdentifier];
        }];
        _GCAssetCollectionIDs_Album = [NSArray arrayWithArray:ma];
    }
    return _GCAssetCollectionIDs_Album;
}

#pragma mark - Fetch by Date

- (NSDictionary <NSString *,NSArray *> *)fetchAssetIDsFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate fromAssetCollectionIDs:(NSArray <NSString *> *)assetCollectionIDs{
    if (Authorized == NO) return nil;
    PHFetchOptions *assetOptions = [PHFetchOptions new];
    //startDate = [startDate dateAtStartOfToday];
    //endDate = [endDate dateAtEndOfToday];
    //NSString *predicateFormat = nil;
    if (startDate && endDate) {
        assetOptions.predicate = [NSPredicate predicateWithFormat:@" (creationDate >= %@) && (creationDate <= %@)",startDate,endDate];
    }else if (startDate) {
        assetOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@",startDate];
    }else if (endDate){
        assetOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate <= %@",endDate];
    }
    assetOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchOptions *assetCollectionOptions = [PHFetchOptions new];
    assetCollectionOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
    PHFetchResult <PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:assetCollectionIDs options:assetCollectionOptions];
    
    NSMutableDictionary <NSString *,NSArray *> *mDic = [NSMutableDictionary new];
    
    for (PHAssetCollection *assetCollection in fetchResult) {
        
        PHFetchResult <PHAsset *> *assetArray = [PHAsset fetchAssetsInAssetCollection:assetCollection options:assetOptions];
        NSMutableArray <NSString *> *assetIDArray = [NSMutableArray new];
        [assetArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.localIdentifier) [assetIDArray addObject:obj.localIdentifier];
        }];
        NSString *key = assetCollection.localIdentifier;
        if (key) [mDic setValue:assetIDArray forKey:key];
    }
    //NSLog(@"%@",mDic);
    return mDic;
}

- (NSDictionary <NSString *,NSArray *> *)fetchAssetsFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate fromAssetCollectionIDs:(NSArray <NSString *> *)assetCollectionIDs{
    if (Authorized == NO) return nil;
    PHFetchOptions *assetOptions = [PHFetchOptions new];
    //startDate = [startDate dateAtStartOfToday];
    //endDate = [endDate dateAtEndOfToday];
    //NSString *predicateFormat = nil;
    if (startDate && endDate) {
        assetOptions.predicate = [NSPredicate predicateWithFormat:@" (creationDate >= %@) && (creationDate <= %@)",startDate,endDate];
    }else if (startDate) {
        assetOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate >= %@",startDate];
    }else if (endDate){
        assetOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate <= %@",endDate];
    }
    assetOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchOptions *assetCollectionOptions = [PHFetchOptions new];
    assetCollectionOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES]];
    PHFetchResult <PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:assetCollectionIDs options:assetCollectionOptions];
    
    NSMutableDictionary <NSString *,NSArray *> *mDic = [NSMutableDictionary new];
    
    for (PHAssetCollection *assetCollection in fetchResult) {
        
        PHFetchResult <PHAsset *> *assetArray = [PHAsset fetchAssetsInAssetCollection:assetCollection options:assetOptions];
        NSString *key = assetCollection.localIdentifier;
        if (key) [mDic setValue:(NSArray *)assetArray forKey:key];
    }
    //NSLog(@"%@",mDic);
    return mDic;
}

/*
- (NSArray <NSString *> *)fetchToday:(NSDate *)today fromAssetCollection:(PHAssetCollection *)assetCollection{
    return [self fetchAssetLocalIdentifiersFormStartDate:today toEndDate:today fromAssetCollection:assetCollection];
}

- (NSArray <NSString *> *)fetchMonth:(NSDate *)oneDayInThisMonth fromAssetCollection:(PHAssetCollection *)assetCollection{
    return [self fetchAssetLocalIdentifiersFormStartDate:[oneDayInThisMonth dateAtStartOfThisMonth] toEndDate:[oneDayInThisMonth dateAtEndOfThisMonth] fromAssetCollection:assetCollection];
}

- (NSArray <NSString *> *)fetchYear:(NSDate *)oneDayInThisYear fromAssetCollection:(PHAssetCollection *)assetCollection{
    return [self fetchAssetLocalIdentifiersFormStartDate:[oneDayInThisYear dateAtStartOfThisYear] toEndDate:[oneDayInThisYear dateAtEndOfThisYear] fromAssetCollection:assetCollection];
}
 */

@end
