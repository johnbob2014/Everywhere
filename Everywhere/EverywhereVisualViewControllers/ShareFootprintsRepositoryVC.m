//
//  ShareFootprintsRepositoryVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "WXApi.h"
#import "ShareFootprintsRepositoryVC.h"

#import "EverywhereSettingManager.h"
#import "EverywhereCoreDataManager.h"

#import "EverywhereFootprintAnnotation.h"

#define ShareButtonHeight 44
#define LabelHeight 20

@interface ShareFootprintsRepositoryVC () <UIDocumentInteractionControllerDelegate>

@end

@implementation ShareFootprintsRepositoryVC{
    UIDocumentInteractionController *documentInteractionController;
    UILabel *titleLabel,*statisticsInfoLabel;
    UITextField *titleTF;
    UITextView *statisticsInfoTV;
    UIButton *firstBtn,*sencondBtn,*thirdBtn;
    
    EverywhereSettingManager *settingManager;
    NSString *mfrString;
    NSString *gpxString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    settingManager = [EverywhereSettingManager defaultManager];
    mfrString = NSLocalizedString(@"MFR Share", @"MFR 分享");
    gpxString = NSLocalizedString(@"GPX Share", @"GPX 分享");
    
    self.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.9, 300);
    self.landscapeContentSizeInPopup = CGSizeMake(300, ScreenWidth * 0.9);
    
    self.view.backgroundColor = [EverywhereSettingManager defaultManager].backgroundColor;
    self.title = NSLocalizedString(@"Share footprints", @"分享足迹");
    
    titleLabel = [UILabel newAutoLayoutView];
    titleLabel.text = NSLocalizedString(@"Set title", @"设置标题");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:LabelHeight];
    
    titleTF = [UITextField newAutoLayoutView];
    titleTF.clearButtonMode = UITextFieldViewModeAlways;
    titleTF.textAlignment = NSTextAlignmentCenter;
    titleTF.font = [UIFont fontWithName:@"FontAwesome" size:titleTF.font.pointSize * 1.2];
    titleTF.layer.borderWidth = 1;
    titleTF.layer.cornerRadius = 3.0;
    titleTF.layer.masksToBounds = YES;
    titleTF.text = self.footprintsRepository.title;
    [self.view addSubview:titleTF];
    [titleTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:5];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [titleTF autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 0.8];
    
    statisticsInfoLabel = [UILabel newAutoLayoutView];
    statisticsInfoLabel.text = NSLocalizedString(@"Set statistics info", @"设置统计信息");
    statisticsInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statisticsInfoLabel];
    [statisticsInfoLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleTF withOffset:10];
    [statisticsInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [statisticsInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [statisticsInfoLabel autoSetDimension:ALDimensionHeight toSize:LabelHeight];
    
    statisticsInfoTV = [UITextView newAutoLayoutView];
    statisticsInfoTV.backgroundColor = [UIColor clearColor];
    //statisticsInfoTV.textAlignment = NSTextAlignmentLeft;
    statisticsInfoTV.font = [UIFont fontWithName:@"FontAwesome" size:statisticsInfoLabel.font.pointSize];
    statisticsInfoTV.layer.borderWidth = 1;
    //statisticsInfoTV.layer.borderColor =
    statisticsInfoTV.layer.cornerRadius = 3.0;
    //statisticsInfoTV.layer.masksToBounds = YES;
    statisticsInfoTV.text = self.footprintsRepository.placemarkStatisticalInfo;
    //if (DEBUGMODE) NSLog(@"%@",statisticsInfoTV.text);
    [self.view addSubview:statisticsInfoTV];
    [statisticsInfoTV autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:statisticsInfoLabel withOffset:5];
    [statisticsInfoTV autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [statisticsInfoTV autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [statisticsInfoTV autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 1.5];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.backgroundColor = DEBUGMODE ? [[UIColor cyanColor] colorWithAlphaComponent:0.6] : [UIColor clearColor];
    infoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [infoButton addTarget:self action:@selector(showInfoAboutWXShareAlertController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:infoButton];
    [infoButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:statisticsInfoTV withOffset:15];
    [infoButton autoSetDimensionsToSize:CGSizeMake(ShareButtonHeight,ShareButtonHeight)];
    [infoButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];


    firstBtn = [UIButton newAutoLayoutView];
    [firstBtn setTitle:NSLocalizedString(@"WeChat Share", @"微信分享") forState:UIControlStateNormal];
    [firstBtn setStyle:UIButtonStylePrimary];
    firstBtn.tag = WXSceneSession;
    [firstBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:firstBtn];
    [firstBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:statisticsInfoTV withOffset:15];
    [firstBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [firstBtn autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:infoButton withOffset:-10];
    [firstBtn autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
    NSString *tempString = mfrString;
    
    sencondBtn = [UIButton newAutoLayoutView];
    if (!settingManager.hasPurchasedShareAndBrowse){
        tempString = [tempString stringByAppendingFormat:@"(%lu)",(long)settingManager.trialCountForMFR];
    }
    [sencondBtn setTitle:tempString forState:UIControlStateNormal];
    [sencondBtn setStyle:UIButtonStylePrimary];
    sencondBtn.tag = 0;
    [sencondBtn addTarget:self action:@selector(fileShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:sencondBtn];
    [sencondBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:firstBtn withOffset:10];
    [sencondBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    //[sencondBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [sencondBtn autoSetDimension:ALDimensionWidth toSize:(self.view.frame.size.width - 30 - 40)/2.0];
    [sencondBtn autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
    tempString = gpxString;
    thirdBtn = [UIButton newAutoLayoutView];
    if (!settingManager.hasPurchasedShareAndBrowse){
         tempString = [tempString stringByAppendingFormat:@"(%lu)",(long)settingManager.trialCountForGPX];
    }
    [thirdBtn setTitle:tempString forState:UIControlStateNormal];
    [thirdBtn setStyle:UIButtonStylePrimary];
    thirdBtn.tag = 1;
    [thirdBtn addTarget:self action:@selector(fileShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:thirdBtn];
    [thirdBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:firstBtn withOffset:10];
    //[thirdBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [thirdBtn autoSetDimension:ALDimensionWidth toSize:(self.view.frame.size.width - 30 - 40)/2.0];
    [thirdBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [thirdBtn autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
}

#pragma mark - File Share

- (void)fileShare:(UIButton *)sender{
    
    if (![EverywhereSettingManager defaultManager].hasPurchasedShareAndBrowse){
        if (sender.tag == 0 && settingManager.trialCountForMFR > 0){
            settingManager.trialCountForMFR--;
            [sender setTitle:[NSString stringWithFormat:@"%@(%lu)",mfrString,(long)settingManager.trialCountForMFR] forState:UIControlStateNormal];
        }else if (sender.tag == 1 && settingManager.trialCountForGPX > 0){
            settingManager.trialCountForGPX--;
            [sender setTitle:[NSString stringWithFormat:@"%@(%lu)",gpxString,(long)settingManager.trialCountForGPX] forState:UIControlStateNormal];
        }else{
            if(self.userDidSelectedPurchaseShareFunctionHandler) self.userDidSelectedPurchaseShareFunctionHandler();
            return;
        }
    }
    
    self.footprintsRepository.title = titleTF.text;
    self.footprintsRepository.placemarkStatisticalInfo = statisticsInfoTV.text;
    
    NSString *filePath = [Path_Caches stringByAppendingPathComponent:self.footprintsRepository.title];
    
    BOOL exportSucceeded = NO;
    documentInteractionController = [UIDocumentInteractionController new];
    documentInteractionController.delegate = self;
    
    switch (sender.tag) {
        case 0:
            filePath = [filePath stringByAppendingString:@".mfr"];
            exportSucceeded = [self.footprintsRepository exportToMFRFile:filePath];
            documentInteractionController.UTI = MFRUTI;
            break;
        case 1:
            filePath = [filePath stringByAppendingString:@".gpx"];
            exportSucceeded = [self.footprintsRepository exportToGPXFile:filePath];
            break;
        default:
            break;
    }
    
    if (exportSucceeded){
        documentInteractionController.URL = [NSURL fileURLWithPath:filePath];
        [documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
    }else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Create File Failed!",@"生成文件失败！")];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WXShare

- (void)wxShare:(UIButton *)sender{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]){
        if(DEBUGMODE) NSLog(@"WeChat uninstalled or not support!");
        return;
    }
    
    WXWebpageObject *webpageObject=[WXWebpageObject new];
    webpageObject.webpageUrl=[self createFootprintsRepositoryString];
    //if(DEBUGMODE) NSLog(@"shareWebpageUrl:\n%@",self.shareWebpageUrl);
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    //mediaMessage.title = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"I shared my footprints to you!Take a look!", @"我分享了一个足迹给你，快来看看吧！"),titleTF.text];
    mediaMessage.title = titleTF.text;
    mediaMessage.description = NSLocalizedString(@"Tap '···' and choose 'Open In Safari' to open AlbumMaps", @"点击右上角“···”，选择“在Safari中打开”，进入《相册地图》查看");
    mediaMessage.mediaObject = webpageObject;
    mediaMessage.thumbData = UIImageJPEGRepresentation(self.thumbImage, 0.5);
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= (int)sender.tag;
    //if(DEBUGMODE) NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
    
    if (succeeded){
        // 如果发送成功，保存到我的分享
        #warning addFootprintsRepository
        [EverywhereCoreDataManager  addEWFR:self.footprintsRepository];
        //if(DEBUGMODE) NSLog(@"%@",self.footprintsRepository);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSString *)createFootprintsRepositoryString{
    self.footprintsRepository.title = titleTF.text;
    
    // 清除缩略图数据
    EverywhereFootprintsRepository *copyedFR = [self.footprintsRepository copy];
    for (EverywhereFootprintAnnotation *footprintAnnotation in copyedFR.footprintAnnotations) {
        footprintAnnotation.thumbnail = nil;
    }
    
    NSData *footprintsRepositoryData = [NSKeyedArchiver archivedDataWithRootObject:copyedFR];
    
    NSString *footprintsRepositoryString = [footprintsRepositoryData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if (footprintsRepositoryString.length > 10*1024*8) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"FootprintsRepository is too big!",@"足迹包数据量太大，无法用微信分享！")];
        return nil;
    }
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",[EverywhereSettingManager defaultManager].wxAppID];
    
    footprintsRepositoryString = [headerString stringByAppendingString:footprintsRepositoryString];
    return footprintsRepositoryString;
    
}

- (void)showInfoAboutWXShareAlertController{
    UIAlertController *informationAlertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Because of the restriction of WeChat content , make sure your footprints count within 30 , otherwise share may fail.\nShareAndBrowse function support multiple share styles and has no footprints count restriction. MFR File support thumbnail. GPX File can be used on portable GPS.", @"由于微信分享内容限制为10K，所以请将分享的足迹点数量控制在30个以内，否则可能会分享失败。\n分享和浏览功能可选择多种方式进行分享，且没有足迹点数量限制;其中，MFR文件支持选择缩略图，更清晰直观；GPX文件则可以在手持GPS上使用。")];
    [self presentViewController:informationAlertController animated:YES completion:nil];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
    return self.view.frame;
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller{
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    
}

@end
