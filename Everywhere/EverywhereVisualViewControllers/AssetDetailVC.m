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

//#import "GCZoomableImageScrollView.h"

#import "PHAsset+Assistant.h"

#import "PHAssetInfo.h"
#import "EverywhereCoreDataManager.h"

@interface AssetDetailVC ()
@property (assign,nonatomic) NSInteger currentIndex;
@property (assign,nonatomic) PHAssetInfo *currentAssetInfo;

@end

@implementation AssetDetailVC{
    //PHFetchResult <PHAsset *> *assetArray;
    //__block NSMutableArray <UIImage *> *imageMA;
    
    PHAsset *currentAsset;
    
    UIImageView *imageView;
    
    UIImage *currentImage;
    
    UIButton *playButton;
    
    UILabel *noteLabel;
    
    UISwitch *eliminateThisAssetSwitch,*actAsThumbnailSwitch;
    
    AVPlayerItem *playerItem;
    
    UIScrollView *assistantScrollView;
    UIImageView *assistantImageView;
    
    CGFloat scaleFactor;
    CGFloat rotationFactor;
    CGFloat currentScaleDelta;
    CGFloat currentRotationDelta;
}

- (NSArray<PHAsset *> *)assetArray{
    if (!_assetArray){
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        _assetArray = (NSArray <PHAsset *> *)[PHAsset fetchAssetsWithLocalIdentifiers:self.assetLocalIdentifiers options:options];
    }
    return _assetArray;
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex >= 0 && currentIndex <= self.assetArray.count - 1) {
        _currentIndex = currentIndex;
        
        //[self asyncFillImageMA];
        
        self.title = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)(currentIndex + 1),(unsigned long)self.assetArray.count];
        
        currentAsset = self.assetArray[currentIndex];
        currentImage = [currentAsset synchronousFetchUIImageAtTargetSize:PHImageManagerMaximumSize];
        imageView.image = currentImage;
        
        if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
            playButton.hidden = NO;
        }else if (currentAsset.mediaType == PHAssetMediaTypeImage){
            playButton.hidden = YES;
            playerItem = nil;
        }
        
        noteLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(currentIndex + 1),(unsigned long)self.assetArray.count];
        if (currentIndex == 0 || currentIndex == self.assetArray.count - 1){
            noteLabel.text = [NSString stringWithFormat:@"%@\n%@",noteLabel.text,NSLocalizedString(@"Swipe up to quite", @"上滑退出")];
        }
        
        self.currentAssetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:currentAsset.localIdentifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        
        eliminateThisAssetSwitch.on = [self.currentAssetInfo.eliminateThisAsset boolValue];
        actAsThumbnailSwitch.on = [self.currentAssetInfo.actAsThumbnail boolValue];
        
    }
}

/*
- (void)asyncFillImageMA{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self.assetArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= self.currentIndex - 2 && idx <= self.currentIndex + 2){
                UIImage *objImage = [obj synchronousFetchUIImageAtTargetSize:PHImageManagerMaximumSize];
                imageMA[idx] = objImage;
            }else{
                imageMA[idx] = [UIImage new];
            }
        }];
    });
}
*/

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //imageMA = [NSMutableArray arrayWithCapacity:self.assetArray.count];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    imageView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [imageView addGestureRecognizer:swipeRightGR];
    UISwipeGestureRecognizer *swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [imageView addGestureRecognizer:swipeLeftGR];
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTapGR:)];
    doubleTapGR.numberOfTapsRequired = 2;
    doubleTapGR.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:doubleTapGR];
    
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

