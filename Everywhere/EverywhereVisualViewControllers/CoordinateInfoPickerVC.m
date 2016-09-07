//
//  CoordinateInfoPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/9/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CoordinateInfoPickerVC.h"
#import "EverywhereCoreDataManager.h"

@interface CoordinateInfoPickerVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NSArray *coordinateInfoArray;
@end

@implementation CoordinateInfoPickerVC{
    UITableView *myTableView;
    NSArray *currentGroupArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Favorite", @"收藏夹");
    
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
//    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) excludingEdge:ALEdgeBottom];
//    [myTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view withOffset:-10];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self updateData];
}

#pragma mark - TableView

- (void)updateData{
    [[EverywhereCoreDataManager appDelegateMOC] save:NULL];
    
    self.coordinateInfoArray = [CoordinateInfo fetchFavoriteCoordinateInfosInManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
    currentGroupArray = self.coordinateInfoArray;
    if (currentGroupArray.count > 0)
        self.title = [NSString stringWithFormat:@"%@ - %lu",NSLocalizedString(@"Favorite", @"收藏夹"),(unsigned long)currentGroupArray.count];
    [myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    CoordinateInfo *coordinateInfo = currentGroupArray[indexPath.row];
    //NSString *headerString = coordinateInfo.isUserManuallyAdded ? @"📍" : @"📌";
    cell.textLabel.text = [NSString stringWithFormat:@"%lu ⭐️ %@",(unsigned long)(indexPath.row + 1),coordinateInfo.title];
    
    NSMutableString *ms = [NSMutableString new];
    if (coordinateInfo.subtitle) [ms appendFormat:@"%@  ",coordinateInfo.subtitle];
    [ms appendFormat:@"%@:%.4f°,%.4f°",NSLocalizedString(@"Coord", @"座标"),[coordinateInfo.latitude doubleValue],[coordinateInfo.longitude doubleValue]];
    if (coordinateInfo.altitude > 0) [ms appendFormat:@"  %@:%.2fm",NSLocalizedString(@"Altitude", @"高度"),[coordinateInfo.altitude doubleValue]];
    //if (coordinateInfo.speed > 0) [ms appendFormat:@"  %@:%.2fkm/h",NSLocalizedString(@"Speed", @"速度"),[coordinateInfo.speed doubleValue]* 3.6];
    cell.detailTextLabel.text = ms;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CoordinateInfo *coordinateInfo = currentGroupArray[indexPath.row];
    
    NSString *alertTitle = NSLocalizedString(@"Items", @"选项");
    NSString *alertMessage = NSLocalizedString(@"Select an action", @"请选择操作");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show on map",@"在地图上查看")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self dismissViewControllerAnimated:YES completion:nil];
                                                           if (self.didSelectCoordinateInfo) {
                                                               self.didSelectCoordinateInfo(coordinateInfo);
                                                           }
                                                       }];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rename",@"重命名")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             __block UITextField *tf;
                                                             UIAlertController *renameAC = [UIAlertController renameAlertControllerWithOKActionHandler:^(UIAlertAction *action) {
                                                                 
                                                                 coordinateInfo.customTitle = tf.text;
                                                                 [self updateData];
                                                                 
                                                             } textFieldConfigurationHandler:^(UITextField *textField) {
                                                                 textField.text = coordinateInfo.title;
                                                                 tf = textField;
                                                             }];
                                                             
                                                             [self presentViewController:renameAC animated:YES completion:nil];
                                                         }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete",@"删除")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                             coordinateInfo.favorite = @(NO);
                                                             [self updateData];
                                                         }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:showAction];
    [alertController addAction:renameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    if (iOS9) alertController.preferredAction = showAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    CoordinateInfo *coordinateInfo = currentGroupArray[indexPath.row];
    
    __block UITextField *tf;
    UIAlertController *renameAC = [UIAlertController renameAlertControllerWithOKActionHandler:^(UIAlertAction *action) {
        
        coordinateInfo.customTitle = tf.text;
        [self updateData];
        
    } textFieldConfigurationHandler:^(UITextField *textField) {
        textField.text = coordinateInfo.title;
        tf = textField;
    }];
    
    [self presentViewController:renameAC animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CoordinateInfo *coordinateInfo = currentGroupArray[indexPath.row];
        
        coordinateInfo.favorite = @(NO);
        [self updateData];
    }
}

@end
