//
//  CalendarVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CalendarVC.h"
#import "AssetsMapVC.h"
#import "AssetsMapProVC.h"
#import "NSDate+Assistant.h"
#import "UIView+AutoLayout.h"
#import "GCPhotoManager.h"
#import "GCLocationAnalyser.h"
#import "TNRadioButtonGroup.h"
#import <JTCalendar.h>

@import Photos;

@interface CalendarVC ()<JTCalendarDelegate>
@property (strong,nonatomic) NSDate *userSelectedDate;
@property (assign,nonatomic) NSInteger mode;
@end

@implementation CalendarVC{
    JTCalendarMenuView *calendarMenuView;
    JTHorizontalCalendarView *calendarContentView;
    JTCalendarManager *calendarManager;
    
    TNRadioButtonGroup *radioGroup;

    NSDate *startDate;
    NSDate *endDate;
    
    GCPhotoManager *photoManager;
    
    UIView *naviBar;
    
}

- (void)setUserSelectedDate:(NSDate *)userSelectedDate{
    _userSelectedDate = userSelectedDate;
}

/*
- (void)setMode:(NSInteger)mode{
    _mode = mode;
    [self updateStartEndDate];
}

- (void)updateStartEndDate{
    switch (self.mode) {
        case 0:{
            startDate = self.userSelectedDate;
            endDate = self.userSelectedDate;
        }
            break;
        case 1:{
            startDate = [self.userSelectedDate dateAtStartOfThisMonth];
            endDate = [self.userSelectedDate dateAtEndOfThisMonth];
        }
            break;
        case 2:{
            startDate = [self.userSelectedDate dateAtStartOfThisYear];
            endDate = [self.userSelectedDate dateAtEndOfThisYear];
        }
            break;
        default:
            break;
    }

}
*/

- (void)viewDidLoad{
    [super viewDidLoad];
    
    photoManager = [GCPhotoManager defaultManager];
    
    self.userSelectedDate = [NSDate date];
    self.mode = 0;
    
    [self initJTCalendar];
    
    [self initRadioGroup];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)initJTCalendar{
    calendarMenuView = [JTCalendarMenuView newAutoLayoutView];
    [self.view addSubview:calendarMenuView];
    [calendarMenuView autoSetDimension:ALDimensionHeight toSize:20];
    [calendarMenuView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    calendarContentView = [JTHorizontalCalendarView newAutoLayoutView];
    [self.view addSubview:calendarContentView];
    [calendarContentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:calendarMenuView];
    [calendarContentView autoSetDimension:ALDimensionHeight toSize:200];
    [calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    calendarManager = [JTCalendarManager new];
    calendarManager.delegate = self;
    
    [calendarManager setMenuView:calendarMenuView];
    [calendarManager setContentView:calendarContentView];
    [calendarManager setDate:[NSDate date]];
    
}

- (void)initRadioGroup {
    TNImageRadioButtonData *dayData = [TNImageRadioButtonData new];
    dayData.labelText = NSLocalizedString(@"Day", @"");
    dayData.identifier = @"Day";
    dayData.selected = YES;
    dayData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    dayData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *monthData = [TNImageRadioButtonData new];
    monthData.labelText = NSLocalizedString(@"Month", @"");
    monthData.identifier = @"Month";
    monthData.selected = NO;
    monthData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    monthData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *yearData = [TNImageRadioButtonData new];
    yearData.labelText = NSLocalizedString(@"Year", @"");
    yearData.identifier = @"Year";
    yearData.selected = NO;
    yearData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    yearData.selectedImage = [UIImage imageNamed:@"checked"];
    
    TNImageRadioButtonData *rangeData = [TNImageRadioButtonData new];
    rangeData.labelText = NSLocalizedString(@"Range", @"");
    rangeData.identifier = @"Range";
    rangeData.selected = NO;
    rangeData.unselectedImage = [UIImage imageNamed:@"unchecked"];
    rangeData.selectedImage = [UIImage imageNamed:@"checked"];
    
    radioGroup = [[TNRadioButtonGroup alloc] initWithRadioButtonData:@[dayData, monthData,yearData,rangeData] layout:TNRadioButtonGroupLayoutVertical];
    radioGroup.identifier = @"Date Group";
    [radioGroup create];
    radioGroup.position = CGPointMake(15, 240);
    
    [self.view addSubview:radioGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(temperatureGroupUpdated:) name:SELECTED_RADIO_BUTTON_CHANGED object:radioGroup];
}

- (void)temperatureGroupUpdated:(NSNotification *)notification {
    NSLog(@"Group updated to %@", radioGroup.selectedRadioButton.data.identifier);
    NSUInteger index = [[@"Day Month Year Range" componentsSeparatedByString:@" "] indexOfObject:radioGroup.selectedRadioButton.data.identifier];
    switch (index) {
        case 0:{
            startDate = self.userSelectedDate;
            endDate = self.userSelectedDate;
        }
            break;
        case 1:{
            startDate = [self.userSelectedDate dateAtStartOfThisMonth];
            endDate = [self.userSelectedDate dateAtEndOfThisMonth];
        }
            break;
        case 2:{
            startDate = [self.userSelectedDate dateAtStartOfThisYear];
            endDate = [self.userSelectedDate dateAtEndOfThisYear];
        }
            break;
        case 3:{
            // ??
            startDate = nil;
            endDate = nil;
        }
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SELECTED_RADIO_BUTTON_CHANGED object:radioGroup];
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
    NSArray *assetsArray = [GCLocationAnalyser analyseLocationsToArray:assetArrayWithLocations nearestDistance:200];
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

#pragma mark - Views customization

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Avenir-Medium" size:16];
    
    UIButton *menuButton = [UIButton new];
    [menuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(menuButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    return menuButton;
}

- (void)menuButtonTouchDown:(id)sender{
    if (self.calendarWillDisappear) self.calendarWillDisappear(startDate,endDate);
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
