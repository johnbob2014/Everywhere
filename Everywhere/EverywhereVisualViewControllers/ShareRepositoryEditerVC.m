//
//  ShareRepositoryEditerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareRepositoryEditerVC.h"
#import "EverywhereSettingManager.h"
#import "EverywhereShareRepositoryManager.h"
#import "GCLocationAnalyser.h"

@interface ShareRepositoryEditerVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (strong,nonatomic) NSMutableArray <EverywhereShareAnnotation *> *shareAnnoMA;
@end

@implementation ShareRepositoryEditerVC{
    NSArray <EverywhereShareAnnotation *> *currentGroupArray;
    //NSMutableArray <EverywhereShareAnnotation *> *editedArray;
    UITextField *mergedDistanceTF;
    NSArray <NSString *> *groupNameArray;
    UISegmentedControl *groupSeg;
    UITableView *myTableView;
    UISwitch *reserveManuallyAddedFootprintSwitch;
    UIButton *mergeButton;
    
    BOOL mergeInOrder;
    BOOL reserveManuallyAddedFootprint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 默认按时刻排序
    mergeInOrder = YES;
    // 默认合并时保留用户手动添加的足迹点
    reserveManuallyAddedFootprint = YES;
    
    self.shareAnnoMA = [NSMutableArray arrayWithArray:self.shareRepository.shareAnnos];
    currentGroupArray = self.shareAnnoMA.reverseObjectEnumerator.allObjects;
    
    self.title = self.shareRepository.title;
    
    UIView *containerView = [UIView newAutoLayoutView];
    [self.view addSubview:containerView];
    [containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [containerView autoSetDimension:ALDimensionHeight toSize:160];

    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) excludingEdge:ALEdgeBottom];
    [myTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:containerView withOffset:-10];
    
    UILabel *mergedDistanceLabel = [UILabel newAutoLayoutView];
    mergedDistanceLabel.text = NSLocalizedString(@"MergedDistance :", @"合并距离：");
    [containerView addSubview:mergedDistanceLabel];
    [mergedDistanceLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [mergedDistanceLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [mergedDistanceLabel autoSetDimension:ALDimensionHeight toSize:30];

    mergedDistanceTF = [UITextField newAutoLayoutView];
    mergedDistanceTF.delegate = self;
    mergedDistanceTF.text = @"200";
    mergedDistanceTF.textAlignment = NSTextAlignmentCenter;
    mergedDistanceTF.clearButtonMode = UITextFieldViewModeAlways;
    mergedDistanceTF.layer.borderWidth = 1;
    mergedDistanceTF.layer.borderColor = [[EverywhereSettingManager defaultManager].extendedTintColor CGColor];
    [containerView addSubview: mergedDistanceTF];
    [mergedDistanceTF autoAlignAxis:ALAxisHorizontal toSameAxisOfView:mergedDistanceLabel];
    [mergedDistanceTF autoSetDimension:ALDimensionWidth toSize:120];
    [mergedDistanceTF autoSetDimension:ALDimensionHeight toSize:30];
    [mergedDistanceTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];

    groupNameArray = @[NSLocalizedString(@"Merge By Moment", @"按时刻合并"),
                       NSLocalizedString(@"Merge By Location", @"按位置合并")];
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = 0;
    [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:groupSeg];
    groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [groupSeg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mergedDistanceLabel withOffset:10];
    [groupSeg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [groupSeg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    
    UILabel *reserveManuallyAddedFootprintLabel = [UILabel newAutoLayoutView];
    reserveManuallyAddedFootprintLabel.text = NSLocalizedString(@"Reserve Manually Added :", @"保留手动添加的 :");
    [containerView addSubview:reserveManuallyAddedFootprintLabel];
    [reserveManuallyAddedFootprintLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
    [reserveManuallyAddedFootprintLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [reserveManuallyAddedFootprintLabel autoSetDimension:ALDimensionHeight toSize:30];
    
    reserveManuallyAddedFootprintSwitch = [UISwitch newAutoLayoutView];
    reserveManuallyAddedFootprintSwitch.on = YES;
    [reserveManuallyAddedFootprintSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:reserveManuallyAddedFootprintSwitch];
    [reserveManuallyAddedFootprintSwitch autoAlignAxis:ALAxisHorizontal toSameAxisOfView:reserveManuallyAddedFootprintLabel];
    [reserveManuallyAddedFootprintSwitch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    
    mergeButton = [UIButton newAutoLayoutView];
    [mergeButton primaryStyle];
    [mergeButton addTarget:self action:@selector(startMerge) forControlEvents:UIControlEventTouchDown];
    [mergeButton setTitle:NSLocalizedString(@"Start Merge", @"开始合并") forState:UIControlStateNormal];
    [containerView addSubview:mergeButton];
    [mergeButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) excludingEdge:ALEdgeTop];
    [mergeButton autoSetDimension:ALDimensionHeight toSize:40];
    
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    mergeInOrder = sender.selectedSegmentIndex == 0 ? YES : NO;
}

- (void)switchValueChanged:(UISwitch *)sender{
    reserveManuallyAddedFootprint = sender.on;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startMerge{
    
    float mergedDistance = [mergedDistanceTF.text floatValue];
    if (mergedDistance == 0) mergedDistance = 200;
    
    NSArray *mergeArray = self.shareAnnoMA;
    NSMutableArray *excluedUserManuallyAddedArray = [NSMutableArray new];
    NSMutableArray *userManuallyAddedArray = [NSMutableArray new];
    if (reserveManuallyAddedFootprint) {
        [self.shareAnnoMA enumerateObjectsUsingBlock:^(EverywhereShareAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isUserManuallyAdded) [userManuallyAddedArray addObject:obj];
            else [excluedUserManuallyAddedArray addObject:obj];
        }];
        mergeArray = excluedUserManuallyAddedArray;
    }
    
    NSArray <NSArray *> *resultArrayArray;
    if (mergeInOrder) {
        resultArrayArray = [GCLocationAnalyser divideLocationsInOrderToArray:mergeArray mergedDistance:mergedDistance];
    }else{
        resultArrayArray = [GCLocationAnalyser divideLocationsOutOfOrderToArray:mergeArray mergedDistance:mergedDistance];
    }
    
    NSMutableArray *resultArray = [NSMutableArray new];
    [resultArrayArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [resultArray addObject:obj.firstObject];
    }];
    
    if (reserveManuallyAddedFootprint) {
        [resultArray addObjectsFromArray:userManuallyAddedArray];
    }
    
    [resultArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult comparisonResult;
        
        NSTimeInterval ti = [((EverywhereShareAnnotation *)obj1).startDate timeIntervalSinceDate:((EverywhereShareAnnotation *)obj2).startDate];
        
        if (ti < 0) comparisonResult = NSOrderedAscending;
        else comparisonResult = NSOrderedDescending;
        
        return comparisonResult;
    }];
    
    NSString *modeString = mergeInOrder ? NSLocalizedString(@"Merged By Moment", @"按时刻合并") : NSLocalizedString(@"Merged By Location", @"位置");
    NSString *distanceString = NSLocalizedString(@"MergedDistance", @"合并距离");
    NSString *reserveString = reserveManuallyAddedFootprint ? NSLocalizedString(@"ReserveManuallyAddedFootprint", @"保留手动添加足迹点") : NSLocalizedString(@"MergeManuallyAddedFootprint", @"合并手动添加足迹点");
    
    EverywhereShareRepository *editedShareRepository = [EverywhereShareRepository new];
    editedShareRepository.shareAnnos = resultArray;
    editedShareRepository.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Edit", @"编辑"),self.shareRepository.title];
    editedShareRepository.creationDate = NOW;
    editedShareRepository.shareRepositoryType = ShareRepositoryTypeRecorded;
    
    [EverywhereShareRepositoryManager addShareRepository:editedShareRepository];
    
    NSString *alertMessage = [NSString stringWithFormat:@"%@,%@ : %.1f,%@\n%@ : %@",modeString,distanceString,mergedDistance,reserveString,NSLocalizedString(@"Saved As", @"存储为"),editedShareRepository.title];
    
    [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:alertMessage]
                       animated:YES completion:nil];
    
    [mergeButton setTitle:NSLocalizedString(@"Succeeded", @"合并成功") forState:UIControlStateNormal];
}

#pragma mark - TableView

- (void)updateData{
    currentGroupArray = self.shareAnnoMA;
    [myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    EverywhereShareAnnotation *shareAnnotation = currentGroupArray[indexPath.row];
    cell.textLabel.text = shareAnnotation.customTitle;
    cell.detailTextLabel.text = shareAnnotation.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //if (self.shareAnnotationDidChangeHandler) self.shareAnnotationDidChangeHandler(currentGroupArray[indexPath.row]);
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

/*
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    EverywhereShareAnnotation *shareAnnotation = currentGroupArray[indexPath.row];
    
    UITableViewRowAction *renameRA = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:NSLocalizedString(@"Rename", @"更名")
                                                                       handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                           UIAlertController *alertController = [self createRenameAlertControllerWithHandler:^(UIAlertAction *action) {
                                                                               NSLog(@"%@",alertController.textFields.firstObject.text);
                                                                               shareAnnotation.customTitle = alertController.textFields.firstObject.text;
                                                                           }];
                                                                           [self presentViewController:alertController animated:YES completion:nil];
                                                                       }];
    
    UITableViewRowAction *deleteRA = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                        title:NSLocalizedString(@"Delete", @"删除")
                                                                      handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                          
                                                                      }];

    return @[renameRA,deleteRA];
}

*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EverywhereShareAnnotation *shareAnnotation = currentGroupArray[indexPath.row];
        [self.shareAnnoMA removeObject:shareAnnotation];
        [self updateData];
    }
}

#pragma mark - Text Field

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *allowedString=NumberAndDecimal;
    NSCharacterSet *forbidenCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:allowedString] invertedSet];
    NSArray *filteredArray=[string componentsSeparatedByCharactersInSet:forbidenCharacterSet];
    NSString *filteredString=[filteredArray componentsJoinedByString:@""];
    
    if (![string isEqualToString:filteredString]) {
        NSLog(@"The character 【%@】 is not allowed!",string);
    }
    
    return [string isEqualToString:filteredString];
}
@end
