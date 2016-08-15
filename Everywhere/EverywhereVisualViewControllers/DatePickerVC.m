//
//  DatePickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "DatePickerVC.h"
#import <JTCalendar.h>
#import "EverywhereSettingManager.h"

@interface DatePickerVC () <JTCalendarDelegate>
@property (strong,nonatomic) NSDate *userSelectedDate;
@end

@implementation DatePickerVC{
    UIView *calendarView;
    JTCalendarMenuView *calendarMenuView;
    JTHorizontalCalendarView *calendarContentView;
    JTCalendarManager *calendarManager;
    
    UISegmentedControl *dateModeSeg;
    UILabel *dateLabel;
    
    UIButton *okButton;
    
    NSDate *startDate;
    NSDate *endDate;
    
    //GCPhotoManager *photoManager;
    
    //UIView *naviBar;
    
    //NSInteger lastIndex;
}

- (void)setUserSelectedDate:(NSDate *)userSelectedDate{
    _userSelectedDate = userSelectedDate;
    //[[NSNotificationCenter defaultCenter] postNotificationName:SELECTED_RADIO_BUTTON_CHANGED object:nil];
    
    switch (dateModeSeg.selectedSegmentIndex) {
        case DateModeDay:{
            startDate = [userSelectedDate dateAtStartOfToday];
            endDate = [userSelectedDate dateAtEndOfToday];
        }
            break;
        case DateModeWeek:{
            startDate = [userSelectedDate dateAtStartOfThisWeek];
            endDate = [userSelectedDate dateAtEndOfThisWeek];
        }
            break;
        case DateModeMonth:{
            startDate = [userSelectedDate dateAtStartOfThisMonth];
            endDate = [userSelectedDate dateAtEndOfThisMonth];
        }
            break;
        case DateModeYear:{
            startDate = [userSelectedDate dateAtStartOfThisYear];
            endDate = [userSelectedDate dateAtEndOfThisYear];
        }
            break;
        case DateModeAll:{
            startDate = nil;
            endDate = nil;
        }
            break;
        case DateModeRange:{
            startDate = nil;
            endDate = nil;
        }
            break;
        default:{
            startDate = [userSelectedDate dateAtStartOfThisMonth];
            endDate = [userSelectedDate dateAtEndOfThisMonth];
        }
            break;
    }
    
    dateLabel.text = [[startDate stringWithFormat:@"yyyy-MM-dd ~ "] stringByAppendingString:[endDate stringWithFormat:@"yyyy-MM-dd"]];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Date Picker", @"日期选择器");
    
    // Month
    //lastIndex = 2;
    
    //photoManager = [GCPhotoManager defaultManager];
    
    self.userSelectedDate = [NSDate date];
    startDate = [[NSDate date] dateAtStartOfToday];
    endDate = [[NSDate date] dateAtEndOfToday];
    
    [self initDateModeSeg];
    [self initJTCalendar];
    [self initDateLabel];
    [self initOKButton];
    
    self.userSelectedDate = [NSDate date];
}

