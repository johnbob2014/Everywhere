//
//  SettingVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *versonLabel;
@property (nonatomic,strong) UITextView *detailTextView;
@property (nonatomic,strong) UILabel *bottomLabel;

@end

@implementation AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title=NSLocalizedString(@"About", @"关于");
    
    [self initAboutUI];

}

-(void)initAboutUI{
    self.imageView=[[UIImageView alloc]initForAutoLayout];
    [self.imageView setImage:[UIImage imageNamed:@"地球_300_300"]];
    [self.view addSubview:self.imageView];
    [self.imageView autoSetDimensionsToSize:CGSizeMake(80, 80)];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [self.imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    self.nameLabel=[[UILabel alloc]initForAutoLayout];
    self.nameLabel.text=NSLocalizedString(@"AlbumMaps", @"相册地图");
    self.nameLabel.font=[UIFont bodyFontWithSizeMultiplier:1.6];
    [self.view addSubview:self.nameLabel];
    [self.nameLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.imageView withOffset:-10];
    [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.imageView withOffset:10];
    
    self.versonLabel=[[UILabel alloc]initForAutoLayout];
    self.versonLabel.text=@"v1.0.0";
    self.versonLabel.font=[UIFont bodyFontWithSizeMultiplier:0.8];
    [self.view addSubview:self.versonLabel];
    [self.versonLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.nameLabel];
    [self.versonLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.imageView withOffset:-10];

    self.bottomLabel=[[UILabel alloc]initForAutoLayout];
    self.bottomLabel.numberOfLines = 0;
    self.bottomLabel.text=NSLocalizedString(@"Phone & WeChat : 17096027537\nEmail : johnbob2014@icloud.com\n\n2016 CTP Technology Co.,Ltd", @"");
    self.bottomLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:self.bottomLabel];
    [self.bottomLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 20, 20, 20) excludingEdge:ALEdgeTop];
    [self.bottomLabel autoSetDimension:ALDimensionHeight toSize:80];
    
    self.detailTextView=[[UITextView alloc]initForAutoLayout];
    self.detailTextView.editable=NO;
    self.detailTextView.font=[UIFont bodyFontWithSizeMultiplier:0.8];
    self.detailTextView.text=NSLocalizedString(@"      ", @"");
    [self.view addSubview:self.detailTextView];
    [self.detailTextView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.imageView withOffset:20];
    [self.detailTextView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
    [self.detailTextView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
    [self.detailTextView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomLabel withOffset:20];
}

@end
