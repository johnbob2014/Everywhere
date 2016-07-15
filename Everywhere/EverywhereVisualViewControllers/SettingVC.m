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

@property (nonatomic,assign) int productIndex;

@property (nonatomic,strong) NSString *shareTitle;
@property (nonatomic,strong) NSString *shareDescription;

@property (nonatomic,strong) EverywhereSettingManager *settingManager;

@end

@implementation SettingVC

#pragma mark - Getter & Setter

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    self.shareTitle=NSLocalizedString(@"中国那么大，我要去看看", @"");
    self.shareDescription=NSLocalizedString(@"提供原创、超清、经典、唯美的景点图片，带你走进三山五岳、烟雨江南，陪你踏遍大江南北、万里河山。", @"");
    
    self.title=@"设置";
    
    //[self initSettingUI];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backToMain)];
    
}

- (void)backToMain{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initSettingUI];
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
    
    // 主题颜色
    NSArray *colorSchemeArray = @[@"Classic Gray",@"Forest Green",@"Fresh Blue",@"Deep Brown"];
    NSString *currentCS = colorSchemeArray[self.settingManager.colorScheme];
    REPickerItem *colorSchemePickerItem = [REPickerItem itemWithTitle:@"Color Scheme"
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
    [section1 addItem:colorSchemePickerItem];
    

    REBoolItem *useCellularDataItem=[REBoolItem itemWithTitle:NSLocalizedString(@"🌐 使用蜂窝移动数据", @"") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        //[SceneryModel sharedModel].canUseCellularData=item.value;
    }];
    REBoolItem *catchHDItem=[REBoolItem itemWithTitle:NSLocalizedString(@"🌈 缓存高清图", @"") value:YES switchValueChangeHandler:^(REBoolItem *item) {
        
    }];
    RETableViewItem *clearCatchItem=[RETableViewItem itemWithTitle:NSLocalizedString(@"❌ 清理缓存",@"") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
    }];
    
    //时刻模式
    RETableViewSection *momentModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"MomentMode", @"时刻模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.mergedDistanceForMoment];
    RETextItem *mergedDistanceForMomentItem = [RETextItem itemWithTitle:NSLocalizedString(@"mergedDistanceForMoment",@"") value:tempString placeholder:@""];
    mergedDistanceForMomentItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergedDistanceForMomentItem.onEndEditing = ^(RETextItem *item){
        NSLog(@"%@",item.value);
        self.settingManager.mergedDistanceForMoment = [item.value doubleValue];
    };

    //mergedDistanceForMomentItem. = NSTextAlignmentRight;
    
    [momentModeSection addItemsFromArray:@[mergedDistanceForMomentItem]];
    
    //地址模式
    RETableViewSection *locationModeSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"LocationMode", @"地址模式")];
    //[optionSection setHeaderHeight:30];
    
    tempString = [NSString stringWithFormat:@"%.f",self.settingManager.mergedDistanceForLocation];
    RETextItem *mergedDistanceForLocationItem = [RETextItem itemWithTitle:NSLocalizedString(@"mergedDistanceForLocation",@"") value:tempString placeholder:@""];
    mergedDistanceForLocationItem.onChangeCharacterInRange = [self createLimitInputBlockWithAllowedString:NumberAndDecimal];
    mergedDistanceForLocationItem.onEndEditing = ^(RETextItem *item){
        NSLog(@"%@",item.value);
        self.settingManager.mergedDistanceForLocation = [item.value doubleValue];
    };
    //mergedDistanceForLocationItem.textAlignment = NSTextAlignmentRight;
    [locationModeSection addItemsFromArray:@[mergedDistanceForLocationItem]];

    //购买
    NSInteger purchasedCoins=[[NSUserDefaults standardUserDefaults] integerForKey:@"purchasedCoins"];
    //    id coins=[[NSUserDefaults standardUserDefaults] objectForKey:@"purchasedCoins"];
    //    if (coins) {
    //        purchasedCoins=(NSInteger)coins;
    //    }else{
    //        purchasedCoins=20;
    //    }
    NSString *headerTitle=[NSString stringWithFormat:@"购买图币(现有图币:%ld) 图币可用于下载高清大图",(long)purchasedCoins];
    
    RETableViewSection *purchaseSection=[RETableViewSection sectionWithHeaderTitle:headerTitle];
    [purchaseSection setHeaderHeight:20];
    [purchaseSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🌠 300图币,6元(0.020元/图币)",@"") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        InAppPurchaseVC *purchaseVC = [InAppPurchaseVC new];
        purchaseVC.productIndex = 0;
        [self.navigationController pushViewController:purchaseVC animated:YES];
    }]];
    
    //分享
    RETableViewSection *shareSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"分享", @"")];
    [shareSection setHeaderHeight:20];
    [shareSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🍀 微信朋友圈",@"") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        //NSLog(@"ok");
        //[self sendToWXscene:WXSceneTimeline];
    }]];
    [shareSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"💠 微信好友",@"") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        //[self sendToWXscene:WXSceneSession];
    }]];
    /*
     [shareSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"✉️ 短信",@"") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
     [item deselectRowAnimated:YES];
     
     //[weakSelf sendSMS];
     }]];
     */
    
    //其他
    RETableViewSection *aboutSection=[RETableViewSection sectionWithHeaderTitle:NSLocalizedString(@"其他", @"")];
    [aboutSection setHeaderHeight:20];
    [aboutSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"💖 给个好评", @"") accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[APP_DOWNLOAD_URL copy]]];
    }]];
    
    [aboutSection addItem:[RETableViewItem itemWithTitle:NSLocalizedString(@"🎉 关于", @"") accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
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

@end
