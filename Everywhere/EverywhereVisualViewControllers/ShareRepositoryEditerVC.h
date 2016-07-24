//
//  ShareRepositoryEditerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereShareRepository.h"

typedef void(^ShareRepositoryDidChangeHandler)(EverywhereShareRepository *changedShareRepository);

@interface ShareRepositoryEditerVC : UIViewController
@property (strong,nonatomic) EverywhereShareRepository *shareRepository;
@property (copy,nonatomic) ShareRepositoryDidChangeHandler shareRepositoryDidChangeHandler;
@end
