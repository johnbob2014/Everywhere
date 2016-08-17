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
    //UILabel *dateLabel;
    UIButton *okButton;
    
    RETableViewManager *reTVManager;
    UITableView *datePickerTableView;
    REDateTimeItem *startDateTimeItem,*endDateTimeItem;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.9, 450);
    self.landscapeContentSizeInPopup = CGSizeMake(450, ScreenWidth * 0.9);
    
    self.title = NSLocalizedString(@"Date Picker", @"日期选择器");
    
    [self initDateModeSeg];
    [self initOKButton];
    [self initRETableView];
    //[self initDateLabel];
}

- (void)initDateModeSeg{
    NSArray <NSString *> *dateModeNameArray = @[NSLocalizedString(@"Day", @"日"),
                                                NSLocalizedString(@"Week", @"周"),
                                                NSLocalizedString(@"Month", @"月"),
                                                NSLocalizedString(@"Year", @"年"),
                                                NSLocalizedString(@"Custom", @"自定义")];
    dateModeSeg = [[UISegmentedControl alloc] initWithItems:dateModeNameArray];
    //dateModeSeg.selectedSegmentIndex = 4;
    [dateModeSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:dateModeSeg];
    dateModeSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [dateModeSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    if (self.dateModeChangedHandler) self.dateModeChangedHandler(sender.selectedSegmentIndex);
    //
    switch (dateModeSeg.selectedSegmentIndex) {
        case DateModeDay:{
            startDateTimeItem.value = [[NSDate date] dateAtStartOfToday];
            endDateTimeItem.value = [[NSDate date] dateAtEndOfToday];
        }
            break;
        case DateModeWeek:{
            startDateTimeItem.value = [[NSDate date] dateAtStartOfThisWeek];
            endDateTimeItem.value = [[NSDate date] dateAtEndOfThisWeek];
        }
            break;
        case DateModeMonth:{
            startDateTimeItem.value = [[NSDate date] dateAtStartOfThisMonth];
            endDateTimeItem.value = [[NSDate date] dateAtEndOfThisMonth];
        }
            break;
        case DateModeYear:{
            startDateTimeItem.value = [[NSDate date] dateAtStartOfThisYear];
            endDateTimeItem.value = [[NSDate date] dateAtEndOfThisYear];
        }
            break;
        default:
            break;
    }
    
    [datePickerTableView reloadData];
    
    //[self updateDateLabel];
}


/*
- (void)initDateLabel{
    dateLabel = [UILabel newAutoLayoutView];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:dateLabel];
    [dateLabel autoSetDimension:ALDimensionHeight toSize:20];
    [dateLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 55, 0) excludingEdge:ALEdgeTop];
}
 
 - (void)updateDateLabel{
 dateLabel.text = [[startDateTimeItem.value stringWithFormat:@"yyyy-MM-dd ~ "] stringByAppendingString:[endDateTimeItem.value stringWithFormat:@"yyyy-MM-dd"]];
 }
*/

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
    [[NSUserDefaults standardUserDefaults] setValue:startDateTimeItem.value forKey:DatePickerCustomStartDate];
    [[NSUserDefaults standardUserDefaults] setValue:endDateTimeItem.value forKey:DatePickerCustomEndDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.dateRangeChangedHandler) self.dateRangeChangedHandler(startDateTimeItem.value,endDateTimeItem.value);
}

- (void)initRETableView{
    datePickerTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    datePickerTableView.translatesAutoresizingMaskIntoConstraints=NO;
    datePickerTableView.scrollEnabled = NO;
    [self.view addSubview:datePickerTableView];
    
    [datePickerTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:dateModeSeg withOffset:20];
    [datePickerTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [datePickerTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [datePickerTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:okButton withOffset:-10];
    //[datePickerTableView autoSetDimension:ALDimensionHeight toSize:400];
    
    reTVManager = [[RETableViewManager alloc]initWithTableView:datePickerTableView delegate:self];
    
    RETableViewSection *datePickerSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Set Date Range", @"设置日期范围")];
    //datePickerSection.headerHeight = 20;
    NSDate *startDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomStartDate];
    if (!startDate) startDate = [[NSDate date] dateAtStartOfToday];
    
    startDateTimeItem = [REDateTimeItem itemWithTitle:NSLocalizedString(@"Start Date", @"开始时间") value:startDate placeholder:nil format:@"yyyy-MM-dd" datePickerMode:UIDatePickerModeDate];
    
    startDateTimeItem.inlineDatePicker=YES;
    
    NSDate *endDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomEndDate];
    if (!endDate) endDate = [[NSDate date] dateAtEndOfToday];

    endDateTimeItem = [REDateTimeItem itemWithTitle:NSLocalizedString(@"End Date", @"结束时间") value:endDate placeholder:nil format:@"yyyy-MM-dd" datePickerMode:UIDatePickerModeDate];
    endDateTimeItem.inlineDatePicker=YES;
    
    [datePickerSection addItemsFromArray:@[startDateTimeItem,endDateTimeItem]];
    
    [reTVManager addSectionsFromArray:@[datePickerSection]];
}

@end
