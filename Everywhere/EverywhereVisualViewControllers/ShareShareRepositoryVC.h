//
//  ShareShareRepositoryVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereShareRepository.h"

@interface ShareShareRepositoryVC : UIViewController

@property (strong,nonatomic) EverywhereShareRepository *shareRepository;

@property (strong,nonatomic) NSData *shareThumbImageData;

@end
