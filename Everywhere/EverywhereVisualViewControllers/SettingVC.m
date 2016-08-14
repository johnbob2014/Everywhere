//
//  SettingVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "SettingVC.h"
#import "UIView+AutoLayout.h"
#import "RETableViewManager.h"
#import "ShareImageVC.h"
#import "InAppPurchaseVC.h"
#import "AboutVC.h"
#import "GCFileBrowser.h"

#import "EverywhereSettingManager.h"
#import "EverywhereFootprintsRepositoryManager.h"
#import "WXApi.h"

typedef BOOL (^OnChangeCharacterInRange)(RETextItem *item, NSRange range, NSString *replacementString);



const NSString *APP_DOWNLOAD_URL=@"https://itunes.apple.com/app/id1072387063";
const NSString *APP_INTRODUCTION_URL=@"http://7xpt9o.com1.z0.glb.clouddn.com/ChinaSceneryIntroduction.html";

@interface SettingVC ()<RETableViewManagerDelegate>

@property (strong,nonatomic) RETableViewManager *reTVManager;
@property (nonatomic,strong) UITableView *settingTableView;

@property (nonatomic,strong) EverywhereSettingManager *settingManager;

//@property (nonatomic,assign) int productIndex;

//@property (nonatomic,strong) NSString *shareTitle;
//@property (nonatomic,strong) NSString *shareDescription;
//@property (nonatomic,strong) NSString *shareWebpageUrl;
//@property (nonatomic,strong) NSData *shareThumbData;


@end

@implementation SettingVC

#pragma mark - Getter & Setter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = VCBackgroundColor;
    
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    self.title = NSLocalizedString(@"Settings",@"设置");
    
    [self initSettingUI];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToMain)];
    
}

- (void)backToMain{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self initSettingUI];
}

-(void)initSettingUI{
    WEAKSELF(weakSelf);
    
    NSString *tempString;
    
    UITableView *settingTableView=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    settingTableView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:settingTableView];
    [settingTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.settingTableView=settingTableView;
    
    self.reTVManager=[[RETableViewManager alloc]initWithTableView:self.settingTableView delegate:self];
    
#pragma mark - 全局设置
    
    RETableViewSection *globleSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Globle", @"全局设置")];

#pragma mark 系统设置
    
    RETableViewItem *systemSettingItem = [RETableViewItem itemWithTitle:NSLocalizedString(@"⚙ App Authorization",@"⚙ 更改应用授权") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        NSURL*url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];

    }];
    
#pragma mark 播放时间间隔
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.playTimeInterval];
    RETextItem *playTimeIntervalItem = [RETextItem itemWithTitle:NSLocalizedString(@"⏲ Play Time Interval",@"⏲ 播放时间间隔") value:tempString placeholder:@""];
    playTimeIntervalItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    playTimeIntervalItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.playTimeInterval = [item.value doubleValue];
    };

    
    
#pragma mark 地图缩放比例
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.mapViewScaleRate];
    RETextItem *mapViewScaleRateItem = [RETextItem itemWithTitle:NSLocalizedString(@"🗺 Map Scale Rate",@"🗺 地图缩放比例") value:tempString placeholder:@""];
    mapViewScaleRateItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mapViewScaleRateItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mapViewScaleRate = [item.value doubleValue];
    };
    
    [globleSection addItemsFromArray:@[systemSettingItem,playTimeIntervalItem,mapViewScaleRateItem]];

    
/*
    REBoolItem *useCellularDataItem=[REBoolItem itemWithTitle:NSLocalizedString(@"🌐 使用蜂窝移动数据", @"") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        //[SceneryModel sharedModel].canUseCellularData=item.value;
    }];
    REBoolItem *catchHDItem=[REBoolItem itemWithTitle:NSLocalizedString(@"🌈 缓存高清图", @"") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        
    }];
    RETableViewItem *clearCatchItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"❌ 清理缓存",@"") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
    }];
*/
#pragma mark 基础模式设置
    
