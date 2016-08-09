//
//  ShareFootprintsRepositoryVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#import "WXApi.h"
#import "ShareFootprintsRepositoryVC.h"
#import "EverywhereFootprintsRepositoryManager.h"
#import "EverywhereSettingManager.h"

@interface ShareFootprintsRepositoryVC () <UIDocumentInteractionControllerDelegate>

@end

@implementation ShareFootprintsRepositoryVC{
    UIDocumentInteractionController *documentInteractionController;
    UILabel *titleLabel;
    UITextField *titleTF;
    UIButton *wxSessionBtn,*fileShareBtn;//*wxTimelineBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = VCBackgroundColor;
    self.title = NSLocalizedString(@"Share footprints", @"分享足迹");
    
    titleLabel = [UILabel newAutoLayoutView];
    titleLabel.text = NSLocalizedString(@"Set title for your footprints", @"为足迹添加标题");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:30];
    
    titleTF = [UITextField newAutoLayoutView];
    
    //titleTF.textColor = [UIColor whiteColor];
    titleTF.clearButtonMode = UITextFieldViewModeAlways;
    titleTF.textAlignment = NSTextAlignmentCenter;
    
    titleTF.font = [UIFont fontWithName:@"FontAwesome" size:titleTF.font.pointSize * 1.2];
    //titleTF.backgroundColor = [UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1];
    
    titleTF.layer.borderWidth = 1;
    titleTF.layer.borderColor = [[EverywhereSettingManager defaultManager].baseTintColor CGColor];
    //titleTF.layer.cornerRadius = 4.0;
    titleTF.layer.masksToBounds = YES;
    
    
    //titleTF.contentMode = UIViewContentModeScaleAspectFit;
    //titleTF.text = NSLocalizedString(@"I shared my footprints to you!Take a look!", @"我分享了一个足迹给你，快来看看吧！");
    titleTF.text = self.footprintsRepository.title; //NSLocalizedString(@"Wonderful Trip To Australia", @"美妙的澳洲之行");
    [self.view addSubview:titleTF];
    [titleTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:5];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [titleTF autoSetDimension:ALDimensionHeight toSize:50];
    //[titleTF autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:sessionBtn withOffset:-5];

    wxSessionBtn = [UIButton newAutoLayoutView];
    [wxSessionBtn setTitle:NSLocalizedString(@"Try WeChat Share", @"体验微信分享") forState:UIControlStateNormal];
    [wxSessionBtn primaryStyle];
    wxSessionBtn.tag = WXSceneSession;
    [wxSessionBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:wxSessionBtn];
    [wxSessionBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleTF withOffset:10];
    [wxSessionBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [wxSessionBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:40];
    [wxSessionBtn autoSetDimension:ALDimensionHeight toSize:40];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [infoButton addTarget:self action:@selector(showInfoAboutWXShareAlertController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:infoButton];
    [infoButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:wxSessionBtn];
    [infoButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];

    fileShareBtn = [UIButton newAutoLayoutView];
    [fileShareBtn setTitle:NSLocalizedString(@"Unlimited Share", @"无限制分享") forState:UIControlStateNormal];
    [fileShareBtn primaryStyle];
    fileShareBtn.tag = WXSceneSession;
    [fileShareBtn addTarget:self action:@selector(fileShare) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:fileShareBtn];
    [fileShareBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:wxSessionBtn withOffset:10];
    [fileShareBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [fileShareBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [fileShareBtn autoSetDimension:ALDimensionHeight toSize:40];

    
    /*
    wxTimelineBtn = [UIButton newAutoLayoutView];
    [wxTimelineBtn setImage:[UIImage imageNamed:@"Share_WXTimeline"] forState:UIControlStateNormal];
    wxTimelineBtn.tag = WXSceneTimeline;
    [wxTimelineBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:wxTimelineBtn];
    [wxTimelineBtn autoSetDimensionsToSize:CGSizeMake(60, 60)];
    [wxTimelineBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:wxSessionBtn withOffset:10];
    [wxTimelineBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    */
    
}

#pragma mark - File Share

- (void)fileShare{
    
    if (![EverywhereSettingManager defaultManager].hasPurchasedShare && self.userDidSelectedPurchaseShareFunctionHandler){
        self.userDidSelectedPurchaseShareFunctionHandler();
        return;
    }
    
    self.footprintsRepository.title = titleTF.text;
    
    NSString *filePath = [Path_Caches stringByAppendingPathComponent:self.footprintsRepository.title];
    filePath = [filePath stringByAppendingString:@".abf"];
    
    if ([self.footprintsRepository exportToFile:filePath]){
        documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
        documentInteractionController.delegate = self;
        documentInteractionController.UTI = ABFUTI;
        //documentInteractionController.icons = @[self.thumbImage];
        
        [documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
    return;
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
    //NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
    
    if (succeeded){
        // 如果发送成功，保存到我的分享
        [EverywhereFootprintsRepositoryManager addFootprintsRepository:self.footprintsRepository];
        NSLog(@"%@",self.footprintsRepository);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSString *)createFootprintsRepositoryString{
    self.footprintsRepository.title = titleTF.text;
    
    NSData *footprintsRepositoryData = [NSKeyedArchiver archivedDataWithRootObject:self.footprintsRepository];
    
    NSString *footprintsRepositoryString = [footprintsRepositoryData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if (footprintsRepositoryString.length > 10*1024*8) {
        NSLog(@"footprintsOrPositionURL is too Long!");
        return nil;
    }
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",WXAppID];
    
    footprintsRepositoryString = [headerString stringByAppendingString:footprintsRepositoryString];
    return footprintsRepositoryString;
    
}

- (void)showInfoAboutWXShareAlertController{
    UIAlertController *infomationAlertController = [UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Because of the limitation of WeChat content , make sure your footprints count within 30 , otherwise share may fail.Unlimited Share support multiple share styles and has no footprints count limitation.", @"由于微信分享内容限制为10K，所以请将分享的足迹点数量控制在30个以内，否则可能会分享失败。无限制分享可选择多种方式分享，且没有足迹点数量限制。")];
    [self presentViewController:infomationAlertController animated:YES completion:nil];
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
