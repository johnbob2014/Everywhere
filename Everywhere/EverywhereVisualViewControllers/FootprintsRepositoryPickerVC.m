//
//  FootprintsRepositoryPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FootprintsRepositoryPickerVC.h"

#import "FootprintsRepositoryEditerVC.h"

#import "EverywhereCoreDataManager.h"
#import "EverywhereSettingManager.h"
#import "ShareFootprintsRepositoryVC.h"

@interface FootprintsRepositoryPickerVC () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation FootprintsRepositoryPickerVC{
    UISegmentedControl *groupSeg;
    NSArray <NSString *> *groupNameArray;
    NSArray <EWFRInfo *> *currentGroupArray;
    NSArray <EWFRInfo *> *ewfrInfoArray;

    UITableView *myTableView;
    
    //UIButton *clearAllButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateDataSource:groupSeg.selectedSegmentIndex];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch (self.showFootprintsRepositoryType) {
        /*
        case FootprintsRepositoryTypeSent|FootprintsRepositoryTypeReceived|FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited|FootprintsRepositoryTypeImported:
            groupNameArray = @[NSLocalizedString(@"Sent", @"发送的"),
                               NSLocalizedString(@"Received", @"接收的"),
                               NSLocalizedString(@"Recorded", @"记录的"),
                               NSLocalizedString(@"Edited", @"编辑的"),
                               NSLocalizedString(@"Imported", @"导入的")];
            break;
        */
        case FootprintsRepositoryTypeSent|FootprintsRepositoryTypeReceived|FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited:
            groupNameArray = @[NSLocalizedString(@"Sent", @"发送的"),
                               NSLocalizedString(@"Received", @"接收的"),
                               NSLocalizedString(@"Recorded", @"记录的"),
                               NSLocalizedString(@"Edited", @"编辑的")];
            break;

        case FootprintsRepositoryTypeSent|FootprintsRepositoryTypeReceived:
            groupNameArray = @[NSLocalizedString(@"Sent", @"发送的"),
                               NSLocalizedString(@"Received", @"接收的")];
            break;
            
        case FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited:
            groupNameArray = @[NSLocalizedString(@"Recorded", @"记录的"),
                               NSLocalizedString(@"Edited", @"编辑的")];
            break;
            
        default:
            break;
    }
    
    
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = 0;
    [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:groupSeg];
    groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [groupSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
    
    if (groupNameArray.count == 1) groupSeg.hidden = YES;
    
    /*
    clearAllButton = [UIButton newAutoLayoutView];
    [clearAllButton infoStyle];
    [clearAllButton addTarget:self action:@selector(clearAll) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:clearAllButton];
    [clearAllButton autoSetDimension:ALDimensionHeight toSize:44];
    [clearAllButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withMultiplier:0.8];
    [clearAllButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [clearAllButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
     */
    
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 10, 10, 10) excludingEdge:ALEdgeTop];
    //[myTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    //[myTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:clearAllButton withOffset:-10];
    
    [self updateDataSource:0];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    // if (self.locationModeDidChangeHandler) self.locationModeDidChangeHandler(sender.selectedSegmentIndex);
    [self updateDataSource:sender.selectedSegmentIndex];
}

