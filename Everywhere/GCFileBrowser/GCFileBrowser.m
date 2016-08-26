//
//  GCFileBrowser.m
//  Everywhere
//
//  Created by BobZhang on 16/8/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define AllActionNormalImageArray @[@"icon-play1",@"icon-view1",@"icon-copy1",@"icon-move1",@"icon-rename1",@"icon-trash1",@"icon-export1"]
#define AllActionHighlightedImageArray @[@"icon-play2",@"icon-view2",@"icon-copy2",@"icon-move2",@"icon-rename2",@"icon-trash2",@"icon-export2"]

#import "GCFileBrowser.h"
#import "GCFileBrowserConfiguration.h"
#import "GCFileTableViewCell.h"

@interface GCFileBrowser ()  <UITableViewDelegate,UITableViewDataSource,GCFileTableViewCellDelegate>

/**
 底部操作菜单 操作项 名称数组（普通状态）
 */
//@property (strong,nonatomic) NSArray <NSString *> *actionNameArray;

/**
 底部操作菜单 操作项 图片数组（普通状态）
 */
//@property (strong,nonatomic) NSArray <UIImage *> *normalImageArray;

/**
 底部操作菜单 操作项 图片数组（高亮状态）
 */
//@property (strong,nonatomic) NSArray <UIImage *> *highlightedImageArray;

/**
 *  选中的 ContentAttributeDictionary MutableArray
 */
@property (strong,nonatomic) NSMutableArray <NSMutableDictionary *> *selectedCADMA;

/**
 *  待复制的 ContentAttributeDictionary MutableArray
 */
@property (strong,nonatomic) NSMutableArray <NSDictionary *> *waitToCopyCADMA;

/**
 *  待移动的 ContentAttributeDictionary MutableArray
 */
@property (strong,nonatomic) NSMutableArray <NSDictionary *> *waitToMoveCADMA;

/**
 *  是否正在等待处理复制或粘贴
 */
@property (assign,nonatomic) BOOL isWaitingToPaste;

@property (assign,nonatomic) NSString *infoStringToAdd;
@end

@implementation GCFileBrowser{
    NSArray <NSMutableDictionary <NSString *,id> *> *contentAttributeMutableDictionaryArray;
    UIView *topView;
    UILabel *pathLabelInTopView,*infoLabelInTopView;;
    
    UIView *bottomView;
    UIView *buttonContainerView;
    UIButton *copyButton,*cutButton,*pasteButton,*deleteButton,*renameButton,*newFolderButton,*showHideBottomInfoTVButton;
    UIView *labelPlaceHolderView;
    UILabel *copyButtonLabel,*cutButtonLabel,*pasteButtonLabel,*deleteButtonLabel,*renameButtonLabel,*newFolderButtonLabel,*showHideBottomInfoTVButtonLabel;
    UITextView *infoTextViewInBottomView;
    NSLayoutConstraint *bottomConstraintForBottomView;
    
    //UISegmentedControl *segmentedControl;
    
    UITableView *contentTableView;
    
    UIDocumentInteractionController *documentInteractionController;
}

#pragma mark - Getter & Setter

- (void)setInfoStringToAdd:(NSString *)infoStringToAdd{
    _infoStringToAdd = infoStringToAdd;
    infoTextViewInBottomView.text = [infoStringToAdd stringByAppendingFormat:@"\n%@",infoTextViewInBottomView.text];
}

- (void)setDirectoryPath:(NSString *)newDirectoryPath{
    _directoryPath = newDirectoryPath;
    
    [self updateDataWithNewDirectoryPath:newDirectoryPath];
}

- (void)updateDataWithNewDirectoryPath:(NSString *)newDirectoryPath{
    self.selectedCADMA = nil;
    
    contentAttributeMutableDictionaryArray = [GCFileBrowser contentAttributeMutableDictionaryArrayWtihDirectoryPath:newDirectoryPath];
    
    self.title = [self.directoryPath lastPathComponent];
    
    pathLabelInTopView.text = [[self.directoryPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""] substringFromIndex:1];
    
    infoLabelInTopView.text = [NSString stringWithFormat:@"%lu",(unsigned long)contentAttributeMutableDictionaryArray.count];
    
    [contentTableView reloadData];
}