#pragma mark 基础模式主题颜色
    RETableViewSection *baseModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"BaseMode", @"基础模式")];
    [baseModeSection setHeaderHeight:20];
    
    NSArray *baseColorSchemeArray = @[NSLocalizedString(@"Classic Gray",@"经典灰"),NSLocalizedString(@"Fresh Purple",@"清新紫"),NSLocalizedString(@"Deep Brown",@"深沉棕")];
    NSString *currentCS = baseColorSchemeArray[self.settingManager.baseColorScheme < baseColorSchemeArray.count ? self.settingManager.baseColorScheme : baseColorSchemeArray.count - 1];
    REPickerItem *baseColorSchemePickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"🌈 ColorScheme",@"🌈 颜色方案")
                                                                value:@[currentCS]
                                                          placeholder:nil
                                                              options:@[baseColorSchemeArray]];
    baseColorSchemePickerItem.onChange = ^(REPickerItem *item){
        BaseColorScheme newCS = [baseColorSchemeArray indexOfObject:item.value.firstObject];
        self.settingManager.baseColorScheme = newCS;
    };
    
    // Use inline picker in iOS 7
    //
    baseColorSchemePickerItem.inlinePicker = YES;

    
#pragma mark 时刻模式合并距离
    //时刻模式
    //RETableViewSection *momentModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"MomentMode", @"时刻模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.mergeDistanceForMoment];
    RETextItem *mergeDistanceForMomentItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Moment Merge Distance",@"📏 时刻模式合并距离") value:tempString placeholder:@""];
    mergeDistanceForMomentItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergeDistanceForMomentItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergeDistanceForMoment = [item.value doubleValue];
    };

#pragma mark 地点模式合并距离
    //地点模式
    //RETableViewSection *locationModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"LocationMode", @"地点模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.mergeDistanceForLocation];
    RETextItem *mergeDistanceForLocationItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Location Merge Distance",@"📏 地点模式合并距离") value:tempString placeholder:@""];
    mergeDistanceForLocationItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergeDistanceForLocationItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergeDistanceForLocation = [item.value doubleValue];
    };
    
    [baseModeSection addItemsFromArray:@[baseColorSchemePickerItem,mergeDistanceForMomentItem,mergeDistanceForLocationItem]];

#pragma mark - 扩展模式设置
    RETableViewSection *extendedModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Extended Mode", @"扩展模式")];
    [extendedModeSection setHeaderHeight:20];
    
#pragma mark 主题颜色
    
    NSArray *extendedModeColorSchemeArray = @[NSLocalizedString(@"Bright Red",@"鲜艳红"),NSLocalizedString(@"Grass Green",@"青草绿")];
    NSString *extendedModeCurrentCS = extendedModeColorSchemeArray[self.settingManager.extendedColorScheme < extendedModeColorSchemeArray.count ? self.settingManager.extendedColorScheme : extendedModeColorSchemeArray.count - 1];
    REPickerItem *extendedModeColorSchemePickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"🌈 ColorScheme",@"🌈 颜色方案")
                                                                value:@[extendedModeCurrentCS]
                                                          placeholder:nil
                                                              options:@[extendedModeColorSchemeArray]];
    extendedModeColorSchemePickerItem.onChange = ^(REPickerItem *item){
        ExtendedColorScheme newCS = [extendedModeColorSchemeArray indexOfObject:item.value.firstObject];
        self.settingManager.extendedColorScheme = newCS;
    };
    
    // Use inline picker in iOS 7
    //
    extendedModeColorSchemePickerItem.inlinePicker = YES;

    
#pragma mark 最短距离
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceForRecord];
    RETextItem *minDistanceForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Min Record Distance",@"📏 最短记录距离") value:tempString placeholder:@""];
    minDistanceForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceForRecord = [item.value doubleValue];
    };

#pragma mark 最短时间间隔
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minTimeIntervalForRecord];
    RETextItem *minTimeIntervalForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"⏱ Min Record TimeInterval",@"⏱ 最短记录间隔") value:tempString placeholder:@""];
    minTimeIntervalForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minTimeIntervalForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minTimeIntervalForRecord = [item.value doubleValue];
    };
    
