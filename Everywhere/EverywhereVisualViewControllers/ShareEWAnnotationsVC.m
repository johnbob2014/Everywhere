//
//  ShareEWAnnotationsVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#import "WXApi.h"
#import "ShareEWAnnotationsVC.h"

@interface ShareEWAnnotationsVC ()

@end

@implementation ShareEWAnnotationsVC{
    UILabel *titleLabel;
    UITextField *titleTF;
    UIButton *sessionBtn,*timelineBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Share footprints", @"分享足迹");
    
    titleLabel = [UILabel newAutoLayoutView];
    titleLabel.text = NSLocalizedString(@"Give a name for your footprints", @"为足迹添加标题");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    [titleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    sessionBtn = [UIButton newAutoLayoutView];
    [sessionBtn infoStyle];
    sessionBtn.tag = WXSceneSession;
    [sessionBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:sessionBtn];
    [sessionBtn autoSetDimension:ALDimensionHeight toSize:44];
    [sessionBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withMultiplier:0.3];
    [sessionBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [sessionBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    timelineBtn = [UIButton newAutoLayoutView];
    [timelineBtn dangerStyle];
    timelineBtn.tag = WXSceneTimeline;
    [timelineBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:timelineBtn];
    [timelineBtn autoSetDimension:ALDimensionHeight toSize:44];
    [timelineBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view withMultiplier:0.3];
    [timelineBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:sessionBtn withOffset:5];
    [timelineBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    titleTF = [UITextField newAutoLayoutView];
    //titleTF.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:titleTF];
    [titleTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:5];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [titleTF autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:sessionBtn withOffset:-5];
}

- (NSString *)createString{
    NSData *trackOrPositionData = [NSKeyedArchiver archivedDataWithRootObject:self.shareAnnos];
    //NSString *trackOrPositionURL = [[NSString alloc] initWithData:trackOrPositionData encoding:NSNonLossyASCIIStringEncoding];
    NSString *trackOrPositionString = [trackOrPositionData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    //NSLog(@"trackOrPositionURL (length:%ld) :\n%@",trackOrPositionString.length,trackOrPositionString);
    
    if (trackOrPositionString.length > 10*1024*8) {
        NSLog(@"trackOrPositionURL is too Long!");
        return nil;
    }
    NSString *headerString = nil;
    if (self.mapShowMode == MapShowModeMoment) headerString = [NSString stringWithFormat:@"%@://AlbumMaps/track/",WXAppID];
    else if (self.mapShowMode == MapShowModeLocation) headerString = [NSString stringWithFormat:@"%@://AlbumMaps/position/radius%0.f/",WXAppID,self.mergedDistanceForLocation];
    
    trackOrPositionString = [headerString stringByAppendingString:trackOrPositionString];
    return trackOrPositionString;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wxShare:(UIButton *)sender{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]){
        if(DEBUGMODE) NSLog(@"WeChat uninstalled or not support!");
        return;
    }
    
    WXWebpageObject *webpageObject=[WXWebpageObject new];
    webpageObject.webpageUrl=[self createString];
    //if(DEBUGMODE) NSLog(@"shareWebpageUrl:\n%@",self.shareWebpageUrl);
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    mediaMessage.title = NSLocalizedString(@"I shared my footprints to you!Take a look!", @"我分享了一个足迹给你，快来看看吧！");
    mediaMessage.description = NSLocalizedString(@"Tap '···' and choose 'Open In Safari' to open AlbumMaps", @"点击右上角“···”，选择“在Safari中打开”，进入《相册地图》查看");
    mediaMessage.mediaObject = webpageObject;
    mediaMessage.thumbData = self.shareThumbData;
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= (int)sender.tag;
    //NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
