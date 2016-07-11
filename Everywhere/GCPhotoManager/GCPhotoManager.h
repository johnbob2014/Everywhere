//
//  GCPhotoManager.h
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCPhotoManager : NSObject

@property (strong,nonatomic) NSString *GCAssetCollectionID_UserLibrary;
@property (nonatomic,strong) NSArray <NSString *> *GCAssetCollectionIDs_Album;

+ (instancetype)defaultManager;

/**
 获取 assetCollectionID : assetIDArray 字典
 */
- (NSDictionary <NSString *,NSArray *> *)fetchAssetIDsFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate fromAssetCollectionIDs:(NSArray <NSString *> *)assetCollectionIDs;

/**
 获取 assetCollectionID : assetArray 字典
 */
- (NSDictionary <NSString *,NSArray *> *)fetchAssetsFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate fromAssetCollectionIDs:(NSArray <NSString *> *)assetCollectionIDs;

@end