//
//  FootprintAnnotationPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FootprintAnnotationPickerVC.h"
#import "EverywhereFootprintsRepository.h"
#import "EverywhereSettingManager.h"
#import "EverywhereCoreDataManager.h"
#import "GCLocationAnalyser.h"

@interface FootprintAnnotationPickerVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
//@property (copy,nonatomic) EverywhereFootprintsRepository *footprintsRepository;
@property (strong,nonatomic) NSMutableArray <EverywhereFootprintAnnotation *> *footprintAnnotationMA;
@end

@implementation FootprintAnnotationPickerVC{
    NSArray <EverywhereFootprintAnnotation *> *currentGroupArray;
    //NSMutableArray <EverywhereFootprintAnnotation *> *editedArray;
    UITextField *mergeDistanceTF;
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
    
    EverywhereFootprintsRepository *footprintsRepository = [EverywhereFootprintsRepository importFromMFRFile:[self.ewfrInfo filePath]];
    
    self.footprintAnnotationMA = [NSMutableArray arrayWithArray:footprintsRepository.footprintAnnotations];
    currentGroupArray = self.footprintAnnotationMA;//self.footprintAnnotationMA.reverseObjectEnumerator.allObjects;
    
    self.title = self.ewfrInfo.title;
    
    UIView *containerView = [UIView newAutoLayoutView];
    [self.view addSubview:containerView];
    [containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [containerView autoSetDimension:ALDimensionHeight toSize:165];

    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) excludingEdge:ALEdgeBottom];
    [myTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:containerView withOffset:-10];
    
    UILabel *mergeDistanceLabel = [UILabel newAutoLayoutView];
    mergeDistanceLabel.text = NSLocalizedString(@"MergeDistance :", @"合并距离：");
    [containerView addSubview:mergeDistanceLabel];
    [mergeDistanceLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [mergeDistanceLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [mergeDistanceLabel autoSetDimension:ALDimensionHeight toSize:30];

    mergeDistanceTF = [UITextField newAutoLayoutView];
    mergeDistanceTF.delegate = self;
    mergeDistanceTF.text = @"200";
    mergeDistanceTF.textAlignment = NSTextAlignmentCenter;
    mergeDistanceTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    mergeDistanceTF.layer.borderWidth = 1;
    mergeDistanceTF.layer.cornerRadius = 3;
    mergeDistanceTF.layer.borderColor = [[EverywhereSettingManager defaultManager].extendedTintColor CGColor];
    [containerView addSubview: mergeDistanceTF];
    [mergeDistanceTF autoAlignAxis:ALAxisHorizontal toSameAxisOfView:mergeDistanceLabel];
    [mergeDistanceTF autoSetDimension:ALDimensionWidth toSize:120];
    [mergeDistanceTF autoSetDimension:ALDimensionHeight toSize:30];
    [mergeDistanceTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];

    groupNameArray = @[NSLocalizedString(@"Merge By Moment", @"按时刻合并"),
                       NSLocalizedString(@"Merge By Location", @"按位置合并")];
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = 0;
    [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:groupSeg];
    groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [groupSeg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mergeDistanceLabel withOffset:10];
    [groupSeg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [groupSeg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    
    UILabel *reserveManuallyAddedFootprintLabel = [UILabel newAutoLayoutView];
    reserveManuallyAddedFootprintLabel.text = NSLocalizedString(@"Reserve Manually Added :", @"保留手动添加足迹点 :");
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
    [mergeButton setStyle:UIButtonStylePrimary];
    [mergeButton addTarget:self action:@selector(startMerge) forControlEvents:UIControlEventTouchDown];
    [mergeButton setTitle:NSLocalizedString(@"Start Merge", @"开始合并") forState:UIControlStateNormal];
    [containerView addSubview:mergeButton];
    [mergeButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 5, 10) excludingEdge:ALEdgeTop];
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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Merging...", @"正在合并...")];
    
    float mergeDistance = [mergeDistanceTF.text floatValue];
    if (mergeDistance == 0) mergeDistance = 200;
    
    NSArray *mergeArray = self.footprintAnnotationMA;
    NSMutableArray *excluedUserManuallyAddedArray = [NSMutableArray new];
    NSMutableArray *userManuallyAddedArray = [NSMutableArray new];
    if (reserveManuallyAddedFootprint) {
        [self.footprintAnnotationMA enumerateObjectsUsingBlock:^(EverywhereFootprintAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isUserManuallyAdded) [userManuallyAddedArray addObject:obj];
            else [excluedUserManuallyAddedArray addObject:obj];
        }];
        mergeArray = excluedUserManuallyAddedArray;
    }
    
    NSArray <NSArray *> *resultArrayArray;
    if (mergeInOrder) {
        resultArrayArray = [GCLocationAnalyser divideLocationsInOrderToArray:mergeArray mergeDistance:mergeDistance];
    }else{
        resultArrayArray = [GCLocationAnalyser divideLocationsOutOfOrderToArray:mergeArray mergeDistance:mergeDistance];
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
        
        NSTimeInterval ti = [((EverywhereFootprintAnnotation *)obj1).startDate timeIntervalSinceDate:((EverywhereFootprintAnnotation *)obj2).startDate];
        
        if (ti < 0) comparisonResult = NSOrderedAscending;
        else if (ti == 0) comparisonResult = NSOrderedSame;
        else comparisonResult = NSOrderedDescending;
        
        return comparisonResult;
    }];
    
    NSString *modeString = mergeInOrder ? NSLocalizedString(@"Merge By Moment", @"按时刻合并") : NSLocalizedString(@"Merge By Location", @"按位置合并");
    NSString *distanceString = NSLocalizedString(@"Merge Distance", @"合并距离");
    NSString *reserveString = reserveManuallyAddedFootprint ? NSLocalizedString(@"ReserveManuallyAddedFootprint", @"保留手动添加足迹点") : NSLocalizedString(@"MergeManuallyAddedFootprint", @"合并手动添加足迹点");
    
    EverywhereFootprintsRepository *editedFootprintsRepository = [EverywhereFootprintsRepository new];
    editedFootprintsRepository.footprintAnnotations = resultArray;
    
    if (!mergeInOrder) editedFootprintsRepository.radius = mergeDistance / 2.0;
    
    editedFootprintsRepository.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Edit", @"编辑"),self.ewfrInfo.title];
    editedFootprintsRepository.creationDate = NOW;
    editedFootprintsRepository.footprintsRepositoryType = FootprintsRepositoryTypeEdited;

    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{});
    
    
    BOOL succeeded = [EverywhereCoreDataManager addEWFR:editedFootprintsRepository];
    NSString *succeededString = succeeded ? NSLocalizedString(@"Succeeded", @"成功") : NSLocalizedString(@"Failed", @"失败");
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Merge ", @"合并"),succeededString]];
    [SVProgressHUD dismiss];
    
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@ : %.1f\n%@\n%@ :\n%@",modeString,distanceString,mergeDistance,reserveString,NSLocalizedString(@"Saved As", @"存储为"),editedFootprintsRepository.title];
    
    [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:alertMessage]
                       animated:YES completion:nil];
    
}

