//
//  EWFRInfo+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/8/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//


#import "EWFRInfo.h"
#import "FootprintsRepository.h"

@interface EWFRInfo (Assistant)

/**
 *  足迹包的存储文件路径
 */
- (NSString *)filePath;

/**
 *  获取 指定identifier 的 EWFRInfo实例
 */
+ (EWFRInfo *)fetchEWFRInfoWithIdentifier:(NSString *)ewfrID inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 *  根据 指定足迹包 创建新的 EWFRInfo实例 注意：足迹包文件不会自动保存！
 */
+ (EWFRInfo *)newEWFRInfoWithEWFR:(FootprintsRepository *)ewfr inManagedObjectContext:(NSManagedObjectContext *)context;

/**
 *  获取 全部 EWFRInfo实例
 */
+ (NSArray <EWFRInfo *> *)fetchAllEWFRInfosInManagedObjectContext:(NSManagedObjectContext *)context;

@end
