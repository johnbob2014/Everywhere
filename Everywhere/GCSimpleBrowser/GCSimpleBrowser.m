//
//  GCSimpleBrowser.m
//  Everywhere
//
//  Created by BobZhang on 2017/2/9.
//  Copyright © 2017年 ZhangBaoGuo. All rights reserved.
//

#import "GCSimpleBrowser.h"
#import <WebKit/WebKit.h>

@interface GCSimpleBrowser ()

@end

@implementation GCSimpleBrowser{
    WKWebView *myWebView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //myWebView = [WKWebView newAutoLayoutView];
    myWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.startURL];
    [myWebView loadRequest:request];
    
    [self.view addSubview:myWebView];
    //[myWebView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
