//
//  AssetsMapProVC.h
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

typedef NS_ENUM(NSInteger, MapShowMode) {
    MapShowModeMoment = 0,      // 时刻模式
    MapShowModeLocation         // 地点模式
};

typedef NS_ENUM(NSInteger, DateMode) {
    DateModeDay = 0,
    DateModeWeek,
    DateModeMonth,
    DateModeYear,
    DateModeAll,
    DateModeRange
};

@interface AssetsMapProVC : UIViewController

@end
