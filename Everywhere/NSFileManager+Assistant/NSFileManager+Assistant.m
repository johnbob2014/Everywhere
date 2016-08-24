//
//  NSFileManager+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/8/24.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "NSFileManager+Assistant.h"

@implementation NSFileManager (Assistant)

+ (BOOL)directoryExistsAtPath:(NSString *)directoryPath autoCreate:(BOOL)autoCreate{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    
    BOOL exists;
    BOOL isDirectory;
    exists = [fm fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    
    if (exists && !isDirectory){
        if ([fm removeItemAtPath:directoryPath error:&error]){
            if (autoCreate) [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
    }
    
    if (!exists){
        if (autoCreate) [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    exists = [fm fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    
    if (exists && isDirectory) return YES;
    else return NO;
}

@end
