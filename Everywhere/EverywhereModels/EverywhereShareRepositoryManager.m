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
    if (![EverywhereShareRepositoryManager shareRepositoryExists:shareRepository]){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shareRepository];
        NSMutableArray *tempMA = [EverywhereShareRepositoryManager shareRepositoryDataArray];
        [tempMA insertObject:data atIndex:0];
        [[NSUserDefaults standardUserDefaults] setValue:tempMA forKey:@"shareRepositoryDataArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSLog(@"addShareRepository error : duplicate shareRepository");
    }
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

+ (void)setShareRepositoryArray:(NSArray <EverywhereShareRepository *> *)shareRepositoryArray{
    NSMutableArray <NSData *> *ma = [NSMutableArray new];
    [shareRepositoryArray enumerateObjectsUsingBlock:^(EverywhereShareRepository * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        [ma addObject:data];
    }];
    
    [[NSUserDefaults standardUserDefaults] setValue:ma forKey:@"shareRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)exportShareRepositoryToFilesAtPath:(NSString *)directoryPath{
    __block NSUInteger count = 0;
    
    [[EverywhereShareRepositoryManager shareRepositoryDataArray] enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EverywhereShareRepository *shareRepository = (EverywhereShareRepository *)[NSKeyedUnarchiver unarchiveObjectWithData:obj];
        NSString *filePath = [directoryPath stringByAppendingPathComponent:shareRepository.title];
        filePath = [filePath stringByAppendingString:@".abf"];
        
        // 如果有重名文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
#warning fix here!
            NSString *newName = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"D.N.", @"重名"),shareRepository.title];
            filePath = [directoryPath stringByAppendingPathComponent:newName];
            filePath = [filePath stringByAppendingString:@".abf"];
        }
        
        if ([obj writeToFile:filePath atomically:YES]){
            count++;
        }
        
    }];
    
    return  count;
}

+ (NSUInteger)importShareRepositoryFromFilesAtPath:(NSString *)directoryPath{
    NSError *error;
    NSArray *fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    if (!fileNameArray){
        NSLog(@"Error reading contents at path : %@\n%@",directoryPath,error.localizedFailureReason);
        return 0;
    }
    
    NSMutableArray *tempMA = [EverywhereShareRepositoryManager shareRepositoryDataArray];
    //[tempMA insertObject:data atIndex:0];
    
    NSUInteger count = 0;
    
    for (NSString *fileName in fileNameArray) {
        //NSLog(@"fileName : %@",fileName);
        
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        
        if ([[filePath pathExtension] isEqualToString:@"abf"]){
            NSData *shareRepositoryData = [NSData dataWithContentsOfFile:filePath];
            EverywhereShareRepository *shareRepository = (EverywhereShareRepository *)[NSKeyedUnarchiver unarchiveObjectWithData:shareRepositoryData];
            
            if (shareRepository && ![EverywhereShareRepositoryManager shareRepositoryExists:shareRepository]){
                
                count++;
                
                [tempMA insertObject:shareRepositoryData atIndex:0];
                
                NSError *removeError;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];

            }
            
        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:tempMA forKey:@"shareRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return count;
}

+ (BOOL)shareRepositoryExists:(EverywhereShareRepository *)shareRepository{
    
    for (EverywhereShareRepository *obj in [EverywhereShareRepositoryManager shareRepositoryArray]) {
        if ([obj.title isEqualToString:shareRepository.title] && obj.shareAnnos.count == shareRepository.shareAnnos.count)
            return YES;
    }
    
    return NO;
}

@end
