//
//  NSURL+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/8/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "NSURL+Assistant.h"

@implementation NSURL (Assistant)

+ (NSURL *)documentURL{
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

+ (NSURL *)inboxURL{
    return [[NSURL documentURL] URLByAppendingPathComponent:@"Inbox"];
}

+ (NSURL *)libraryURL{
    return [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].lastObject;
}

+ (NSURL *)cachesURL{
    return [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask].lastObject;
}

@end
