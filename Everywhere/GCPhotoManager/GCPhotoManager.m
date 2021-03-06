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

@implementation GCPhotoManager

/*
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
            
            instance = nil;
        }else if (authorizationStatus == PHAuthorizationStatusDenied || authorizationStatus == PHAuthorizationStatusRestricted){
            if(DEBUGMODE) NSLog(@"无法访问相册");
            instance = nil;
        }
    });
    
    return instance;
}
*/

+ (NSString *)GCAssetCollectionID_UserLibrary{
    if (Authorized == NO) return nil;
    
    PHFetchResult <PHAssetCollection *> *fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    return fetchResultArray.firstObject.localIdentifier;
}

+ (NSArray <NSString *> *)GCAssetCollectionIDs_Album{
    if (Authorized == NO) return nil;
    
    NSMutableArray <NSString *> *ma = [NSMutableArray new];
    PHFetchResult <PHAssetCollection *> *fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    [fetchResultArray enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.localIdentifier) [ma addObject:obj.localIdentifier];
    }];
    return ma;
}

#pragma mark - Fetch by Date

+ (NSDictionary <NSString *,NSArray *> *)fetchAssetIDsFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate fromAssetCollectionIDs:(NSArray <NSString *> *)assetCollectionIDs{
    if (Authorized == NO) return nil;
    PHFetchOptions *assetOptions = [PHFetchOptions new];
   
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
    //if(DEBUGMODE) NSLog(@"%@",mDic);
    return mDic;
}

+ (NSDictionary <NSString *,NSArray *> *)fetchAssetsFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate fromAssetCollectionIDs:(NSArray <NSString *> *)assetCollectionIDs{
    if (Authorized == NO) return nil;
    PHFetchOptions *assetOptions = [PHFetchOptions new];
    
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
    //if(DEBUGMODE) NSLog(@"%@",mDic);
    return mDic;
}

@end