- (void)updateDataSource:(NSInteger)index{
    NSMutableArray *sentArray = [NSMutableArray new];
    NSMutableArray *receivedArray = [NSMutableArray new];
    NSMutableArray *recordedArray = [NSMutableArray new];
    NSMutableArray *editedArray = [NSMutableArray new];

    ewfrInfoArray = [EverywhereCoreDataManager allEWFRs];
    
    [ewfrInfoArray enumerateObjectsUsingBlock:^(EWFRInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch ([obj.footprintsRepositoryType integerValue]) {
            case FootprintsRepositoryTypeSent:
                [sentArray addObject:obj];
                break;
            case FootprintsRepositoryTypeReceived:
                [receivedArray addObject:obj];
                break;
            case FootprintsRepositoryTypeRecorded:
                [recordedArray addObject:obj];
                break;
            case FootprintsRepositoryTypeEdited:
                [editedArray addObject:obj];
                break;
            default:
                break;
        }
    }];
    
    switch (index) {
        case 0:
            currentGroupArray = sentArray;
            if (self.showFootprintsRepositoryType == (FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited)) currentGroupArray = recordedArray;
            break;
        case 1:
            currentGroupArray = receivedArray;
            if (self.showFootprintsRepositoryType == (FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited)) currentGroupArray = editedArray;
            break;
        case 2:
            currentGroupArray = recordedArray;
            break;
        case 3:
            currentGroupArray = editedArray;
            break;
        default:
            break;
            
    }
    
    self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[index],(unsigned long)currentGroupArray.count];
    
    [myTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    EWFRInfo *ewfrInfo = currentGroupArray[indexPath.row];
    NSString *headerString;
    
    switch ([ewfrInfo.footprintsRepositoryType integerValue]) {
        case FootprintsRepositoryTypeSent:
            headerString = @"📤";
            break;
        case FootprintsRepositoryTypeReceived:
            headerString = @"📥";
            break;
        case FootprintsRepositoryTypeRecorded:
            headerString = @"🎥";
            break;
        case FootprintsRepositoryTypeEdited:
            headerString = @"📦";
            break;
        default:
            break;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%lu %@ %@",(unsigned long)(indexPath.row + 1),headerString,ewfrInfo.title];
    
    NSMutableString *ms = [NSMutableString new];
    [ms appendFormat:@"%@:%lu",NSLocalizedString(@"FpCount", @"足迹点数"),(unsigned long)[ewfrInfo.footprintsCount integerValue]];
    [ms appendFormat:@"  %@:%.2fkm",NSLocalizedString(@"Distance", @"里程"),[ewfrInfo.distance doubleValue]/1000.0];
    [ms appendFormat:@"  %@:%.2fkm/h",NSLocalizedString(@"AvgSpeed", @"平时时速"),[ewfrInfo.averageSpeed doubleValue]*3.6];
    cell.detailTextLabel.text = ms;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EWFRInfo *ewfrInfo = currentGroupArray[indexPath.row];
    EverywhereFootprintsRepository *footprintsRepository = [EverywhereFootprintsRepository importFromMFRFile:[ewfrInfo filePath]];
    footprintsRepository.title = ewfrInfo.title;
    
    NSString *alertTitle = NSLocalizedString(@"Items", @"选项");
    NSString *alertMessage = NSLocalizedString(@"Select an action", @"请选择操作");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show",@"查看")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                         if (self.footprintsRepositoryDidChangeHandler) {
                                                             self.footprintsRepositoryDidChangeHandler(footprintsRepository);
                                                         }
                                                     }];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share",@"分享")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           ShareFootprintsRepositoryVC *shareFRVC = [ShareFootprintsRepositoryVC new];
                                                           shareFRVC.footprintsRepository = [footprintsRepository copy];
                                                           shareFRVC.thumbImage = [UIImage imageNamed:@"地球_300_300"];
                                                           
                                                           shareFRVC.userDidSelectedPurchaseShareFunctionHandler = ^(){
                                                               UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note",@"提示") message:NSLocalizedString(@"You haven't puchased ShareAndBrowse.",@"您尚未购买分享和浏览！")];
                                                               [self presentViewController:alertController animated:YES completion:nil];
                                                           };
                                                           
                                                           if(self.popupController) [self.popupController pushViewController:shareFRVC animated:YES];
                                                           
                                                       }];
    
    UIAlertAction *exportAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Export",@"导出")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if (![EverywhereSettingManager defaultManager].hasPurchasedImportAndExport){
                                                                 UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note",@"提示") message:NSLocalizedString(@"You haven't puchased ImportAndExport.",@"您尚未购买导入和导出！")];
                                                                 [self presentViewController:alertController animated:YES completion:nil];
                                                             }else{

                                                                 NSString *dirPath = [[NSURL documentURL].path stringByAppendingPathComponent:@"Exported"];
                                                                 [NSFileManager directoryExistsAtPath:dirPath autoCreate:YES];
                                                                 
                                                                 NSString *exportToGPXPath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gpx",footprintsRepository.title]];
                                                                 BOOL exportToGPX = [footprintsRepository exportToGPXFile:exportToGPXPath];
                                                                 
                                                                 NSString *exportToMFRPath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mfr",footprintsRepository.title]];
                                                                 BOOL exportToMFR = [footprintsRepository exportToMFRFile:exportToMFRPath];
                                                                 
                                                                 NSMutableString *messageMS = [NSMutableString new];
                                                                 [messageMS appendFormat:@"%@ %@",NSLocalizedString(@"Export To MFR", @"导出为MFR文件"),exportToMFR ? NSLocalizedString(@"Succeeded", @"成功") : NSLocalizedString(@"Failed", @"失败")];
                                                                 [messageMS appendFormat:@"\n%@ %@",NSLocalizedString(@"Export To GPX", @"导出为GPX文件"),exportToGPX ? NSLocalizedString(@"Succeeded", @"成功") : NSLocalizedString(@"Failed", @"失败")];
                                                                 
                                                                 UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note",@"提示") message:messageMS];
                                                                 [self presentViewController:alertController animated:YES completion:nil];
                                                             }
                                                             
                                                         }];
    
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rename",@"重命名")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            __block UITextField *tf;
                                                            UIAlertController *renameAC = [UIAlertController renameAlertControllerWithActionHandler:^(UIAlertAction *action) {
                                                                
                                                                ewfrInfo.title = tf.text;
                                                                [ewfrInfo.managedObjectContext save:NULL];
                                                                
                                                                [self updateDataSource:groupSeg.selectedSegmentIndex];
                                                                
                                                            } textFieldConfigurationHandler:^(UITextField *textField) {
                                                                textField.text = footprintsRepository.title;
                                                                tf = textField;
                                                            }];
                                                            
                                                            [self presentViewController:renameAC animated:YES completion:nil];
                                                        }];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete",@"删除")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [EverywhereCoreDataManager removeEWFRInfo:ewfrInfo];
                                                             [self updateDataSource:groupSeg.selectedSegmentIndex];
                                                         }];

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:showAction];
    [alertController addAction:shareAction];
    [alertController addAction:exportAction];
    [alertController addAction:renameAction];
    [alertController addAction:deleteAction];
    [alertController addAction:cancelAction];
    if (iOS9) alertController.preferredAction = showAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
 
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    EWFRInfo *ewfrInfo = currentGroupArray[indexPath.row];
    
    if ([EverywhereSettingManager defaultManager].hasPurchasedRecordAndEdit) {
        FootprintsRepositoryEditerVC *footprintsRepositoryEditerVC = [FootprintsRepositoryEditerVC new];
        footprintsRepositoryEditerVC.ewfrInfo = ewfrInfo;
        footprintsRepositoryEditerVC.contentSizeInPopup = self.contentSizeInPopup;
        footprintsRepositoryEditerVC.landscapeContentSizeInPopup = self.landscapeContentSizeInPopup;
        [self.popupController pushViewController:footprintsRepositoryEditerVC animated:YES];
    }else{
        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"You haven't got RecordFucntionAndRecordMode so you can not edit it.", @"您没有购买足迹记录 & 记录模式，无法编辑。")]
                           animated:YES
                         completion:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

/*
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    uitableviewrowaction
}
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EWFRInfo *ewfrInfo = currentGroupArray[indexPath.row];
        [EverywhereCoreDataManager removeEWFRInfo:ewfrInfo];
        [self updateDataSource:groupSeg.selectedSegmentIndex];
    }
}

@end
