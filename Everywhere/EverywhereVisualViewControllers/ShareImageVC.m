//
//  ShareImageVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#import "ShareImageVC.h"
#import "WXApi.h"

@interface ShareImageVC ()

@end

@implementation ShareImageVC{
UIImageView *imageView;
    UIButton *sessionBtn,*timelineBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = VCBackgroundColor;
    self.title = NSLocalizedString(@"Share Snap Shots", @"分享截图");
    
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

    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [imageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:sessionBtn withOffset:-10];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.shareImage) {
        imageView.image = self.shareImage;
    }else{
        imageView.image = [UIImage imageNamed:@"地球_300_300"];
    }
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
    webpageObject.webpageUrl=self.shareWebpageUrl;
    if(DEBUGMODE) NSLog(@"shareWebpageUrl:\n%@",self.shareWebpageUrl);
    
    WXImageObject *imageObject = [WXImageObject new];
    imageObject.imageData = UIImagePNGRepresentation(self.shareImage);
    //UIImage *thumbImage = [GM thumbImageFromImage:sourceImage limitSize:CGSizeMake(150, 150)];
    
    
    id mediaObject;
    if (self.shareImage) mediaObject = imageObject;
    else mediaObject = webpageObject;
    
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
    req.scene= (int)sender.tag;
    //NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
