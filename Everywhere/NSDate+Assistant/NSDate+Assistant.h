//
//  NSDate+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/6/30.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FirstDayOfWeek) {
    FirstDayOfWeekIsSunday = 0,
    FirstDayOfWeekIsMonday = 1
};

static const NSTimeInterval TI_MINUTE;
static const NSTimeInterval TI_HOUR;
static const NSTimeInterval TI_DAY;
static const NSTimeInterval TI_WEEK;

@interface NSDate (Assistant)

- (BOOL)isSameDay:(NSDate *)aDate;
- (BOOL)isInSameWeek:(NSDate *)aDate;
- (BOOL)isInSameMonth:(NSDate *)aDate;
- (BOOL)isInSameYear:(NSDate *)aDate;

- (NSDate *) dateAtStartOfToday;
- (NSDate *) dateAtEndOfToday;
- (NSDate *) dateAtStartOfThisWeek:(enum FirstDayOfWeek)firstDayOfWeek;
- (NSDate *) dateAtEndOfThisWeek:(enum FirstDayOfWeek)firstDayOfWeek;
- (NSDate *) dateAtStartOfThisMonth;
- (NSDate *) dateAtEndOfThisMonth;
- (NSDate *) dateAtStartOfThisYear;
- (NSDate *) dateAtEndOfThisYear;

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

- (NSString *) stringWithDefaultFormat;
- (NSString *) stringWithFormat: (NSString *) format;
- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle;
+ (NSString *) localizedStringWithFormat:(NSString *)format startDate:(NSDate *)startDate endDate:(NSDate *)endDate firstDayOfWeek:(enum FirstDayOfWeek)firstDayOfWeek;

+ (NSDate *)dateFromGPXTimeString:(NSString *)timeString;
@end
