//
//  EverywhereShareRepositoryManager.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereShareRepositoryManager.h"


@interface EverywhereShareRepositoryManager ()
//@property (strong,nonatomic) NSMutableArray <NSData *> *shareRepositoryDataArray;
@end

@implementation EverywhereShareRepositoryManager

/*
+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}
*/

+ (NSMutableArray<NSData *> *)shareRepositoryDataArray{
    NSMutableArray <NSData *> *shareRepositoryDataArray = nil;
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"shareRepositoryDataArray"];
    if (tempArray) shareRepositoryDataArray = [NSMutableArray arrayWithArray:tempArray];
    if (!shareRepositoryDataArray)  shareRepositoryDataArray = [NSMutableArray new];
    return shareRepositoryDataArray;
}

/*
+ (void)save{
    [[NSUserDefaults standardUserDefaults] setValue:[EverywhereShareRepositoryManager shareRepositoryDataArray] forKey:@"shareRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
 */


+ (void)addShareRepository:(EverywhereShareRepository *)shareRepository{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shareRepository];
    NSMutableArray *tempMA = [EverywhereShareRepositoryManager shareRepositoryDataArray];
    [tempMA insertObject:data atIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:tempMA forKey:@"shareRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeLastAddedShareRepository{
    NSMutableArray *tempMA = [EverywhereShareRepositoryManager shareRepositoryDataArray];
    [tempMA removeObjectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:tempMA forKey:@"shareRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray <EverywhereShareRepository *> *)shareRepositoryArray{
    NSMutableArray <EverywhereShareRepository *> *ma = [NSMutableArray new];
    [[EverywhereShareRepositoryManager shareRepositoryDataArray] enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EverywhereShareRepository *shareRepository = (EverywhereShareRepository *)[NSKeyedUnarchiver unarchiveObjectWithData:obj];
        [ma addObject:shareRepository];
    }];
    return ma;
}

@end
