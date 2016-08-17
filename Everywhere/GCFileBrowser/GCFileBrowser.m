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

@end

@implementation GCFileBrowser{
    NSArray <NSMutableDictionary <NSString *,id> *> *contentAttributeMutableDictionaryArray;
    UIView *topView;
    UILabel *pathLabelInTopView,*infoLabelInTopView;;
    
    UIView *bottomView;
    UIView *buttonContainerView;
    UIButton *copyButton,*cutButton,*pasteButton,*deleteButton,*renameButton;
    UILabel *infoLabelInBottomView;
    NSLayoutConstraint *bottomConstraintForBottomView;
    
    //UISegmentedControl *segmentedControl;
    
    UITableView *contentTableView;
    
    UIDocumentInteractionController *documentInteractionController;
}

#pragma mark - Getter & Setter


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
    
    if (self.enableActionMenu) [self initBottomView]; //[self initSegmentedControl];
    
    [self initContentTabelView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateDataWithNewDirectoryPath:self.directoryPath];
    
    if (infoLabelInBottomView){
        if (self.waitToCopyCADMA.count == 0 && self.waitToMoveCADMA.count == 0){
            [self hideBottomInfoLabel];
        }else if (self.waitToCopyCADMA.count > 0){
            infoLabelInBottomView.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.selectedCADMA.count,NSLocalizedString(@"items has been copied.Select destination to paste.", @"项已复制，请选择目标位置进行粘贴。")];
        }else if (self.waitToMoveCADMA.count > 0){
            infoLabelInBottomView.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.selectedCADMA.count,NSLocalizedString(@"items has been cut.Select destination to paste.", @"项已剪切，请选择目标位置进行粘贴。")];
        }
    }
    
}

#pragma mark - Init Subviews

