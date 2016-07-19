//
//  ShareRepositoryPickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereShareRepository.h"

typedef void(^ShareRepositoryDidChangeHandler)(EverywhereShareRepository *choosedShareRepository);

@interface ShareRepositoryPickerVC : UIViewController

//@property (strong,nonatomic) NSArray <EverywhereShareRepository *> *shareRepositoryArray;
@property (copy,nonatomic) ShareRepositoryDidChangeHandler shareRepositoryDidChangeHandler;

@end
