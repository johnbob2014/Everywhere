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
#import "WXApi.h"

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"
#import "AssetDetailVC.h"

typedef BOOL (^OnChangeCharacterInRange)(RETextItem *item, NSRange range, NSString *replacementString);

const NSString *APP_DOWNLOAD_URL=@"https://itunes.apple.com/app/id1072387063";
const NSString *APP_INTRODUCTION_URL=@"http://7xpt9o.com1.z0.glb.clouddn.com/ChinaSceneryIntroduction.html";

@interface SettingVC ()<RETableViewManagerDelegate>

@property (strong,nonatomic) RETableViewManager *reTVManager;
@property (nonatomic,strong) UITableView *settingTableView;

@property (nonatomic,strong) EverywhereSettingManager *settingManager;

@end

@implementation SettingVC

#pragma mark - Getter & Setter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    self.title = NSLocalizedString(@"Settings",@"设置");
    
    [self initSettingUI];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToMain)];
    
}

- (void)backToMain{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark 每周第一天
    NSArray *firstDayOfWeekArray = @[NSLocalizedString(@"Sunday",@"星期日"),NSLocalizedString(@"Monday",@"星期一")];
    NSString *currentFirstDayOfWeek = firstDayOfWeekArray[self.settingManager.firstDayOfWeek < firstDayOfWeekArray.count ? self.settingManager.firstDayOfWeek : firstDayOfWeekArray.count - 1];
    REPickerItem *firstDayOfWeekPickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"First Day Of Week",@"每周第一天")
                                                                   value:@[currentFirstDayOfWeek]
                                                             placeholder:nil
                                                                 options:@[firstDayOfWeekArray]];
    firstDayOfWeekPickerItem.onChange = ^(REPickerItem *item){
        FirstDayOfWeek newCS = [firstDayOfWeekArray indexOfObject:item.value.firstObject];
        self.settingManager.firstDayOfWeek = newCS;
    };
    
    firstDayOfWeekPickerItem.inlinePicker = YES;

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
    
    [globleSection addItemsFromArray:@[systemSettingItem,firstDayOfWeekPickerItem,playTimeIntervalItem,mapViewScaleRateItem]];
    
#pragma mark - 基础模式设置
    
#pragma mark 基础模式主题颜色
    RETableViewSection *baseModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"BaseMode", @"基础模式")];
    [baseModeSection setHeaderHeight:20];
    
    NSArray *baseColorSchemeArray = @[NSLocalizedString(@"Sky Blue",@"天空蓝"),NSLocalizedString(@"Sakura Pink",@"樱花粉"),NSLocalizedString(@"Classic Gray",@"经典灰"),NSLocalizedString(@"Fresh Plum",@"清新紫"),NSLocalizedString(@"Deep Brown",@"深沉棕")];
    NSString *currentCS = baseColorSchemeArray[self.settingManager.baseColorScheme < baseColorSchemeArray.count ? self.settingManager.baseColorScheme : baseColorSchemeArray.count - 1];
    REPickerItem *baseColorSchemePickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"🌈 ColorScheme",@"🌈 颜色方案")
                                                                value:@[currentCS]
                                                          placeholder:nil
                                                              options:@[baseColorSchemeArray]];
    baseColorSchemePickerItem.onChange = ^(REPickerItem *item){
        BaseColorScheme newCS = [baseColorSchemeArray indexOfObject:item.value.firstObject];
        self.settingManager.baseColorScheme = newCS;
    };
    
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
    
    
#pragma mark 已排除照片管理
    RETableViewItem *eliminatedAssetsItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"🌁 Eliminated Photos",@"🌁 已排除照片") accessoryType:UITableViewCellAccessoryDisclosureIndicator  selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        NSArray<PHAssetInfo *> *eliminatedArray = [PHAssetInfo fetchEliminatedAssetInfosInManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        
        if (eliminatedArray.count > 0){
            __block NSMutableArray <NSString *> *assetLocalIdentifiers = [NSMutableArray new];
            [eliminatedArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [assetLocalIdentifiers addObject:obj.localIdentifier];
            }];
            AssetDetailVC *showVC = [AssetDetailVC new];
            showVC.assetLocalIdentifiers = assetLocalIdentifiers;
            [self.navigationController pushViewController:showVC animated:YES];
        }else{
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"No Eliminated Photos!", @"没有已排除的照片！")];
        }
    }];
    
    [baseModeSection addItemsFromArray:@[baseColorSchemePickerItem,mergeDistanceForMomentItem,mergeDistanceForLocationItem,eliminatedAssetsItem]];