- (void)initTopView{
    topView = [UIView newAutoLayoutView];

    topView.backgroundColor = VCBackgroundColor;
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
    bottomView.backgroundColor = DEBUGMODE ? RandomFlatColor : ClearColor;
    [self.view addSubview:bottomView];
    [bottomView autoSetDimension:ALDimensionHeight toSize:5 + FileActionButtonEdgeLength + 5 + 20 + 5];
    [bottomView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [bottomView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    bottomConstraintForBottomView = [bottomView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:-30];
    
    infoLabelInBottomView = [UILabel newAutoLayoutView];
    infoLabelInBottomView.textAlignment = NSTextAlignmentCenter;
    [infoLabelInBottomView setStyle:UILabelStyleBrownBold];
    [bottomView addSubview:infoLabelInBottomView];
    [infoLabelInBottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 5, 0) excludingEdge:ALEdgeTop];
    
    buttonContainerView = [UIView newAutoLayoutView];
    buttonContainerView.backgroundColor = DEBUGMODE ? RandomFlatColor : ClearColor;
    [bottomView addSubview:buttonContainerView];
    [buttonContainerView autoSetDimensionsToSize:CGSizeMake(FileActionButtonEdgeLength * 5 + FileActionButtonOffset * 4, FileActionButtonEdgeLength)];
    [buttonContainerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [buttonContainerView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    copyButton = [UIButton newAutoLayoutView];
    [copyButton setImage:[UIImage imageNamed:@"icon-copy1"] forState:UIControlStateNormal];
    [copyButton setImage:[UIImage imageNamed:@"icon-copy2"] forState:UIControlStateHighlighted];
    [copyButton addTarget:self action:@selector(copyButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:copyButton];
    [copyButton autoSetDimensionsToSize:FileActionButtonSize];
    [copyButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [copyButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    cutButton = [UIButton newAutoLayoutView];
    [cutButton setImage:[UIImage imageNamed:@"icon-move1"] forState:UIControlStateNormal];
    [cutButton setImage:[UIImage imageNamed:@"icon-move2"] forState:UIControlStateHighlighted];
    [cutButton addTarget:self action:@selector(cutButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:cutButton];
    [cutButton autoSetDimensionsToSize:FileActionButtonSize];
    [cutButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [cutButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:copyButton withOffset:FileActionButtonOffset];
    
    pasteButton = [UIButton newAutoLayoutView];
    [pasteButton setImage:[UIImage imageNamed:@"icon-play1"] forState:UIControlStateNormal];
    [pasteButton setImage:[UIImage imageNamed:@"icon-play2"] forState:UIControlStateHighlighted];
    [pasteButton addTarget:self action:@selector(pasteButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:pasteButton];
    [pasteButton autoSetDimensionsToSize:FileActionButtonSize];
    [pasteButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [pasteButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:cutButton withOffset:FileActionButtonOffset];
    
    deleteButton = [UIButton newAutoLayoutView];
    [deleteButton setImage:[UIImage imageNamed:@"icon-trash1"] forState:UIControlStateNormal];
    [deleteButton setImage:[UIImage imageNamed:@"icon-trash2"] forState:UIControlStateHighlighted];
    [deleteButton addTarget:self action:@selector(deleteButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:deleteButton];
    [deleteButton autoSetDimensionsToSize:FileActionButtonSize];
    [deleteButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [deleteButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:pasteButton withOffset:FileActionButtonOffset];
    
    renameButton = [UIButton newAutoLayoutView];
    [renameButton setImage:[UIImage imageNamed:@"icon-rename1"] forState:UIControlStateNormal];
    [renameButton setImage:[UIImage imageNamed:@"icon-rename2"] forState:UIControlStateHighlighted];
    [renameButton addTarget:self action:@selector(renameButtonTD) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:renameButton];
    [renameButton autoSetDimensionsToSize:FileActionButtonSize];
    [renameButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [renameButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:deleteButton withOffset:FileActionButtonOffset];
    
    if (ScreenWidth > 320) buttonContainerView.transform = CGAffineTransformMakeScale(1.3, 1.3);
}

- (void)copyButtonTD{
    [self showBottomInfoLabel];
    if (self.selectedCADMA.count > 0){
        self.waitToCopyCADMA = (NSMutableArray<NSDictionary *> *)self.selectedCADMA;
        
        infoLabelInBottomView.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.selectedCADMA.count,NSLocalizedString(@"items has been copied.Select destination to paste.", @"项已复制，请选择目标位置进行粘贴。")];
        
    }else{
        [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"Haven't choose an item yet.", @"尚未选择项目，请点击名称左侧图标进行选择。")];
    }
}

- (void)cutButtonTD{
    [self showBottomInfoLabel];
    if (self.selectedCADMA.count > 0){
        
        self.waitToMoveCADMA = (NSMutableArray<NSDictionary *> *)self.selectedCADMA;
        
        infoLabelInBottomView.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.selectedCADMA.count,NSLocalizedString(@"items has been cut.Select destination to paste.", @"项已剪切，请选择目标位置进行粘贴。")];
        
    }else{
        [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"Haven't choose an item yet.", @"尚未选择项目，请点击名称左侧图标进行选择。")];
    }
}

- (void)pasteButtonTD{
    if (self.waitToCopyCADMA.count == 0 && self.waitToMoveCADMA.count == 0){
        [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"No item to copy.", @"没有要复制或移动的项目。")];
        return;
    }else if (self.waitToCopyCADMA.count > 0){
        [self showBottomInfoLabel];
        
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
            
            infoLabelInBottomView.text = [NSString stringWithFormat:@"%@ %u/%lu : %@",NSLocalizedString(@"Now copying", @"正在复制"),idx + 1,(unsigned long)self.waitToCopyCADMA.count,successString];
        }];
        
        [self showNoteAndHideBottomInfoLabel:[NSString stringWithFormat:@"%@ %@ : %lu,%@ : %u",NSLocalizedString(@"Finish copying.", @"复制完成。"),NSLocalizedString(@"Succeeded", @"成功"),(unsigned long)successCount,NSLocalizedString(@"Failed", @"失败"),self.waitToCopyCADMA.count - successCount]];
        
        self.waitToCopyCADMA = nil;
        [self updateDataWithNewDirectoryPath:self.directoryPath];
    }else if (self.waitToMoveCADMA.count > 0){
        [self showBottomInfoLabel];
        
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
            
            infoLabelInBottomView.text = [NSString stringWithFormat:@"%@ %u/%lu : %@",NSLocalizedString(@"Now moving", @"正在移动"),idx + 1,(unsigned long)self.waitToMoveCADMA.count,successString];
        }];
        
        [self showNoteAndHideBottomInfoLabel:[NSString stringWithFormat:@"%@ %@ : %lu,%@ : %u",NSLocalizedString(@"Finish moving.", @"移动完成。"),NSLocalizedString(@"Succeeded", @"成功"),(unsigned long)successCount,NSLocalizedString(@"Failed", @"失败"),self.waitToMoveCADMA.count - successCount]];
        
        self.waitToMoveCADMA = nil;
        [self updateDataWithNewDirectoryPath:self.directoryPath];
    }
}

- (void)deleteButtonTD{
    
    infoLabelInBottomView.text = NSLocalizedString(@"Confirm delete", @"确认删除");
    [self showBottomInfoLabel];
    
    if (self.selectedCADMA.count > 0){
        
        UIAlertActionHandler okActionHandler = ^(UIAlertAction *action) {
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
                
                infoLabelInBottomView.text = [NSString stringWithFormat:@"%@ %u/%lu : %@",NSLocalizedString(@"Now deleting", @"正在删除"),idx + 1,(unsigned long)self.waitToMoveCADMA.count,successString];
            }];
            
            [self showNoteAndHideBottomInfoLabel:[NSString stringWithFormat:@"%@ %@ : %lu,%@ : %u",NSLocalizedString(@"Finish deleting.", @"删除完成。"),NSLocalizedString(@"Succeeded", @"成功"),(unsigned long)successCount,NSLocalizedString(@"Failed", @"失败"),self.selectedCADMA.count - successCount]];
            
            self.selectedCADMA = nil;

            
            [self updateDataWithNewDirectoryPath:self.directoryPath];
        };
        
        UIAlertActionHandler cancelActionHandler = ^(UIAlertAction *action) {
            [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"Cancel delete", @"取消删除")];
        };
        
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")
                                                                                         message:NSLocalizedString(@"Are you sure to delete?", @"确认删除？")
                                                                                 okActionHandler:okActionHandler
                                                                             cancelActionHandler:cancelActionHandler];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"No item to delete.", @"没有要删除的项目。")];
    }
}

