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

#define NumberAndDecimal @"0123456789.\n"
#define Number @"0123456789\n"
#define kAlphaNum @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\n"
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
    NSString *tempString;
    
    UITableView *settingTableView=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    settingTableView.translatesAutoresizingMaskIntoConstraints=NO;
    //settingTableView.delegate=self;
    //settingTableView.dataSource=self;
    
    [self.view addSubview:settingTableView];
    [settingTableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    self.settingTableView=settingTableView;
    
    //WeakSelf(weakSelf);
    
    self.reTVManager=[[RETableViewManager alloc]initWithTableView:self.settingTableView delegate:self];
    
#pragma mark 全局设置
    
    RETableViewSection *section1=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Globle", @"全局设置")];
    
#pragma mark 主题颜色
    
    NSArray *colorSchemeArray = @[NSLocalizedString(@"Classic Gray",@"经典灰"),NSLocalizedString(@"Fresh Purple",@"清新紫"),NSLocalizedString(@"Deep Brown",@"深沉棕")];
    NSString *currentCS = colorSchemeArray[self.settingManager.colorScheme < colorSchemeArray.count ? self.settingManager.colorScheme : colorSchemeArray.count - 1];
    REPickerItem *colorSchemePickerItem = [REPickerItem itemWithTitle:NSLocalizedString(@"Color Scheme",@"颜色方案")
                                                     value:@[currentCS]
                                               placeholder:nil
                                                   options:@[colorSchemeArray]];
    colorSchemePickerItem.onChange = ^(REPickerItem *item){
        ColorScheme newCS = [colorSchemeArray indexOfObject:item.value.firstObject];
        self.settingManager.colorScheme = newCS;
    };
    
    // Use inline picker in iOS 7
    //
    colorSchemePickerItem.inlinePicker = YES;
    
#pragma mark 播放时间间隔
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.playTimeInterval];
    RETextItem *playTimeIntervalItem = [RETextItem itemWithTitle:NSLocalizedString(@"Play Time Interval",@"播放时间间隔") value:tempString placeholder:@""];
    playTimeIntervalItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    playTimeIntervalItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.playTimeInterval = [item.value doubleValue];
    };

    [section1 addItemsFromArray:@[colorSchemePickerItem,playTimeIntervalItem]];
    
    
    
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
#pragma mark 时刻模式
    RETableViewSection *mainModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"BaseMode", @"基础模式")];
    //时刻模式
    RETableViewSection *momentModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"MomentMode", @"时刻模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.mergedDistanceForMoment];
    RETextItem *mergedDistanceForMomentItem = [RETextItem itemWithTitle:NSLocalizedString(@"Merged Distance",@"时刻模式合并距离") value:tempString placeholder:@""];
    mergedDistanceForMomentItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergedDistanceForMomentItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergedDistanceForMoment = [item.value doubleValue];
    };

    //mergedDistanceForMomentItem. = NSTextAlignmentRight;
    
    //[momentModeSection addItemsFromArray:@[mergedDistanceForMomentItem]];
    
#pragma mark 地址模式
    
    //地址模式
    RETableViewSection *locationModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"LocationMode", @"地址模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.mergedDistanceForLocation];
    RETextItem *mergedDistanceForLocationItem = [RETextItem itemWithTitle:NSLocalizedString(@"Merged Distance",@"地址模式合并距离") value:tempString placeholder:@""];
    mergedDistanceForLocationItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergedDistanceForLocationItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergedDistanceForLocation = [item.value doubleValue];
    };
    //mergedDistanceForLocationItem.textAlignment = NSTextAlignmentRight;
    //[locationModeSection addItemsFromArray:@[mergedDistanceForLocationItem]];
    
    [mainModeSection addItemsFromArray:@[mergedDistanceForMomentItem,mergedDistanceForLocationItem]];

#pragma mark 记录模式
    
    RETableViewSection *extendedModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"RecordMode", @"记录模式")];
    //self.settingManager.shortestTimeIntervalForRecord
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.shortestDistanceForRecord];
    RETextItem *shortestDistanceForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"Shortest Distance",@"最短距离") value:tempString placeholder:@""];
    shortestDistanceForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    shortestDistanceForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.shortestDistanceForRecord = [item.value doubleValue];
    };
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.shortestTimeIntervalForRecord];
    RETextItem *shortestTimeIntervalForRecordItem = [RETextItem itemWithTitle:NSLocalizedString(@"Shortest TimeInterval",@"最短时间间隔") value:tempString placeholder:@""];
    shortestTimeIntervalForRecordItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    shortestTimeIntervalForRecordItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.shortestTimeIntervalForRecord = [item.value doubleValue];
    };

    RETableViewItem *clearCatchItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"❌ 清空所有足迹",@"") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [EverywhereShareRepositoryManager setShareRepositoryArray:nil];
    }];
    [extendedModeSection addItemsFromArray:@[shortestDistanceForRecordItem,shortestTimeIntervalForRecordItem,clearCatchItem]];

    