- (void)imageViewDoubleTapGR:(UITapGestureRecognizer *)sender{
    if (currentImage.size.width <= self.view.frame.size.width || currentImage.size.height <= self.view.frame.size.height) return;
    
    assistantScrollView = [UIScrollView newAutoLayoutView];
    
    assistantScrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:assistantScrollView];
    [assistantScrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    
    assistantImageView = [[UIImageView alloc] initWithImage:currentImage];
    [assistantScrollView addSubview:assistantImageView];
    assistantImageView.frame = CGRectMake(0, 0, currentImage.size.width, currentImage.size.height);
    
    assistantScrollView.contentSize = assistantImageView.frame.size;
    assistantScrollView.contentOffset = CGPointMake((currentImage.size.width - self.view.frame.size.width) / 2.0, (currentImage.size.height - self.view.frame.size.height) / 2.0);
    
    assistantImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(assistantImageViewDoubleTapGR:)];
    doubleTapGR.numberOfTapsRequired = 2;
    doubleTapGR.numberOfTouchesRequired = 1;
    [assistantImageView addGestureRecognizer:doubleTapGR];
    
    /*
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGRAction:)];
    [assistantImageView addGestureRecognizer:pinchGR];
    
    UIRotationGestureRecognizer *rotationGR=[[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationGRAction:)];
    [assistantImageView addGestureRecognizer:rotationGR];
    
    scaleFactor=1.0;
    rotationFactor=0.0;
    */
}

- (void)assistantImageViewDoubleTapGR:(UITapGestureRecognizer *)sender{
    [assistantScrollView removeFromSuperview];
}

- (void)pinchGRAction:(UIPinchGestureRecognizer *)sender{
    NSLog(@"scale: %.2f",sender.scale);
    CGFloat newScaleDelta=sender.scale - 1;
    
    [self updateViewTransformWithScaleDelta:newScaleDelta andRotationDelta:0];
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        //self.scaleFactor=scaleAmount;
        scaleFactor+=newScaleDelta;
        currentScaleDelta=0;
    }
}

- (void)rotationGRAction:(UIRotationGestureRecognizer *)sender{
    NSLog(@"rotation: %.2f",sender.rotation);
    CGFloat newRotationDelta=sender.rotation;
    
    [self updateViewTransformWithScaleDelta:0 andRotationDelta:newRotationDelta];
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        //self.rotationFactor=rotationAmount;
        rotationFactor+=newRotationDelta;
        currentRotationDelta=0;
    }
}

- (void)updateViewTransformWithScaleDelta:(CGFloat)scaleDelta andRotationDelta:(CGFloat)rotationDelta{
    if (scaleDelta != 0) {
        currentScaleDelta = scaleDelta;
    }
    if (rotationDelta != 0) {
        currentRotationDelta = rotationDelta;
    }
    
    CGFloat scaleAmount=scaleFactor+currentScaleDelta;
    
    if (scaleAmount < 0.2) return;
    
    CGAffineTransform scaleTransform=CGAffineTransformMakeScale(scaleAmount, scaleAmount);
    
    CGFloat roatationAmount=rotationFactor+currentRotationDelta;
    CGAffineTransform rotationTransform=CGAffineTransformMakeRotation(roatationAmount);
    
    CGAffineTransform combinedTransform=CGAffineTransformConcat(scaleTransform, rotationTransform);
    
    //assistantScrollView.contentSize = CGSizeApplyAffineTransform(assistantScrollView.contentSize, scaleTransform);
    
    [assistantImageView setTransform:combinedTransform];
    
}


- (void)play:(UIButton *)sender{
    
    [SVProgressHUD show];
    playerItem = [currentAsset synchronousFetchAVPlayerItem];
    [SVProgressHUD dismiss];
    
    if (playerItem) {
        AVPlayerViewController *playerVC = [AVPlayerViewController new];
        playerVC.player = [AVPlayer playerWithPlayerItem:playerItem];
        playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
        playerVC.allowsPictureInPicturePlayback = true;    //画中画，iPad可用
        playerVC.showsPlaybackControls = true;
        
        [self presentViewController:playerVC animated:YES completion:nil];
        
        [playerVC.player play];

    }else{
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Failed to load video!", @"加载视频失败！")];
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

