//
//  EverywhereShareRepositoryManager.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EverywhereShareRepository.h"

@interface EverywhereShareRepositoryManager : NSObject

+ (void)addShareRepository:(EverywhereShareRepository *)shareRepository;
+ (void)removeLastShareRepository;
+ (NSArray <EverywhereShareRepository *> *)shareRepositoryArray;

@end
