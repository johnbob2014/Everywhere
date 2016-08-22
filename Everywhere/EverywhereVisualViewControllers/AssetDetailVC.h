//
//  AssetDetailVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/6.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereAnnotation.h"

@interface AssetDetailVC : UIViewController
//@property (strong,nonatomic) EverywhereAnnotation *ewAnnotation;
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;
@end
