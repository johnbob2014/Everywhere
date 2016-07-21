//
//  NSDate+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/6/30.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "NSDate+Assistant.h"

static const NSTimeInterval TI_MINUTE = 60;
static const NSTimeInterval TI_HOUR = 3600;
//static const NSTimeInterval TI_DAY = 86400;
//static const NSTimeInterval TI_WEEK = 604800;

static const NSInteger BIG_MONTH[7] = {1,3,5,7,8,10,12};

@implementation NSDate (Assistant)

+ (NSCalendar *) currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

- (NSInteger) daysOfThisMonth{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self];
    BOOL isBigMonth = NO;
    for (int i = 0; i < 7; i++) {
        if ( components.month == BIG_MONTH[i]) isBigMonth = YES;
    }
    
    NSInteger days;
    
    if (isBigMonth) {
        days = 31;
    }else if (components.month != 2){
        days = 30;
    }else if (components.year%4 == 0){
        days = 29;
    }else{
        days = 28;
    }
    
    return days;
}

#pragma mark - Comparing Dates

- (BOOL)isSameDay:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

- (BOOL)isInSameWeek:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.weekOfYear == components2.weekOfYear));
}

- (BOOL)isInSameMonth:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:aDate];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month));
}

- (BOOL)isInSameYear:(NSDate *)aDate
{
    NSDateComponents *components1 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *components2 = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:aDate];
    return (components1.year == components2.year);
}

#pragma mark - Adjusting Dates

// Thaks, rsjohnson
- (NSDate *) dateByAddingYears: (NSInteger) dYears
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:dYears];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingYears: (NSInteger) dYears
{
    return [self dateByAddingYears:-dYears];
}

- (NSDate *) dateByAddingMonths: (NSInteger) dMonths
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:dMonths];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingMonths: (NSInteger) dMonths
{
    return [self dateByAddingMonths:-dMonths];
}

// Courtesy of dedan who mentions issues with Daylight Savings
- (NSDate *) dateByAddingDays: (NSInteger) dDays
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:dDays];
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:self options:0];
    return newDate;
}

- (NSDate *) dateBySubtractingDays: (NSInteger) dDays
{
    return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *) dateByAddingHours: (NSInteger) dHours
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + TI_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingHours: (NSInteger) dHours
{
    return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *) dateByAddingMinutes: (NSInteger) dMinutes
{
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + TI_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

- (NSDate *) dateBySubtractingMinutes: (NSInteger) dMinutes
{
    return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDateComponents *) componentsWithOffsetFromDate: (NSDate *) aDate
{
    NSDateComponents *dTime = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:aDate toDate:self options:0];
    return dTime;
}

#pragma mark - Extremes

- (NSDate *) dateAtStartOfToday{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *) dateAtEndOfToday{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.hour = 23; // Thanks Aleksey Kononov
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *) dateAtStartOfThisWeek{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    NSDate *monday = [self dateBySubtractingDays:components.weekday - 1];
    return [monday dateAtStartOfToday];
}

- (NSDate *) dateAtEndOfThisWeek{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    NSDate *monday = [self dateByAddingDays:7 - components.weekday];
    return [monday dateAtEndOfToday];
}

- (NSDate *) dateAtStartOfThisMonth{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self];
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *) dateAtEndOfThisMonth{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self];
    components.day = [self daysOfThisMonth];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *) dateAtStartOfThisYear{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    components.month = 1;
    components.day = 1;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *) dateAtEndOfThisYear{
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear fromDate:self];
    components.month = 12;
    components.day = 31;
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

#pragma mark - String Properties
- (NSString *) stringWithDefaultFormat{
    return [self stringWithFormat:@"yyyy-MM-dd hh:mm:ss"];
}

- (NSString *) stringWithFormat: (NSString *) format
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *) stringWithDateStyle: (NSDateFormatterStyle) dateStyle timeStyle: (NSDateFormatterStyle) timeStyle
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    //    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

+ (NSString *)localizedStringWithFormat:(NSString *)format startDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if (!startDate || !endDate) return nil;
    if ([startDate isSameDay:endDate]){
        if ([startDate isSameDay:[NSDate date]]) return NSLocalizedString(@"Today", @"今天");
        else return [startDate stringWithFormat:format];
    }
    if ([startDate isInSameWeek:endDate]) {
        if ([startDate isSameDay:[startDate dateAtStartOfThisWeek]]) {
            if ([endDate isSameDay:[endDate dateAtEndOfThisWeek]]) {
                if ([startDate isInSameWeek:[NSDate date]]) return NSLocalizedString(@"This Week", @"本周");
            }
        }
    }
    if ([startDate isInSameMonth:endDate]) {
        if ([startDate isSameDay:[startDate dateAtStartOfThisMonth]]) {
            if ([endDate isSameDay:[endDate dateAtEndOfThisMonth]]) {
                if ([startDate isInSameMonth:[NSDate date]]) return NSLocalizedString(@"This Month", @"本月");
                else return [startDate stringWithFormat:@"yyyy-MM"];
            }
        }
    }
    if ([startDate isInSameYear:endDate]) {
        if ([startDate isSameDay:[startDate dateAtStartOfThisYear]]) {
            if ([endDate isSameDay:[endDate dateAtEndOfThisYear]]) {
                if ([startDate isInSameYear:[NSDate date]]) return NSLocalizedString(@"This Year", @"今年");
                else return [startDate stringWithFormat:@"yyyy"];
            }
        }
    }
    NSMutableString *ms = [NSMutableString new];
    //[ms appendString:NSLocalizedString(@"From ", @"从 ")];
    [ms appendString:[startDate stringWithFormat:format]];
    [ms appendString:@" ~ "];//NSLocalizedString(@" To ", @" 到 ")];
    [ms appendString:[endDate stringWithFormat:format]];
    return ms;
}
@end
