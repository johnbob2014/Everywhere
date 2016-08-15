//
//  GCFileBrowser.m
//  Everywhere
//
//  Created by BobZhang on 16/8/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCFileBrowser.h"
#import "GCFileBrowserConfiguration.h"
#import "GCFileTableViewCell.h"

@interface GCFileBrowser ()  <UITableViewDelegate,UITableViewDataSource,GCFileTableViewCellDelegate>

/**
 底部操作菜单 操作项 名称数组（普通状态）
 */
@property (strong,nonatomic) NSArray <NSString *> *actionNameArray;

/**
 底部操作菜单 操作项 图片数组（普通状态）
 */
@property (strong,nonatomic) NSArray <UIImage *> *normalImageArray;

/**
 底部操作菜单 操作项 图片数组（高亮状态）
 */
@property (strong,nonatomic) NSArray <UIImage *> *highlightedImageArray;


@end

@implementation GCFileBrowser{
    NSArray <NSMutableDictionary <NSString *,id> *> *contentAttributeMutableDictionaryArray;
    UIView *topView;
    UILabel *pathLabelInTopView,*infoLabelInTopView;;
    
    UISegmentedControl *segmentedControl;
    UITableView *contentTableView;
    
    UIDocumentInteractionController *documentInteractionController;
}

#pragma mark - Getter & Setter


- (void)setDirectoryPath:(NSString *)newDirectoryPath{
    _directoryPath = newDirectoryPath;
    
    contentAttributeMutableDictionaryArray = [GCFileBrowser contentAttributeMutableDictionaryArrayWtihDirectoryPath:newDirectoryPath];
    
    self.title = [self.directoryPath lastPathComponent];
    
    pathLabelInTopView.text = [[self.directoryPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""] substringFromIndex:1];
    
    infoLabelInTopView.text = [NSString stringWithFormat:@"%lu",(unsigned long)contentAttributeMutableDictionaryArray.count];
}

+ (NSArray <NSMutableDictionary <NSString *,id> *> *)contentAttributeMutableDictionaryArrayWtihDirectoryPath:(NSString *)directoryPath{

    NSMutableArray <NSMutableDictionary <NSString *,id> *> *tempMA = [NSMutableArray new];
    
    for (NSString *contentName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL]) {
        
        if ([directoryPath isEqualToString:Path_Documents]){
            if ([contentName containsString:@"tencent_analysis_WXOMTAStore"]) continue;
            if ([[contentName pathExtension] containsString:@"sqlite"]) continue;
        }
        
        NSMutableDictionary <NSString *,id> *contentAttributes = [NSMutableDictionary new];
        [contentAttributes setValue:contentName forKey:kContentName];
        
        NSString *contentPath = [directoryPath stringByAppendingPathComponent:contentName];
        [contentAttributes setValue:contentPath forKey:kContentPath];
        
        BOOL isDirectory;
        [[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&isDirectory];
        [contentAttributes setValue:[NSNumber numberWithBool:isDirectory] forKey:kContentIsDirectory];
        
        NSUInteger subitemCount = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:contentPath error:NULL].count;
        [contentAttributes setValue:[NSNumber numberWithUnsignedInteger:subitemCount] forKey:kContentSubitemCount];
        
        NSDictionary *attributesFromFileManager = [[NSFileManager defaultManager] attributesOfItemAtPath:contentPath error:NULL];
        [contentAttributes setValue:attributesFromFileManager forKey:kContentAttributesFromFileManager];
        
        [contentAttributes setValue:[NSNumber numberWithBool:NO] forKey:kContentIsSelected];
        
        [tempMA addObject:contentAttributes];
    }
    
    return tempMA;
}

#define AllActionNormalImageArray @[@"icon-play1",@"icon-view1",@"icon-copy1",@"icon-move1",@"icon-rename1",@"icon-trash1",@"icon-export1"]
#define AllActionHighlightedImageArray @[@"icon-play2",@"icon-view2",@"icon-copy2",@"icon-move2",@"icon-rename2",@"icon-trash2",@"icon-export2"]

- (NSArray<UIImage *> *)normalImageArray{
    if (!_normalImageArray){
        NSMutableArray <UIImage *> *imageArray = [NSMutableArray array];
        for (NSString *imageName in @[@"icon-copy1",@"icon-move1",@"icon-rename1",@"icon-trash1",@"icon-export1"]) {
            [imageArray addObject:[UIImage imageNamed:imageName]];
        }
        _normalImageArray = imageArray;
    }
    return _normalImageArray;
}

