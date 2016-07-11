//
//  DatePickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DateRangeChangedHandler)(NSDate *choosedStartDate,NSDate *choosedEndDate);
typedef void(^DateModeChangedHandler)(DateMode choosedDateMode);

@interface DatePickerVC : UIViewController

@property (copy,nonatomic) DateRangeChangedHandler dateRangeChangedHandler;
@property (copy,nonatomic) DateModeChangedHandler dateModeChangedHandler;

@end
