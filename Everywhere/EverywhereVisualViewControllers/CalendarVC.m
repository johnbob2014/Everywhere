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
#import <JTCalendar.h>

@import Photos;

@interface CalendarVC ()<JTCalendarDelegate>

@end

@implementation CalendarVC{
    JTCalendarMenuView *calendarMenuView;
    JTHorizontalCalendarView *calendarContentView;
    JTCalendarManager *calendarManager;
    NSDate *userSelectedDate;
    
    GCPhotoManager *photoManager;
    
    NSMutableDictionary <NSString *,NSArray *> *assetsDictionary;
}

- (void)viewDidLoad{
    photoManager = [GCPhotoManager defaultManager];
    
    userSelectedDate = [NSDate date];
    
    [self initJTCalendar];
    /*
    seg = [[UISegmentedControl alloc] initWithItems:[@"Day Month Year" componentsSeparatedByString:@" "]];
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    */
    //[self asyncFetchAssets];
    
    //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44 - 20, [UIScreen mainScreen].bounds.size.height - 44 - 20 - 64 , 44, 44);
    /*
     addButton = [VCFloatingActionButton newAutoLayoutView];
     addButton.imageArray = @[@"fb-icon",@"twitter-icon",@"google-icon",@"linkedin-icon"];
     addButton.labelArray = @[@"Facebook",@"Twitter",@"Google Plus",@"Linked in"];
     addButton.hideWhileScrolling = NO;
     addButton.delegate = self;
     
     //NSLog(@"%@",NSStringFromCGRect(self.view.frame));
     [self.view insertSubview:addButton aboveSubview:self.tableView];
     [addButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
     [addButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
     [addButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
     NSLog(@"%@",NSStringFromCGRect(addButton.frame));
     */
}


