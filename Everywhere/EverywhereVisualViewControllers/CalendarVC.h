//
//  CalendarVC.h
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CalendarWillDisappear)(NSDate *choosedStartDate,NSDate *choosedEndDate);

@interface CalendarVC : UIViewController

@property (copy,nonatomic) CalendarWillDisappear calendarWillDisappear;

@end
