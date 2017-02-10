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

#import "GCZoomableImageScrollView.h"
#import "GCZoomableImageScrollViewCell.h"
#import "GCLineFlowLayout.h"

#import "PHAsset+Assistant.h"

#import "PHAssetInfo.h"
#import "EverywhereCoreDataManager.h"

@interface AssetDetailVC () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (assign,nonatomic) NSInteger currentIndex;
@property (assign,nonatomic) PHAssetInfo *currentAssetInfo;

@end

@implementation AssetDetailVC{
    PHAsset *currentAsset;
    
    GCLineFlowLayout *lineFlowLayout;
    UICollectionView *myCollectionView;
    
    UIButton *playButton;
    
    UILabel *noteLabel;
    
    UISwitch *eliminateThisAssetSwitch,*actAsThumbnailSwitch;
    
    AVPlayerItem *playerItem;
    
    BOOL eliminateStateDidChange;
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
        
        NSString *indexInfo = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)(currentIndex + 1),(unsigned long)self.assetArray.count];
        self.title = indexInfo;
        noteLabel.text = indexInfo;
        if (currentIndex == 0 || currentIndex == self.assetArray.count - 1){
            noteLabel.text = [NSString stringWithFormat:@"%@\n%@",noteLabel.text,NSLocalizedString(@"Swipe up to quite", @"上滑退出")];
        }
        
        currentAsset = self.assetArray[currentIndex];
        BOOL playButtonHidden;
        if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
            playButtonHidden = NO;
        }else if (currentAsset.mediaType == PHAssetMediaTypeImage){
            playButtonHidden = YES;
            playerItem = nil;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            playButton.hidden = playButtonHidden;
        }];
        
        self.currentAssetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:currentAsset.localIdentifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        eliminateThisAssetSwitch.on = [self.currentAssetInfo.eliminateThisAsset boolValue];
        actAsThumbnailSwitch.on = [self.currentAssetInfo.actAsThumbnail boolValue];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

// Notifies the container that the size of its view is about to change.
// UIKit calls this method before changing the size of a presented view controller’s view. You can override this method in your own objects and use it to perform additional tasks related to the size change. For example, a container view controller might use this method to override the traits of its embedded child view controllers. Use the provided coordinator object to animate any changes you make.
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [myCollectionView.collectionViewLayout invalidateLayout];
    lineFlowLayout.itemSize = size;
    [myCollectionView setCollectionViewLayout:lineFlowLayout animated:NO];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    eliminateStateDidChange = NO;
    
    if(self.assetArray.count == 0){
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Note", @"") message:NSLocalizedString(@"No photos!", @"没有照片！") okActionHandler:^(UIAlertAction *action) {
            if(self.navigationController)
                [self.navigationController popViewControllerAnimated:YES];
        }];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    lineFlowLayout = [[GCLineFlowLayout alloc] init];
    lineFlowLayout.itemSize = self.view.frame.size;
    
    myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:lineFlowLayout];
    myCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    myCollectionView.delegate = self;
    myCollectionView.dataSource = self;
    //myCollectionView.pagingEnabled = YES;
    [myCollectionView registerClass:[GCZoomableImageScrollViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:myCollectionView];
    [myCollectionView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    if (self.swipeUpToQuit){
        UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
        swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
        [myCollectionView addGestureRecognizer:swipeUpGR];
    }
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Video_WBG"] forState:UIControlStateNormal];
    playButton.alpha = 0.6;
    [playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:playButton];
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

- (void)viewWillDisappear:(BOOL)animated{
    if (eliminateStateDidChange){
        if(self.eliminateStateDidChangeHandler) self.eliminateStateDidChangeHandler();
    }
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
    eliminateStateDidChange = YES;
}

- (void)actAsThumbnailSwitchValueChanged:(UISwitch *)sender{
    self.currentAssetInfo.actAsThumbnail = @(sender.on);
    [[EverywhereCoreDataManager appDelegateMOC] save:NULL];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GCZoomableImageScrollViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    currentAsset = self.assetArray[indexPath.item];
    cell.zoomableImageScrollView.image = [currentAsset synchronousFetchUIImageAtTargetSize:PHImageManagerMaximumSize];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"indexPath.item: %ld",(long)indexPath.item);
    self.currentIndex = indexPath.item;
}

@end

