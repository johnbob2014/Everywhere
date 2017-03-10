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

#import "FootprintAnnotation.h"

#define ShareButtonHeight 40
#define LabelHeight 20

@interface ShareFootprintsRepositoryVC () <UIDocumentInteractionControllerDelegate>

@end

@implementation ShareFootprintsRepositoryVC{
    UIDocumentInteractionController *documentInteractionController;
    UILabel *titleLabel,*statisticsInfoLabel,*thumbnailLabel;
    UITextField *titleTF;
    UITextView *statisticsInfoTV;
    UIScrollView *thumbnailSV;
    UIButton *bottomLeftButton,*topLeftButton,*topRightButton;
    
    NSString *mfrString;
    NSString *gpxString;
    
    EverywhereSettingManager *settingManager;
    FootprintsRepository *wxShareFR;
    
    CGFloat thumbnailOffset;
    CGFloat thumbnailWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    settingManager = [EverywhereSettingManager defaultManager];
    mfrString = NSLocalizedString(@"MFR Share", @"MFR分享");
    gpxString = NSLocalizedString(@"GPX Share", @"GPX分享");
    
    self.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.9, 480);
    self.landscapeContentSizeInPopup = CGSizeMake(480, ScreenWidth * 0.9);
    
    self.view.backgroundColor = [EverywhereSettingManager defaultManager].backgroundColor;
    self.title = NSLocalizedString(@"Share footprints", @"分享足迹");
    
    titleLabel = [UILabel newAutoLayoutView];
    titleLabel.text = NSLocalizedString(@"Set Title", @"设置标题");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:LabelHeight];
    
    titleTF = [UITextField newAutoLayoutView];
    titleTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    titleTF.textAlignment = NSTextAlignmentCenter;
    titleTF.font = [UIFont fontWithName:@"FontAwesome" size:titleTF.font.pointSize * 1.2];
    titleTF.layer.borderWidth = 1;
    titleTF.layer.borderColor = [settingManager.baseTintColor CGColor];
    titleTF.layer.cornerRadius = 3.0;
    titleTF.layer.masksToBounds = YES;
    titleTF.text = self.footprintsRepository.title;
    [self.view addSubview:titleTF];
    [titleTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:5];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [titleTF autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 0.8];
    
    statisticsInfoLabel = [UILabel newAutoLayoutView];
    statisticsInfoLabel.text = NSLocalizedString(@"Set Statistics Info", @"设置统计信息");
    statisticsInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:statisticsInfoLabel];
    [statisticsInfoLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleTF withOffset:10];
    [statisticsInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [statisticsInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [statisticsInfoLabel autoSetDimension:ALDimensionHeight toSize:LabelHeight];
    
    statisticsInfoTV = [UITextView newAutoLayoutView];
    statisticsInfoTV.backgroundColor = [UIColor clearColor];
    statisticsInfoTV.font = [UIFont fontWithName:@"FontAwesome" size:statisticsInfoLabel.font.pointSize];
    statisticsInfoTV.layer.borderWidth = 1;
    statisticsInfoTV.layer.borderColor = [settingManager.baseTintColor CGColor];
    statisticsInfoTV.layer.cornerRadius = 3.0;
    statisticsInfoTV.text = self.footprintsRepository.placemarkStatisticalInfo;
    [self.view addSubview:statisticsInfoTV];
    [statisticsInfoTV autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:statisticsInfoLabel withOffset:5];
    [statisticsInfoTV autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [statisticsInfoTV autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [statisticsInfoTV autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 1.5];
    
    thumbnailLabel = [UILabel newAutoLayoutView];
    thumbnailLabel.text = [NSString stringWithFormat:@"%@ - %lu",NSLocalizedString(@"MFR Thumbnails", @"MFR缩略图"),(long)self.footprintsRepository.thumbnailCount];
    thumbnailLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:thumbnailLabel];
    [thumbnailLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:statisticsInfoTV withOffset:10];
    [thumbnailLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [thumbnailLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [thumbnailLabel autoSetDimension:ALDimensionHeight toSize:LabelHeight];
    
    thumbnailSV = [UIScrollView newAutoLayoutView];
    thumbnailSV.backgroundColor = ClearColor;
    [self.view addSubview:thumbnailSV];
    [thumbnailSV autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:thumbnailLabel withOffset:5];
    [thumbnailSV autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [thumbnailSV autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [thumbnailSV autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 4 + 5];
    
    thumbnailOffset = 5;
    thumbnailWidth = ShareButtonHeight * 3;//(ScreenWidth - 20 - 2 * thumbnailOffset)/3.0;
    [self updateThumbnailSV];
    
    [self initButtons];
}

- (void)updateThumbnailSV{
    
    for(UIView *view in thumbnailSV.subviews){
        [view removeFromSuperview];
    }
    
    thumbnailSV.contentSize = CGSizeMake((thumbnailWidth + thumbnailOffset) * self.footprintsRepository.thumbnailCount, ShareButtonHeight * 4);
    
    // 第1层循环
    __block NSUInteger addedCount = 0;
    [self.footprintsRepository.footprintAnnotations enumerateObjectsUsingBlock:^(FootprintAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 第2层循环
        [obj.thumbnailArray enumerateObjectsUsingBlock:^(id _Nonnull image, NSUInteger imageIndex, BOOL * _Nonnull stop) {
            UIImageView *iv = [[UIImageView alloc] initWithImage: ([image isKindOfClass:[UIImage class]] ? image : [[UIImage alloc] initWithData:image])];
            iv.backgroundColor = ClearColor;
            iv.contentMode = UIViewContentModeScaleAspectFit;
            
            iv.tag = idx;
            iv.userInteractionEnabled = YES;
            
            iv.frame = CGRectMake((thumbnailWidth + thumbnailOffset) * addedCount, 0, thumbnailWidth, ShareButtonHeight * 4);
            //if(DEBUGMODE) NSLog(@"%u %@",addedCount,NSStringFromCGRect(iv.frame));
            
            UIButton *crossButton = [UIButton newAutoLayoutView];
            crossButton.alpha = 0.6;
            crossButton.tag = imageIndex;
            [crossButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
            [crossButton addTarget:self action:@selector(crossButtonTD:) forControlEvents:UIControlEventTouchDown];
            [iv addSubview:crossButton];
            [crossButton autoSetDimensionsToSize:CGSizeMake(25, 25)];
            [crossButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
            [crossButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
            
            [thumbnailSV addSubview:iv];
            addedCount++;
        }];
    }];

}

- (void)initButtons{
    UIView *buttonContainerView = [UIView newAutoLayoutView];
    buttonContainerView.backgroundColor = DEBUGMODE ? [[UIColor randomFlatColor] colorWithAlphaComponent:0.6] : ClearColor;
    [self.view addSubview:buttonContainerView];
    [buttonContainerView autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight * 2 + 10];
    [buttonContainerView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withOffset:-20];
    [buttonContainerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:thumbnailSV withOffset:10];
    [buttonContainerView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.view];
    
    NSString *tempString = mfrString;
    
    topLeftButton = [UIButton newAutoLayoutView];
    if (!settingManager.hasPurchasedShareAndBrowse){
        tempString = [tempString stringByAppendingFormat:@"(%lu)",(long)settingManager.trialCountForShareAndBrowse];
    }
    [topLeftButton setTitle:tempString forState:UIControlStateNormal];
    [topLeftButton setStyle:UIButtonStylePrimary];
    topLeftButton.tag = 0;
    [topLeftButton addTarget:self action:@selector(fileShare:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:topLeftButton];
    [topLeftButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [topLeftButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [topLeftButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
    tempString = gpxString;
    topRightButton = [UIButton newAutoLayoutView];
    if (!settingManager.hasPurchasedShareAndBrowse){
        tempString = [tempString stringByAppendingFormat:@"(%lu)",(long)settingManager.trialCountForShareAndBrowse];
    }
    [topRightButton setTitle:tempString forState:UIControlStateNormal];
    [topRightButton setStyle:UIButtonStylePrimary];
    topRightButton.tag = 1;
    [topRightButton addTarget:self action:@selector(fileShare:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:topRightButton];
    [topRightButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [topRightButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [topRightButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    [topRightButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:topLeftButton];
    [topRightButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:topLeftButton withOffset:10];
    
    bottomLeftButton = [UIButton newAutoLayoutView];
    [bottomLeftButton setTitle:NSLocalizedString(@"Free Share", @"无图分享") forState:UIControlStateNormal];
    [bottomLeftButton setStyle:UIButtonStylePrimary];
    bottomLeftButton.tag = WXSceneSession;
    [bottomLeftButton addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:bottomLeftButton];
    [bottomLeftButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [bottomLeftButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [bottomLeftButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    
    UIButton *bottomRightButton = [UIButton newAutoLayoutView];
    [bottomRightButton setTitle:NSLocalizedString(@"Instructions", @"分享说明") forState:UIControlStateNormal];
    [bottomRightButton setStyle:UIButtonStylePrimary];
    [bottomRightButton addTarget:self action:@selector(showInfoAlertController) forControlEvents:UIControlEventTouchDown];
    [buttonContainerView addSubview:bottomRightButton];
    [bottomRightButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [bottomRightButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [bottomRightButton autoSetDimension:ALDimensionHeight toSize:ShareButtonHeight];
    [bottomRightButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:bottomLeftButton];
    [bottomRightButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:bottomLeftButton withOffset:10];
}

#pragma mark - Thumnail Images

- (void)crossButtonTD:(UIButton *)sender{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromCGPoint(CGPointMake(sender.superview.tag, sender.tag)));
    
    FootprintAnnotation *modifiedFA = self.footprintsRepository.footprintAnnotations[sender.superview.tag];
    [modifiedFA.thumbnailArray removeObjectAtIndex:sender.tag];
    
    [self updateThumbnailSV];
    
    thumbnailLabel.text = [NSString stringWithFormat:@"%@ - %lu",NSLocalizedString(@"MFR Thumbnails", @"MFR缩略图"),(long)self.footprintsRepository.thumbnailCount];
}

#pragma mark - File Share

- (void)fileShare:(UIButton *)sender{
    
    if (![EverywhereSettingManager defaultManager].hasPurchasedShareAndBrowse){
        if (settingManager.trialCountForShareAndBrowse > 0){
            settingManager.trialCountForShareAndBrowse--;
            [topLeftButton setTitle:[NSString stringWithFormat:@"%@(%lu)",mfrString,(long)settingManager.trialCountForShareAndBrowse] forState:UIControlStateNormal];
            [topRightButton setTitle:[NSString stringWithFormat:@"%@(%lu)",gpxString,(long)settingManager.trialCountForShareAndBrowse] forState:UIControlStateNormal];
        }else{
            if(self.userDidSelectedPurchaseShareFunctionHandler) self.userDidSelectedPurchaseShareFunctionHandler();
            return;
        }
    }
    
    self.footprintsRepository.title = titleTF.text;
    self.footprintsRepository.placemarkStatisticalInfo = statisticsInfoTV.text;
    
    NSString *filePath = [[NSURL cachesURL].path stringByAppendingPathComponent:self.footprintsRepository.title];
    
    BOOL exportSucceeded = NO;
    documentInteractionController = [UIDocumentInteractionController new];
    documentInteractionController.delegate = self;
    
    switch (sender.tag) {
        case 0:
            filePath = [filePath stringByAppendingString:@".mfr"];
            exportSucceeded = [self.footprintsRepository exportToMFRFile:filePath];
            documentInteractionController.UTI = UTI_MFR;
            break;
        case 1:
            filePath = [filePath stringByAppendingString:@".gpx"];
            exportSucceeded = [self.footprintsRepository exportToGPXFile:filePath];
            documentInteractionController.UTI = UTI_GPX;
            break;
        default:
            break;
    }
    
    if (exportSucceeded){
        documentInteractionController.URL = [NSURL fileURLWithPath:filePath];
        [documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if(DEBUGMODE) NSLog(@"异步保存分享的足迹包");
            [EverywhereCoreDataManager addEWFR:self.footprintsRepository];
        });
        
    }else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"File Share Failed!",@"文件分享失败！")];
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
    BOOL succeeded=[WXApi sendReq:req];
    
    if (succeeded){
        // 如果发送成功，保存到我的分享（微信分享数据量很小，直接保存）
        [EverywhereCoreDataManager addEWFR:wxShareFR];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"WeChat Share Failed!",@"微信分享失败！")];
    }
}

- (NSString *)createFootprintsRepositoryString{
    self.footprintsRepository.title = titleTF.text;
    self.footprintsRepository.placemarkStatisticalInfo = statisticsInfoTV.text;
    
    // 清除缩略图数据
    wxShareFR = [self.footprintsRepository copy];
    for (FootprintAnnotation *footprintAnnotation in wxShareFR.footprintAnnotations) {
        footprintAnnotation.thumbnailArray = nil;
    }
    
    NSData *footprintsRepositoryData = [NSKeyedArchiver archivedDataWithRootObject:wxShareFR];
    
    NSString *footprintsRepositoryString = [footprintsRepositoryData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if (footprintsRepositoryString.length > 10*1024*8) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"FootprintsRepository is too big!",@"足迹包数据量太大，无法用微信分享！")];
        return nil;
    }
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",[EverywhereSettingManager defaultManager].appWXID];
    
    footprintsRepositoryString = [headerString stringByAppendingString:footprintsRepositoryString];
    return footprintsRepositoryString;
}

- (void)showInfoAlertController{
    NSMutableString *ms = [NSMutableString new];
    [ms appendFormat:@"%@\n",NSLocalizedString(@"ShareAndBrowse function include MFR and GPX file share without footprints count restriction. MFR file support thumbnails. GPX file can be used on portable GPS.", @"分享和浏览功能可以MFR或GPX两种文件格式进行分享，均没有足迹点数量限制。MFR文件支持缩略图。GPX文件可以在手持GPS上使用。")];
    [ms appendFormat:@"%@\n",NSLocalizedString(@"You have 10 chances to try until you purchase ShareAndBrowse function.", @"如果未购买分享和浏览功能，您仍有10次试用机会。")];
    [ms appendFormat:@"%@\n",NSLocalizedString(@"WeChat share is free. But it doesn't support thumbnails and has footprints count restriction.Because of the restriction of WeChat content, make sure your footprints count is less than 30, otherwise share may fail.",@"无图分享免费使用，信托微信消息进行分享，有足迹点数量限制。由于微信将分享内容限制为10K，所以请将足迹点数量控制在30个以内，否则可能会分享失败。")];
    
    UIAlertController *informationAlertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:ms];
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