- (void)renameButtonTD{
    
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
                
                [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"Rename succeeded", @"重命名成功")];
            }else{
                [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"Rename Failed", @"重命名失败")];
            }
        };
        
        UIAlertController *renameAC = [UIAlertController renameAlertControllerWithActionHandler:renameActionHandler
                                                                  textFieldConfigurationHandler:^(UITextField *textField) {
                                                                    textField.text = selectedContentAttributeMutableDictionary[kContentName];
                                                                    tf = textField;
                                                                }];
        
        [self presentViewController:renameAC animated:YES completion:nil];

    }else{
        [self showBottomInfoLabel];
        [self showNoteAndHideBottomInfoLabel:NSLocalizedString(@"Only support 1 item at once.", @"每次只能重命名1个项目。")];
    }
}

- (void)showBottomInfoLabel{
    [UIView animateWithDuration:1.0 animations:^{
        bottomConstraintForBottomView.constant = 0;
    }];
}

- (void)hideBottomInfoLabel{
    [UIView animateWithDuration:1.0 animations:^{
        bottomConstraintForBottomView.constant = 30;
    }];
}


- (void)showNoteAndHideBottomInfoLabel:(NSString *)noteString{
    infoLabelInBottomView.text = noteString;
    [self performSelector:@selector(hideBottomInfoLabel) withObject:self afterDelay:3.0];
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
        infoLabelInTopView.text = NSLocalizedString(@"Waiting to paste.", @"等待粘贴，无法选择。");
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
