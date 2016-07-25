//
//  SettingVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#import "SettingVC.h"
#import "UIView+AutoLayout.h"
#import "RETableViewManager.h"
#import "ShareImageVC.h"
#import "InAppPurchaseVC.h"
#import "AboutVC.h"

#import "EverywhereSettingManager.h"
#import "EverywhereShareRepositoryManager.h"
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
    
#pragma mark 全局设置
    
    RETableViewSection *globleSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Globle", @"全局设置")];
    
    
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
    
    [globleSection addItemsFromArray:@[playTimeIntervalItem,mapViewScaleRateItem]];

    
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
    
    NSArray *baseColorSchemeArray = @[NSLocalizedString(@"Classic Gray",@"经典灰"),NSLocalizedString(@"Fresh Purple",@"清新紫"),NSLocalizedString(@"Deep Brown",@"深沉棕")];
    NSString *currentCS = baseColorSchemeArray[self.settingManager.baseColorScheme < baseColorSchemeArray.count ? self.settingManager.baseColorScheme : baseColorSchemeArray.count - 1];
    REPickerItem *baseColorSchemePickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"⛰ BaseColorScheme",@"⛰ 颜色方案")
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
    RETextItem *mergeDistanceForMomentItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Merge Distance For Moment",@"📏 时刻模式合并距离") value:tempString placeholder:@""];
    mergeDistanceForMomentItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergeDistanceForMomentItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergeDistanceForMoment = [item.value doubleValue];
    };

#pragma mark 地址模式合并距离
    //地址模式
    //RETableViewSection *locationModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"LocationMode", @"地址模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.mergeDistanceForLocation];
    RETextItem *mergeDistanceForLocationItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Merge Distance For Location",@"📏 地址模式合并距离") value:tempString placeholder:@""];
    mergeDistanceForLocationItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergeDistanceForLocationItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergeDistanceForLocation = [item.value doubleValue];
    };
    
    [baseModeSection addItemsFromArray:@[baseColorSchemePickerItem,mergeDistanceForMomentItem,mergeDistanceForLocationItem]];

#pragma mark - 扩展模式设置
    
#pragma mark 扩展模式主题颜色
    
    NSArray *extendedModeColorSchemeArray = @[NSLocalizedString(@"Bright Red",@"鲜艳红"),NSLocalizedString(@"Grass Green",@"青草绿")];
    NSString *extendedModeCurrentCS = extendedModeColorSchemeArray[self.settingManager.extendedColorScheme < extendedModeColorSchemeArray.count ? self.settingManager.extendedColorScheme : extendedModeColorSchemeArray.count - 1];
    REPickerItem *extendedModeColorSchemePickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"🏔 ExtendedColorScheme",@"🏔 颜色方案")
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

    RETableViewSection *extendedModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Extended Mode", @"扩展模式")];
    //self.settingManager.minTimeIntervalForRecord
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minDistanceForRecord];
    RETextItem *minDistanceForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"📏 Min Distance",@"📏 最短距离") value:tempString placeholder:@""];
    minDistanceForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minDistanceForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minDistanceForRecord = [item.value doubleValue];
    };
    
    tempString = [NSString stringWithFormat:@"%.1f",self.settingManager.minTimeIntervalForRecord];
    RETextItem *minTimeIntervalForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"⏱ Min TimeInterval",@"⏱ 最短时间间隔") value:tempString placeholder:@""];
    minTimeIntervalForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    minTimeIntervalForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.minTimeIntervalForRecord = [item.value doubleValue];
    };
    
    tempString = [NSString stringWithFormat:@"%lu",(long)self.settingManager.maxFootprintsCountForRecord];
    RETextItem *maxFootprintsCountForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"🎚 Max Footprints Count",@"🎚 最大足迹点数") value:tempString placeholder:@""];
    maxFootprintsCountForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:Number];
    maxFootprintsCountForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.maxFootprintsCountForRecord = [item.value integerValue];
    };

    RETableViewItem *clearCatchItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"❌ 清空所有足迹",@"") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")
                                                                                         message:NSLocalizedString(@"All your footprints will be deleted and can not be restored! Are you sure?", @"您分享、接收、记录的所有足迹都将被删除，此操作无法恢复，请务必谨慎。确认删除？")
                                                                                       okHandler:^(UIAlertAction *action) {
                                                                                           [EverywhereShareRepositoryManager setShareRepositoryArray:nil];
                                                                                       }];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
        
    }];
    
    [extendedModeSection addItemsFromArray:@[extendedModeColorSchemePickerItem,minDistanceForRecordItem,minTimeIntervalForRecordItem,maxFootprintsCountForRecordItem,clearCatchItem]];

    
#pragma mark 购买
    
    RETableViewSection *purchaseSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Purchase and Restore", @"购买与恢复")];
    [purchaseSection setHeaderHeight:20];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🎑 ShareFunctionAndBrowserMode",@"🎑 分享功能和浏览模式") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:0 transactionType:TransactionTypePurchase];
    }]];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🚘 RecordFuntionAndRecordMode",@"🚘 足迹记录和记录模式") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseVC:0 transactionType:TransactionTypePurchase];
    }]];

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
    RETableViewSection *aboutSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Others", @"")];
    [aboutSection setHeaderHeight:20];
    [aboutSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"💖 Praise me!", @"💖 给个好评") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:AppDownloadURLString]];
    }]];
    
    [aboutSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🎉 About", @"🎉 关于") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        AboutVC *aboutVC = [AboutVC new];
        aboutVC.edgesForExtendedLayout = UIRectEdgeNone;
        [self.navigationController pushViewController:aboutVC animated:YES];
    }]];
    
    [self.reTVManager addSectionsFromArray:@[globleSection,baseModeSection,extendedModeSection,purchaseSection,shareSection,aboutSection]];
}

#pragma mark - RE Block

-(OnChangeCharacterInRange)createLimitInputBlockWithAllowedString:(NSString *)string{
    OnChangeCharacterInRange block=^(RETextItem *item, NSRange range, NSString *replacementString){
        NSString *allowedString=string;
        NSCharacterSet *forbidenCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:allowedString] invertedSet];
        NSArray *filteredArray=[replacementString componentsSeparatedByCharactersInSet:forbidenCharacterSet];
        NSString *filteredString=[filteredArray componentsJoinedByString:@""];
        
        if (![replacementString isEqualToString:filteredString]) {
            NSLog(@"The character 【%@】 is not allowed!",replacementString);
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
    webpageObject.webpageUrl = AppDownloadURLString;
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    mediaMessage.title = NSLocalizedString(@"AlbumMaps——Album and Footprints Management Expert", @"相册地图——您的相册和足迹管理专家");
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

- (void)showPurchaseVC:(NSInteger)productIndex transactionType:(enum TransactionType)transactionType{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    inAppPurchaseVC.productIDs = ProductIDs;
    inAppPurchaseVC.productIndex = productIndex;
    inAppPurchaseVC.transactionType = transactionType;
    
    WEAKSELF(weakSelf);
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(BOOL succeeded,NSInteger productIndex,enum TransactionType transactionType){
        if (succeeded) {
            if (productIndex == 0) weakSelf.settingManager.hasPurchasedShare = YES;
            if (productIndex == 1) weakSelf.settingManager.hasPurchasedRecord = YES;
        }
        NSLog(@"%@",succeeded? @"用户购买成功！" : @"用户购买失败！");
    };
    [self.navigationController pushViewController:inAppPurchaseVC animated:YES];
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inAppPurchaseVC];
    //[self presentViewController:nav animated:YES completion:nil];
}

@end
