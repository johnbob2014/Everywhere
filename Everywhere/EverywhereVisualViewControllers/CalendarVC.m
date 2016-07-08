//
//  CalendarVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CalendarVC.h"
#import "AssetsMapProVC.h"
#import "NSDate+Assistant.h"
#import "UIView+AutoLayout.h"
#import "GCPhotoManager.h"
#import "GCLocationAnalyser.h"
#import "TNRadioButtonGroup.h"
#import <JTCalendar.h>
#import "UIButton+Bootstrap.h"

@import Photos;

@interface CalendarVC ()<JTCalendarDelegate>
@property (strong,nonatomic) NSDate *userSelectedDate;
@end

@implementation CalendarVC{
    UIView *calendarView;
    JTCalendarMenuView *calendarMenuView;
    JTHorizontalCalendarView *calendarContentView;
    JTCalendarManager *calendarManager;
    
    UIView *radioGroupView;
    TNRadioButtonGroup *radioGroupDayWeekMonth;
    TNRadioButtonGroup *radioGroupYearAllRange;
    TNRadioButtonGroup *radioGroupShortLong;
    
    UILabel *dateLabel;
    
    UIButton *okButton;

    NSDate *startDate;
    NSDate *endDate;
    
    GCPhotoManager *photoManager;
    
    //UIView *naviBar;
    
    NSInteger lastIndex;
}

- (void)setUserSelectedDate:(NSDate *)userSelectedDate{
    _userSelectedDate = userSelectedDate;
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTED_RADIO_BUTTON_CHANGED object:nil];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Date Picker", @"");
    
    // Month
    lastIndex = 2;
    
    photoManager = [GCPhotoManager defaultManager];
    
    self.userSelectedDate = [NSDate date];
    startDate = [[NSDate date] dateAtStartOfToday];
    endDate = [[NSDate date] dateAtEndOfToday];
    
    [self initJTCalendar];
    
    [self initRadioGroup];
    
    okButton = [UIButton newAutoLayoutView];
    [okButton primaryStyle];
    [okButton setTitle:NSLocalizedString(@"OK", @"") forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:okButton];
    [okButton autoSetDimension:ALDimensionHeight toSize:40];
    [okButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 5, 5) excludingEdge:ALEdgeTop];
    
    dateLabel = [UILabel newAutoLayoutView];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:dateLabel];
    [dateLabel autoSetDimension:ALDimensionHeight toSize:20];
    [dateLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 55, 0) excludingEdge:ALEdgeTop];
}