- (NSArray<UIImage *> *)highlightedImageArray{
    if (!_highlightedImageArray){
        NSMutableArray <UIImage *> *imageArray = [NSMutableArray array];
        for (NSString *imageName in @[@"icon-copy2",@"icon-move2",@"icon-rename2",@"icon-trash2",@"icon-export2"]) {
            [imageArray addObject:[UIImage imageNamed:imageName]];
        }
        _highlightedImageArray = imageArray;
    }
    return _highlightedImageArray;
}


#pragma mark - Life Cycle

- (instancetype)initWithDirectoryPath:(NSString *)directoryPath{
    self = [super init];
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self) {
        self.directoryPath = directoryPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.actionNameArray = @[NSLocalizedString(@"Copy",@"复制"),NSLocalizedString(@"Cut",@"剪切"),NSLocalizedString(@"Paste",@"粘贴")];
    
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    self.view.backgroundColor = VCBackgroundColor;
    
    if (!self.directoryPath) self.directoryPath = Path_Documents;
    
    [self initTopView];
    
    if (self.enableActionMenu) [self initSegmentedControl];
    
    [self initContentTabelView];
    
}

#pragma mark - Init Subviews

- (void)initTopView{
    topView = [UIView newAutoLayoutView];

    topView.backgroundColor = VCBackgroundColor;
    [self.view addSubview:topView];
    [topView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [topView autoSetDimension:ALDimensionHeight toSize:30];
    
    pathLabelInTopView = [UILabel newAutoLayoutView];
    [pathLabelInTopView setFont:GCFONT_FILES_COUNTER];
    [pathLabelInTopView setTextColor:GCCOLOR_FILES_COUNTER];
    [pathLabelInTopView setShadowColor:GCCOLOR_FILES_COUNTER_SHADOW];
    [pathLabelInTopView setShadowOffset:CGSizeMake(0, 1)];
    pathLabelInTopView.text = [[self.directoryPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""] substringFromIndex:1];
    [topView addSubview:pathLabelInTopView];
    [pathLabelInTopView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [pathLabelInTopView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    infoLabelInTopView = [UILabel newAutoLayoutView];
    [infoLabelInTopView setFont:GCFONT_FILES_COUNTER];
    [infoLabelInTopView setTextColor:GCCOLOR_FILES_COUNTER];
    [infoLabelInTopView setShadowColor:GCCOLOR_FILES_COUNTER_SHADOW];
    [infoLabelInTopView setShadowOffset:CGSizeMake(0, 1)];
    infoLabelInTopView.text = [NSString stringWithFormat:@"0/%lu",(unsigned long)contentAttributeMutableDictionaryArray.count];
    [topView addSubview:infoLabelInTopView];
    [infoLabelInTopView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [infoLabelInTopView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

- (void)initSegmentedControl{
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:self.normalImageArray];
    segmentedControl.tintColor = GCCOLOR_FILES_COUNTER;
    
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
    [segmentedControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 5, 10) excludingEdge:ALEdgeTop];
    [segmentedControl autoSetDimension:ALDimensionHeight toSize:44];
}

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    if(DEBUGMODE) NSLog(@"selectedSegmentIndex : %ld",(long)index);
    
    if (self.actionNameArray) return;
    [segmentedControl setImage:self.highlightedImageArray[index] forSegmentAtIndex:index];
    [self performSelector:@selector(deselectSegmentControlAtIndex:) withObject:[NSNumber numberWithInteger:index] afterDelay:0.5f];
}

- (void)deselectSegmentControlAtIndex:(NSNumber *)deselectIndex{
    NSInteger index = [deselectIndex integerValue];
    [segmentedControl setImage:self.normalImageArray[index] forSegmentAtIndex:index];
}

- (void)initContentTabelView{
    contentTableView = [UITableView newAutoLayoutView];
    [contentTableView registerClass:[GCFileTableViewCell class] forCellReuseIdentifier:@"GCFileTableViewCell"];
    //[contentTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [contentTableView setBackgroundColor:[UIColor clearColor]];
    //[contentTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLineEtched];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    //[contentTableView setShowsHorizontalScrollIndicator:YES];
    //[contentTableView setShowsHorizontalScrollIndicator:YES];
    
    [self.view addSubview:contentTableView];
    
    [contentTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView withOffset:0];
    
    if (self.enableActionMenu && [self.view.subviews containsObject:segmentedControl])
        [contentTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:segmentedControl withOffset:5];
    else
        [contentTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    [contentTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [contentTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
}

#pragma mark - UITableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contentAttributeMutableDictionaryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GCFileTableViewCell"];
    if (!cell) cell = [[GCFileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GCFileTableViewCell"];
    
    NSDictionary *contentAttributes = contentAttributeMutableDictionaryArray[indexPath.row];
    
    cell.isSelected = [contentAttributes[kContentIsSelected] boolValue];
    
    if ([contentAttributes[kContentIsDirectory] boolValue]) {
        cell.isDirectory = YES;
        
        NSUInteger subitemCount = [contentAttributes[kContentSubitemCount] unsignedIntegerValue];
        
        if (subitemCount > 0)
            [cell.countLabel setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)subitemCount,NSLocalizedString(@"Subitem", @"个子项")]];
        else
            [cell.countLabel setText:NSLocalizedString(@"Empty", @"目录为空")];
        
    } else {
        cell.isDirectory = NO;
    }
    
    cell.title = contentAttributes[kContentName];
    
    NSDictionary *attributes = contentAttributes[kContentAttributesFromFileManager];
    
    [cell.createdValueLabel setText:[[attributes fileCreationDate] stringWithDefaultFormat]];
    [cell.sizeValueLabel setText:[GCFileBrowser fileSizeString:[attributes fileSize]]];
    [cell.changedValueLabel setText:[[attributes fileModificationDate] stringWithDefaultFormat]];
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    
    [cell.accessoryView setAutoresizingMask:UIViewAutoresizingNone];
    
    return cell;
}

+ (NSString *)fileSizeString:(unsigned long long)fileSize{
    NSString *fileSizeString;
    float floatSize;
    if (fileSize > 1024.0f * 1024.0f){
        floatSize = (double)fileSize / (1024.0f * 1024.0f);
        fileSizeString = [NSString stringWithFormat:@"%.2f M",floatSize];
    }else if (fileSize >= 1024.0f){
        floatSize = (double)fileSize / 1024.0f;
        fileSizeString = [NSString stringWithFormat:@"%.1f K",floatSize];
    }else{
        fileSizeString = [NSString stringWithFormat:@"%.0llu B",fileSize];
    }
    return fileSizeString;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (ScreenHeight > 568 ? 65 : 55);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    GCFileTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.title = cell.title;
    
    NSDictionary *contentAttributes = contentAttributeMutableDictionaryArray[indexPath.row];
    if ([contentAttributes[kContentIsDirectory] boolValue]){
        GCFileBrowser *fileBrowser = [GCFileBrowser new];
        fileBrowser.edgesForExtendedLayout = UIRectEdgeNone;
        
        fileBrowser.directoryPath = contentAttributes[kContentPath];
        
        fileBrowser.enableActionMenu = self.enableActionMenu;
        fileBrowser.enableDocumentInteractionController = self.enableDocumentInteractionController;
        
        if (self.navigationController)
            [self.navigationController pushViewController:fileBrowser animated:YES];
        else{
            UINavigationController *nav =[[UINavigationController alloc] initWithRootViewController:self];
            [nav pushViewController:fileBrowser animated:YES];
        }
        
    }else{
        if (self.enableDocumentInteractionController){
            NSString *filePath = contentAttributes[kContentPath];
            documentInteractionController = [UIDocumentInteractionController new];
            //documentInteractionController.delegate = self;
            documentInteractionController.URL = [NSURL fileURLWithPath:filePath];
            [documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
        }
    }
}

#pragma mark - GCFileTableViewDelegate

- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapIconAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *contentAttributes = contentAttributeMutableDictionaryArray[indexPath.row];
    
    if ([contentAttributes[kContentIsSelected] boolValue]) {
        cell.isSelected = NO;
        [contentAttributes setValue:[NSNumber numberWithBool:NO] forKey:kContentIsSelected];
    } else {
        cell.isSelected = YES;
        [contentAttributes setValue:[NSNumber numberWithBool:YES] forKey:kContentIsSelected];
    }
    
    __block NSUInteger selectedContentCount = 0;
    [contentAttributeMutableDictionaryArray enumerateObjectsUsingBlock:^(NSMutableDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[kContentIsSelected] boolValue]) selectedContentCount++;
    }];
    
    infoLabelInTopView.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)selectedContentCount,(unsigned long)contentAttributeMutableDictionaryArray.count];
}

- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapActionAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
