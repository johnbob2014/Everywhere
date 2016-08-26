//
//  NSURL+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/8/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Assistant)

+ (NSURL *)documentURL;
+ (NSURL *)inboxURL;
+ (NSURL *)libraryURL;
+ (NSURL *)cachesURL;

@end