- (void)okButtonTouchDown:(UIButton *)sender{
    // NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.dateRangeDidChangeHandler) self.dateRangeDidChangeHandler(startDate,endDate);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initJTCalendar{
    calendarView = [UIView newAutoLayoutView];
    [self.view addSubview:calendarView];
    [calendarView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
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

- (void)initRadioGroup {
    radioGroupView = [UIView newAutoLayoutView];
    
    TNCircularRadioButtonData *shortData = [TNCircularRadioButtonData new];
    shortData.labelText = NSLocalizedString(@"S", @"");
    shortData.labelFont = [UIFont systemFontOfSize:16];
    shortData.identifier = @"Short";
    shortData.selected = YES;
    
    TNCircularRadioButtonData *longData = [TNCircularRadioButtonData new];
    longData.labelText = NSLocalizedString(@"L", @"");
    longData.labelFont = [UIFont systemFontOfSize:16];
    longData.identifier = @"Long";
    longData.selected = NO;
    
    radioGroupShortLong = [[TNRadioButtonGroup alloc] initWithRadioButtonData:@[shortData,longData] layout:TNRadioButtonGroupLayoutVertical];
    radioGroupShortLong.marginBetweenItems = 20;
    [radioGroupShortLong create];
    radioGroupShortLong.position = CGPointMake(10, 245);
    [self.view addSubview:radioGroupShortLong];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioGroupShortLongUpdated:) name:SELECTED_RADIO_BUTTON_CHANGED object:radioGroupShortLong];

    TNImageRadioButtonData *dayData = [TNImageRadioButtonData new];
    dayData.labelText = NSLocalizedString(@"Day", @"");
    dayData.identifier = @"Day";
    dayData.selected = NO;
    dayData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    dayData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *weekData = [TNImageRadioButtonData new];
    weekData.labelText = NSLocalizedString(@"Week", @"");
    weekData.identifier = @"Week";
    weekData.selected = NO;
    weekData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    weekData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *monthData = [TNImageRadioButtonData new];
    monthData.labelText = NSLocalizedString(@"Month", @"");
    monthData.identifier = @"Month";
    monthData.selected = YES;
    monthData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    monthData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *yearData = [TNImageRadioButtonData new];
    yearData.labelText = NSLocalizedString(@"Year", @"");
    yearData.identifier = @"Year";
    yearData.selected = YES;
    yearData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    yearData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *allData = [TNImageRadioButtonData new];
    allData.labelText = NSLocalizedString(@"All", @"");
    allData.identifier = @"All";
    allData.selected = NO;
    allData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    allData.selectedImage = [UIImage imageNamed:@"checked"];

    TNImageRadioButtonData *rangeData = [TNImageRadioButtonData new];
    rangeData.labelText = NSLocalizedString(@"Range", @"");
    rangeData.identifier = @"Range";
    rangeData.selected = NO;
    rangeData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    rangeData.selectedImage = [UIImage imageNamed:@"checked"];
    
    radioGroupDayWeekMonth = [[TNRadioButtonGroup alloc] initWithRadioButtonData:@[dayData,weekData,monthData] layout:TNRadioButtonGroupLayoutHorizontal];
    radioGroupDayWeekMonth.identifier = @"Date Group 1";
    //radioGroup.marginBetweenItems = 15;
    [radioGroupDayWeekMonth create];
    radioGroupDayWeekMonth.position = CGPointMake(70, 240);
    
    radioGroupYearAllRange = [[TNRadioButtonGroup alloc] initWithRadioButtonData:@[yearData,allData,rangeData] layout:TNRadioButtonGroupLayoutHorizontal];
    radioGroupYearAllRange.identifier = @"Date Group 2";
    //radioGroup.marginBetweenItems = 15;
    [radioGroupYearAllRange create];
    radioGroupYearAllRange.position = CGPointMake(70, 280);
    radioGroupYearAllRange.userInteractionEnabled = NO;
    radioGroupYearAllRange.alpha = 0.3;
    
    [self.view addSubview:radioGroupDayWeekMonth];
    [self.view addSubview:radioGroupYearAllRange];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(radioGroupUpdated:) name:SELECTED_RADIO_BUTTON_CHANGED object:nil];
}

- (void)radioGroupShortLongUpdated:(NSNotification *)notification{
    NSUInteger index = [[@"Short Long" componentsSeparatedByString:@" "] indexOfObject:radioGroupShortLong.selectedRadioButton.data.identifier];
    if (index == 0) {
        radioGroupDayWeekMonth.alpha = 1.0;
        radioGroupDayWeekMonth.userInteractionEnabled = YES;
        radioGroupYearAllRange.alpha = 0.3;
        radioGroupYearAllRange.userInteractionEnabled = NO;
        lastIndex = [[@"Day Week Month Year All Range" componentsSeparatedByString:@" "] indexOfObject:radioGroupDayWeekMonth.selectedRadioButton.data.identifier];
    }else if (index == 1){
        radioGroupDayWeekMonth.alpha = 0.3;
        radioGroupDayWeekMonth.userInteractionEnabled = NO;
        radioGroupYearAllRange.alpha = 1.0;
        radioGroupYearAllRange.userInteractionEnabled = YES;
        lastIndex = [[@"Day Week Month Year All Range" componentsSeparatedByString:@" "] indexOfObject:radioGroupYearAllRange.selectedRadioButton.data.identifier];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SELECTED_RADIO_BUTTON_CHANGED object:nil];
}

