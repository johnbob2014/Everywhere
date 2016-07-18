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
    UITableView *myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Share Track Picker", @"分享轨迹选取器");
    
    myTableView = [UITableView newAutoLayoutView];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:myTableView];
    [myTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];//UIEdgeInsetsMake(0, 10, 10, 10) excludingEdge:ALEdgeTop];
    //[myTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.shareRepositoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    EverywhereShareRepository *shareRepository = self.shareRepositoryArray[indexPath.row];
    cell.textLabel.text = shareRepository.title;
    cell.detailTextLabel.text = [shareRepository.creationDate stringWithDefaultFormat];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.shareRepositoryDidChangeHandler) self.shareRepositoryDidChangeHandler(self.shareRepositoryArray[indexPath.row]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