+ (NSArray <NSMutableDictionary <NSString *,id> *> *)contentAttributeMutableDictionaryArrayWtihDirectoryPath:(NSString *)directoryPath{

    NSMutableArray <NSMutableDictionary <NSString *,id> *> *tempMA = [NSMutableArray new];
    
    for (NSString *contentName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL]) {
        
        // 如果为 Documents 目录，排除部分文件和文件夹
        if ([directoryPath isEqualToString:[NSURL documentURL].path]){
            // 排除 微信统计文件
            if ([contentName containsString:@"tencent_analysis_WXOMTAStore"]) continue;
            // 排除 3个 CoreDate支持文件
            if ([[contentName pathExtension] containsString:@"sqlite"]) continue;
            // 排除 Inbox 文件夹
            if ([contentName isEqualToString:@"Inbox"]) continue;
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

- (NSMutableArray<NSMutableDictionary *> *)selectedCADMA{
    if (!_selectedCADMA){
        __block NSMutableArray<NSMutableDictionary *> *tempCADMA = [NSMutableArray new];
        [contentAttributeMutableDictionaryArray enumerateObjectsUsingBlock:^(NSMutableDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[kContentIsSelected] boolValue]) [tempCADMA addObject:obj];
        }];
        _selectedCADMA = tempCADMA;
    }
    return _selectedCADMA;
}

- (NSMutableArray<NSDictionary *> *)waitToCopyCADMA{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kWaitToCopyContentAttributeDictionaryMutableArray];
}

- (void)setWaitToCopyCADMA:(NSMutableArray<NSDictionary *> *)waitToCopyCADMA{
    [[NSUserDefaults standardUserDefaults] setValue:waitToCopyCADMA forKey:kWaitToCopyContentAttributeDictionaryMutableArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableArray<NSDictionary *> *)waitToMoveCADMA{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kWaitToMoveContentAttributeDictionaryMutableArray];
}

- (void)setWaitToMoveCADMA:(NSMutableArray<NSDictionary *> *)waitToMoveCADMA{
    [[NSUserDefaults standardUserDefaults] setValue:waitToMoveCADMA forKey:kWaitToMoveContentAttributeDictionaryMutableArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isWaitingToPaste{
    if (self.waitToCopyCADMA.count > 0 || self.waitToMoveCADMA.count > 0) return YES;
    return NO;
}
/*
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
*/

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.actionNameArray = @[NSLocalizedString(@"Copy",@"复制"),NSLocalizedString(@"Cut",@"剪切"),NSLocalizedString(@"Paste",@"粘贴")];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (!self.directoryPath) self.directoryPath = [NSURL documentURL].path;
    
    [self initTopView];
    
    if (self.enableActionMenu) [self initBottomView]; //[self initSegmentedControl];
    
    [self initContentTabelView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateDataWithNewDirectoryPath:self.directoryPath];
    
    if (infoTextViewInBottomView){
        infoTextViewInBottomView.text = nil;
        if (self.waitToCopyCADMA.count == 0 && self.waitToMoveCADMA.count == 0){
            [self hideBottomInfoTV];
        }else if (self.waitToCopyCADMA.count > 0){
            bottomConstraintForBottomView.constant = 0;
            self.infoStringToAdd = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.waitToCopyCADMA.count,NSLocalizedString(@"items has been copied.Select destination to paste.", @"项已复制，请选择目标位置进行粘贴。")];
        }else if (self.waitToMoveCADMA.count > 0){
            bottomConstraintForBottomView.constant = 0;
            self.infoStringToAdd = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.waitToMoveCADMA.count,NSLocalizedString(@"items has been cut.Select destination to paste.", @"项已剪切，请选择目标位置进行粘贴。")];
        }
    }
    
}

#pragma mark - Init Subviews