- (void)initDateModeSeg{
    NSArray <NSString *> *dateModeNameArray = @[NSLocalizedString(@"Day", @"日"),
                                                NSLocalizedString(@"Week", @"周"),
                                                NSLocalizedString(@"Month", @"月"),
                                                NSLocalizedString(@"Year", @"年"),
                                                NSLocalizedString(@"All", @"全部")];
    dateModeSeg = [[UISegmentedControl alloc] initWithItems:dateModeNameArray];
    dateModeSeg.selectedSegmentIndex = [EverywhereSettingManager defaultManager].dateMode;
    [dateModeSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:dateModeSeg];
    dateModeSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [dateModeSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    if (self.dateModeChangedHandler) self.dateModeChangedHandler(sender.selectedSegmentIndex);
    //
    self.userSelectedDate = self.userSelectedDate;
}

- (void)initJTCalendar{
    calendarView = [UIView newAutoLayoutView];
    [self.view addSubview:calendarView];
    [calendarView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:dateModeSeg withOffset:10];
    [calendarView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [calendarView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [calendarView autoSetDimension:ALDimensionHeight toSize:220];
    
    calendarMenuView = [JTCalendarMenuView newAutoLayoutView];
    [calendarView addSubview:calendarMenuView];
    [calendarMenuView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [calendarMenuView autoSetDimension:ALDimensionHeight toSize:20];
    
    calendarContentView = [JTHorizontalCalendarView newAutoLayoutView];
    [calendarView addSubview:calendarContentView];
    [calendarContentView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [calendarContentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:calendarMenuView];
    
    calendarManager = [JTCalendarManager new];
    calendarManager.delegate = self;
    
    [calendarManager setMenuView:calendarMenuView];
    [calendarManager setContentView:calendarContentView];
    [calendarManager setDate:[NSDate date]];
}

- (void)initDateLabel{
    dateLabel = [UILabel newAutoLayoutView];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:dateLabel];
    [dateLabel autoSetDimension:ALDimensionHeight toSize:20];
    [dateLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 55, 0) excludingEdge:ALEdgeTop];
}

- (void)initOKButton{
    okButton = [UIButton newAutoLayoutView];
    [okButton setStyle:UIButtonStylePrimary];
    [okButton setTitle:NSLocalizedString(@"OK", @"确定") forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:okButton];
    [okButton autoSetDimension:ALDimensionHeight toSize:40];
    [okButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 5, 5) excludingEdge:ALEdgeTop];
    
}

- (void)okButtonTouchDown:(UIButton *)sender{
    // if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.dateRangeChangedHandler) self.dateRangeChangedHandler(startDate,endDate);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - JTCalendarDelegate

- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.hidden = NO;
    
    // Test if the dayView is from another month than the page
    // Use only in month mode for indicate the day of the previous or next month
    if([dayView isFromAnotherMonth]){
        dayView.hidden = YES;
    }
    // Today
    else if([calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor greenColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(self.userSelectedDate && [calendarManager.dateHelper date:self.userSelectedDate isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor brownColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    // Your method to test if a date have an event for example
    dayView.dotView.hidden = YES;
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    // Use to indicate the selected date
    self.userSelectedDate = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [calendarManager reload];
                    } completion:nil];
    
    // Load the previous or next page if touch a day from another month
    if(![calendarManager.dateHelper date:calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [calendarContentView loadNextPageWithAnimation];
        }
        else{
            [calendarContentView loadPreviousPageWithAnimation];
        }
    }
}

- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar{
    self.userSelectedDate = [self.userSelectedDate dateByAddingMonths:1];
    //calendarManager.date = self.userSelectedDate;
    //[calendarManager reload];
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar{
    self.userSelectedDate = [self.userSelectedDate dateBySubtractingMonths:1];
    //calendarManager.date = self.userSelectedDate;
    //[calendarManager reload];
}


#pragma mark - JTCalendar Views customization

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    
    UIButton *menuButton = [UIButton new];
    [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //[menuButton addTarget:self action:@selector(menuButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    return menuButton;
}

- (void)menuButtonTouchDown:(id)sender{
    
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UIButton *)menuItemView date:(NSDate *)date{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM";
        
        dateFormatter.locale = calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = calendarManager.dateHelper.calendar.timeZone;
    }
    
    [menuItemView setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
    //menuItemView.text = [dateFormatter stringFromDate:date];
}

/*
 - (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
 {
 JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
 
 for(UILabel *label in view.dayViews){
 label.textColor = [UIColor blackColor];
 label.font = [UIFont fontWithName:@"Avenir-Light" size:14];
 }
 
 return view;
 }
 
 - (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar
 {
 JTCalendarDayView *view = [JTCalendarDayView new];
 
 view.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:13];
 
 view.circleRatio = .8;
 view.dotRatio = 1. / .9;
 
 return view;
 }
 */

@end
