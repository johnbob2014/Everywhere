//
//  EverywhereFootprintsRepositoryManager.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereFootprintsRepositoryManager.h"


@interface EverywhereFootprintsRepositoryManager ()
//@property (strong,nonatomic) NSMutableArray <NSData *> *footprintsRepositoryDataArray;
@end

@implementation EverywhereFootprintsRepositoryManager

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

+ (NSMutableArray<NSData *> *)footprintsRepositoryDataArray{
    NSMutableArray <NSData *> *footprintsRepositoryDataArray = nil;
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"footprintsRepositoryDataArray"];
    if (tempArray) footprintsRepositoryDataArray = [NSMutableArray arrayWithArray:tempArray];
    if (!footprintsRepositoryDataArray)  footprintsRepositoryDataArray = [NSMutableArray new];
    return footprintsRepositoryDataArray;
}

/*
+ (void)save{
    [[NSUserDefaults standardUserDefaults] setValue:[EverywhereFootprintsRepositoryManager footprintsRepositoryDataArray] forKey:@"footprintsRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
 */


+ (void)addFootprintsRepository:(EverywhereFootprintsRepository *)footprintsRepository{
    if (![EverywhereFootprintsRepositoryManager footprintsRepositoryExists:footprintsRepository]){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:footprintsRepository];
        NSMutableArray *tempMA = [EverywhereFootprintsRepositoryManager footprintsRepositoryDataArray];
        [tempMA insertObject:data atIndex:0];
        [[NSUserDefaults standardUserDefaults] setValue:tempMA forKey:@"footprintsRepositoryDataArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSLog(@"addFootprintsRepository error : duplicate footprintsRepository");
    }
}

+ (void)removeLastAddedFootprintsRepository{
    NSMutableArray *tempMA = [EverywhereFootprintsRepositoryManager footprintsRepositoryDataArray];
    [tempMA removeObjectAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setValue:tempMA forKey:@"footprintsRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray <EverywhereFootprintsRepository *> *)footprintsRepositoryArray{
    NSMutableArray <EverywhereFootprintsRepository *> *ma = [NSMutableArray new];
    [[EverywhereFootprintsRepositoryManager footprintsRepositoryDataArray] enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EverywhereFootprintsRepository *footprintsRepository = (EverywhereFootprintsRepository *)[NSKeyedUnarchiver unarchiveObjectWithData:obj];
        [ma addObject:footprintsRepository];
    }];
    return ma;
}

+ (void)setFootprintsRepositoryArray:(NSArray <EverywhereFootprintsRepository *> *)footprintsRepositoryArray{
    NSMutableArray <NSData *> *ma = [NSMutableArray new];
    [footprintsRepositoryArray enumerateObjectsUsingBlock:^(EverywhereFootprintsRepository * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
        [ma addObject:data];
    }];
    
    [[NSUserDefaults standardUserDefaults] setValue:ma forKey:@"footprintsRepositoryDataArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)exportFootprintsRepositoryToMFRFilesAtPath:(NSString *)directoryPath{
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:NULL]){
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    __block NSUInteger count = 0;
    
    for (EverywhereFootprintsRepository *footprintsRepository in [EverywhereFootprintsRepositoryManager footprintsRepositoryArray]) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:footprintsRepository.title];
        filePath = [filePath stringByAppendingString:@".mfr"];
        
        // 如果有重名文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            
            // 如果已经存在这个足迹包，跳出本次循环
            EverywhereFootprintsRepository *footprintsRepositoryFromExistsFile = [EverywhereFootprintsRepository importFromMFRFile:filePath];
            if ([EverywhereFootprintsRepositoryManager footprintsRepositoryExists:footprintsRepositoryFromExistsFile]) continue;
            
            // 如果不存在，更改一个名称来存储
            NSString *newName = [NSString stringWithFormat:@"%@(%@%.0f)",footprintsRepository.title,NSLocalizedString(@"Exported", @"导出"),[[NSDate date] timeIntervalSinceReferenceDate]*10000];
            filePath = [directoryPath stringByAppendingPathComponent:newName];
            filePath = [filePath stringByAppendingString:@".mfr"];
        }
        
        if ([footprintsRepository exportToMFRFile:filePath]){
            count++;
        }

    }
    
    return  count;
}

