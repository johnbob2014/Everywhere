//
//  EWFRInfo+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/8/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//


#import "EWFRInfo.h"
#import "EverywhereFootprintsRepository.h"

@interface EWFRInfo (Assistant)

- (NSString *)filePath;

+ (EWFRInfo *)fetchEWFRInfoWithIdentifier:(NSString *)ewfrID inManagedObjectContext:(NSManagedObjectContext *)context;
+ (EWFRInfo *)newEWFRInfoWithEWFR:(EverywhereFootprintsRepository *)ewfr inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray <EWFRInfo *> *)fetchAllEWFRInfosInManagedObjectContext:(NSManagedObjectContext *)context;

@end
