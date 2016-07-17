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
#import "ShareVC.h"
#import "InAppPurchaseVC.h"
#import "AboutVC.h"

#define NumberAndDecimal @"0123456789.\n"
#define Number @"0123456789\n"
#define kAlphaNum @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\n"
typedef BOOL (^OnChangeCharacterInRange)(RETextItem *item, NSRange range, NSString *replacementString);

#import "EverywhereSettingManager.h"
#import "WXApi.h"

const NSString *APP_DOWNLOAD_URL=@"https://itunes.apple.com/app/id1072387063";
const NSString *APP_INTRODUCTION_URL=@"http://7xpt9o.com1.z0.glb.clouddn.com/ChinaSceneryIntroduction.html";

@interface SettingVC ()<RETableViewManagerDelegate>

@property (strong,nonatomic) RETableViewManager *reTVManager;
@property (nonatomic,strong) UITableView *settingTableView;

@property (nonatomic,strong) EverywhereSettingManager *settingManager;

@property (nonatomic,assign) int productIndex;


@property (nonatomic,strong) NSString *shareTitle;
@property (nonatomic,strong) NSString *shareDescription;
@property (nonatomic,strong) NSString *shareWebpageUrl;
@property (nonatomic,strong) NSData *shareThumbData;


@end

@implementation SettingVC

#pragma mark - Getter & Setter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    self.shareTitle=NSLocalizedString(@"中国那么大，我要去看看", @"");
    self.shareDescription=NSLocalizedString(@"提供原创、超清、经典、唯美的景点图片，带你走进三山五岳、烟雨江南，陪你踏遍大江南北、万里河山。", @"");
    self.shareWebpageUrl=AppDownloadURLString;
    self.shareThumbData = nil;
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
    
    //
    RETableViewSection *section1=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"section1", @"时刻模式")];
    
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
    RETextItem *playTimeIntervalItem = [RETextItem itemWithTitle:NSLocalizedString(@"Play Time Interval(s)",@"播放时间间隔（秒）") value:tempString placeholder:@""];
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
    
    //时刻模式
    RETableViewSection *momentModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"MomentMode", @"时刻模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.mergedDistanceForMoment];
    RETextItem *mergedDistanceForMomentItem = [RETextItem itemWithTitle:NSLocalizedString(@"Moment Mode Merged Distance(m)",@"时刻模式合并距离（米）") value:tempString placeholder:@""];
    mergedDistanceForMomentItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergedDistanceForMomentItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergedDistanceForMoment = [item.value doubleValue];
    };

    //mergedDistanceForMomentItem. = NSTextAlignmentRight;
    
    [momentModeSection addItemsFromArray:@[mergedDistanceForMomentItem]];
    
#pragma mark 时刻模式
    
    //地址模式
    RETableViewSection *locationModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"LocationMode", @"地址模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.mergedDistanceForLocation];
    RETextItem *mergedDistanceForLocationItem = [RETextItem itemWithTitle:NSLocalizedString(@"Location Mode Merged Distance(m)",@"地址模式合并距离（米）") value:tempString placeholder:@""];
    mergedDistanceForLocationItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergedDistanceForLocationItem.onEndEditing = ^(RETextItem *item){
        if(DEBUGMODE) NSLog(@"%@",item.value);
        self.settingManager.mergedDistanceForLocation = [item.value doubleValue];
    };
    //mergedDistanceForLocationItem.textAlignment = NSTextAlignmentRight;
    [locationModeSection addItemsFromArray:@[mergedDistanceForLocationItem]];

#pragma mark 购买
    
    RETableViewSection *purchaseSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Purchase and Restore", @"购买与恢复")];
    [purchaseSection setHeaderHeight:20];
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"Share Function",@"轨迹分享") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
    }]];

#pragma mark 分享
    RETableViewSection *shareSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"Share", @"分享")];
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
    
    [self.reTVManager addSectionsFromArray:@[section1,momentModeSection,locationModeSection,purchaseSection,shareSection,aboutSection]];
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
    webpageObject.webpageUrl=self.shareWebpageUrl;
    if(DEBUGMODE) NSLog(@"shareWebpageUrl:\n%@",self.shareWebpageUrl);
    
    id mediaObject;
    mediaObject = webpageObject;
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    mediaMessage.title = self.shareTitle;
    mediaMessage.description = self.shareDescription;
    mediaMessage.mediaObject = mediaObject;
    mediaMessage.thumbData = self.shareThumbData;
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= wxScene;

    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
}

@end
