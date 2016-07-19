//
//  ShareRepositoryPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareRepositoryPickerVC.h"
#import "EverywhereShareRepositoryManager.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // self.title = NSLocalizedString(@"Share Track Picker", @"分享轨迹选取器");
    
    groupNameArray = @[NSLocalizedString(@"Sended", @"发出的"),
                       NSLocalizedString(@"Received", @"接收的"),
                       NSLocalizedString(@"Recorded", @"记录的")];
    
    //currentGroupArray = self.placemarkInfoDictionary[kLocalityArray];
    //self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[self.initLocationMode],(unsigned long)currentGroupArray.count];
    
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = 1;
    [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:groupSeg];
    groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [groupSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
    
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
    
    [self updateDataSource:1];
}

- (void)clearAll{
    [EverywhereShareRepositoryManager setShareRepositoryArray:nil];
    [myTableView reloadData];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    // if (self.locationModeDidChangeHandler) self.locationModeDidChangeHandler(sender.selectedSegmentIndex);
    [self updateDataSource:sender.selectedSegmentIndex];
}

- (void)updateDataSource:(NSInteger)index{
    NSMutableArray *sendedArray = [NSMutableArray new];
    NSMutableArray *receivedArray = [NSMutableArray new];
    NSMutableArray *recordedArray = [NSMutableArray new];
    
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
            default:
                break;
        }
    }];
    
    switch (index) {
        case 0:{
            currentGroupArray = sendedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[0],(unsigned long)currentGroupArray.count];
        }
            break;
        case 1:{
            currentGroupArray = receivedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[1],(unsigned long)currentGroupArray.count];
        }
        case 2:{
            currentGroupArray = recordedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[2],(unsigned long)currentGroupArray.count];
        }
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
    EverywhereShareRepository *shareRepository = currentGroupArray[indexPath.row];
    cell.textLabel.text = shareRepository.title;
    NSString *tempString = NSLocalizedString(@"footprints", @"个足迹点");
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu %@ %@",(unsigned long)shareRepository.shareAnnos.count,tempString,[shareRepository.creationDate stringWithDefaultFormat]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.shareRepositoryDidChangeHandler) self.shareRepositoryDidChangeHandler(currentGroupArray[indexPath.row]);
    [self dismissViewControllerAnimated:YES completion:nil];
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