- (void)initTopView{
    topView = [UIView newAutoLayoutView];

    //topView.backgroundColor = VCBackgroundColor;
    [self.view addSubview:topView];
    [topView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [topView autoSetDimension:ALDimensionHeight toSize:30];
    
    pathLabelInTopView = [UILabel newAutoLayoutView];
    [pathLabelInTopView setStyle:UILabelStyleBrownBold];
    pathLabelInTopView.text = [[self.directoryPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""] substringFromIndex:1];
    [topView addSubview:pathLabelInTopView];
    [pathLabelInTopView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [pathLabelInTopView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    infoLabelInTopView = [UILabel newAutoLayoutView];
    [infoLabelInTopView setStyle:UILabelStyleBrownBold];
    infoLabelInTopView.text = [NSString stringWithFormat:@"0/%lu",(unsigned long)contentAttributeMutableDictionaryArray.count];
    [topView addSubview:infoLabelInTopView];
    [infoLabelInTopView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [infoLabelInTopView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
}

- (void)initBottomView{
    bottomView = [UIView newAutoLayoutView];
    bottomView.backgroundColor = ClearColor;//DEBUGMODE ? RandomFlatColor : ClearColor;
    [self.view addSubview:bottomView];
    [bottomView autoSetDimension:ALDimensionHeight toSize:5 + FileActionButtonEdgeLength + FileActionLabelHeight + 5 + TextViewHeight + 5];
    [bottomView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [bottomView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    bottomConstraintForBottomView = [bottomView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:- BottomConstraintConstant];
    
    buttonContainerView = [UIView newAutoLayoutView];
    buttonContainerView.backgroundColor = ClearColor;//DEBUGMODE ? RandomFlatColor : ClearColor;
    [bottomView addSubview:buttonContainerView];
    [buttonContainerView autoSetDimensionsToSize:CGSizeMake(FileActionButtonEdgeLength * 7 + FileActionButtonOffset * 6, FileActionButtonEdgeLength)];
    [buttonContainerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [buttonContainerView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    copyButton = [UIButton newAutoLayoutView];
    [copyButton setImage:[UIImage imageNamed:@"icon-copy1@2x"] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"icon-copy2@2x"] forState:UIControlStateHighlighted];
    [copyButton addTarget:self action:@selector(copyButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:copyButton];
    [copyButton autoSetDimensionsToSize:FileActionButtonSize];
    [copyButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [copyButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    cutButton = [UIButton newAutoLayoutView];
    [cutButton setImage:[UIImage imageNamed:@"icon-move1@2x"] forState:UIControlStateNormal];
    [cutButton setImage:[UIImage imageNamed:@"icon-move2@2x"] forState:UIControlStateHighlighted];
    [cutButton addTarget:self action:@selector(cutButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:cutButton];
    [cutButton autoSetDimensionsToSize:FileActionButtonSize];
    [cutButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [cutButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:copyButton withOffset:FileActionButtonOffset];
    
    pasteButton = [UIButton newAutoLayoutView];
    [pasteButton setImage:[UIImage imageNamed:@"icon-play1@2x"] forState:UIControlStateNormal];
    [pasteButton setImage:[UIImage imageNamed:@"icon-play2@2x"] forState:UIControlStateHighlighted];
    [pasteButton addTarget:self action:@selector(pasteButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:pasteButton];
    [pasteButton autoSetDimensionsToSize:FileActionButtonSize];
    [pasteButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [pasteButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:cutButton withOffset:FileActionButtonOffset];
    
    deleteButton = [UIButton newAutoLayoutView];
    [deleteButton setImage:[UIImage imageNamed:@"icon-trash1@2x"] forState:UIControlStateNormal];
    [deleteButton setImage:[UIImage imageNamed:@"icon-trash2@2x"] forState:UIControlStateHighlighted];
    [deleteButton addTarget:self action:@selector(deleteButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:deleteButton];
    [deleteButton autoSetDimensionsToSize:FileActionButtonSize];
    [deleteButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [deleteButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:pasteButton withOffset:FileActionButtonOffset];
    
    renameButton = [UIButton newAutoLayoutView];
    [renameButton setImage:[UIImage imageNamed:@"icon-rename1@2x"] forState:UIControlStateNormal];
    [renameButton setImage:[UIImage imageNamed:@"icon-rename2@2x"] forState:UIControlStateHighlighted];
    [renameButton addTarget:self action:@selector(renameButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:renameButton];
    [renameButton autoSetDimensionsToSize:FileActionButtonSize];
    [renameButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [renameButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:deleteButton withOffset:FileActionButtonOffset];
    
    newFolderButton = [UIButton newAutoLayoutView];
    [newFolderButton setTitle:@"📁" forState:UIControlStateNormal];
    //[newFolderButton setImage:[UIImage imageNamed:@"icon-rename1@2x"] forState:UIControlStateNormal];
    //[newFolderButton setImage:[UIImage imageNamed:@"icon-rename2@2x"] forState:UIControlStateHighlighted];
    [newFolderButton addTarget:self action:@selector(newFolderButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:newFolderButton];
    [newFolderButton autoSetDimensionsToSize:FileActionButtonSize];
    [newFolderButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [newFolderButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:renameButton withOffset:FileActionButtonOffset];
    
    showHideBottomInfoTVButton = [UIButton newAutoLayoutView];
    [showHideBottomInfoTVButton setImage:[UIImage imageNamed:@"icon-view1@2x"] forState:UIControlStateNormal];
    [showHideBottomInfoTVButton setImage:[UIImage imageNamed:@"icon-view2@2x"] forState:UIControlStateHighlighted];
    [showHideBottomInfoTVButton addTarget:self action:@selector(showHideBottomInfoTVButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:showHideBottomInfoTVButton];
    [showHideBottomInfoTVButton autoSetDimensionsToSize:FileActionButtonSize];
    [showHideBottomInfoTVButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [showHideBottomInfoTVButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:newFolderButton withOffset:FileActionButtonOffset];
    
    //if (ScreenWidth > 320) buttonContainerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    labelPlaceHolderView = [UIView newAutoLayoutView];
    [bottomView addSubview:labelPlaceHolderView];
    [labelPlaceHolderView autoSetDimension:ALDimensionHeight toSize:FileActionLabelHeight];
    [labelPlaceHolderView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:buttonContainerView];
    [labelPlaceHolderView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [labelPlaceHolderView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    copyButtonLabel = [UILabel newAutoLayoutView];
    copyButtonLabel.textColor = [UIColor blackColor];
    copyButtonLabel.textAlignment = NSTextAlignmentCenter;
    copyButtonLabel.font = FileActionLabelFont;
    copyButtonLabel.text = NSLocalizedString(@"Copy", @"复制");
    [bottomView addSubview:copyButtonLabel];
    [copyButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [copyButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:copyButton];
    [copyButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:copyButton];
    
    cutButtonLabel = [UILabel newAutoLayoutView];
    cutButtonLabel.textColor = [UIColor blackColor];
    cutButtonLabel.textAlignment = NSTextAlignmentCenter;
    cutButtonLabel.font = FileActionLabelFont;
    cutButtonLabel.text = NSLocalizedString(@"Cut", @"剪切");
    [bottomView addSubview:cutButtonLabel];
    [cutButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [cutButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:cutButton];
    [cutButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:cutButton];
    
    pasteButtonLabel = [UILabel newAutoLayoutView];
    pasteButtonLabel.textColor = [UIColor blackColor];
    pasteButtonLabel.textAlignment = NSTextAlignmentCenter;
    pasteButtonLabel.font = FileActionLabelFont;
    pasteButtonLabel.text = NSLocalizedString(@"Paste", @"粘贴");
    [bottomView addSubview:pasteButtonLabel];
    [pasteButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [pasteButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:pasteButton];
    [pasteButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:pasteButton];
    
    deleteButtonLabel = [UILabel newAutoLayoutView];
    deleteButtonLabel.textColor = [UIColor blackColor];
    deleteButtonLabel.textAlignment = NSTextAlignmentCenter;
    deleteButtonLabel.font = FileActionLabelFont;
    deleteButtonLabel.text = NSLocalizedString(@"Delete", @"删除");
    [bottomView addSubview:deleteButtonLabel];
    [deleteButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [deleteButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:deleteButton];
    [deleteButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:deleteButton];
    
    renameButtonLabel = [UILabel newAutoLayoutView];
    renameButtonLabel.textColor = [UIColor blackColor];
    renameButtonLabel.textAlignment = NSTextAlignmentCenter;
    renameButtonLabel.font = FileActionLabelFont;
    renameButtonLabel.text = NSLocalizedString(@"Rename", @"重命名");
    [bottomView addSubview:renameButtonLabel];
    [renameButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [renameButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:renameButton];
    [renameButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:renameButton  withMultiplier:1.2];
    
    newFolderButtonLabel = [UILabel newAutoLayoutView];
    newFolderButtonLabel.textColor = [UIColor blackColor];
    newFolderButtonLabel.textAlignment = NSTextAlignmentCenter;
    newFolderButtonLabel.font = FileActionLabelFont;
    newFolderButtonLabel.text = NSLocalizedString(@"New", @"新文件夹");
    [bottomView addSubview:newFolderButtonLabel];
    [newFolderButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [newFolderButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:newFolderButton];
    [newFolderButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:newFolderButton];
    
    showHideBottomInfoTVButtonLabel = [UILabel newAutoLayoutView];
    showHideBottomInfoTVButtonLabel.textColor = [UIColor blackColor];
    showHideBottomInfoTVButtonLabel.textAlignment = NSTextAlignmentCenter;
    showHideBottomInfoTVButtonLabel.font = FileActionLabelFont;
    showHideBottomInfoTVButtonLabel.text = NSLocalizedString(@"Info", @"详情");
    [bottomView addSubview:showHideBottomInfoTVButtonLabel];
    [showHideBottomInfoTVButtonLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:labelPlaceHolderView];
    [showHideBottomInfoTVButtonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:showHideBottomInfoTVButton];
    [showHideBottomInfoTVButtonLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:showHideBottomInfoTVButton];

    infoTextViewInBottomView = [UITextView newAutoLayoutView];
    infoTextViewInBottomView.editable = NO;
    infoTextViewInBottomView.textAlignment = NSTextAlignmentLeft;
    //[infoTextViewInBottomView setStyle:UILabelStyleBrownBold];
    [bottomView addSubview:infoTextViewInBottomView];
    [infoTextViewInBottomView autoSetDimension:ALDimensionHeight toSize:TextViewHeight];
    [infoTextViewInBottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 5, 5) excludingEdge:ALEdgeTop];
}

- (void)copyButtonTD{
    infoTextViewInBottomView.text = nil;
    [self showBottomInfoTV];
    if (self.selectedCADMA.count > 0){
        self.waitToCopyCADMA = (NSMutableArray<NSDictionary *> *)self.selectedCADMA;
        
        self.infoStringToAdd = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.selectedCADMA.count,NSLocalizedString(@"items has been copied.Select destination to paste.", @"项已复制，请选择目标位置进行粘贴。")];
        
    }else{
        self.infoStringToAdd = NSLocalizedString(@"Haven't choose an item yet.", @"尚未选择项目，请点击名称左侧图标进行选择。");
    }
}

- (void)cutButtonTD{
    infoTextViewInBottomView.text = nil;
    [self showBottomInfoTV];
    if (self.selectedCADMA.count > 0){
        
        self.waitToMoveCADMA = (NSMutableArray<NSDictionary *> *)self.selectedCADMA;
        
        self.infoStringToAdd = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.selectedCADMA.count,NSLocalizedString(@"items has been cut.Select destination to paste.", @"项已剪切，请选择目标位置进行粘贴。")];
        
    }else{
        self.infoStringToAdd = NSLocalizedString(@"Haven't choose an item yet.", @"尚未选择项目，请点击名称左侧图标进行选择。");
    }
}

- (void)pasteButtonTD{
    if (self.waitToCopyCADMA.count == 0 && self.waitToMoveCADMA.count == 0){
        self.infoStringToAdd = NSLocalizedString(@"No item to copy or move.", @"没有要复制或移动的项目。");
        return;
    }else if (self.waitToCopyCADMA.count > 0){
        [self showBottomInfoTV];
        
        __block NSUInteger successCount = 0;
        [self.waitToCopyCADMA enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *contentPath = obj[kContentPath];
            
            if ([[contentPath stringByDeletingLastPathComponent] isEqualToString:self.directoryPath]){
                UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                                    message:NSLocalizedString(@"Can not perform Copy in original directory", @"无法在源目录中进行复制操作！")];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
            
            NSString *successString;
            NSError *error;
            NSString *destinationPath = [self.directoryPath stringByAppendingPathComponent:obj[kContentName]];
            if([[NSFileManager defaultManager] copyItemAtPath:contentPath toPath:destinationPath error:&error]){
                successString = NSLocalizedString(@"Succeeded", @"成功");
                successCount++;
            }else{
                successString = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Failed", @"失败"),error.localizedFailureReason];
            }
            
            self.infoStringToAdd = [NSString stringWithFormat:@"%@ %lu/%lu : %@",NSLocalizedString(@"Now copying", @"正在复制"),idx + 1,(unsigned long)self.waitToCopyCADMA.count,successString];
        }];
        
        self.infoStringToAdd = [NSString stringWithFormat:@"%@ %@ : %lu,%@ : %lu",NSLocalizedString(@"Finish copying.", @"复制完成。"),NSLocalizedString(@"Succeeded", @"成功"),(unsigned long)successCount,NSLocalizedString(@"Failed", @"失败"),self.waitToCopyCADMA.count - successCount];
        
        self.waitToCopyCADMA = nil;
        [self updateDataWithNewDirectoryPath:self.directoryPath];
    }else if (self.waitToMoveCADMA.count > 0){
        [self showBottomInfoTV];
        
        __block NSUInteger successCount = 0;
        [self.waitToMoveCADMA enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *contentPath = obj[kContentPath];
            
            if ([[contentPath stringByDeletingLastPathComponent] isEqualToString:self.directoryPath]){
                UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                                    message:NSLocalizedString(@"Can not perform Copy or Cut in original directory", @"无法在源目录中进行剪切操作！")];
                [self presentViewController:alertController animated:YES completion:nil];
                return;
            }
            
            NSString *successString;
            NSError *error;
            NSString *destinationPath = [self.directoryPath stringByAppendingPathComponent:obj[kContentName]];
            if([[NSFileManager defaultManager] moveItemAtPath:contentPath toPath:destinationPath error:&error]){
                successString = NSLocalizedString(@"Succeeded", @"成功");
                successCount++;
            }else{
                successString = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Failed", @"失败"),error.localizedFailureReason];
            }
            
            self.infoStringToAdd = [NSString stringWithFormat:@"%@ %lu/%lu : %@",NSLocalizedString(@"Now moving", @"正在移动"),idx + 1,(unsigned long)self.waitToMoveCADMA.count,successString];
        }];
        
        self.infoStringToAdd = [NSString stringWithFormat:@"%@ %@ : %lu,%@ : %lu",NSLocalizedString(@"Finish moving.", @"移动完成。"),NSLocalizedString(@"Succeeded", @"成功"),(unsigned long)successCount,NSLocalizedString(@"Failed", @"失败"),self.waitToMoveCADMA.count - successCount];
        
        self.waitToMoveCADMA = nil;
        [self updateDataWithNewDirectoryPath:self.directoryPath];
    }
}

- (void)deleteButtonTD{
    infoTextViewInBottomView.text = nil;
    
    if (self.selectedCADMA.count > 0){
        
        UIAlertActionHandler okActionHandler = ^(UIAlertAction *action) {
            [self showBottomInfoTV];
            __block NSUInteger successCount = 0;
            [self.selectedCADMA enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *contentPath = obj[kContentPath];
                
                NSString *successString;
                NSError *error;
                if([[NSFileManager defaultManager] removeItemAtPath:contentPath error:&error]){
                    successString = NSLocalizedString(@"Succeeded", @"成功");
                    successCount++;
                }else{
                    successString = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Failed", @"失败"),error.localizedFailureReason];
                }
                
                self.infoStringToAdd = [NSString stringWithFormat:@"%@ %lu/%lu : %@",NSLocalizedString(@"Now deleting", @"正在删除"),idx + 1,(unsigned long)self.waitToMoveCADMA.count,successString];
            }];
            
            self.infoStringToAdd = [NSString stringWithFormat:@"%@ %@ : %lu,%@ : %lu",NSLocalizedString(@"Finish deleting.", @"删除完成。"),NSLocalizedString(@"Succeeded", @"成功"),(unsigned long)successCount,NSLocalizedString(@"Failed", @"失败"),self.selectedCADMA.count - successCount];
            
            self.selectedCADMA = nil;

            
            [self updateDataWithNewDirectoryPath:self.directoryPath];
        };
        
        UIAlertActionHandler cancelActionHandler = ^(UIAlertAction *action) {
            self.infoStringToAdd = NSLocalizedString(@"Cancel delete", @"取消删除");
        };
        
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")
                                                                                         message:NSLocalizedString(@"Are you sure to delete?", @"确认删除？")
                                                                                 okActionHandler:okActionHandler
                                                                             cancelActionHandler:cancelActionHandler];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        self.infoStringToAdd = NSLocalizedString(@"No item to delete.", @"没有要删除的项目。");
    }
}

- (void)renameButtonTD{
    infoTextViewInBottomView.text = nil;
    if (self.selectedCADMA.count == 1){
        __block UITextField *tf;
        __block NSMutableDictionary *selectedContentAttributeMutableDictionary = self.selectedCADMA.firstObject;
        
        UIAlertActionHandler renameActionHandler = ^(UIAlertAction *action) {
            NSString *originalPath = selectedContentAttributeMutableDictionary[kContentPath];
            NSString *newPath = [self.directoryPath stringByAppendingPathComponent:tf.text];
            if ([[NSFileManager defaultManager] moveItemAtPath:originalPath toPath:newPath error:NULL]){
                [selectedContentAttributeMutableDictionary setValue:tf.text forKey:kContentName];
                [selectedContentAttributeMutableDictionary setValue:[NSNumber numberWithBool:NO] forKey:kContentIsSelected];
                self.selectedCADMA = nil;
                [contentTableView reloadData];
                
                self.infoStringToAdd = NSLocalizedString(@"Rename succeeded", @"重命名成功");
            }else{
                self.infoStringToAdd = NSLocalizedString(@"Rename Failed", @"重命名失败");
            }
        };
        
        UIAlertController *renameAC = [UIAlertController renameAlertControllerWithActionHandler:renameActionHandler
                                                                  textFieldConfigurationHandler:^(UITextField *textField) {
                                                                    textField.text = selectedContentAttributeMutableDictionary[kContentName];
                                                                    tf = textField;
                                                                }];
        
        [self presentViewController:renameAC animated:YES completion:nil];

    }else{
        [self showBottomInfoTV];
        self.infoStringToAdd = NSLocalizedString(@"Only support 1 item at once.", @"每次只能重命名1个项目。");
    }
}

- (void)newFolderButtonTD{
    infoTextViewInBottomView.text = nil;
    [self showBottomInfoTV];
    NSString *newFolderName = [NSString stringWithFormat:@"%@-%.0f",NSLocalizedString(@"NewFolder", @"新文件夹"),[[NSDate date] timeIntervalSinceReferenceDate]*1000];;
    NSString *newFolderPath = [self.directoryPath stringByAppendingPathComponent:newFolderName];
    NSError *error;
    if ([[NSFileManager defaultManager] createDirectoryAtPath:newFolderPath withIntermediateDirectories:NO attributes:nil error:&error]){
        self.infoStringToAdd = NSLocalizedString(@"Create new folder succeeded", @"新建文件夹成功");
        [self updateDataWithNewDirectoryPath:self.directoryPath];
    }else{
        self.infoStringToAdd = NSLocalizedString(@"Create new folder failed", @"新建文件夹失败");
    }
}

- (void)showHideBottomInfoTVButtonTD{
    infoTextViewInBottomView.text = nil;
    [UIView animateWithDuration:1.0 animations:^{
        bottomConstraintForBottomView.constant = bottomConstraintForBottomView.constant == 0 ? BottomConstraintConstant : 0;
    }];
}

- (void)showBottomInfoTV{
    [UIView animateWithDuration:1.0 animations:^{
        bottomConstraintForBottomView.constant = 0;
    }];
}

- (void)hideBottomInfoTV{
    [UIView animateWithDuration:1.0 animations:^{
        bottomConstraintForBottomView.constant = BottomConstraintConstant;
    }];
}

/*
- (void)initSegmentedControl{
 
    segmentedControl = [[UISegmentedControl alloc] initWithItems:self.normalImageArray];
 
    [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [segmentedControl setMomentary:YES];
    
    [segmentedControl setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setDividerImage:[UIImage imageNamed:@"transparent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [segmentedControl setBackgroundImage:[[UIImage imageNamed:@"transparent"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:[[UIImage imageNamed:@"transparent"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
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
*/

- (void)initContentTabelView{
    contentTableView = [UITableView newAutoLayoutView];
    [contentTableView registerClass:[GCFileTableViewCell class] forCellReuseIdentifier:@"GCFileTableViewCell"];
    [contentTableView setBackgroundColor:[UIColor clearColor]];
    contentTableView.delegate = self;
    contentTableView.dataSource = self;
    //[contentTableView setShowsHorizontalScrollIndicator:YES];
    //[contentTableView setShowsHorizontalScrollIndicator:YES];
    
    [self.view addSubview:contentTableView];
    
    [contentTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView withOffset:0];
    
    if (self.enableActionMenu && [self.view.subviews containsObject:bottomView])
        [contentTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:bottomView withOffset:5];
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
            [cell.subitemCountLabel setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)subitemCount,NSLocalizedString(@"Subitem", @"个子项")]];
        else
            [cell.subitemCountLabel setText:NSLocalizedString(@"Empty", @"目录为空")];
        
    } else {
        cell.isDirectory = NO;
    }
    
    cell.contentName = contentAttributes[kContentName];
    
    NSDictionary *attributes = contentAttributes[kContentAttributesFromFileManager];
    
    [cell.createdLabel setText:[[attributes fileCreationDate] stringWithDefaultFormat]];
    [cell.sizeLabel setText:[GCFileBrowser fileSizeString:[attributes fileSize]]];
    [cell.changedLabel setText:[[attributes fileModificationDate] stringWithDefaultFormat]];
    
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
    if (self.isWaitingToPaste){
        [self showBottomInfoTV];
        self.infoStringToAdd = NSLocalizedString(@"Waiting to paste.Can not choose now.", @"等待粘贴，无法选择。");
        return;
    }
    
    NSDictionary *contentAttributes = contentAttributeMutableDictionaryArray[indexPath.row];
    
    if ([contentAttributes[kContentIsSelected] boolValue]) {
        cell.isSelected = NO;
        [contentAttributes setValue:[NSNumber numberWithBool:NO] forKey:kContentIsSelected];
    } else {
        cell.isSelected = YES;
        [contentAttributes setValue:[NSNumber numberWithBool:YES] forKey:kContentIsSelected];
    }
    
    self.selectedCADMA = nil;
    infoLabelInTopView.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)self.selectedCADMA.count,(unsigned long)contentAttributeMutableDictionaryArray.count];
}

/*
- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapActionAtIndexPath:(NSIndexPath *)indexPath{
    
}
 */
@end
