//
//  ShareVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareVC.h"
#import "WXApi.h"

@interface ShareVC ()

@end

@implementation ShareVC{
UIImageView *imageView;
    UIButton *sessionBtn,*timelineBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [imageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:sessionBtn withOffset:-10];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.image) {
        imageView.image = self.image;
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
    webpageObject.webpageUrl=self.webpageUrl;
    NSLog(@"%@",self.webpageUrl);
    
    WXImageObject *imageObject = [WXImageObject new];
    imageObject.imageData = UIImagePNGRepresentation(self.image);
    //UIImage *thumbImage = [GM thumbImageFromImage:sourceImage limitSize:CGSizeMake(150, 150)];
    NSData *thumbImageData=UIImageJPEGRepresentation([UIImage imageNamed:@"地球_300_300"], 0.5);
    
    id mediaObject;
    if (self.image) mediaObject = imageObject;
    else mediaObject = webpageObject;
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    mediaMessage.title=@"title";
    mediaMessage.description=@"description";
    mediaMessage.mediaObject=mediaObject;
    mediaMessage.thumbData=thumbImageData;
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= (int)sender.tag;
    //NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");

}
@end
