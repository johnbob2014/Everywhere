//
//  ShareImageVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/14.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "ShareImageVC.h"

#import "EverywhereSettingManager.h"
#import "WXApi.h"


#define ButtonSize CGSizeMake(50, 50)
#define ButtonEdgeLength 50
#define ButtonOffset 15

@interface ShareImageVC ()

@end

@implementation ShareImageVC{
    UIDocumentInteractionController *documentInteractionController;
    UIImageView *imageView;
    UIButton *fileBtn,*sessionBtn,*timelineBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Share Snap Shots", @"分享截图");
    
    UIView *buttonContainer = [UIView newAutoLayoutView];
    buttonContainer.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
    [self.view addSubview:buttonContainer];
    [buttonContainer autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength * 3 + ButtonOffset * 2, ButtonEdgeLength)];
    [buttonContainer autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [buttonContainer autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    fileBtn = [UIButton newAutoLayoutView];
    fileBtn.alpha = 0.8;
    [fileBtn setImage:[UIImage imageNamed:@"IcoMoon_Share_WBG"] forState:UIControlStateNormal];
    [fileBtn addTarget:self action:@selector(fileShare) forControlEvents:UIControlEventTouchDown];
    [buttonContainer addSubview:fileBtn];
    [fileBtn autoSetDimensionsToSize:ButtonSize];
    [fileBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [fileBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    sessionBtn = [UIButton newAutoLayoutView];
    [sessionBtn setImage:[UIImage imageNamed:@"Share_WXSession"] forState:UIControlStateNormal];
    sessionBtn.tag = WXSceneSession;
    [sessionBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [buttonContainer addSubview:sessionBtn];
    [sessionBtn autoSetDimensionsToSize:ButtonSize];
    [sessionBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:fileBtn withOffset:ButtonOffset];
    [sessionBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    timelineBtn = [UIButton newAutoLayoutView];
    [timelineBtn setImage:[UIImage imageNamed:@"Share_WXTimeline"] forState:UIControlStateNormal];
    timelineBtn.tag = WXSceneTimeline;
    [timelineBtn addTarget:self action:@selector(wxShare:) forControlEvents:UIControlEventTouchDown];
    [buttonContainer addSubview:timelineBtn];
    [timelineBtn autoSetDimensionsToSize:ButtonSize];
    [timelineBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:sessionBtn withOffset:ButtonOffset];
    [timelineBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [imageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:buttonContainer withOffset: - ButtonOffset / 3];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    imageView.image = self.shareImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fileShare{
    NSString *filePath = [[NSURL cachesURL].path stringByAppendingPathComponent:@"shareImage.png"];
    NSData *imageData = UIImagePNGRepresentation(self.shareImage);
    [imageData writeToFile:filePath atomically:YES];
    
    documentInteractionController = [UIDocumentInteractionController new];
    //documentInteractionController.delegate = self;
    documentInteractionController.URL = [NSURL fileURLWithPath:filePath];
    [documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
}

- (void)wxShare:(UIButton *)sender{
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]){
        if(DEBUGMODE) NSLog(@"WeChat uninstalled or not support!");
        return;
    }
    
    /*
    WXWebpageObject *webpageObject=[WXWebpageObject new];
    webpageObject.webpageUrl=self.shareWebpageUrl;
    if(DEBUGMODE) NSLog(@"shareWebpageUrl:\n%@",self.shareWebpageUrl);
    */
    
    
    WXImageObject *imageObject = [WXImageObject new];
    imageObject.imageData = UIImagePNGRepresentation(self.shareImage);
    //UIImage *thumbImage = [GM thumbImageFromImage:sourceImage limitSize:CGSizeMake(150, 150)];
    
    /*
    id mediaObject;
    if (self.shareImage) mediaObject = imageObject;
    else mediaObject = webpageObject;
    */
    
    WXMediaMessage *mediaMessage=[WXMediaMessage alloc];
    // WXWebpageObject : 会话显示title、description、thumbData（图标较小)，朋友圈显示title、thumbData（图标较小),两者都发送webpageUrl
    // WXImageObject   : 会话只显示thumbData（图标较大)，朋友圈显示分享的图片,两者都发送imageData
    mediaMessage.title = self.shareTitle;
    mediaMessage.description = self.shareDescription;
    mediaMessage.mediaObject = imageObject;
    mediaMessage.thumbData = self.shareThumbData;
    
    SendMessageToWXReq *req=[SendMessageToWXReq new];
    req.message=mediaMessage;
    req.bText=NO;
    req.scene= (int)sender.tag;
    //if(DEBUGMODE) NSLog(@"%@",req);
    BOOL succeeded=[WXApi sendReq:req];
    if(DEBUGMODE) NSLog(@"SendMessageToWXReq : %@",succeeded? @"Succeeded" : @"Failed");
    
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end