#pragma mark - 扩展模式设置
    RETableViewSection *extendedModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Extended Mode", @"扩展模式")];
    [extendedModeSection setHeaderHeight:20];
    
#pragma mark 主题颜色
    
    NSArray *extendedModeColorSchemeArray = @[NSLocalizedString(@"Forest Green",@"森林绿"),NSLocalizedString(@"Bright Orange",@"鲜艳橙"),NSLocalizedString(@"Watermelon Red",@"西瓜红")];
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
    
#pragma mark 缩略图缩放比例
    
    tempString = [NSString stringWithFormat:@"%.2f",self.settingManager.thumbnailScaleRate];
    RETextItem *thumbnailScaleRateItem = [RETextItem itemWithTitle:NSLocalizedString(@"🔎 Thumbail Scale Rate",@"🔎 缩略图缩放比例") value:tempString placeholder:@""];
    thumbnailScaleRateItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    thumbnailScaleRateItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.thumbnailScaleRate = [item.value doubleValue];
    };
    
#pragma mark 缩略图质量
    
    tempString = [NSString stringWithFormat:@"%.2f",self.settingManager.thumbnailCompressionQuality];
    RETextItem *thumbnailCompressionQualityItem = [RETextItem itemWithTitle:NSLocalizedString(@"🔎 Thumbail Compression",@"🔎 缩略图压缩比") value:tempString placeholder:@""];
    thumbnailCompressionQualityItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    thumbnailCompressionQualityItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.thumbnailCompressionQuality = [item.value doubleValue];
    };
    

#pragma mark 最大足迹点数
    tempString = [NSString stringWithFormat:@"%lu",(long)self.settingManager.maxFootprintsCountForRecord];
    RETextItem *maxFootprintsCountForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"🎚 Max Footprints Count",@"🎚 单条记录最大足迹点数") value:tempString placeholder:@""];
    maxFootprintsCountForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:Number];
    maxFootprintsCountForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.maxFootprintsCountForRecord = [item.value integerValue];
    };

#pragma mark 间隔
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minTimeIntervalForRecord];
    RETextItem *minTimeIntervalForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"⏱ Custom Record TimeInterval",@"⏱ 自定义记录间隔") value:tempString placeholder:@"s"];
    minTimeIntervalForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minTimeIntervalForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minTimeIntervalForRecord = [item.value doubleValue];
    };

#pragma mark 距离
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceForRecord];
    RETextItem *minDistanceForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Custom Record Distance",@"📏 自定义记录距离") value:tempString placeholder:@"m"];
    minDistanceForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceForRecord = [item.value doubleValue];
    };

#pragma mark 步行距离
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceWalkForRecord];
    RETextItem *minDistanceWalkForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Walk Record Distance",@"📏 步行记录距离") value:tempString placeholder:@"m"];
    minDistanceWalkForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceWalkForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceWalkForRecord = [item.value doubleValue];
    };
    
#pragma mark 骑行距离
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceRideForRecord];
    RETextItem *minDistanceRideForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Ride Record Distance",@"📏 骑行记录距离") value:tempString placeholder:@"m"];
    minDistanceRideForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceRideForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceRideForRecord = [item.value doubleValue];
    };

#pragma mark 驾车距离
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceDriveForRecord];
    RETextItem *minDistanceDriveForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Drive Record Distance",@"📏 驾车记录距离") value:tempString placeholder:@"m"];
    minDistanceDriveForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceDriveForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceDriveForRecord = [item.value doubleValue];
    };

#pragma mark 驾车距离
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceHighSpeedForRecord];
    RETextItem *minDistanceHighSpeedForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 HighSpeed Record Distance",@"📏 高速记录距离") value:tempString placeholder:@"m"];
    minDistanceHighSpeedForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceHighSpeedForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceHighSpeedForRecord = [item.value doubleValue];
    };
    
    [extendedModeSection addItemsFromArray:@[extendedModeColorSchemePickerItem,thumbnailScaleRateItem,thumbnailCompressionQualityItem,maxFootprintsCountForRecordItem,minTimeIntervalForRecordItem,minDistanceForRecordItem,minDistanceWalkForRecordItem,minDistanceRideForRecordItem,minDistanceDriveForRecordItem,minDistanceHighSpeedForRecordItem]];
    
