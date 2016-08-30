//
//  DatePickerProVC.m
//  Everywhere
//
//  Created by BobZhang on 16/8/16.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "DatePickerProVC.h"
#import "RETableViewManager.h"

@interface DatePickerProVC () <RETableViewManagerDelegate>

@end

@implementation DatePickerProVC{
    UISegmentedControl *dateModeSeg;
    //UILabel *nowLabel;
    UIButton *todayButton,*okButton;
    
    RETableViewManager *reTVManager;
    UITableView *datePickerTableView;
    REDateTimeItem *startDateTimeItem,*endDateTimeItem;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.9, 450);
    self.landscapeContentSizeInPopup = CGSizeMake(450, ScreenWidth * 0.9);
    
    //self.title = NSLocalizedString(@"Date Picker", @"日期选择器");
    self.title = [[NSDate date] stringWithFormat:@"yyyy-MM-dd  EEEE"];
    
    [self initDateModeSeg];
    //[self initNowLabel];
    [self initButtons];
    [self initRETableView];
    
    [self updateDateData:self.dateMode];
}

- (void)initDateModeSeg{
    NSArray <NSString *> *dateModeNameArray = @[NSLocalizedString(@"Day", @"日"),
                                                NSLocalizedString(@"Week", @"周"),
                                                NSLocalizedString(@"Month", @"月"),
                                                NSLocalizedString(@"Year", @"年"),
                                                NSLocalizedString(@"Custom", @"自定义")];
    dateModeSeg = [[UISegmentedControl alloc] initWithItems:dateModeNameArray];
    dateModeSeg.selectedSegmentIndex = self.dateMode;
    [dateModeSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:dateModeSeg];
    dateModeSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [dateModeSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    self.dateMode = sender.selectedSegmentIndex;
    if (self.dateModeChangedHandler) self.dateModeChangedHandler(self.dateMode);
    [self updateDateData:self.dateMode];
}

- (void)updateDateData:(enum DateMode)dateMode{
    switch (dateMode) {
        case DateModeDay:
            startDateTimeItem.value = [startDateTimeItem.value dateAtStartOfToday];
            endDateTimeItem.value = [startDateTimeItem.value dateAtEndOfToday];
            break;
        case DateModeWeek:
            startDateTimeItem.value = [startDateTimeItem.value dateAtStartOfThisWeek:self.firstDayOfWeek];
            endDateTimeItem.value = [startDateTimeItem.value dateAtEndOfThisWeek:self.firstDayOfWeek];
            break;
        case DateModeMonth:
            startDateTimeItem.value = [startDateTimeItem.value dateAtStartOfThisMonth];
            endDateTimeItem.value = [startDateTimeItem.value dateAtEndOfThisMonth];
            break;
        case DateModeYear:
            startDateTimeItem.value = [startDateTimeItem.value dateAtStartOfThisYear];
            endDateTimeItem.value = [startDateTimeItem.value dateAtEndOfThisYear];
            break;
        case DateModeCustom:
            startDateTimeItem.value = [startDateTimeItem.value dateAtStartOfToday];
            endDateTimeItem.value = [endDateTimeItem.value dateAtEndOfToday];
            break;
        default:
            break;
    }
    
    [datePickerTableView reloadData];
}

/*
- (void)initNowLabel{
    nowLabel = [UILabel newAutoLayoutView];
    nowLabel.textAlignment = NSTextAlignmentCenter;
    nowLabel.text = [[NSDate date] stringWithFormat:@"yyyy-MM-dd  EEEE"];
    [nowLabel setStyle:UILabelStyleBrownBold];
    nowLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [self.view addSubview:nowLabel];
    [nowLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:dateModeSeg withOffset:10];
    [nowLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
}
*/

- (void)initButtons{
    todayButton = [UIButton newAutoLayoutView];
    [todayButton setStyle:UIButtonStylePrimary];
    [todayButton setTitle:NSLocalizedString(@"Today", @"今天") forState:UIControlStateNormal];
    [todayButton addTarget:self action:@selector(todayButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:todayButton];
    [todayButton autoSetDimension:ALDimensionHeight toSize:40];
    [todayButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [todayButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    
    okButton = [UIButton newAutoLayoutView];
    [okButton setStyle:UIButtonStylePrimary];
    [okButton setTitle:NSLocalizedString(@"OK", @"确定") forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:okButton];
    [okButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [okButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [okButton autoSetDimension:ALDimensionHeight toSize:40];
    [okButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:todayButton];
    [okButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:todayButton withOffset:10];
}

- (void)todayButtonTouchDown:(UIButton *)sender{
    startDateTimeItem.value = [NSDate date];
    [self updateDateData:self.dateMode];
}

- (void)okButtonTouchDown:(UIButton *)sender{
    // if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    [[NSUserDefaults standardUserDefaults] setValue:startDateTimeItem.value forKey:DatePickerCustomStartDate];
    [[NSUserDefaults standardUserDefaults] setValue:endDateTimeItem.value forKey:DatePickerCustomEndDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dateRangeChangedHandler) self.dateRangeChangedHandler(startDateTimeItem.value,endDateTimeItem.value);
    }];
}

- (void)initRETableView{
    datePickerTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    datePickerTableView.translatesAutoresizingMaskIntoConstraints=NO;
    datePickerTableView.scrollEnabled = NO;
    [self.view addSubview:datePickerTableView];
    
    [datePickerTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:dateModeSeg withOffset:10];
    [datePickerTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [datePickerTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [datePickerTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:okButton withOffset:-10];
    //[datePickerTableView autoSetDimension:ALDimensionHeight toSize:400];
    
    reTVManager = [[RETableViewManager alloc]initWithTableView:datePickerTableView delegate:self];
    
    RETableViewSection *datePickerSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Set Date Range", @"设置日期范围")];
    //datePickerSection.headerHeight = 20;
    NSDate *startDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomStartDate];
    if (!startDate) startDate = [[NSDate date] dateAtStartOfToday];
    
    WEAKSELF(weakSelf);
    startDateTimeItem = [REDateTimeItem itemWithTitle:NSLocalizedString(@"Start Date", @"开始时间") value:startDate placeholder:nil format:@"yyyy-MM-dd  EEE" datePickerMode:UIDatePickerModeDate];
    startDateTimeItem.locale = [NSCalendar currentCalendar].locale;
    startDateTimeItem.onChange = ^(REDateTimeItem *item){
        [weakSelf updateDateData:weakSelf.dateMode];
    };
    startDateTimeItem.inlineDatePicker=YES;
    
    NSDate *endDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomEndDate];
    if (!endDate) endDate = [[NSDate date] dateAtEndOfToday];

    endDateTimeItem = [REDateTimeItem itemWithTitle:NSLocalizedString(@"End Date", @"结束时间") value:endDate placeholder:nil format:@"yyyy-MM-dd  EEE" datePickerMode:UIDatePickerModeDate];
    endDateTimeItem.locale = [NSCalendar currentCalendar].locale;
    endDateTimeItem.inlineDatePicker=YES;
    
    [datePickerSection addItemsFromArray:@[startDateTimeItem,endDateTimeItem]];
    
    [reTVManager addSectionsFromArray:@[datePickerSection]];
}

@end