#pragma mark 最大足迹点数
    tempString = [NSString stringWithFormat:@"%lu",(long)self.settingManager.maxFootprintsCountForRecord];
    RETextItem *maxFootprintsCountForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"🎚 Max Footprints Count",@"🎚 单条记录最大足迹点数") value:tempString placeholder:@""];
    maxFootprintsCountForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:Number];
    maxFootprintsCountForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.maxFootprintsCountForRecord = [item.value integerValue];
    };
    
    [extendedModeSection addItemsFromArray:@[extendedModeColorSchemePickerItem,minDistanceForRecordItem,minTimeIntervalForRecordItem,maxFootprintsCountForRecordItem]];
    
#pragma mark - 足迹包管理
    RETableViewSection *frManagementSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Footpinrts Repository Management", @"足迹包管理")];
    [frManagementSection setHeaderHeight:20];
    
    //RETableViewSection *fileManagementSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"File Management", @"文件管理")];
    //[fileManagementSection setHeaderHeight:20];
    RETableViewItem *documentsItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"🗂 File Browser",@"🗂 文件浏览器") accessoryType:UITableViewCellAccessoryDisclosureIndicator  selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [self checkhasPurchasedImportAndExport];
        
        GCFileBrowser *fileBrowser = [GCFileBrowser new];
        fileBrowser.edgesForExtendedLayout = UIRectEdgeNone;
        
        fileBrowser.enableActionMenu = NO;
        fileBrowser.enableDocumentInteractionController = [EverywhereSettingManager defaultManager].hasPurchasedShareAndBrowse;
        
        [self.navigationController pushViewController:fileBrowser animated:YES];
        /*
         UIAlertActionHandler okActionHandler = ^(UIAlertAction *action) {
         NSUInteger count = [EverywhereFootprintsRepositoryManager clearFootprintsRepositoryFilesAtPath:Path_Documents];
         
         NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Delete footprints repository files count", @"删除足迹包文件数量"),(unsigned long)count];
         UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
         message:alertMessage];
         [weakSelf presentViewController:alertController animated:YES completion:nil];
         
         };
         
         UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")
         message:NSLocalizedString(@"All your footprints repository files in Documents directory will be deleted and can not be restored! Are you sure?", @"您用户文档中的所有足迹包文件都将被删除，此操作无法恢复，请务必谨慎。确认删除？")
         okActionHandler:okActionHandler];
         [weakSelf presentViewController:alertController animated:YES completion:nil];
         */
        
    }];
    //documentsItem.enabled = self.settingManager.hasPurchasedImportAndExport;
    
    //[fileManagementSection addItemsFromArray:@[documentsItem]];

    RETableViewItem *exportRepositoryToMFRItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"📤 Export to MFR Files",@"📤 导出足迹包至MFR文件") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [self checkhasPurchasedImportAndExport];
        NSUInteger count = [EverywhereFootprintsRepositoryManager exportFootprintsRepositoryToMFRFilesAtPath:[Path_Documents stringByAppendingPathComponent:@"Exported MFR"]];
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Successfully export repository to mfr files count", @"成功导出足迹包至MFR文件数量"),(unsigned long)count];
        UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                           message:alertMessage];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    //exportRepositoryToMFRItem.enabled = [EverywhereSettingManager defaultManager].hasPurchasedImportAndExport;
    
    RETableViewItem *exportRepositoryToGPXItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"📤 Export to GPX Files",@"📤 导出足迹包至GPX文件") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [self checkhasPurchasedImportAndExport];
        NSUInteger count = [EverywhereFootprintsRepositoryManager exportFootprintsRepositoryToGPXFilesAtPath:[Path_Documents stringByAppendingPathComponent:@"Exported GPX"]];
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Successfully export repository to gpx files count", @"成功导出足迹包至GPX文件数量"),(unsigned long)count];
        UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                           message:alertMessage];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    //exportRepositoryToGPXItem.enabled = [EverywhereSettingManager defaultManager].hasPurchasedImportAndExport;
    
    RETableViewItem *importRepositoryItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"📥 Import From Documents Directory",@"📥 从Documents目录导入足迹包") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [self checkhasPurchasedImportAndExport];
        NSString *moveDirectoryPath = [Path_Documents stringByAppendingPathComponent:@"Imported Files"];
        NSArray <EverywhereFootprintsRepository *> *importedArray = [EverywhereFootprintsRepositoryManager importFootprintsRepositoryFromFilesAtPath:Path_Documents moveAddedFilesToPath:moveDirectoryPath];
        /*
        NSArray <EverywhereFootprintsRepository *> *newArray = [[EverywhereFootprintsRepositoryManager footprintsRepositoryArray] arrayByAddingObjectsFromArray:importedArray];
        [EverywhereFootprintsRepositoryManager setFootprintsRepositoryArray:newArray];
        */
        
        NSUInteger count = importedArray.count;
        NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Successfully import repository count", @"成功导入足迹包数量"),(unsigned long)count];
        UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                           message:alertMessage];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    }];
    //importRepositoryItem.enabled = [EverywhereSettingManager defaultManager].hasPurchasedImportAndExport;

    RETableViewItem *clearCatchItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"❌ Clear All Footprints Repositories",@"❌ 清空所有足迹包") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        UIAlertActionHandler okActionHandler = ^(UIAlertAction *action) {
            
            NSUInteger count = [EverywhereFootprintsRepositoryManager footprintsRepositoryArray].count;
            
            [EverywhereFootprintsRepositoryManager setFootprintsRepositoryArray:nil];
            
            NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Delete footprints repository count", @"删除足迹包数量"),(unsigned long)count];
            UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                               message:alertMessage];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
            
        };
        
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")
                                                                                         message:NSLocalizedString(@"All your footprints will be deleted and can not be restored! Are you sure?", @"您分享、接收、记录的所有足迹都将被删除，此操作无法恢复，请务必谨慎。确认删除？")
                                                                                       okActionHandler:okActionHandler];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
        
    }];
    

    
    [frManagementSection addItemsFromArray:@[documentsItem,exportRepositoryToMFRItem,exportRepositoryToGPXItem,importRepositoryItem,clearCatchItem]];
