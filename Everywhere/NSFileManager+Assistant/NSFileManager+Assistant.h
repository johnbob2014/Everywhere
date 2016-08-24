//
//  NSFileManager+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/8/24.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Assistant)

+ (BOOL)directoryExistsAtPath:(NSString *)directoryPath autoCreate:(BOOL)autoCreate;

@end
