//
//  AssetDetailVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/6.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "AssetDetailVC.h"
@import Photos;
@import AVKit;

#import "PHAsset+Assistant.h"

#import "PHAssetInfo.h"
#import "EverywhereCoreDataManager.h"

@interface AssetDetailVC ()
@property (assign,nonatomic) NSInteger currentIndex;
@property (assign,nonatomic) PHAssetInfo *currentAssetInfo;
@end

@implementation AssetDetailVC{
    PHFetchResult <PHAsset *> *assetArray;
    
    UIImageView *imageView;
    
    UIButton *playButton;
    
    UILabel *noteLabel;
    
    UISwitch *eliminateThisAssetSwitch,*actAsThumbnailSwitch;
    
    AVPlayerItem *playerItem;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex >= 0 && currentIndex <= assetArray.count - 1) {
        _currentIndex = currentIndex;
        
        PHAsset *currentAsset = assetArray[currentIndex];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             imageView.image = [currentAsset synchronousFetchUIImageAtTargetSize:PHImageManagerMaximumSize];
                         }
                         completion:^(BOOL finished) {
                             self.title = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)(currentIndex + 1),(unsigned long)assetArray.count];
                         }];
        
        
        if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
            playButton.hidden = NO;
            playerItem = [currentAsset synchronousFetchAVPlayerItem];
        }else if (currentAsset.mediaType == PHAssetMediaTypeImage){
            playButton.hidden = YES;
        }
        
        noteLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(currentIndex + 1),(unsigned long)assetArray.count];
        if (currentIndex == 0 || currentIndex == assetArray.count - 1){
            noteLabel.text = [NSString stringWithFormat:@"%@\n%@",noteLabel.text,NSLocalizedString(@"Swipe up to quite", @"上滑退出")];
        }
        
        self.currentAssetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:currentAsset.localIdentifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        
        eliminateThisAssetSwitch.on = [self.currentAssetInfo.eliminateThisAsset boolValue];
        actAsThumbnailSwitch.on = [self.currentAssetInfo.actAsThumbnail boolValue];
        
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    PHFetchOptions *options = [PHFetchOptions new];
    // 按日期排列
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    assetArray = [PHAsset fetchAssetsWithLocalIdentifiers:self.assetLocalIdentifiers options:options];
    
    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    // imageView.image = [PHAsset synchronousFetchUIImageFromPHAsset:assetArray[self.currentIndex] targetSize:PHImageManagerMaximumSize];
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    imageView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [imageView addGestureRecognizer:swipeRightGR];
    UISwipeGestureRecognizer *swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [imageView addGestureRecognizer:swipeLeftGR];
    
    if (self.swipeUpToQuit){
        UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
        swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
        [imageView addGestureRecognizer:swipeUpGR];
    }
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Video_WBG"] forState:UIControlStateNormal];
    playButton.alpha = 0.6;
    [playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchDown];
    [imageView addSubview:playButton];
    [playButton autoCenterInSuperview];
    [playButton autoSetDimensionsToSize:CGSizeMake(50, 50)];
    playButton.hidden = YES;
    
    if (self.showIndexLabel){
        noteLabel = [UILabel newAutoLayoutView];
        noteLabel.textColor = [UIColor whiteColor];
        noteLabel.textAlignment = NSTextAlignmentCenter;
        noteLabel.font = [UIFont bodyFontWithSizeMultiplier:1.2];
        noteLabel.numberOfLines = 0;
        [self.view addSubview:noteLabel];
        [noteLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 0, 0, 0) excludingEdge:ALEdgeBottom];
    }
    
    UIView *bottomView = [UIView newAutoLayoutView];
    [self.view addSubview:bottomView];
    [bottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [bottomView autoSetDimension:ALDimensionHeight toSize:30];
    
    UILabel *eliminateThisAssetLabel = [UILabel newAutoLayoutView];
    eliminateThisAssetLabel.textColor = [UIColor whiteColor];
    eliminateThisAssetLabel.text = NSLocalizedString(@"Eliminate:", @"排除：");
    [bottomView addSubview:eliminateThisAssetLabel];
    [eliminateThisAssetLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [eliminateThisAssetLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    eliminateThisAssetSwitch = [UISwitch newAutoLayoutView];
    [eliminateThisAssetSwitch addTarget:self action:@selector(eliminateThisAssetSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:eliminateThisAssetSwitch];
    [eliminateThisAssetSwitch autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:eliminateThisAssetLabel withOffset:10];
    [eliminateThisAssetSwitch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    

    actAsThumbnailSwitch = [UISwitch newAutoLayoutView];
    [actAsThumbnailSwitch addTarget:self action:@selector(actAsThumbnailSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:actAsThumbnailSwitch];
    [actAsThumbnailSwitch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [actAsThumbnailSwitch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UILabel *actAsThumbnailLabel = [UILabel newAutoLayoutView];
    actAsThumbnailLabel.textColor = [UIColor whiteColor];
    actAsThumbnailLabel.text = NSLocalizedString(@"Share:", @"分享：");
    [bottomView addSubview:actAsThumbnailLabel];
    [actAsThumbnailLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:actAsThumbnailSwitch withOffset:-10];
    [actAsThumbnailLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

    self.currentIndex = 0;
}

- (void)swipeRight:(UISwipeGestureRecognizer *)sender{
    self.currentIndex--;
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)sender{
    self.currentIndex++;
}

- (void)swipeUp:(UISwipeGestureRecognizer *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)play:(UIButton *)sender{
    if (playerItem) {
        AVPlayerViewController *playerVC = [AVPlayerViewController new];
        playerVC.player = [AVPlayer playerWithPlayerItem:playerItem];
        playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
        playerVC.allowsPictureInPicturePlayback = true;    //画中画，iPad可用
        playerVC.showsPlaybackControls = true;
        
        [self presentViewController:playerVC animated:YES completion:nil];
        
        [playerVC.player play];

    }
}

- (void)eliminateThisAssetSwitchValueChanged:(UISwitch *)sender{
    self.currentAssetInfo.eliminateThisAsset = @(sender.on);
    [[EverywhereCoreDataManager appDelegateMOC] save:NULL];
}

- (void)actAsThumbnailSwitchValueChanged:(UISwitch *)sender{
    self.currentAssetInfo.actAsThumbnail = @(sender.on);
    [[EverywhereCoreDataManager appDelegateMOC] save:NULL];
}

@end