#pragma mark 购买
    
    RETableViewSection *purchaseSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Purchase and Restore", @"购买与恢复")];
    [purchaseSection setHeaderHeight:20];
    
    WEAKSELF(weakSelf);
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"ShareFunctionAndBrowserMode",@"分享功能和浏览模式") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseShareFunctionAlertController];
    }]];
    
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"RecordFuntionAndRecordMode",@"足迹记录和记录模式") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [weakSelf showPurchaseRecordFunctionAlertController];
    }]];

#pragma mark 分享
    RETableViewSection *shareSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Share <AlbumMaps> to friends", @"分享《相册地图》给朋友")];
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
    
    [self.reTVManager addSectionsFromArray:@[section1,mainModeSection,extendedModeSection,purchaseSection,shareSection,aboutSection]];
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
    mediaMessage.title = NSLocalizedString(@"AlbumMaps——Nice Album and Footprints Manager", @"相册地图——您的相册和足迹管理专家");
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

#pragma mark - copied From AssetsMapProVC

- (void)showPurchaseShareFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"ShareFunctionAndBrowserMode",@"分享功能和浏览模式");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Share your footprints to others", @"1.将足迹分享给他人"),NSLocalizedString(@"2.Store footprints both sended by you and shared by others", @"2.存储足迹，包括自己发送的和别人分享的"),NSLocalizedString(@"3.Unlock Browser Mode and  lookup stored footprints anytime", @"3.解锁浏览模式，随时查看分享足迹"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:0];
}

- (void)showPurchaseRecordFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"RecordFuntionAndRecordMode",@"足迹记录和记录模式");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Record your footprints, support background recording", @"1.记录你的运动足迹"),NSLocalizedString(@"2.Intelligently edit your footprints", @"2.足迹智能编辑"),NSLocalizedString(@"3.Unlock Record Mode to manage your recorded footprints", @"3.解锁记录模式，管理你记录的足迹"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:1];
}

- (void)showPurchaseAlertControllerWithTitle:(NSString *)title message:(NSString *)message productIndex:(NSInteger)productIndex{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self showPurchaseVC:productIndex transactionType:TransactionTypePurchase];
                                                           }];
    UIAlertAction *restoreAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restore",@"恢复")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self showPurchaseVC:productIndex transactionType:TransactionTypeRestore];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:purchaseAction];
    [alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showInfomationAlertControllerWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定") style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPurchaseVC:(NSInteger)productIndex transactionType:(enum TransactionType)transactionType{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    inAppPurchaseVC.productIDs = ProductIDs;
    inAppPurchaseVC.productIndex = productIndex;
    inAppPurchaseVC.transactionType = transactionType;
    
    WEAKSELF(weakSelf);
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(BOOL success,NSInteger productIndex,enum TransactionType transactionType){
        NSString *typeString = transactionType == TransactionTypePurchase ? NSLocalizedString(@"Purchase", @"购买") : NSLocalizedString(@"Restore", @"恢复");
        NSString *resultString = nil;
        NSString *productNameString = productIndex == 0 ? NSLocalizedString(@"ShareFunctionAndBrowserMode",@"分享功能和浏览模式"): NSLocalizedString(@"RecordFuntionAndRecordMode",@"足迹记录和记录模式");
        
        if (success) {
            resultString = NSLocalizedString(@"Succeeded", @"成功");
            if (productIndex == 0) self.settingManager.hasPurchasedShare = YES;
            if (productIndex == 1) self.settingManager.hasPurchasedRecord = YES;
        }else{
            resultString = NSLocalizedString(@"Failed", @"失败");
        }
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@ %@ %@",typeString,productNameString,resultString];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf showInfomationAlertControllerWithTitle:NSLocalizedString(@"Purchase/Restore Result", @"购买/恢复结果") message:alertMessage];
        });
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inAppPurchaseVC];
    [self presentViewController:nav animated:YES completion:nil];
}


@end
