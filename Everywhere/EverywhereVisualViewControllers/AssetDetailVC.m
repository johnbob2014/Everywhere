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
    
    UISwitch *isTakenByUserSwitch,*actAsThumbnailSwitch;
    
    AVPlayerItem *playerItem;
}

/*
- (NSArray<NSString *> *)assetLocalIdentifiers{
    if(!_assetLocalIdentifiers){
        _assetLocalIdentifiers = self.ewAnnotation.assetLocalIdentifiers;
    }
    return _assetLocalIdentifiers;
}
*/

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
        
        if (currentIndex > 0) noteLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(currentIndex + 1),(unsigned long)assetArray.count];
        else noteLabel.text = NSLocalizedString(@"Swipe up to quite", @"上滑退出");
        
        self.currentAssetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:currentAsset.localIdentifier inManagedObjectContext:[EverywhereCoreDataManager defaultManager].appDelegateMOC];
        
        isTakenByUserSwitch.on = self.currentAssetInfo.isTakenByUser;
        actAsThumbnailSwitch.on = self.currentAssetInfo.actAsThumbnail;
        
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad{
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
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [imageView addGestureRecognizer:swipeUpGR];
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Video_WBG"] forState:UIControlStateNormal];
    playButton.alpha = 0.6;
    [playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchDown];
    [imageView addSubview:playButton];
    [playButton autoCenterInSuperview];
    [playButton autoSetDimensionsToSize:CGSizeMake(50, 50)];
    playButton.hidden = YES;
    
    noteLabel = [UILabel newAutoLayoutView];
    noteLabel.textColor = [UIColor whiteColor];
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.font = [UIFont bodyFontWithSizeMultiplier:1.2];
    noteLabel.text = NSLocalizedString(@"Swipe up to quite", @"上滑退出");
    [self.view addSubview:noteLabel];
    [noteLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 0, 0, 0) excludingEdge:ALEdgeBottom];
    
    UIView *bottomView = [UIView newAutoLayoutView];
    [self.view addSubview:bottomView];
    [bottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [bottomView autoSetDimension:ALDimensionHeight toSize:30];
    
    UILabel *isTakenByUserLabel = [UILabel newAutoLayoutView];
    isTakenByUserLabel.textColor = [UIColor whiteColor];
    isTakenByUserLabel.text = NSLocalizedString(@"Is taken by me :", @"我拍摄的：");
    [bottomView addSubview:isTakenByUserLabel];
    [isTakenByUserLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [isTakenByUserLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    isTakenByUserSwitch = [UISwitch newAutoLayoutView];
    [isTakenByUserSwitch addTarget:self action:@selector(isTakenByUserSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:isTakenByUserSwitch];
    [isTakenByUserSwitch autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:isTakenByUserLabel withOffset:10];
    [isTakenByUserSwitch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    

    actAsThumbnailSwitch = [UISwitch newAutoLayoutView];
    [actAsThumbnailSwitch addTarget:self action:@selector(actAsThumbnailSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:actAsThumbnailSwitch];
    [actAsThumbnailSwitch autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [actAsThumbnailSwitch autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UILabel *actAsThumbnailLabel = [UILabel newAutoLayoutView];
    actAsThumbnailLabel.textColor = [UIColor whiteColor];
    actAsThumbnailLabel.text = NSLocalizedString(@"Act As Thumbnail :", @"用作缩略图：");
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

- (void)isTakenByUserSwitchValueChanged:(UISwitch *)sender{
    self.currentAssetInfo.isTakenByUser = @(sender.on);
    [[EverywhereCoreDataManager defaultManager].appDelegateMOC save:NULL];
}

- (void)actAsThumbnailSwitchValueChanged:(UISwitch *)sender{
    self.currentAssetInfo.actAsThumbnail = @(sender.on);
    [[EverywhereCoreDataManager defaultManager].appDelegateMOC save:NULL];
}


@end

