//
//  LocationPickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LocationDidChangeHandler)(NSString *choosedLocation);
typedef void(^LocationModeDidChangeHandler)(LocationMode choosedLocationMode);

@interface LocationPickerVC : UIViewController
@property (strong,nonatomic) NSDictionary <NSString *,NSArray <NSString *> *> *placemarkInfoDictionary;
@property (copy,nonatomic) LocationDidChangeHandler locationDidChangeHandler;
@property (copy,nonatomic) LocationModeDidChangeHandler locationModeDidChangeHandler;
@property (assign,nonatomic) LocationMode initLocationMode;
@end
