//
//  GCFileBrowser.m
//  Everywhere
//
//  Created by BobZhang on 16/8/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCFileBrowser.h"
#import "GCFileTableViewCell.h"

@interface GCFileBrowser ()  <UITableViewDelegate,UITableViewDataSource,GCFileTableViewCellDelegate>

@property (strong,nonatomic) NSArray <UIImage *> *normalImageArray;
@property (strong,nonatomic) NSArray <UIImage *> *highlightedImageArray;
//@property (strong,nonatomic) UISegmentedControl *segmentedControl;
//@property (strong,nonatomic) NSArray <NSString *> *contentNameArray;

@end

@implementation GCFileBrowser{
    NSArray <NSString *> *contentNameArray;
    NSMutableArray <NSString *> *selectedContentNameArray;
    
    UIView *topView;
    UISegmentedControl *segmentedControl;
    UITableView *contentTableView;
}

/*
@synthesize directoryPath;

- (NSString *)directoryPath{
    if (!directoryPath){
        directoryPath = Path_Documents;
    }
    return directoryPath;
}
*/

- (void)setDirectoryPath:(NSString *)newDirectoryPath{
    _directoryPath = newDirectoryPath;
    contentNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:newDirectoryPath error:NULL];
    NSLog(@"%@",contentNameArray);
    selectedContentNameArray = [NSMutableArray new];
}

- (NSArray<UIImage *> *)normalImageArray{
    if (!_normalImageArray){
        NSMutableArray <UIImage *> *imageArray = [NSMutableArray array];
        for (NSString *imageName in @[@"icon-play1",@"icon-view1",@"icon-copy1",@"icon-move1",@"icon-rename1",@"icon-trash1",@"icon-export1"]) {
            [imageArray addObject:[UIImage imageNamed:imageName]];
        }
        _normalImageArray = imageArray;
    }
    return _normalImageArray;
}

- (NSArray<UIImage *> *)highlightedImageArray{
    if (!_highlightedImageArray){
        NSMutableArray <UIImage *> *imageArray = [NSMutableArray array];
        for (NSString *imageName in @[@"icon-play2",@"icon-view2",@"icon-copy2",@"icon-move2",@"icon-rename2",@"icon-trash2",@"icon-export2"]) {
            [imageArray addObject:[UIImage imageNamed:imageName]];
        }
        _highlightedImageArray = imageArray;
    }
    return _highlightedImageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!self.directoryPath) self.directoryPath = Path_Documents;
    
    self.title = [self.directoryPath lastPathComponent];
    
    self.view.backgroundColor = VCBackgroundColor;
    
    [self initTopView];
    
    [self initSegmentedControl];
    
    [self initContentTabelView];
}

- (void)initTopView{
    topView = [UIView newAutoLayoutView];
    topView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:topView];
    [topView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [topView autoSetDimension:ALDimensionHeight toSize:40];
}

- (void)initSegmentedControl{
    segmentedControl = [[UISegmentedControl alloc] initWithItems:self.normalImageArray];
    segmentedControl.tintColor = [UIColor blueColor];
    
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [segmentedControl setMomentary:YES];
    
    [segmentedControl setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    //segmentedControl.contentMode = UIViewContentModeBottomLeft;
    
    [segmentedControl setBackgroundImage:[[UIImage imageNamed:@"transparent"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[[UIImage imageNamed:@"transparent"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    /*
    [segmentedControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    */
    
    segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:segmentedControl];
    [segmentedControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10) excludingEdge:ALEdgeTop];
    [segmentedControl autoSetDimension:ALDimensionHeight toSize:40];
}


- (void)initContentTabelView{
    contentTableView = [UITableView newAutoLayoutView];
    [contentTableView registerClass:[GCFileTableViewCell class] forCellReuseIdentifier:@"GCFileTableViewCell"];
    //[contentTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [contentTableView setBackgroundColor:[UIColor clearColor]];
    [contentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    //[contentTableView setShowsHorizontalScrollIndicator:YES];
    //[contentTableView setShowsHorizontalScrollIndicator:YES];
    
    [self.view addSubview:contentTableView];
    
    [contentTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView withOffset:0];
    [contentTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:segmentedControl withOffset:0];
    [contentTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [contentTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    NSLog(@"selectedSegmentIndex : %ld",(long)index);
    [segmentedControl setImage:self.highlightedImageArray[index] forSegmentAtIndex:index];
    [self performSelector:@selector(deselectSegmentControlAtIndex:) withObject:[NSNumber numberWithInteger:index] afterDelay:0.30f];
}

- (void)deselectSegmentControlAtIndex:(NSNumber *)deselectIndex{
    NSInteger index = [deselectIndex integerValue];
    [segmentedControl setImage:self.normalImageArray[index] forSegmentAtIndex:index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contentNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GCFileTableViewCell"];
    if (!cell)
        cell = [[GCFileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCFileTableViewCell"];
    
    // reset background for reused cells
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-short"]];
    [backgroundImageView setContentMode:UIViewContentModeTopRight];
    [cell setBackgroundView:backgroundImageView];
    
    NSString *contentName = contentNameArray[indexPath.row];
    NSString *contentPath = [self.directoryPath stringByAppendingPathComponent:contentName];
    BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&isDirectory];
    
    [cell.iconButton setSelected:[selectedContentNameArray containsObject:contentName]];
    
    // show "tall" bg if selected
    if ([cell.iconButton isSelected]) {
        
    }
    
    if (isDirectory) {
        [cell setIsFile:NO];
        
        [cell.countLabel setHidden:NO];
        
        [cell.changedLabel setHidden:YES];
        [cell.changedValueLabel setHidden:YES];
        [cell.sizeLabel setHidden:YES];
        [cell.sizeValueLabel setHidden:YES];
        
        NSUInteger numberOfSubitems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:contentPath error:NULL].count;
        
        if ( numberOfSubitems)
            [cell.countLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)numberOfSubitems]];
        else
            [cell.countLabel setText:@"-"];
    } else {
        [cell setIsFile:YES];
        
        [cell.countLabel setHidden:YES];
        
        [cell.changedLabel setHidden:NO];
        [cell.changedValueLabel setHidden:NO];
        [cell.sizeLabel setHidden:NO];
        [cell.sizeValueLabel setHidden:NO];
    }
    
    [cell.titleTextField setText:contentName];
    [cell.titleTextField sizeToFit];
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:contentPath error:NULL];
    
    [cell.createdValueLabel setText:[[attributes fileCreationDate] stringWithDefaultFormat]];
    [cell.sizeValueLabel setText:[NSString stringWithFormat:@"%.0llu",[attributes fileSize]]];
    [cell.changedValueLabel setText:[[attributes fileModificationDate] stringWithDefaultFormat]];
    
    cell.delegate = self;
    
    [cell setIndexPath:indexPath];
    
    [cell.accessoryView setAutoresizingMask:UIViewAutoresizingNone];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

#pragma mark - KOFileTableViewDelegate
- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapIconAtIndexPath:(NSIndexPath *)indexPath {
    NSString *contentName = contentNameArray[indexPath.row];
    
    //cell.clipsToBounds = YES;
    
    if ([selectedContentNameArray containsObject:contentName]) {
        [cell.iconButton setSelected:NO];
        [selectedContentNameArray removeObject:contentName];
    } else {
        [cell.iconButton setSelected:YES];
        [selectedContentNameArray addObject:contentName];
    }
    
}
@end
