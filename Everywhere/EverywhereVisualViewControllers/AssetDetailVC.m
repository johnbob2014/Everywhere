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
#import "UIView+AutoLayout.h"


@interface AssetDetailVC ()
@property (assign,nonatomic) NSInteger currentIndex;
@end

@implementation AssetDetailVC{
    PHFetchResult <PHAsset *> *assetArray;
    
    UIImageView *imageView;
    
    UIButton *playButton;
    
    UILabel *noteLabel;
    
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
        
        if (currentIndex > 0) noteLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(currentIndex + 1),(unsigned long)assetArray.count];
        else noteLabel.text = NSLocalizedString(@"Swipe up to quite", @"上滑退出");
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

@end

