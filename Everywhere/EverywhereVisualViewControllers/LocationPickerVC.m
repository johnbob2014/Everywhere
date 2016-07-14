//
//  LocationPickerVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "LocationPickerVC.h"

@interface LocationPickerVC ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation LocationPickerVC{
    UISegmentedControl *groupSeg;
    UITableView *myTableView;
    NSArray <NSString *> *groupNameArray;
    NSArray <NSString *> *currentGroupArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    groupNameArray = @[NSLocalizedString(@"St.", @""),
                       NSLocalizedString(@"Dist.", @""),
                       NSLocalizedString(@"City", @""),
                       NSLocalizedString(@"Prov.", @""),
                       NSLocalizedString(@"State", @"")];
    
    //currentGroupArray = self.placemarkInfoDictionary[kLocalityArray];
    //self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[self.initLocationMode],(unsigned long)currentGroupArray.count];
    
    groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
    groupSeg.selectedSegmentIndex = self.initLocationMode;
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
    
    [self updateDataSource:self.initLocationMode];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    if (self.locationModeDidChangeHandler) self.locationModeDidChangeHandler(sender.selectedSegmentIndex);
    [self updateDataSource:sender.selectedSegmentIndex];
}

- (void)updateDataSource:(LocationMode)locationMode{
    switch (locationMode) {
        case LocationModeThoroughfare:{
            currentGroupArray = self.placemarkInfoDictionary[kThoroughfareArray];
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[0],(unsigned long)currentGroupArray.count];
        }
            break;
        case LocationModeSubLocality:{
            currentGroupArray = self.placemarkInfoDictionary[kSubLocalityArray];
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[1],(unsigned long)currentGroupArray.count];
        }
            break;
        case LocationModeLocality:{
            currentGroupArray = self.placemarkInfoDictionary[kLocalityArray];
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[2],(unsigned long)currentGroupArray.count];
        }
            break;
        case LocationModeAdministrativeArea:{
            currentGroupArray = self.placemarkInfoDictionary[kAdministrativeAreaArray];
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[3],(unsigned long)currentGroupArray.count];
        }
            break;
        case LocationModeCountry:{
            currentGroupArray = self.placemarkInfoDictionary[kCountryArray];
            self.title = [NSString stringWithFormat:@"%@ (%ld)",groupNameArray[4],(unsigned long)currentGroupArray.count];
        }
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

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return currentGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cell.textLabel.text = currentGroupArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.locationDidChangeHandler) self.locationDidChangeHandler(currentGroupArray[indexPath.row]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
