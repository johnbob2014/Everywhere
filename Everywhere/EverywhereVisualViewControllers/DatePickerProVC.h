//
//  DatePickerProVC.h
//  Everywhere
//
//  Created by BobZhang on 16/8/16.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DatePickerCustomStartDate @"DatePickerCustomStartDate"
#define DatePickerCustomEndDate @"DatePickerCustomEndDate"

typedef void(^DateRangeChangedHandler)(NSDate *choosedStartDate,NSDate *choosedEndDate);
typedef void(^DateModeChangedHandler)(DateMode choosedDateMode);

@interface DatePickerProVC : UIViewController

/**
 *  日期模式
 */
@property (assign,nonatomic) DateMode dateMode;

/**
 *  每周第一天是 星期日 还是 星期一
 */
@property (assign,nonatomic) FirstDayOfWeek firstDayOfWeek;

/**
 *  传送用户选择的开始、结束日期
 */
@property (copy,nonatomic) DateRangeChangedHandler dateRangeChangedHandler;

/**
 *  传送用户选择的日期模式
 */
@property (copy,nonatomic) DateModeChangedHandler dateModeChangedHandler;

@end
