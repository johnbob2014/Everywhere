//
//  ShareAnnotationPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareAnnotationPickerVC.h"
#import "EverywhereSettingManager.h"

@interface ShareAnnotationPickerVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation ShareAnnotationPickerVC{
    NSArray <EverywhereShareAnnotation *> *currentGroupArray;
    NSMutableArray <EverywhereShareAnnotation *> *editedArray;
    UITextField *mergedDistanceTF;
    NSArray <NSString *> *groupNameArray;
    UISegmentedControl *groupSeg;
    UITableView *myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    currentGroupArray = self.shareAnnos;
    editedArray = [NSMutableArray arrayWithArray:self.shareAnnos];
    
    UILabel *mergedDistanceLabel = [UILabel newAutoLayoutView];
    mergedDistanceLabel.text = NSLocalizedString(@"MergedDistance :", @"合并距离：");
    [self.view addSubview:mergedDistanceLabel];
    [mergedDistanceLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [mergedDistanceLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [mergedDistanceLabel autoSetDimension:ALDimensionHeight toSize:30];

    mergedDistanceTF = [UITextField newAutoLayoutView];
    mergedDistanceTF.text = @"200";
    mergedDistanceTF.textAlignment = NSTextAlignmentCenter;
    mergedDistanceTF.clearButtonMode = UITextFieldViewModeAlways;
    mergedDistanceTF.layer.borderWidth = 1;
    mergedDistanceTF.layer.borderColor = [[EverywhereSettingManager defaultManager].color CGColor];
    
    [self.view addSubview: mergedDistanceTF];
    [mergedDistanceTF autoAlignAxis:ALAxisHorizontal toSameAxisOfView:mergedDistanceLabel];
    [mergedDistanceTF autoSetDimension:ALDimensionWidth toSize:120];
    [mergedDistanceTF autoSetDimension:ALDimensionHeight toSize:30];
    [mergedDistanceTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];

    groupNameArray = @[NSLocalizedString(@"By Time", @"按时间"),
                       NSLocalizedString(@"By Location", @"按位置")];
    
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = 0;
    [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:groupSeg];
    groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
    
    [groupSeg autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mergedDistanceLabel withOffset:10];
    [groupSeg autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [groupSeg autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 10, 10, 10) excludingEdge:ALEdgeTop];
    
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    // if (self.locationModeDidChangeHandler) self.locationModeDidChangeHandler(sender.selectedSegmentIndex);
    // [self updateDataSource:sender.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
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

- (UIAlertController *)createRenameAlertControllerWithHandler:(void (^)(UIAlertAction *action))handler{
    
    NSString *alertTitle = NSLocalizedString(@"Rename", @"更名");
    NSString *alertMessage = NSLocalizedString(@"Enter a new name", @"输入新名称");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定")
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    return alertController;
}


/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EverywhereShareAnnotation *shareAnnotation = currentGroupArray[indexPath.row];
        
    }
}
*/

@end
