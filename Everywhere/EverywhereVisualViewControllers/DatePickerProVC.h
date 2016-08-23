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

@property (assign,nonatomic) DateMode dateMode;
@property (assign,nonatomic) FirstDayOfWeek firstDayOfWeek;

@property (copy,nonatomic) DateRangeChangedHandler dateRangeChangedHandler;
@property (copy,nonatomic) DateModeChangedHandler dateModeChangedHandler;

@end
