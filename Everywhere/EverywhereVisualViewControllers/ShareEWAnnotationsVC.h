//
//  ShareEWAnnotationsVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereShareMKAnnotation.h"

@interface ShareEWAnnotationsVC : UIViewController

@property (strong,nonatomic) NSArray <EverywhereShareMKAnnotation *> *shareAnnos;
@property (strong,nonatomic) NSData *shareThumbData;
@property (assign,nonatomic) MapShowMode mapShowMode;
@property (assign,nonatomic) CLLocationDistance mergedDistanceForLocation;
@end
