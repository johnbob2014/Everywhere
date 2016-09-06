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

/**
 *  必须，要显示的地址信息字典
 *  字典键为 国家、省、市、县区、村镇 5个，值为对应的字符串数组
 */
@property (strong,nonatomic) NSDictionary <NSString *,NSArray <NSString *> *> *placemarkInfoDictionary;

/**
 *  初始地址模式
 */
@property (assign,nonatomic) LocationMode initLocationMode;

/**
 *  传送用户选择的地址
 */
@property (copy,nonatomic) LocationDidChangeHandler locationDidChangeHandler;

/**
 *  传送用户选择的地址模式
 */
@property (copy,nonatomic) LocationModeDidChangeHandler locationModeDidChangeHandler;

@end
