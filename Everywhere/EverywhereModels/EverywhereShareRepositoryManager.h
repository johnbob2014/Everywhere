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

+ (instancetype)defaultManager;
- (void)addshareRepository:(EverywhereShareRepository *)shareRepository;
- (NSArray <EverywhereShareRepository *> *)shareRepositoryArray;

@end
