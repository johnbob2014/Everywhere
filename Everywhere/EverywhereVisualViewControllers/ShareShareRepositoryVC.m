//
//  ShareShareRepositoryVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#import "WXApi.h"
#import "ShareShareRepositoryVC.h"
#import "EverywhereShareRepositoryManager.h"
#import "EverywhereSettingManager.h"

@interface ShareShareRepositoryVC ()

@end

@implementation ShareShareRepositoryVC{
    UILabel *titleLabel;
    UITextField *titleTF;
    UIButton *sessionBtn,*timelineBtn;
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
    
    sessionBtn = [UIButton newAutoLayoutView];
    [sessionBtn setImage:[UIImage imageNamed:@"Share_WXSession"] forState:UIControlStateNormal];
    sessionBtn.tag = WXSceneSession;
    [sessionBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:sessionBtn];
    [sessionBtn autoSetDimensionsToSize:CGSizeMake(60, 60)];
    [sessionBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [sessionBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    timelineBtn = [UIButton newAutoLayoutView];
    [timelineBtn setImage:[UIImage imageNamed:@"Share_WXTimeline"] forState:UIControlStateNormal];
    timelineBtn.tag = WXSceneTimeline;
    [timelineBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:timelineBtn];
    [timelineBtn autoSetDimensionsToSize:CGSizeMake(60, 60)];
    [timelineBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:sessionBtn withOffset:10];
    [timelineBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
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
    titleTF.text = self.shareRepository.title; //NSLocalizedString(@"Wonderful Trip To Australia", @"美妙的澳洲之行");
    [self.view addSubview:titleTF];
    [titleTF autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleLabel withOffset:5];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [titleTF autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [titleTF autoSetDimension:ALDimensionHeight toSize:50];
    //[titleTF autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:sessionBtn withOffset:-5];
}

- (NSString *)createShareRepositoryString{
    self.shareRepository.title = titleTF.text;
    
    NSData *shareRepositoryData = [NSKeyedArchiver archivedDataWithRootObject:self.shareRepository];
    
    NSString *shareRepositoryString = [shareRepositoryData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    if (shareRepositoryString.length > 10*1024*8) {
        NSLog(@"footprintsOrPositionURL is too Long!");
        return nil;
    }
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",WXAppID];
    
    shareRepositoryString = [headerString stringByAppendingString:shareRepositoryString];
    return shareRepositoryString;

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
    webpageObject.webpageUrl=[self createShareRepositoryString];
    //if(DEBUGMODE) NSLog(@"shareWebpageUrl:\n%@",self.shareWebpageUrl);
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    mediaMessage.title = titleTF.text;
    mediaMessage.description = NSLocalizedString(@"Tap '···' and choose 'Open In Safari' to open AlbumMaps", @"点击右上角“···”，选择“在Safari中打开”，进入《相册地图》查看");
    mediaMessage.mediaObject = webpageObject;
    mediaMessage.thumbData = self.shareThumbImageData;
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= (int)sender.tag;
    //NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
    
    if (succeeded){
        // 如果发送成功，保存到我的分享
        [EverywhereShareRepositoryManager addShareRepository:self.shareRepository];
        NSLog(@"%@",self.shareRepository);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
