//
//  NSDate+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/6/30.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSTimeInterval TI_MINUTE;
static const NSTimeInterval TI_HOUR;
static const NSTimeInterval TI_DAY;
static const NSTimeInterval TI_WEEK;

@interface NSDate (Assistant)
- (NSDate *) dateAtStartOfToday;
- (NSDate *) dateAtEndOfToday;
- (NSDate *) dateAtStartOfThisWeek;
- (NSDate *) dateAtEndOfThisWeek;
- (NSDate *) dateAtStartOfThisMonth;
- (NSDate *) dateAtEndOfThisMonth;
- (NSDate *) dateAtStartOfThisYear;
- (NSDate *) dateAtEndOfThisYear;
- (NSString *) stringWithDefaultFormat;
- (NSString *) stringWithFormat: (NSString *) format;
- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle;

- (NSDate *) dateByAddingYears: (NSInteger) dYears;
- (NSDate *) dateBySubtractingYears: (NSInteger) dYears;
- (NSDate *) dateByAddingMonths: (NSInteger) dMonths;
- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths;
- (NSDate *) dateByAddingDays: (NSInteger) dDays;
- (NSDate *) dateBySubtractingDays: (NSInteger) dDays;
- (NSDate *) dateByAddingHours: (NSInteger) dHours;
- (NSDate *) dateBySubtractingHours: (NSInteger) dHours;
- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes;
- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes;
- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate;

@end