#pragma mark 购买
    
    RETableViewSection *purchaseSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Purchase and Restore", @"购买与恢复")];
    [purchaseSection setHeaderHeight:20];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🎑 Purchase ShareAndBrowse Function",@"🎑 购买 分享和浏览 功能") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(0)]];
    }]];
       
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🎥 Purchase RecordAndEdit Function",@"🎥 购买 记录和编辑 功能") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(1)]];
    }]];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🔂 Purchase ImportAndExport Function",@"🔂 购买 导入和导出 功能") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(2)]];
    }]];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"📦 Purchase All Functions Suit (30% Discount)",@"📦 购买 全部功能套装 (7折优惠)") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(3)]];
    }]];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"⛲️ Restore Purchases",@"⛲️ 恢复已购") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:TransactionTypeRestore productIndexArray:nil];
    }]];

    /*
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"⛲️ Restore Purchases",@"⛲️ 恢复已购") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:0 transactionType:TransactionTypeRestore];
    }]];
     */

   
#pragma mark 分享
    RETableViewSection *shareSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Share《AlbumMaps》 to friends", @"分享《相册地图》给朋友")];
    [shareSection setHeaderHeight:20];
    [shareSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🍀 WeChat Timeline",@"🍀 微信朋友圈") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [self wxShare:WXSceneTimeline];
    }]];
    [shareSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"💠 WeChat Session",@"💠 微信好友") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [self wxShare:WXSceneSession];
    }]];
    /*
     [shareSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"✉️ 短信",@"") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
     [item deselectRowAnimated:YES];
     
     //[weakSelf sendSMS];
     }]];
     */
    
#pragma mark 其他
    RETableViewSection *aboutSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Others", @"其它")];
    [aboutSection setHeaderHeight:20];
    [aboutSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"💖 Praise me!", @"💖 给个好评") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.settingManager.appURLString]];
    }]];
    
    [aboutSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🎉 About", @"🎉 关于") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        AboutVC *aboutVC = [AboutVC new];
        aboutVC.edgesForExtendedLayout = UIRectEdgeNone;
        [self.navigationController pushViewController:aboutVC animated:YES];
    }]];
    
    // 添加sections
    [self.reTVManager addSectionsFromArray:@[globleSection,baseModeSection,extendedModeSection,frManagementSection,purchaseSection,shareSection,aboutSection]];
}