- (void)radioGroupUpdated:(NSNotification *)notification {
    TNRadioButtonGroup *radioGroup = notification.object;
    
    NSUInteger index1 = [[@"Day Week Month Year All Range" componentsSeparatedByString:@" "] indexOfObject:radioGroupDayWeekMonth.selectedRadioButton.data.identifier];
    NSUInteger index2 = [[@"Day Week Month Year All Range" componentsSeparatedByString:@" "] indexOfObject:radioGroupYearAllRange.selectedRadioButton.data.identifier];
    
    NSUInteger index;
    if (radioGroup == radioGroupDayWeekMonth) {
        index = index1;
        lastIndex = index;
    }else if (radioGroup == radioGroupYearAllRange){
        index = index2;
        lastIndex = index;
    }else{
        index = lastIndex;
    }
    
    NSLog(@"%ld : %@",(unsigned long)index,[@"Day Week Month Year All Range" componentsSeparatedByString:@" "][index]);
    
    switch (index) {
        case 0:{
            // Day
            startDate = [self.userSelectedDate dateAtStartOfToday];
            endDate = [self.userSelectedDate dateAtEndOfToday];
        }
            break;
        case 1:{
            // Week
            startDate = [self.userSelectedDate dateAtStartOfThisWeek];
            endDate = [self.userSelectedDate dateAtEndOfThisWeek];
        }
            break;
        case 2:{
            // Month
            startDate = [self.userSelectedDate dateAtStartOfThisMonth];
            endDate = [self.userSelectedDate dateAtEndOfThisMonth];
        }
            break;
        case 3:{
            // Year
            startDate = [self.userSelectedDate dateAtStartOfThisYear];
            endDate = [self.userSelectedDate dateAtEndOfThisYear];
        }
            break;
        case 4:{
            // All
            startDate = nil;
            endDate = nil;
        }
            break;
        case 5:{
            // Range
            startDate = nil;
            endDate = nil;
        }
            break;
            
        default:
            break;
    }
    
    dateLabel.text = [[startDate stringWithFormat:@"yyyy-MM-dd ~ "] stringByAppendingString:[endDate stringWithFormat:@"yyyy-MM-dd"]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SELECTED_RADIO_BUTTON_CHANGED object:radioGroupDayWeekMonth];
}

/*
- (void)initNaviBar{
    naviBar = [UIView newAutoLayoutView];
    [naviBar setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    [self.view addSubview:naviBar];
    [naviBar autoSetDimension:ALDimensionHeight toSize:44];
    [naviBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 20, 5) excludingEdge:ALEdgeTop];
    
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"Day Month Year" componentsSeparatedByString:@" "]];
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [naviBar addSubview:seg];
    [seg autoSetDimensionsToSize:CGSizeMake(220, 30)];
    [seg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [seg autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UIButton *goButton = [UIButton newAutoLayoutView];
    [goButton setTitle:@"Go!" forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(goButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:goButton];
    
    [goButton autoSetDimensionsToSize:CGSizeMake(100, 40)];
    [goButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [goButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}


- (void)segmentControlValueChanged:(UISegmentedControl *)sender{
    self.mode = sender.selectedSegmentIndex;
}

- (void)goButtonPressed:(UIButton *)sender{
    NSDictionary *dic = [photoManager fetchAssetsFormStartDate:startDate toEndDate:endDate fromAssetCollectionIDs:@[photoManager.GCAssetCollectionID_UserLibrary]];
    NSArray <PHAsset *> *assetArray = dic[photoManager.GCAssetCollectionID_UserLibrary];
    NSMutableArray *assetArrayWithLocations = [NSMutableArray new];
    [assetArray enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.location) [assetArrayWithLocations addObject:obj];
    }];
    NSArray *assetsArray = [GCLocationAnalyser divideLocationsInOrderToArray:assetArrayWithLocations nearestDistance:200];
    [self pushAssetsMapProVCWithAssetsArray:assetsArray title:nil];
}
*/

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
        dayView.circleView.backgroundColor = [[UIColor brownColor] colorWithAlphaComponent:0.4];
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
}

- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar{
    self.userSelectedDate = [self.userSelectedDate dateBySubtractingMonths:1];
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
