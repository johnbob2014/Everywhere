//
//  EverywhereCoreDataManager.h
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreData;

@interface EverywhereCoreDataManager : NSObject

@property (strong,nonatomic) NSManagedObjectContext *appMOC;
//@property (assign,nonatomic) BOOL isFirstLoad;
@property (strong,nonatomic) NSDate *lastUpdateDate;

+ (instancetype)defaultManager;

@end