#pragma mark - TableView

- (void)updateData{
    currentGroupArray = self.footprintAnnotationMA;
    [myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    //cell.accessoryType = UITableViewCellAccessoryDetailButton;
    EverywhereFootprintAnnotation *footprintAnnotation = currentGroupArray[indexPath.row];
    NSString *headerString = footprintAnnotation.isUserManuallyAdded ? @"📍" : @"🔸";
    cell.textLabel.text = [NSString stringWithFormat:@"%lu %@ %@",(unsigned long)(indexPath.row + 1),headerString,footprintAnnotation.customTitle];
    
    NSMutableString *ms = [NSMutableString new];
    [ms appendFormat:@"%@:%.6f°,%.6f°",NSLocalizedString(@"Coord", @"座标"),footprintAnnotation.coordinateWGS84.latitude,footprintAnnotation.coordinateWGS84.longitude];
    if (footprintAnnotation.altitude != 0) [ms appendFormat:@"  %@:%.2fm",NSLocalizedString(@"Altitude", @"高度"),footprintAnnotation.altitude];
    //if (footprintAnnotation.speed > 0) [ms appendFormat:@"  %@:%.2fkm/h",NSLocalizedString(@"Speed", @"速度"),footprintAnnotation.speed * 3.6];
    cell.detailTextLabel.text = ms;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EverywhereFootprintAnnotation *footprintAnnotation = currentGroupArray[indexPath.row];
    
    NSString *alertTitle = NSLocalizedString(@"Items", @"选项");
    NSString *alertMessage = NSLocalizedString(@"Select an action", @"请选择操作");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rename",@"重命名")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             __block UITextField *tf;
                                                             UIAlertController *renameAC = [UIAlertController renameAlertControllerWithActionHandler:^(UIAlertAction *action) {
                                                                 
                                                                 footprintAnnotation.customTitle = tf.text;
                                                                 [self updateData];
                                                                 
                                                             } textFieldConfigurationHandler:^(UITextField *textField) {
                                                                 textField.text = footprintAnnotation.customTitle;
                                                                 tf = textField;
                                                             }];
                                                             
                                                             [self presentViewController:renameAC animated:YES completion:nil];
                                                         }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete",@"删除")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self.footprintAnnotationMA removeObject:footprintAnnotation];
                                                             [self updateData];
                                                         }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:renameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    if (iOS9) alertController.preferredAction = renameAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

/*
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    EverywhereFootprintAnnotation *footprintAnnotation = currentGroupArray[indexPath.row];
    
    UITableViewRowAction *renameRA = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:NSLocalizedString(@"Rename", @"重命名")
                                                                       handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                           UIAlertController *alertController = [self createRenameAlertControllerWithHandler:^(UIAlertAction *action) {
                                                                               if(DEBUGMODE) NSLog(@"%@",alertController.textFields.firstObject.text);
                                                                               footprintAnnotation.customTitle = alertController.textFields.firstObject.text;
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
        EverywhereFootprintAnnotation *footprintAnnotation = currentGroupArray[indexPath.row];
        [self.footprintAnnotationMA removeObject:footprintAnnotation];
        [self updateData];
    }
}

#pragma mark - Text Field

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *allowedString = NumberAndDecimal;
    NSCharacterSet *forbidenCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:allowedString] invertedSet];
    NSArray *filteredArray = [string componentsSeparatedByCharactersInSet:forbidenCharacterSet];
    NSString *filteredString = [filteredArray componentsJoinedByString:@""];
    
    if (![string isEqualToString:filteredString]) {
        if(DEBUGMODE) NSLog(@"The character 【%@】 is not allowed!",string);
    }
    
    return [string isEqualToString:filteredString];
    
    //return [NumberAndDecimal containsString:string];
}
@end
