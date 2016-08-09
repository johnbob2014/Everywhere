//
//  EverywhereFootprintsRepositoryManager.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EverywhereFootprintsRepository.h"

@interface EverywhereFootprintsRepositoryManager : NSObject

+ (void)addFootprintsRepository:(EverywhereFootprintsRepository *)footprintsRepository;
+ (void)removeLastAddedFootprintsRepository;
+ (NSArray <EverywhereFootprintsRepository *> *)footprintsRepositoryArray;
+ (void)setFootprintsRepositoryArray:(NSArray <EverywhereFootprintsRepository *> *)footprintsRepositoryArray;

+ (BOOL)footprintsRepositoryExists:(EverywhereFootprintsRepository *)footprintsRepository;

+ (NSUInteger)exportFootprintsRepositoryToFilesAtPath:(NSString *)directoryPath;
+ (NSArray <EverywhereFootprintsRepository *> *)importFootprintsRepositoryFromFilesAtPath:(NSString *)directoryPath;

+ (NSUInteger)clearFootprintsRepositoryFilesAtPath:(NSString *)directoryPath;

@end