- (void)initJTCalendar{
    calendarMenuView = [JTCalendarMenuView newAutoLayoutView];
    [self.view addSubview:calendarMenuView];
    [calendarMenuView autoSetDimension:ALDimensionHeight toSize:30];
    [calendarMenuView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    calendarContentView = [JTHorizontalCalendarView newAutoLayoutView];
    [self.view addSubview:calendarContentView];
    [calendarContentView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:calendarMenuView];
    [calendarContentView autoSetDimension:ALDimensionHeight toSize:[UIScreen mainScreen].bounds.size.height/3.0];
    [calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [calendarContentView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    calendarManager = [JTCalendarManager new];
    calendarManager.delegate = self;
    
    [calendarManager setMenuView:calendarMenuView];
    [calendarManager setContentView:calendarContentView];
    [calendarManager setDate:[NSDate date]];
    
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
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(userSelectedDate && [calendarManager.dateHelper date:userSelectedDate isTheSameDayThan:dayView.date]){
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
    userSelectedDate = dayView.date;
    
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
    /*
     NSLog(@"%@",NSStringFromSelector(_cmd));
    NSDictionary *dic = [photoManager fetchAssetIDsFormStartDate:userSelectedDate toEndDate:userSelectedDate fromAssetCollectionIDs:@[photoManager.GCAssetCollectionID_UserLibrary]];
    [self pushAssetsMapVCWithAssetLocalIdentifiers:dic[photoManager.GCAssetCollectionID_UserLibrary] title:nil];
     */
    
    NSDictionary *dic = [photoManager fetchAssetsFormStartDate:userSelectedDate toEndDate:userSelectedDate fromAssetCollectionIDs:@[photoManager.GCAssetCollectionID_UserLibrary]];
    NSArray <PHAsset *> *assetArray = dic[photoManager.GCAssetCollectionID_UserLibrary];
    NSMutableArray *assetArrayWithLocations = [NSMutableArray new];
    [assetArray enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.location) [assetArrayWithLocations addObject:obj];
    }];
    NSArray *assetsArray = [GCLocationAnalyser analyseLocationsToArray:assetArrayWithLocations nearestDistance:200];
    [self pushAssetsMapProVCWithAssetsArray:assetsArray title:nil];
    
}

- (void)pushAssetsMapVCWithAssetLocalIdentifiers:(NSArray <NSString *> *)assetLocalIdentifiers title:(NSString *)title{
    AssetsMapVC *showVC = [AssetsMapVC new];
    showVC.assetLocalIdentifiers = assetLocalIdentifiers;
    showVC.title = title;
    [self.navigationController pushViewController:showVC animated:YES];
}


-(void)pushAssetsMapProVCWithAssetsArray:(NSArray <NSArray *> *)assetsArray title:(NSString *)title{
    AssetsMapProVC *showVC = [AssetsMapProVC new];
    showVC.assetsArray = assetsArray;
    showVC.title = title;
    [self.navigationController pushViewController:showVC animated:YES];
}


- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UIButton *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy MM";
        
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


/*
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //NSLog(@"%@",NSStringFromCGRect(addButton.frame));
    //[addButton setNormalImage:[UIImage imageNamed:@"plus"] andPressedImage:[UIImage imageNamed:@"cross"] withScrollview:nil];
    
}

- (void)didSelectMenuOptionAtIndex:(NSInteger)row{
    NSLog(@"Floating action tapped index %tu",row);
}
*/

/*
- (void)segChanged:(id)sender{
    [self asyncFetchAssets];
}

- (void)asyncFetchAssets{
    assetsDictionary = [NSMutableDictionary new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchAssets];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

- (void)fetchAssets{
    
    PHFetchResult <PHAssetCollection *> *fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHAssetCollection *CameraRoll = fetchResultArray.firstObject;
    if (!CameraRoll) return;
    
    //NSLog(@"%ld,%@\,%@",CameraRoll.estimatedAssetCount,CameraRoll.startDate,CameraRoll.endDate);
    NSInteger i = 365;
    if (seg.selectedSegmentIndex == 1)
        i = 120;
    else if (seg.selectedSegmentIndex ==2)
        i = 10;
    
    NSDate *now = [NSDate date];
    NSDate *lastEndDate = [now dateAtEndOfToday];
    if (seg.selectedSegmentIndex == 1)
        lastEndDate = [now dateAtEndOfThisMonth];
    else if (seg.selectedSegmentIndex ==2)
        lastEndDate = [now dateAtEndOfThisYear];
    PHFetchOptions *options = [PHFetchOptions new];
    
    while (i > 0) {
        i--;
        
        NSDate *startDate = [lastEndDate dateAtStartOfToday];
        
        if (seg.selectedSegmentIndex == 1)
            startDate = [lastEndDate dateAtStartOfThisMonth];
        else if (seg.selectedSegmentIndex ==2)
            startDate = [lastEndDate dateAtStartOfThisYear];
        
        options.predicate = [NSPredicate predicateWithFormat:@" (creationDate > %@) && (creationDate < %@)",startDate,lastEndDate];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult <PHAsset *> *assetArray = [PHAsset fetchAssetsInAssetCollection:CameraRoll options:options];
        NSMutableArray <NSString *> *assetIDArray = [NSMutableArray new];
        [assetArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.location && obj.localIdentifier) [assetIDArray addObject:obj.localIdentifier];
        }];
        
        if (assetIDArray.count > 0) {
            NSString *assetIDArrayName = [startDate stringWithFormat:@"yyyy-MM-dd"];
            if (seg.selectedSegmentIndex == 1)
                assetIDArrayName = [startDate stringWithFormat:@"yyyy-MM"];
            else if (seg.selectedSegmentIndex ==2)
                assetIDArrayName = [startDate stringWithFormat:@"yyyy"];
            
            if (assetIDArrayName) [assetsDictionary setValue:assetIDArray forKey:assetIDArrayName];
            //NSLog(@"%ld",assetArray.count);
        }
        
        lastEndDate = [lastEndDate dateBySubtractingDays:1];
        if (seg.selectedSegmentIndex == 1){
            lastEndDate = [lastEndDate dateBySubtractingMonths:1];
            lastEndDate = [lastEndDate dateAtEndOfThisMonth];
        }
        else if (seg.selectedSegmentIndex ==2)
            lastEndDate = [lastEndDate dateBySubtractingYears:1];
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [assetsDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
 
     //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
     //if (!cell) {
     //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
     //}
 
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    NSArray *keyArray = assetsDictionary.allKeys;
    keyArray = [keyArray sortedArrayUsingSelector:@selector(localizedCompare:)].reverseObjectEnumerator.allObjects;
    cell.textLabel.text = keyArray[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)(assetsDictionary.count - indexPath.row)];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //AssetsTVC *showVC = [AssetsTVC new];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    AssetsMapVC *showVC = [AssetsMapVC new];
    showVC.assetLocalIdentifiers = assetsDictionary[cell.textLabel.text];
    [self.navigationController pushViewController:showVC animated:YES];
}
*/
@end