#pragma mark - 足迹包管理
    RETableViewSection *frManagementSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Footpinrts Repository Management", @"足迹包管理")];
    [frManagementSection setHeaderHeight:20];

#pragma mark  文件管理
    //RETableViewSection *fileManagementSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"File Management", @"文件管理")];
    //[fileManagementSection setHeaderHeight:20];
    RETableViewItem *documentsItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"🗂 File Browser",@"🗂 文件浏览器") accessoryType:UITableViewCellAccessoryDisclosureIndicator  selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        [self checkhasPurchasedImportAndExport];
        
        GCFileBrowser *fileBrowser = [GCFileBrowser new];
        
        fileBrowser.edgesForExtendedLayout = UIRectEdgeNone;
        
        fileBrowser.enableActionMenu = [EverywhereSettingManager defaultManager].hasPurchasedImportAndExport;
        fileBrowser.enableDocumentInteractionController = [EverywhereSettingManager defaultManager].hasPurchasedShareAndBrowse;
        
        [self.navigationController pushViewController:fileBrowser animated:YES];
        
    }];
    
    //[fileManagementSection addItemsFromArray:@[documentsItem]];

    RETableViewItem *exportRepositoryToMFRItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"📤 Export to MFR Files",@"📤 导出足迹包至MFR文件") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        if ([self checkhasPurchasedImportAndExport]){
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Exporting", @"正在导出")];
            NSUInteger count = [EverywhereCoreDataManager  exportFootprintsRepositoryToMFRFilesAtPath:[Path_Documents stringByAppendingPathComponent:@"Exported"]];
            [SVProgressHUD dismiss];
            
            NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Successfully export repository to mfr files count", @"成功导出足迹包至MFR文件数量"),(unsigned long)count];
            UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                               message:alertMessage];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    RETableViewItem *exportRepositoryToGPXItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"📤 Export to GPX Files",@"📤 导出足迹包至GPX文件") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        if ([self checkhasPurchasedImportAndExport]){
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Exporting", @"正在导出")];
            NSUInteger count = [EverywhereCoreDataManager  exportFootprintsRepositoryToGPXFilesAtPath:[Path_Documents stringByAppendingPathComponent:@"Exported"]];
            [SVProgressHUD dismiss];
            NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Successfully export repository to gpx files count", @"成功导出足迹包至GPX文件数量"),(unsigned long)count];
            UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                               message:alertMessage];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    RETableViewItem *importRepositoryItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"📥 Import From Documents Directory",@"📥 从Documents目录导入足迹包") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        if ([self checkhasPurchasedImportAndExport]){
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Importing", @"正在导入")];
            NSString *moveDirectoryPath = [Path_Documents stringByAppendingPathComponent:@"Imported"];
            NSUInteger count = [EverywhereCoreDataManager  importFootprintsRepositoryFromFilesAtPath:Path_Documents moveAddedFilesToPath:moveDirectoryPath];
            [SVProgressHUD dismiss];
            
            NSString *alertMessage = [NSString stringWithFormat:@"%@ : %lu",NSLocalizedString(@"Successfully import repository count", @"成功导入足迹包数量"),(unsigned long)count];
            UIAlertController *alertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                               message:alertMessage];
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        }
    }];
    
    RETableViewItem *clearCatchItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"❌ Clear All Footprints Repositories",@"❌ 清空所有足迹包") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        UIAlertActionHandler okActionHandler = ^(UIAlertAction *action) {

            NSUInteger count = [EverywhereCoreDataManager removeAllEWFRInfos];
            
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
            switch (productIndex) {
                case 0:
                    weakSelf.settingManager.hasPurchasedShareAndBrowse = YES;
                    break;
                case 1:
                    weakSelf.settingManager.hasPurchasedRecordAndEdit = YES;
                    break;
                case 2:
                    weakSelf.settingManager.hasPurchasedImportAndExport = YES;
                    break;
                case 3:
                    weakSelf.settingManager.hasPurchasedShareAndBrowse = YES;
                    weakSelf.settingManager.hasPurchasedRecordAndEdit = YES;
                    weakSelf.settingManager.hasPurchasedImportAndExport = YES;
                    break;
                default:
                    break;
            }
        }
        if(DEBUGMODE) NSLog(@"%@ %@",self.settingManager.appProductIDArray[productIndex],succeeded? @"成功！" : @"用失败！");
    };
    
    [self.navigationController pushViewController:inAppPurchaseVC animated:YES];
}

@end
