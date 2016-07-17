//
//  EverywhereShareRepositoryManager.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereShareRepositoryManager.h"


@interface EverywhereShareRepositoryManager ()
@property (strong,nonatomic) NSMutableArray <NSData *> *shareRepositoryDataArray;
@end

@implementation EverywhereShareRepositoryManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (NSMutableArray<NSData *> *)shareRepositoryDataArray{
    if(!_shareRepositoryDataArray){
        NSArray *tempArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"shareRepositoryDataArray"];
        if (tempArray) {
            _shareRepositoryDataArray = [NSMutableArray arrayWithArray:tempArray];
        }
        if (!_shareRepositoryDataArray) {
            _shareRepositoryDataArray = [NSMutableArray new];
        }
    }
    return _shareRepositoryDataArray;
}


- (void)addshareRepository:(EverywhereShareRepository *)shareRepository{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shareRepository];
    [self.shareRepositoryDataArray addObject:data];
    [[NSUserDefaults standardUserDefaults] setValue:self.shareRepositoryDataArray forKey:@"shareRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray <EverywhereShareRepository *> *)shareRepositoryArray{
    NSMutableArray *ma = [NSMutableArray new];
    [self.shareRepositoryDataArray enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EverywhereShareRepository *shareRepository = (EverywhereShareRepository *)[NSKeyedUnarchiver unarchiveObjectWithData:obj];
        [ma addObject:shareRepository];
    }];
    return ma;
}

@end
