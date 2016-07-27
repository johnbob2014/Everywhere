//
//  ShareRepositoryPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareRepositoryPickerVC.h"

#import "ShareRepositoryEditerVC.h"

#import "EverywhereShareRepositoryManager.h"
#import "EverywhereSettingManager.h"
#import "ShareShareRepositoryVC.h"

@interface ShareRepositoryPickerVC () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation ShareRepositoryPickerVC{
    UISegmentedControl *groupSeg;
    NSArray <NSString *> *groupNameArray;
    NSArray <EverywhereShareRepository *> *currentGroupArray;
    
    NSMutableArray <EverywhereShareRepository *> *shareRepositoryMA;

    UITableView *myTableView;
    
    //UIButton *clearAllButton;
}

- (void)viewWillAppear:(BOOL)animated{
    [self updateDataSource:groupSeg.selectedSegmentIndex];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    switch (self.showShareRepositoryType) {
        case ShareRepositoryTypeSended|ShareRepositoryTypeReceived|ShareRepositoryTypeRecorded|ShareRepositoryTypeEdited:
            groupNameArray = @[NSLocalizedString(@"Sended", @"发送的"),
                               NSLocalizedString(@"Received", @"接收的"),
                               NSLocalizedString(@"Recorded", @"记录的"),
                               NSLocalizedString(@"Edited", @"编辑的")];
            break;

        case ShareRepositoryTypeSended|ShareRepositoryTypeReceived:
            groupNameArray = @[NSLocalizedString(@"Sended", @"发送的"),
                               NSLocalizedString(@"Received", @"接收的")];
            break;
            
        case ShareRepositoryTypeRecorded|ShareRepositoryTypeEdited:
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
    NSMutableArray *sendedArray = [NSMutableArray new];
    NSMutableArray *receivedArray = [NSMutableArray new];
    NSMutableArray *recordedArray = [NSMutableArray new];
    NSMutableArray *editedArray = [NSMutableArray new];
    
    shareRepositoryMA = [NSMutableArray arrayWithArray:[EverywhereShareRepositoryManager shareRepositoryArray]];
    
    [shareRepositoryMA enumerateObjectsUsingBlock:^(EverywhereShareRepository * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.shareRepositoryType) {
            case ShareRepositoryTypeSended:
                [sendedArray addObject:obj];
                break;
            case ShareRepositoryTypeReceived:
                [receivedArray addObject:obj];
                break;
            case ShareRepositoryTypeRecorded:
                [recordedArray addObject:obj];
                break;
            case ShareRepositoryTypeEdited:
                [editedArray addObject:obj];
                break;
            default:
                break;
        }
    }];
    
    switch (index) {
        case 0:
            currentGroupArray = sendedArray;
            if (self.showShareRepositoryType == ShareRepositoryTypeRecorded) currentGroupArray = recordedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[0],(unsigned long)currentGroupArray.count];
            break;
        case 1:
            currentGroupArray = receivedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[1],(unsigned long)currentGroupArray.count];
            break;
        case 2:
            currentGroupArray = recordedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[2],(unsigned long)currentGroupArray.count];
            break;
        case 3:
            currentGroupArray = editedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[3],(unsigned long)currentGroupArray.count];
            break;
        default:
            break;
            
    }
    [myTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    EverywhereShareRepository *shareRepository = currentGroupArray[indexPath.row];
    NSString *headerString;
    switch (shareRepository.shareRepositoryType) {
        case ShareRepositoryTypeSended:
            headerString = @"🏹 ";
            break;
        case ShareRepositoryTypeReceived:
            headerString = @"🎣 ";
            break;
        case ShareRepositoryTypeRecorded:
            headerString = @"🚴 ";
            break;
        case ShareRepositoryTypeEdited:
            headerString = @"✏️ ";
            break;
        default:
            break;
    }
    cell.textLabel.text = [headerString stringByAppendingString:shareRepository.title];
    NSString *tempString = NSLocalizedString(@"footprints", @"个足迹点");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@ %@",(unsigned long)shareRepository.shareAnnos.count,tempString,[shareRepository.creationDate stringWithDefaultFormat]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EverywhereShareRepository *shareRepository = currentGroupArray[indexPath.row];
    
    NSString *alertTitle = NSLocalizedString(@"Items", @"选项");
    NSString *alertMessage = NSLocalizedString(@"Select an action", @"请选择操作");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *showAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Show",@"查看")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                         if (self.shareRepositoryDidChangeHandler) self.shareRepositoryDidChangeHandler(currentGroupArray[indexPath.row]);
                                                     }];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share",@"分享")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           ShareShareRepositoryVC *ssVC = [ShareShareRepositoryVC new];
                                                           ssVC.shareRepository = shareRepository;
                                                           NSData *thumbImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"地球_300_300"], 0.5);
                                                           ssVC.shareThumbImageData = thumbImageData;
                                                           
                                                           ssVC.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.8, 200);
                                                           ssVC.landscapeContentSizeInPopup = CGSizeMake(200, ScreenWidth * 0.8);
                                                           [self.popupController pushViewController:ssVC animated:YES];
                                                       }];
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Rename",@"重命名")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            __block UITextField *tf;
                                                            UIAlertController *renameAC = [UIAlertController renameAlertControllerWithActionHandler:^(UIAlertAction *action) {
                                                                
                                                                EverywhereShareRepository *copyShareRepository = [shareRepository copy];
                                                                copyShareRepository.title = tf.text;
                                                                NSLog(@"EverywhereShareRepository new name : %@",copyShareRepository.title);
                                                                [shareRepositoryMA removeObject:shareRepository];
                                                                [shareRepositoryMA addObject:copyShareRepository];
                                                                [EverywhereShareRepositoryManager setShareRepositoryArray:shareRepositoryMA];
                                                                [self updateDataSource:groupSeg.selectedSegmentIndex];
                                                                
                                                            } textFieldConfigurationHandler:^(UITextField *textField) {
                                                                textField.text = shareRepository.title;
                                                                tf = textField;
                                                            }];
                                                            
                                                            [self presentViewController:renameAC animated:YES completion:nil];
                                                        }];

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:showAction];
    if([EverywhereSettingManager defaultManager].hasPurchasedShare){
        
        [alertController addAction:shareAction];
    }
    [alertController addAction:renameAction];
    [alertController addAction:cancelAction];
    alertController.preferredAction = showAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
 
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"%@",cell.accessoryView);
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    if ([EverywhereSettingManager defaultManager].hasPurchasedRecord) {
        ShareRepositoryEditerVC *shareRepositoryEditerVC = [ShareRepositoryEditerVC new];
        shareRepositoryEditerVC.shareRepository = currentGroupArray[indexPath.row];
        shareRepositoryEditerVC.contentSizeInPopup = CGSizeMake(300, 400);
        shareRepositoryEditerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
        [self.popupController pushViewController:shareRepositoryEditerVC animated:YES];
    }else{
        [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"You haven't got RecordFucntionAndRecordMode so you can not edit it.", @"您没有购买足迹记录和记录模式，无法编辑。")]
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
        EverywhereShareRepository *shareRepository = currentGroupArray[indexPath.row];
        [shareRepositoryMA removeObject:shareRepository];
        [EverywhereShareRepositoryManager setShareRepositoryArray:shareRepositoryMA];
        
        [self updateDataSource:groupSeg.selectedSegmentIndex];
    }
}

@end
