//
//  ShareRepositoryPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareRepositoryPickerVC.h"

@interface ShareRepositoryPickerVC () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation ShareRepositoryPickerVC{
    UISegmentedControl *groupSeg;
    NSArray <NSString *> *groupNameArray;
    NSArray <EverywhereShareRepository *> *currentGroupArray;

    UITableView *myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Share Track Picker", @"分享轨迹选取器");
    
    groupNameArray = @[NSLocalizedString(@"Sended", @"发出的"),
                       NSLocalizedString(@"Received", @"接收的"),];
    
    //currentGroupArray = self.placemarkInfoDictionary[kLocalityArray];
    //self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[self.initLocationMode],(unsigned long)currentGroupArray.count];
    
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = 0;
    [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:groupSeg];
    groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
    [groupSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 0, 10) excludingEdge:ALEdgeBottom];
    
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 10, 10, 10) excludingEdge:ALEdgeTop];
    [myTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
    
    [self updateDataSource:0];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    // if (self.locationModeDidChangeHandler) self.locationModeDidChangeHandler(sender.selectedSegmentIndex);
    [self updateDataSource:sender.selectedSegmentIndex];
}

- (void)updateDataSource:(NSInteger)index{
    NSMutableArray *createdArray = [NSMutableArray new];
    NSMutableArray *receivedArray = [NSMutableArray new];
    
    [self.shareRepositoryArray enumerateObjectsUsingBlock:^(EverywhereShareRepository * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSharedByMe) [createdArray addObject:obj];
        else [receivedArray addObject:obj];
    }];
    
    switch (index) {
        case 0:{
            currentGroupArray = createdArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[0],(unsigned long)currentGroupArray.count];
        }
            break;
        case 1:{
            currentGroupArray = receivedArray;
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[1],(unsigned long)currentGroupArray.count];
        }        default:
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

@end