+ (NSUInteger)exportFootprintsRepositoryToGPXFilesAtPath:(NSString *)directoryPath{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:NULL]){
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    __block NSUInteger count = 0;
    for (EverywhereFootprintsRepository *footprintsRepository in [EverywhereFootprintsRepositoryManager footprintsRepositoryArray]) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:footprintsRepository.title];
        filePath = [filePath stringByAppendingString:@".gpx"];
        
        // 如果有重名文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            
            // 如果已经存在这个足迹包，跳出本次循环
            EverywhereFootprintsRepository *footprintsRepositoryFromExistsFile = [EverywhereFootprintsRepository importFromGPXFile:filePath];
            if ([EverywhereFootprintsRepositoryManager footprintsRepositoryExists:footprintsRepositoryFromExistsFile]) continue;
            
            // 如果不存在，更改一个名称来存储
            NSString *newName = [NSString stringWithFormat:@"%@(%@%.0f)",footprintsRepository.title,NSLocalizedString(@"Exported", @"导出"),[[NSDate date] timeIntervalSinceReferenceDate]*10000];
            filePath = [directoryPath stringByAppendingPathComponent:newName];
            filePath = [filePath stringByAppendingString:@".gpx"];
        }
        
        if ([footprintsRepository exportToGPXFile:filePath]){
            count++;
        }
        
    }
    
    return  count;
}

+ (NSArray <EverywhereFootprintsRepository *> *)importFootprintsRepositoryFromFilesAtPath:(NSString *)directoryPath{
    NSError *error;
    NSArray *fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    if (!fileNameArray){
        NSLog(@"Error reading contents at path : %@\n%@",directoryPath,error.localizedFailureReason);
        return nil;
    }
    
    NSMutableArray <EverywhereFootprintsRepository *> *tempMA = [NSMutableArray new];
    
    NSUInteger count = 0;
    
    for (NSString *fileName in fileNameArray) {
        
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        NSString *pathExtension = [fileName pathExtension].lowercaseString;
        
        EverywhereFootprintsRepository *footprintsRepository;
        
        if ([pathExtension isEqualToString:@"mfr"])
            footprintsRepository = [EverywhereFootprintsRepository importFromMFRFile:filePath];
        else if ([pathExtension isEqualToString:@"gpx"])
            footprintsRepository = [EverywhereFootprintsRepository importFromGPXFile:filePath];
        
        if (footprintsRepository && ![EverywhereFootprintsRepositoryManager footprintsRepositoryExists:footprintsRepository]){
            count++;
            [tempMA insertObject:footprintsRepository atIndex:0];
            
            // 删除已经导入的文件
            NSError *removeError;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
        }
    }
   
    return tempMA;
}

+ (BOOL)footprintsRepositoryExists:(EverywhereFootprintsRepository *)footprintsRepository{
    
    for (EverywhereFootprintsRepository *obj in [EverywhereFootprintsRepositoryManager footprintsRepositoryArray]) {
        if ([obj.title isEqualToString:footprintsRepository.title] && obj.footprintAnnotations.count == footprintsRepository.footprintAnnotations.count)
            return YES;
    }
    
    return NO;
}

+ (NSUInteger)clearFootprintsRepositoryFilesAtPath:(NSString *)directoryPath{
    NSError *error;
    NSArray *fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
    
    if (!fileNameArray){
        NSLog(@"Error reading contents at path : %@\n%@",directoryPath,error.localizedFailureReason);
        return 0;
    }
    
    NSUInteger count = 0;
    
    for (NSString *fileName in fileNameArray) {
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        
        if ([[filePath pathExtension] isEqualToString:@"mfr"]){
            NSError *removeError;
            if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError]) count++;
            else NSLog(@"remove %@ error : %@",[filePath lastPathComponent],removeError.localizedDescription);
        }
    }
    
    return count;
}
@end