- (BOOL)checkhasPurchasedImportAndExport{
    if (self.settingManager.hasPurchasedImportAndExport) return YES;
    else{
        [self showPurchaseImportAndExportAlertController];
        return NO;
    }
}

#pragma mark - RE Block

-(OnChangeCharacterInRange)createLimitInputBlockWithAllowedString:(NSString *)string{
    OnChangeCharacterInRange block=^(RETextItem *item, NSRange range, NSString *replacementString){
        NSString *allowedString=string;
        NSCharacterSet *forbidenCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:allowedString] invertedSet];
        NSArray *filteredArray=[replacementString componentsSeparatedByCharactersInSet:forbidenCharacterSet];
        NSString *filteredString=[filteredArray componentsJoinedByString:@""];
        
        if (![replacementString isEqualToString:filteredString]) {
            if(DEBUGMODE) NSLog(@"The character 【%@】 is not allowed!",replacementString);
        }
        
        return [replacementString isEqualToString:filteredString];
    };
    
    return block;
}

#pragma mark - Simple WX Share

- (void)wxShare:(enum WXScene)wxScene{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]){
        if(DEBUGMODE) NSLog(@"WeChat uninstalled or not support!");
        return;
    }
    
    WXWebpageObject *webpageObject=[WXWebpageObject new];
    webpageObject.webpageUrl = self.settingManager.appURLString;
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话显示分享的图片，并以thumbData作为缩略图，朋友圈只显示分享的图片,两者都发送imageData
    mediaMessage.title = NSLocalizedString(@"AlbumMaps : Album and Footprints Management Expert", @"相册地图——您的相册和足迹管理专家");
    mediaMessage.description = NSLocalizedString(@"Record your life by albums.Measure the world by footprints.",@"用相册记录人生，用足迹丈量世界");
    mediaMessage.mediaObject = webpageObject;
    mediaMessage.thumbData = UIImageJPEGRepresentation([UIImage imageNamed:@"地球_300_300"], 0.5);
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= wxScene;

    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
}

#pragma mark - Simple Purchase

- (void)showPurchaseImportAndExportAlertController{
    NSString *alertTitle = NSLocalizedString(@"ImportAndExport",@"导入和导出");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Import and export your footprints repository to MFR or GPX files , which can be used in portable GPS", @"1.将足迹包导出为MFR或GPX文件，可在手持GPS上使用"),NSLocalizedString(@"2.Unlock File Browser to manage your footprints repository files on iPhone or iPad", @"2.解锁文件浏览器，在iPhone或iPad上管理足迹包文件"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:2];
}

- (void)showPurchaseAlertControllerWithTitle:(NSString *)title message:(NSString *)message productIndex:(NSInteger)productIndex{
    WEAKSELF(weakSelf);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [weakSelf showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(productIndex)]];
                                                           }];
    /*
     UIAlertAction *restoreAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restore",@"恢复")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action) {
     [weakSelf showPurchaseVC:productIndex transactionType:TransactionTypeRestore];
     }];
     */
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:purchaseAction];
    //[alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = purchaseAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPurchaseVC:(enum TransactionType)transactionType productIndexArray:(NSArray <NSNumber *> *)productIndexArray{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    inAppPurchaseVC.productIDArray = self.settingManager.appProductIDArray;
    inAppPurchaseVC.transactionType = transactionType;
    inAppPurchaseVC.productIndexArray = productIndexArray;
    
    WEAKSELF(weakSelf);
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(enum TransactionType transactionType,NSInteger productIndex,BOOL succeeded){
        if (succeeded) {
            if (productIndex == 0) weakSelf.settingManager.hasPurchasedShareAndBrowse = YES;
            if (productIndex == 1) weakSelf.settingManager.hasPurchasedRecordAndEdit = YES;
            if (productIndex == 2) weakSelf.settingManager.hasPurchasedImportAndExport = YES;
        }
        if(DEBUGMODE) NSLog(@"%@",succeeded? @"用户购买成功！" : @"用户购买失败！");
    };
    
    [self.navigationController pushViewController:inAppPurchaseVC animated:YES];
}

@end
