//
//  AssetsMapProVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "AssetsMapProVC.h"
@import Photos;
@import MapKit;

#import "EverywhereMKAnnotation.h"
#import "EverywhereSettingManager.h"
#import "EverywhereShareMKAnnotation.h"
#import "EverywhereShareRepository.h"
#import "EverywhereShareRepositoryManager.h"

#import "NSDate+Assistant.h"
#import "UIView+AutoLayout.h"
#import "PHAsset+Assistant.h"
#import "UIFont+Assistant.h"
#import "GCLocationAnalyser.h"
#import <STPopup.h>
#import "GCLocationAnalyser.h"
#import "GCPhotoManager.h"
#import "LocationInfoBar.h"
#import "PlacemarkInfoBar.h"
#import "CLPlacemark+Assistant.h"
#import "DatePickerVC.h"
#import "AssetDetailVC.h"
#import "UIButton+Bootstrap.h"
#import "MapShowModeBar.h"
#import "LocationPickerVC.h"
#import "SettingVC.h"
#import "ShareImageVC.h"
#import "ShareEWShareRepositoryVC.h"
#import "ShareBar.h"
#import "InAppPurchaseVC.h"
#import "ShareRepositoryPickerVC.h"

#import "CLPlacemark+Assistant.h"

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"
#import "CoordinateInfo.h"

#import "GCPolyline.h"
#import "GCRoutePolyline.h"
#import "GCRoutePolylineManager.h"

@interface AssetsMapProVC () <MKMapViewDelegate,UIGestureRecognizerDelegate>
//@property (assign,nonatomic) MapShowMode mapShowMode;
//@property (assign,nonatomic) CLLocationDistance mergedDistanceForMoment;
//@property (assign,nonatomic) CLLocationDistance mergedDistanceForLocation;
@property (strong,nonatomic) NSArray <PHAssetInfo *> *assetInfoArray;
@property (strong,nonatomic) NSArray <PHAsset *> *assetArray;
@property (strong,nonatomic) NSArray <NSArray <PHAsset *> *> *assetsArray;
@property (assign,nonatomic) NSInteger currentAnnotationIndex;

@property (strong,nonatomic) NSDate *startDate;
@property (strong,nonatomic) NSDate *endDate;
@property (strong,nonatomic) NSString *lastPlacemark;

@property (strong,nonatomic) GCPhotoManager *photoManager;
@property (strong,nonatomic) EverywhereCoreDataManager *cdManager;
@property (strong,nonatomic) EverywhereSettingManager *settingManager;

@property (strong,nonatomic) MKMapView *myMapView;

@property (strong,nonatomic) NSArray <id<MKAnnotation>> *addedIDAnnos;
@property (strong,nonatomic) NSArray <EverywhereMKAnnotation *> *addedEWAnnos;
@property (strong,nonatomic) NSArray <EverywhereShareMKAnnotation *> *addedEWShareAnnos;
//@property (assign,nonatomic) CLLocationDistance shareRadius;

@end

@implementation AssetsMapProVC{
    STPopupController *popupController;
    
    MapShowModeBar *msMomentLocationModeBar;
    MapShowModeBar *msShareEditModeBar;
    UIButton *quiteShareModeButton;
    
    LocationInfoBar *locationInfoBar;
    float locationInfoBarHeight;
    BOOL locationInfoBarIsOutOfVisualView;
    
    PlacemarkInfoBar *placemarkInfoBar;
    float placemarkInfoBarHeight;
    BOOL placemarkInfoBarIsHidden;
    
    ShareBar *shareBar;

    UIView *naviBar;
    UIButton *firstButton;
    UIButton *previousButton;
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *lastButton;
    UILabel *currentAnnotationIndexLabel;
    BOOL isPlaying;
    NSTimer *playTimer;
    
    UIView *leftVerticalBar;
    UIView *rightVerticalBar;
    UIView *rightSwipeVerticalBar;
    BOOL verticalBarIsAlphaZero;
    
    __block CLLocationDistance maxDistance;
    __block CLLocationDistance totalDistance;
    __block CLLocationDistance totalArea;
}

#pragma mark - Getter & Setter

- (void)setAssetInfoArray:(NSArray<PHAssetInfo *> *)assetInfoArray{
    if (!assetInfoArray) return;
    
    _assetInfoArray = assetInfoArray;
    
    [self updateMapShowModeBar];
    currentAnnotationIndexLabel.text = @"";
    
    if (assetInfoArray.count > 0) {
        NSMutableArray *assetIDArry = [NSMutableArray new];
        [assetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [assetIDArry addObject:obj.localIdentifier];
        }];
        
        PHFetchOptions *options = [PHFetchOptions new];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult <PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:assetIDArry options:options];
        self.assetArray = (NSArray <PHAsset *> *)fetchResult;
        
        NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:assetInfoArray];
        [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapShowMode:self.settingManager.mapShowMode];
    }
}

- (void)setAssetArray:(NSArray<PHAsset *> *)assetArray{
    if (!assetArray) return;
    
    _assetArray = assetArray;
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:
            self.assetsArray = [GCLocationAnalyser divideLocationsInOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)assetArray mergedDistance:self.settingManager.mergedDistanceForMoment];
            break;
        case MapShowModeLocation:
            self.assetsArray = [GCLocationAnalyser divideLocationsOutOfOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)assetArray mergedDistance:self.settingManager.mergedDistanceForLocation];
            break;
        default:
            break;
    }
}

- (void)setAssetsArray:(NSArray<NSArray<PHAsset *> *> *)assetsArray{
    if (!assetsArray) return;
    
    _assetsArray = assetsArray;
    
    self.addedEWAnnos = nil;
    self.addedEWShareAnnos = nil;
    [self addAnnotations];
    
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:
            [self addLineOverlaysPro:self.addedEWAnnos];
            break;
        case MapShowModeLocation:
            [self addCircleOverlaysPro:self.addedEWAnnos radius:self.settingManager.mergedDistanceForLocation / 2.0];
            break;
        default:
            break;
    }
    
    // 如果地图已经初始化，才进行更新
    if (self.myMapView) [self updateVisualViewAfterAddAnnotationsAndOverlays];    
}

- (void)setAddedIDAnnos:(NSArray<id<MKAnnotation>> *)addedIDAnnos{
    _addedIDAnnos = addedIDAnnos;
    // 设置导航序号
    self.currentAnnotationIndex = 0;
}

#pragma mark - Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.photoManager = [GCPhotoManager defaultManager];
    self.cdManager = [EverywhereCoreDataManager defaultManager];
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    [self initMapView];
    
    [self initMapShowModeBar];
    
    [self initNaviBar];
    
    [self initLocationInfoBar];
    
    // PlacemarkInfoBar 位于 MapShowModeBar 下方10
    [self initPlacemarkInfoBar];
    
    [self initButtonsAndVerticalAccessoriesBar];
    
    [self initData];

    [self initPopupController];
    
    [self initShareBar];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateBarColor:self.settingManager.color];
    
    [self showVerticalBar];
    msMomentLocationModeBar.alpha = 1;
    naviBar.alpha = 1;
    shareBar.alpha = 0;
}

- (void)updateBarColor:(UIColor *)newColor{
    locationInfoBar.backgroundColor = newColor;
    placemarkInfoBar.backgroundColor = newColor;
    naviBar.backgroundColor = newColor;
    shareBar.backgroundColor = newColor;
    
    msMomentLocationModeBar.contentViewBackgroundColor = newColor;
    msShareEditModeBar.contentViewBackgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        locationInfoBarHeight = 150;
        locationInfoBar.frame = CGRectMake(5, -locationInfoBarHeight - 40, ScreenWidth - 10 , locationInfoBarHeight);
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        locationInfoBarHeight = 90;
        locationInfoBar.frame = CGRectMake(5, -locationInfoBarHeight - 40, ScreenHeight - 10, locationInfoBarHeight);
    }
}

/*
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    
}
*/

#pragma mark - Init Interface

#pragma mark MapView

- (void)initMapView{
    self.myMapView = [MKMapView newAutoLayoutView];
    self.myMapView.delegate = self;
    //self.myMapView.showsUserLocation = YES;
    
    [self.view addSubview:self.myMapView];
    [self.myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    //NSLog(@"%@",self.myMapView.gestureRecognizers);
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    longPressGR.minimumPressDuration = 2.0;
    [self.myMapView addGestureRecognizer:longPressGR];
    
    /*
    UITapGestureRecognizer *mapViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    mapViewTapGR.delegate = self;
    [self.myMapView addGestureRecognizer:mapViewTapGR];
    */
    
    //NSLog(@"%@",self.myMapView.gestureRecognizers);
}

- (void)mapViewTapGR:(id)sender{
    if (verticalBarIsAlphaZero) [self showVerticalBar];
    else [self hideVerticalBar];
}

/*
//UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}
*/

#pragma mark ModeBar

- (void)initMapShowModeBar{
    WEAKSELF(weakSelf);
    
    msMomentLocationModeBar = [[MapShowModeBar alloc]initWithModeSegItems:[NSLocalizedString(@"MomentMode LocationMode",@"") componentsSeparatedByString:@" "]
                                                selectedSegIndex:self.settingManager.mapShowMode
                                                 leftButtonImage:[UIImage imageNamed:@"IcoMoon_Calendar"]
                                                rightButtonImage:[UIImage imageNamed:@"IcoMoon_Dribble3"]];
    msMomentLocationModeBar.modeSegEnabled = YES;
    
    [self.view addSubview:msMomentLocationModeBar];
    [msMomentLocationModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msMomentLocationModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msMomentLocationModeBar.mapShowModeChangedHandler = ^(UISegmentedControl *sender){
        // 记录当前地图模式
        weakSelf.settingManager.mapShowMode = sender.selectedSegmentIndex;
        [weakSelf clearData];
    };
    
    msMomentLocationModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        [weakSelf showDatePicker];
    };
    
    msMomentLocationModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        [weakSelf showLocationPicker];
    };
    
    msShareEditModeBar = [[MapShowModeBar alloc]initWithModeSegItems:[NSLocalizedString(@"ShareMode EditMode",@"") componentsSeparatedByString:@" "]
                                                    selectedSegIndex:0
                                                     leftButtonImage:[UIImage imageNamed:@"IcoMoon_Share2_WOBG"]
                                                    rightButtonImage:[UIImage imageNamed:@"IcoMoon_Trophy_WOBG"]];
    
    //msShareEditModeBar.leftButtonEnabled = self.settingManager.hasPurchasedShare;
    
    [self.view addSubview:msShareEditModeBar];
    [msShareEditModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msShareEditModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msShareEditModeBar.mapShowModeChangedHandler = ^(UISegmentedControl *sender){
        
    };
    
    msShareEditModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        if (weakSelf.settingManager.hasPurchasedShare) [weakSelf showShareRepositoryPicker];
        else [weakSelf showPurchaseShareFunctionAlertController];
    };
    
    msShareEditModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        
    };
    
    msShareEditModeBar.hidden = YES;
    msShareEditModeBar.modeSegEnabled = NO;

}

- (void)clearData{
    self.assetInfoArray = nil;
    self.assetArray = nil;
    self.assetsArray = nil;
    
    self.addedEWAnnos = nil;
    self.addedEWShareAnnos = nil;
    
    self.endDate = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.lastPlacemark = @"";
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
}

- (void)updateMapShowModeBar{
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:
            msMomentLocationModeBar.info = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
            break;
        case MapShowModeLocation:
            msMomentLocationModeBar.info = self.lastPlacemark;
            break;
        default:
            break;
    }
}

- (void)showDatePicker{
    DatePickerVC *datePickerVC = [DatePickerVC new];
    
    WEAKSELF(weakSelf);
    //__weak AssetsMapProVC *weakSelf = self;
    
    datePickerVC.dateModeChangedHandler = ^(DateMode choosedDateMode){
        weakSelf.settingManager.dateMode = choosedDateMode;
    };
    
    datePickerVC.dateRangeChangedHandler = ^(NSDate *choosedStartDate,NSDate *choosedEndDate){
        //settingManager.mapShowMode = MapShowModeMoment;
        weakSelf.startDate = choosedStartDate;
        weakSelf.endDate = choosedEndDate;
        weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:weakSelf.startDate toEndDate:weakSelf.endDate inManagedObjectContext:weakSelf.cdManager.appMOC];
    };
    
    datePickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    datePickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:datePickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showLocationPicker{
    WEAKSELF(weakSelf);
    LocationPickerVC *locationPickerVC = [LocationPickerVC new];
    NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:weakSelf.cdManager.appMOC];
    locationPickerVC.placemarkInfoDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:allAssetInfoArray];
    
    locationPickerVC.locationModeDidChangeHandler = ^(LocationMode choosedLocationMode){
        weakSelf.settingManager.locationMode = choosedLocationMode;
    };
    
    locationPickerVC.locationDidChangeHandler = ^(NSString *choosedLocation){
        weakSelf.settingManager.lastPlacemark = choosedLocation;
        weakSelf.lastPlacemark = choosedLocation;
        weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:choosedLocation inManagedObjectContext:weakSelf.cdManager.appMOC];
    };
    
    locationPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    locationPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:locationPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}



- (void)showShareRepositoryPicker{
    WEAKSELF(weakSelf);
    
    ShareRepositoryPickerVC *shareRepositoryPickerVC = [ShareRepositoryPickerVC new];
        shareRepositoryPickerVC.shareRepositoryArray = [EverywhereShareRepositoryManager shareRepositoryArray];
    shareRepositoryPickerVC.shareRepositoryDidChangeHandler = ^(EverywhereShareRepository *choosedShareRepository){
        [weakSelf showEWShareRepository:choosedShareRepository];
    };
    
    shareRepositoryPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    shareRepositoryPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:shareRepositoryPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

#pragma mark Navigation Bar

- (void)initNaviBar{
    
    naviBar = [UIView newAutoLayoutView];
    
    [self.view addSubview:naviBar];
    [naviBar autoSetDimension:ALDimensionHeight toSize:44];
    [naviBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 20, 5) excludingEdge:ALEdgeTop];
    
    firstButton = [UIButton newAutoLayoutView];
    [firstButton setTitle:@"⏪" forState:UIControlStateNormal];
    firstButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [firstButton addTarget:self action:@selector(firstButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:firstButton];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [firstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    //[firstButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    previousButton = [UIButton newAutoLayoutView];
    [previousButton setTitle:@"⬅️" forState:UIControlStateNormal];
    previousButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [previousButton addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:previousButton];
    [previousButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:firstButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [previousButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setTitle:@"▶️" forState:UIControlStateNormal];
    playButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:playButton];
    [playButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [playButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    nextButton = [UIButton newAutoLayoutView];
    [nextButton setTitle:@"➡️" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:nextButton];
    [nextButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:playButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [nextButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    lastButton = [UIButton newAutoLayoutView];
    [lastButton setTitle:@"⏩" forState:UIControlStateNormal];
    lastButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [lastButton addTarget:self action:@selector(lastButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:lastButton];
    [lastButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:nextButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [lastButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    currentAnnotationIndexLabel = [UILabel newAutoLayoutView];
    currentAnnotationIndexLabel.textColor = [UIColor whiteColor];
    [naviBar addSubview:currentAnnotationIndexLabel];
    [currentAnnotationIndexLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [currentAnnotationIndexLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [currentAnnotationIndexLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastButton withOffset:10 relation:NSLayoutRelationGreaterThanOrEqual];
    
    self.currentAnnotationIndex = 0;
    
    isPlaying = NO;
}

- (void)firstButtonPressed:(id)sender{
    id<MKAnnotation> idAnno = self.addedIDAnnos.firstObject;
    [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
    [self.myMapView selectAnnotation:idAnno animated:YES];
}

- (void)previousButtonPressed:(id)sender{
    id<MKAnnotation> idAnno = self.myMapView.selectedAnnotations.firstObject;
    if (!idAnno && self.currentAnnotationIndex) {
        idAnno = self.addedIDAnnos[self.currentAnnotationIndex];
    }
    if (idAnno) {
        NSInteger index = [self.addedIDAnnos indexOfObject:idAnno];
        if (--index >= 0) {
            [self.myMapView deselectAnnotation:idAnno animated:YES];
            idAnno = self.addedIDAnnos[index];
            [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
            [self.myMapView selectAnnotation:idAnno animated:YES];
        }
    }
}

- (void)playButtonPressed:(id)sender{
    if (isPlaying) {
        // 暂停播放
        [sender setTitle:@"▶️" forState:UIControlStateNormal];
        [playTimer invalidate];
        playTimer = nil;
    }else{
        // 开始播放
        [sender setTitle:@"⏸" forState:UIControlStateNormal];
        playTimer = [NSTimer scheduledTimerWithTimeInterval:self.settingManager.playTimeInterval target:self selector:@selector(nextButtonPressed:) userInfo:nil repeats:YES];
    }
    isPlaying = !isPlaying;
}

- (void)nextButtonPressed:(id)sender{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    //NSLog(@"%@",self.addedIDAnnos);
    id<MKAnnotation> idAnno = self.myMapView.selectedAnnotations.firstObject;
    if (!idAnno && self.currentAnnotationIndex) {
        idAnno = self.addedIDAnnos[self.currentAnnotationIndex];
    }
    if (idAnno) {
        NSInteger index = [self.addedIDAnnos indexOfObject:idAnno];
        if (++index < self.addedIDAnnos.count) {
            [self.myMapView deselectAnnotation:idAnno animated:YES];
            idAnno = self.addedIDAnnos[index];
            
            [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
            [self.myMapView selectAnnotation:idAnno animated:YES];
        }
        if (index == self.addedIDAnnos.count) {
            [self playButtonPressed:playButton];
        }
    }
}

- (void)lastButtonPressed:(id)sender{
    id<MKAnnotation> idAnno = self.addedIDAnnos.lastObject;
    [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
    [self.myMapView selectAnnotation:idAnno animated:YES];
}

- (CLLocation *)averageLocationForLocations:(NSArray <CLLocation *> *)locations{
    
    CLLocationCoordinate2D resultCoordinate;
    CLLocationDistance resultAltitude = 0;
    
    for (CLLocation *location in locations) {
        resultCoordinate.latitude += location.coordinate.latitude;
        resultCoordinate.longitude += location.coordinate.longitude;
        resultAltitude += location.altitude;
    }
    
    double count = (double)locations.count;
    
    resultCoordinate.longitude /= count;
    resultCoordinate.latitude /= count;
    resultAltitude /= count;
    
    CLLocation *resultLocation = [[CLLocation alloc] initWithCoordinate:resultCoordinate altitude:resultAltitude horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]];
    
    return resultLocation;
}

#pragma mark Location Info Bar

- (void)initLocationInfoBar{
    locationInfoBarHeight = 150;
    locationInfoBar = [[LocationInfoBar alloc] initWithFrame:CGRectMake(5, -locationInfoBarHeight - 40, ScreenWidth - 10, locationInfoBarHeight)];
    [self.view addSubview:locationInfoBar];
    locationInfoBarIsOutOfVisualView = YES;
    
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(locationInfoBarSwipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [locationInfoBar addGestureRecognizer:swipeUpGR];
}

- (void)locationInfoBarSwipeUp:(UISwipeGestureRecognizer *)sender{
    [self hideLocationInfoBar];
}

- (void)showLocationInfoBar{
    
    if (msMomentLocationModeBar.alpha || placemarkInfoBar.alpha) {
        [UIView animateWithDuration:0.2 animations:^{
            msMomentLocationModeBar.alpha = 0;
            placemarkInfoBar.alpha = 0;
        }];
    }
    
    if (!msShareEditModeBar.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            msShareEditModeBar.alpha = 0;
            quiteShareModeButton.alpha = 0;
        }];
    }
    
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.4 animations:^{
                                      locationInfoBar.frame = CGRectMake(5, 20 + 10, ScreenWidth - 10, locationInfoBarHeight);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.3 animations:^{
                                      locationInfoBar.frame = CGRectMake(5, 20, ScreenWidth - 10, locationInfoBarHeight);
                                  }];
                                  
                              }
                              completion:^(BOOL finished) {
                                  locationInfoBarIsOutOfVisualView = NO;
                              }];

}

- (void)hideLocationInfoBar{
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
                                      locationInfoBar.frame = CGRectMake(5, 20 + 10, ScreenWidth - 10, locationInfoBarHeight);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.4 animations:^{
                                      locationInfoBar.frame = CGRectMake(5, -locationInfoBarHeight, ScreenWidth - 10, locationInfoBarHeight);
                                  }];
                                  
                              }
                              completion:^(BOOL finished) {
                                  locationInfoBarIsOutOfVisualView = YES;
                                  [UIView animateWithDuration:0.2 animations:^{
                                      msMomentLocationModeBar.alpha = 1;
                                      placemarkInfoBar.alpha = 1;
                                  }];
                                  
                                  if (!msShareEditModeBar.hidden) {
                                      [UIView animateWithDuration:0.2 animations:^{
                                          msShareEditModeBar.alpha = 1;
                                          quiteShareModeButton.alpha = 0.6;
                                      }];
                                  }

                              }];
    
}

#pragma mark Placemark Info Bar

- (void)initPlacemarkInfoBar{
    placemarkInfoBarHeight = 80;
    placemarkInfoBar = [PlacemarkInfoBar newAutoLayoutView];
    [self.view addSubview:placemarkInfoBar];
    [placemarkInfoBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msMomentLocationModeBar withOffset:10];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [placemarkInfoBar autoSetDimension:ALDimensionHeight toSize:placemarkInfoBarHeight];
    
    NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
    [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapShowMode:self.settingManager.mapShowMode];
}

- (void)updatePlacemarkInfoBarWithPlacemarkDictionary:(NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkDictionary mapShowMode:(enum MapShowMode)mapShowMode{
    // 更新统计信息
   
    placemarkInfoBar.countryCount = placemarkDictionary[kCountryArray].count;
    placemarkInfoBar.administrativeAreaCount = placemarkDictionary[kAdministrativeAreaArray].count;
    placemarkInfoBar.localityCount = placemarkDictionary[kLocalityArray].count;
    placemarkInfoBar.subLocalityCount = placemarkDictionary[kSubLocalityArray].count;
    placemarkInfoBar.thoroughfareCount = placemarkDictionary[kThoroughfareArray].count;
    
    switch (mapShowMode) {
        case 0:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Distance", @"");
            placemarkInfoBar.totalDistance = totalDistance;
        }
            break;
        case 1:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Area", @"");
            totalArea = self.addedEWAnnos.count * M_PI * pow(self.settingManager.mergedDistanceForLocation,2);
            placemarkInfoBar.totalArea = totalArea;
        }
            break;
        default:
            break;
    }
}

#pragma mark Buttons And Vertical Accessories Bars

#define ButtonPlaceholderHeight 60
#define ButtionSize CGSizeMake(44, 44)
#define ButtionEdgeLength 44

- (void)initButtonsAndVerticalAccessoriesBar{

#pragma mark leftVerticalBar
    
    leftVerticalBar = [UIView newAutoLayoutView];
    leftVerticalBar.backgroundColor = [UIColor clearColor];//[[UIColor cyanColor] colorWithAlphaComponent:0.3];//
    [self.view addSubview:leftVerticalBar];
    [leftVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [leftVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [leftVerticalBar autoSetDimensionsToSize:CGSizeMake(44, ButtonPlaceholderHeight * 4)];
    
    UIButton *leftBtn1 = [UIButton newAutoLayoutView];
    leftBtn1.alpha = 0.6;
    [leftBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Setting_WBG"] forState:UIControlStateNormal];
    leftBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn1 addTarget:self action:@selector(showSettingVC) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn1];
    [leftBtn1 autoSetDimensionsToSize:ButtionSize];
    [leftBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
    

    UIButton *leftBtn2 = [UIButton newAutoLayoutView];
    leftBtn2.alpha = 0.6;
    [leftBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Glasses_WBG"] forState:UIControlStateNormal];
    leftBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn2 addTarget:self action:@selector(showHideMapShowModeBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn2];
    [leftBtn2 autoSetDimensionsToSize:ButtionSize];
    [leftBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn1 withOffset:16];
    
    UIButton *leftBtn3 = [UIButton newAutoLayoutView];
    leftBtn3.alpha = 0.6;
    [leftBtn3 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_StatisticBar1_WBG"] forState:UIControlStateNormal];
    leftBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn3 addTarget:self action:@selector(showHidePlacemarkInfoBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn3];
    [leftBtn3 autoSetDimensionsToSize:ButtionSize];
    [leftBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn2 withOffset:16];
    
    UIButton *leftBtn4 = [UIButton newAutoLayoutView];
    leftBtn4.alpha = 0.6;
    [leftBtn4 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Trophy_WBG"] forState:UIControlStateNormal];
    leftBtn4.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn4 addTarget:self action:@selector(showHideNaviBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn4];
    [leftBtn4 autoSetDimensionsToSize:ButtionSize];
    [leftBtn4 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn4 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn3 withOffset:16];
    
    //[leftVerticalView.subviews autoDistributeViewsAlongAxis:ALAxisVertical withFixedSize:44 insetSpacing:YES alignment:NSLayoutFormatAlignAllLeft];
#pragma mark rightSwipeVerticalBar
    
    rightSwipeVerticalBar = [UIView newAutoLayoutView];
    rightSwipeVerticalBar.backgroundColor = [UIColor clearColor];//[[UIColor cyanColor] colorWithAlphaComponent:0.3];//
    [self.view addSubview:rightSwipeVerticalBar];
    [rightSwipeVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightSwipeVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [rightSwipeVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtionEdgeLength, ButtonPlaceholderHeight * 2.5)];
    
    UIImageView *swipeImageView = [UIImageView newAutoLayoutView];
    swipeImageView.alpha = 0.6;
    swipeImageView.image = [UIImage imageNamed:@"IcoMoon_SlideBar_Long"];
    swipeImageView.contentMode = UIViewContentModeScaleAspectFit;
    swipeImageView.layer.cornerRadius = 10.0;
    [rightSwipeVerticalBar addSubview:swipeImageView];
    [swipeImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UIView *swipeScaleView = [UIView newAutoLayoutView];
    swipeScaleView.backgroundColor = [UIColor clearColor];
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeScaleViewSwipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [swipeScaleView addGestureRecognizer:swipeUpGR];
    UISwipeGestureRecognizer *swipeDownGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeScaleViewSwipeDown:)];
    swipeDownGR.direction = UISwipeGestureRecognizerDirectionDown;
    [swipeScaleView addGestureRecognizer:swipeDownGR];
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeScaleViewDoubleTap:)];
    doubleTapGR.numberOfTapsRequired = 2;
    [swipeScaleView addGestureRecognizer:doubleTapGR];
    [rightSwipeVerticalBar addSubview:swipeScaleView];
    [swipeScaleView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

#pragma mark rightVerticalBar
    
    rightVerticalBar = [UIView newAutoLayoutView];
    rightVerticalBar.backgroundColor = [UIColor clearColor];//[[UIColor brownColor] colorWithAlphaComponent:0.3];//
    [self.view addSubview:rightVerticalBar];
    [rightVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:rightSwipeVerticalBar withOffset:0];
    [rightVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtionEdgeLength, ButtonPlaceholderHeight * 3)];
    
    UIButton *rightBtn1 = [UIButton newAutoLayoutView];
    rightBtn1.alpha = 0.6;
    [rightBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share_WBG"] forState:UIControlStateNormal];
    rightBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn1 addTarget:self action:@selector(showShareImageVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn1];
    [rightBtn1 autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [rightBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
    
    UIButton *rightBtn2 = [UIButton newAutoLayoutView];
    rightBtn2.alpha = 0.6;
    [rightBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share2_WBG"] forState:UIControlStateNormal];
    rightBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn2 addTarget:self action:@selector(showShareEWShareRepositoryVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn2];
    [rightBtn2 autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [rightBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn1 withOffset:16];
    
    UIButton *rightBtn3 = [UIButton newAutoLayoutView];
    rightBtn3.alpha = 0.6;
    [rightBtn3 setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    rightBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn3 addTarget:self action:@selector(enterShareMode) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn3];
    [rightBtn3 autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [rightBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn2 withOffset:16];
    
#pragma mark Button
    quiteShareModeButton = [UIButton newAutoLayoutView];
    quiteShareModeButton.alpha = 0.6;
    [quiteShareModeButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    quiteShareModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quiteShareModeButton addTarget:self action:@selector(showQuiteShareModeAlertController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:quiteShareModeButton];
    [quiteShareModeButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [quiteShareModeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msShareEditModeBar withOffset:10];
    [quiteShareModeButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    quiteShareModeButton.hidden = YES;
}

- (void)showVerticalBar{
    leftVerticalBar.alpha = 1;
    rightVerticalBar.alpha = 1;
    rightSwipeVerticalBar.alpha = 1;
    verticalBarIsAlphaZero = NO;
}

- (void)hideVerticalBar{
    leftVerticalBar.alpha = 0;
    rightVerticalBar.alpha = 0;
    rightSwipeVerticalBar.alpha = 0;
    verticalBarIsAlphaZero = YES;
}

- (void)showHideMapShowModeBar{
    [UIView animateWithDuration:0.3 animations:^{
        msMomentLocationModeBar.alpha = (msMomentLocationModeBar.alpha == 1) ? 0 : 1;
    }];
    
}

- (void)showHidePlacemarkInfoBar{
    [UIView animateWithDuration:0.3 animations:^{
        placemarkInfoBar.alpha = (placemarkInfoBar.alpha == 1) ? 0 : 1;
    }];
    
}

- (void)showHideNaviBar{
    [UIView animateWithDuration:0.3 animations:^{
        naviBar.alpha = (naviBar.alpha == 1) ? 0 : 1;
    }];
    
}

- (void)swipeScaleViewSwipeUp:(UISwipeGestureRecognizer *)sender{
    [self scaleMapView:1.0 / self.settingManager.mapViewScaleRate];
}

- (void)swipeScaleViewSwipeDown:(UISwipeGestureRecognizer *)sender{
    [self scaleMapView:self.settingManager.mapViewScaleRate];
}

- (void)swipeScaleViewDoubleTap:(UITapGestureRecognizer *)sender{
    CGPoint tapPoint = [sender locationInView:sender.view];
    if (tapPoint.y < sender.view.bounds.size.height / 2.0) {
        [self scaleMapView:1.0 / (self.settingManager.mapViewScaleRate * 2.0)];
    }else{
        [self scaleMapView:self.settingManager.mapViewScaleRate * 2.0];
    }
}

- (void)scaleMapView:(float)mapViewScaleRate{
    MKCoordinateRegion oldRegion = self.myMapView.region;
    MKCoordinateSpan newSpan = MKCoordinateSpanMake(oldRegion.span.latitudeDelta * mapViewScaleRate, oldRegion.span.longitudeDelta * mapViewScaleRate);
    
    if (newSpan.latitudeDelta < 145.8 && newSpan.latitudeDelta > 0.0008) {
        if (newSpan.latitudeDelta < 145.3 && newSpan.longitudeDelta > 0.0006) {
            if(DEBUGMODE) NSLog(@"%@",NSStringFromCGPoint(CGPointMake(newSpan.latitudeDelta, newSpan.longitudeDelta)));
            MKCoordinateRegion newRegion = MKCoordinateRegionMake(oldRegion.center, newSpan);
            [self.myMapView setRegion:newRegion animated:YES];
        }
    }
}


#pragma mark PopupController

- (void)initPopupController{
    [STPopupNavigationBar appearance].barTintColor = [UIColor colorWithRed:0.20 green:0.60 blue:0.86 alpha:1.0];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18],
                                                               NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Cochin" size:17] } forState:UIControlStateNormal];
}

#pragma mark Share Bar

- (void)initShareBar{
    shareBar = [ShareBar newAutoLayoutView];
    shareBar.sideViewShrinkRate = 0.8;
    shareBar.title =  @"用相册记录人生，用足迹丈量世界";
    shareBar.titleFont = [UIFont bodyFontWithSizeMultiplier:1.0];
    shareBar.leftImage = [UIImage imageNamed:@"地球_300_300"];
    shareBar.leftText = NSLocalizedString(@"AlbumMaps", @"相册地图");
    shareBar.rightImage = [UIImage imageNamed:@"1133399709_300"];
    shareBar.rightText = NSLocalizedString(@"ScanToDL", @"扫描下载");
    [self.view addSubview:shareBar];
    [shareBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [shareBar autoSetDimension:ALDimensionHeight toSize:150];
    //[shareBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view withMultiplier:0.2];
}

#pragma mark Data

- (void)initData{
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:{
            // 时刻模式初始化
            switch (self.settingManager.dateMode) {
                case DateModeDay:{
                    self.startDate = [NOW dateAtStartOfToday];
                    self.endDate = [NOW dateAtEndOfToday];
                }
                    break;
                case DateModeWeek:{
                    self.startDate = [NOW dateAtStartOfThisWeek];
                    self.endDate = [NOW dateAtEndOfThisWeek];
                }
                    break;
                case DateModeMonth:{
                    self.startDate = [NOW dateAtStartOfThisMonth];
                    self.endDate = [NOW dateAtEndOfThisMonth];
                }
                    break;
                case DateModeYear:{
                    self.startDate = [NOW dateAtStartOfThisYear];
                    self.endDate = [NOW dateAtEndOfThisYear];
                }
                    break;
                case DateModeAll:{
                    self.startDate = nil;
                    self.endDate = nil;
                }
                    break;
                default:{
                    self.startDate = [NOW dateAtStartOfThisMonth];
                    self.endDate = [NOW dateAtEndOfThisMonth];
                }
                    break;
            }
            
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:self.startDate toEndDate:self.endDate inManagedObjectContext:self.cdManager.appMOC];
        }
            break;
        case MapShowModeLocation:{
            // 位置模式初始化
            self.lastPlacemark = self.settingManager.lastPlacemark;
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:self.settingManager.lastPlacemark inManagedObjectContext:self.cdManager.appMOC];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - Scene Change

- (void)showSettingVC{
    SettingVC *settingVC = [SettingVC new];
    settingVC.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showShareImageVC{
    [self hideVerticalBar];
    msMomentLocationModeBar.alpha = 0;
    placemarkInfoBar.alpha = 0;
    naviBar.alpha = 0;
    
    NSMutableString *ms = [NSMutableString new];
    
    if (self.settingManager.mapShowMode == MapShowModeMoment) {
        [ms appendFormat:@"%@",[NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate]];
        [ms appendString:NSLocalizedString(@" I have my footprints over ", @" 我的足迹遍布 ")];
    }else{
        [ms appendString:NSLocalizedString(@"I have been in ", @"我到过 ")];
        [ms appendFormat:@"%@",self.lastPlacemark];
        [ms appendString:NSLocalizedString(@" for ", @" 的 ")];
    }
    
    if (placemarkInfoBar.countryCount) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.countryCount];
        [ms appendString:NSLocalizedString(@" States,", @"xx个国家,")];
    }
    if (placemarkInfoBar.administrativeAreaCount) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.administrativeAreaCount];
        [ms appendString:NSLocalizedString(@" AdministrativeAreas,", @"xx个省,")];
    }
    if (placemarkInfoBar.localityCount){
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.localityCount];
        [ms appendString:NSLocalizedString(@" Localities,", @"xx个市,")];
    }
    if (placemarkInfoBar.subLocalityCount) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.subLocalityCount];
        [ms appendString:NSLocalizedString(@" SubLocalities,", @"xx个县区,")];
    }
    if (placemarkInfoBar.thoroughfareCount) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.thoroughfareCount];
        [ms appendString:NSLocalizedString(@" Thoroughfares", @"xx个村镇街道")];
    }
    
    [ms appendString:NSLocalizedString(@"\nTotal ", @"\n总")];
    [ms appendFormat:@"%@ %@",placemarkInfoBar.totalTitle,placemarkInfoBar.totalString];
    
    shareBar.middleText = ms;
    // 设置字体大小
    shareBar.middleFont = [UIFont bodyFontWithSizeMultiplier:0.9];
    // 显示出来，以便进行截图
    shareBar.alpha = 1;

    UIGraphicsBeginImageContext(CGSizeMake(ScreenWidth, naviBar.frame.origin.y + naviBar.frame.size.height));
    
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:YES];
    
    UIImage *contentImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *thumbImageData=UIImageJPEGRepresentation([UIImage imageNamed:@"地球_300_300"], 0.5);
    
    ShareImageVC *ssVC = [ShareImageVC new];
    ssVC.shareImage = contentImage;
    ssVC.shareThumbData = thumbImageData;
    ssVC.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.8, ScreenHeight * 0.85);
    ssVC.landscapeContentSizeInPopup = CGSizeMake(ScreenHeight * 0.85, ScreenWidth * 0.8);

    popupController = [[STPopupController alloc] initWithRootViewController:ssVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showShareEWShareRepositoryVC{
    // 如果没有分享功能
    if (!self.settingManager.hasPurchasedShare) {
        [self showPurchaseShareFunctionAlertController];
        return;
    }
    
    if (!self.addedEWShareAnnos) return;
    
    // 生成分享对象
    EverywhereShareRepository *shareRepository = [EverywhereShareRepository new];
    shareRepository.shareAnnos = self.addedEWShareAnnos;
    shareRepository.radius = self.settingManager.mergedDistanceForLocation;
    shareRepository.creationDate = NOW;
    shareRepository.isSharedByMe = YES;
    
    if (self.settingManager.mapShowMode == MapShowModeMoment) shareRepository.title = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
    else shareRepository.title = self.lastPlacemark;
    
    ShareEWShareRepositoryVC *ssVC = [ShareEWShareRepositoryVC new];
    ssVC.shareRepository = shareRepository;
    NSData *thumbImageData=UIImageJPEGRepresentation([UIImage imageNamed:@"地球_300_300"], 0.5);
    ssVC.shareThumbImageData = thumbImageData;
    
    ssVC.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.9, 200);
    ssVC.landscapeContentSizeInPopup = CGSizeMake(200, ScreenWidth * 0.9);
    popupController = [[STPopupController alloc] initWithRootViewController:ssVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
    
    // 测试使用
    //
}

- (void)showPurchaseShareFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"Purchase Share Function",@"购买分享功能");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Share your footprints to others", @"1.将足迹分享给他人"),NSLocalizedString(@"2.Store footprints shared by others and lookup anytime", @"2.存储别人分享的足迹，并实时查看"),NSLocalizedString(@"Cost $0.99,continue?", @"价格6元，是否购买？")];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self showPurchaseShareFunctionVC];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPurchaseShareFunctionVC{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    inAppPurchaseVC.transactionType = TransactionTypePurchase;
    inAppPurchaseVC.productIndex = 0;
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(BOOL success,int productIndex,enum TransactionType transactionType){
#warning here
        if (YES) {
            self.settingManager.hasPurchasedShare = YES;
            NSLog(@"%@",self.settingManager.hasPurchasedShare? @"1111" : @"0000");
        }
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inAppPurchaseVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveShareRepositoryString:(NSString *)receivedString{
    NSString *shareRepositoryString = nil;
    //CLLocationDistance sharedRadius = 0;
    
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",WXAppID];
    
    /*
    if ([receivedString containsString:@"track/"]) {
        // 时刻模式分享的足迹
        headerString = [NSString stringWithFormat:@"%@://AlbumMaps/track/",WXAppID];
        trackOrPositionString = [receivedString stringByReplacingOccurrencesOfString:headerString withString:@""];
    }else if ([receivedString containsString:@"position/"]){
        // 地点模式分享的足迹
        headerString = [NSString stringWithFormat:@"%@://AlbumMaps/position/",WXAppID];
        trackOrPositionString = [receivedString stringByReplacingOccurrencesOfString:headerString withString:@""];
        NSString *radiusNumberString = [trackOrPositionString substringToIndex:[trackOrPositionString rangeOfString:@"/"].location + 1];
        if (DEBUGMODE) NSLog(@"radiusNumberString : %@",radiusNumberString);
        trackOrPositionString = [trackOrPositionString stringByReplacingOccurrencesOfString:radiusNumberString withString:@""];
        
        radiusNumberString = [radiusNumberString stringByReplacingOccurrencesOfString:@"radius" withString:@""];
        radiusNumberString = [radiusNumberString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
        sharedRadius = [radiusNumberString doubleValue];
    }
    */
    shareRepositoryString = [receivedString stringByReplacingOccurrencesOfString:headerString withString:@""];
    // For iOS9
    shareRepositoryString = [shareRepositoryString stringByReplacingOccurrencesOfString:@"%0D%0A" withString:@"\n"];
    // For iOS8
    shareRepositoryString = [shareRepositoryString stringByReplacingOccurrencesOfString:@"%20" withString:@"\n"];
    
    //if (DEBUGMODE) NSLog(@"\n%@",shareRepositoryString);
    
    NSData *shareRepositoryData = [[NSData alloc] initWithBase64EncodedString:shareRepositoryString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    // 获取接收到的分享对象
    EverywhereShareRepository *shareRepository = nil;
    
    // 解析数据可能出错
    @try {
        shareRepository = [NSKeyedUnarchiver unarchiveObjectWithData:shareRepositoryData];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    //if (DEBUGMODE) NSLog(@"received shareAnnotation count : %lu",(unsigned long)receivedEWShareAnnos.count);
    
    if (!shareRepository) return;
    // 成功获取分享的数据
    
    // 修改属性
    shareRepository.isSharedByMe = NO;
    // 新接收到，先保存shareRepository，如果用户选择丢弃，再删除掉
    [EverywhereShareRepositoryManager addShareRepository:shareRepository];
    if (DEBUGMODE) NSLog(@"shareRepositoryArray count : %lu",(unsigned long)[EverywhereShareRepositoryManager shareRepositoryArray].count);
    
    // 显示主界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *alertTitle = NSLocalizedString(@"Receive Shared Footprints",@"收到分享的足迹");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@ %lu %@%@",shareRepository.title,NSLocalizedString(@"There are", @"该足迹共有"),(unsigned long)shareRepository.shareAnnos.count,NSLocalizedString(@"footprints.", @"个足迹点，"), NSLocalizedString(@"Would you like to accept the footprints and enter Share Mode?", @"是否接收足迹并进入分享模式？")];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self enterShareMode];
                                                         [self showEWShareRepository:shareRepository];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)enterShareMode{
    msMomentLocationModeBar.hidden = YES;
    placemarkInfoBar.hidden = YES;
    leftVerticalBar.hidden = YES;
    rightVerticalBar.hidden = YES;
    
    msShareEditModeBar.hidden = NO;
    quiteShareModeButton.hidden = NO;
    
    naviBar.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
}

- (void)showEWShareRepository:(EverywhereShareRepository *)shareRepository{
    // 清理地图
    self.addedEWAnnos = nil;
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    
    // 添加接收到的ShareAnnotations
    [self.myMapView addAnnotations:shareRepository.shareAnnos];
    
    // 设置addedIDAnnos，用于导航
    self.addedIDAnnos = shareRepository.shareAnnos;
    
    // 添加Overlays
    if (shareRepository.radius == 0){
        // 时刻模式 分享的足迹
        [self addLineOverlaysPro:shareRepository.shareAnnos];
    }else{
        // 地点模式 分享的足迹
        [self addCircleOverlaysPro:shareRepository.shareAnnos radius:shareRepository.radius];
    }
    
    [self updateVisualViewAfterAddAnnotationsAndOverlays];
}

- (void)showQuiteShareModeAlertController{
    
    if (self.settingManager.hasPurchasedShare) {
        // 如果已经购买了分享模式，直接退出（内容已经保存），不再询问
        [self quiteShareMode];
        return;
    }
    
    NSString *alertTitle = NSLocalizedString(@"Quite Share Mode",@"退出分享模式");
    NSString *alertMessage = NSLocalizedString(@"How to dealwith the footprints?", @"请选择足迹处理方式");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    /*
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save",@"保存")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self quiteShareMode];
                                                       }];
     */
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self showPurchaseShareFunctionVC];
                                                           }];
    UIAlertAction *dropAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Drop",@"丢弃")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           // 用户选择丢弃，则删除保存的shareRepository
                                                           [EverywhereShareRepositoryManager removeLastAddedShareRepository];
                                                           [self quiteShareMode];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:purchaseAction];
    [alertController addAction:dropAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)quiteShareMode{
    
    msMomentLocationModeBar.hidden = NO;
    placemarkInfoBar.hidden = NO;
    leftVerticalBar.hidden = NO;
    rightVerticalBar.hidden = NO;

    msShareEditModeBar.hidden = YES;
    quiteShareModeButton.hidden = YES;
    
    naviBar.backgroundColor = self.settingManager.color;
    
    // 清理地图
    self.addedEWShareAnnos = nil;
    self.addedIDAnnos = nil;
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
}

#pragma mark - Add Annotations And Overlays

- (void)addAnnotations{
    // 清理数组
    self.addedEWAnnos = nil;
    self.addedEWShareAnnos = nil;
    NSMutableArray <EverywhereMKAnnotation *> *annotationsToAdd = [NSMutableArray new];
    NSMutableArray <EverywhereShareMKAnnotation *> *shareAnnotationsToAdd = [NSMutableArray new];
    // 添加 MKAnnotations
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    
    [self.assetsArray enumerateObjectsUsingBlock:^(NSArray<PHAsset *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EverywhereMKAnnotation *anno = [EverywhereMKAnnotation new];
        PHAsset *firstAsset = obj.firstObject;
        PHAsset *lastAsset = obj.lastObject;
        anno.location = firstAsset.location;
        
        if (self.settingManager.mapShowMode == MapShowModeMoment) {
            anno.annotationTitle = [firstAsset.creationDate stringWithDefaultFormat];
        }else{
            anno.annotationTitle = [NSString stringWithFormat:@"%@ ~ %@",[firstAsset.creationDate stringWithFormat:@"yyyy-MM-dd"],[lastAsset.creationDate stringWithFormat:@"yyyy-MM-dd"]];
        }
        
        NSMutableArray *ids = [NSMutableArray new];
        [obj enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ids addObject:obj.localIdentifier];
        }];
        anno.assetLocalIdentifiers = ids;
        
        [annotationsToAdd addObject:anno];
        //[self.myMapView addAnnotation:anno];
        
        EverywhereShareMKAnnotation *shareAnno = [EverywhereShareMKAnnotation new];
        shareAnno.annotationCoordinate = firstAsset.location.coordinate;
        shareAnno.startDate = firstAsset.creationDate;
        if (self.settingManager.mapShowMode == MapShowModeLocation) shareAnno.endDate = lastAsset.creationDate;
        [shareAnnotationsToAdd addObject:shareAnno];
    }];
    
    if (!annotationsToAdd || !annotationsToAdd.count) return;
    [self.myMapView addAnnotations:annotationsToAdd];
    self.addedIDAnnos = annotationsToAdd;
    self.addedEWAnnos = annotationsToAdd;
    self.addedEWShareAnnos = shareAnnotationsToAdd;
}

- (void)addLineOverlaysPro:(NSArray <id<MKAnnotation>> *)annotationArray{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    maxDistance = 500;
    if (annotationArray.count >= 2) {
        // 记录距离信息
        NSMutableArray *distanceArray = [NSMutableArray new];
        totalDistance = 0;
        
        // 添加 MKOverlays
        
        NSMutableArray <MKPolyline *> *polylinesToAdd = [NSMutableArray new];
        NSMutableArray <MKPolygon *> *polygonsToAdd = [NSMutableArray new];
        __block CLLocationCoordinate2D lastCoordinate;
        [annotationArray enumerateObjectsUsingBlock:^(id<MKAnnotation> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= 1) {
                CLLocationCoordinate2D points[2];
                points[0] = lastCoordinate;
                points[1] = obj.coordinate;
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:points count:2];
                polyline.title = [NSString stringWithFormat:@"MKPolyline : %lu",(unsigned long)idx];
                [polylinesToAdd addObject:polyline];
                
                CLLocationDistance subDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
                if (maxDistance < subDistance) maxDistance = subDistance;
                totalDistance += subDistance;
                [distanceArray addObject:[NSNumber numberWithDouble:subDistance]];
                
                MKMapPoint start_MP = MKMapPointForCoordinate(lastCoordinate);
                MKMapPoint end_MP = MKMapPointForCoordinate(obj.coordinate);
                
                MKMapPoint x_MP,y_MP,z_MP;
                CLLocationDistance arrowLength = subDistance;
                
                double z_radian = atan2(end_MP.x - start_MP.x, end_MP.y - start_MP.y);
                z_MP.x = end_MP.x - arrowLength * 0.75 * sin(z_radian);
                z_MP.y = end_MP.y - arrowLength * 0.75 * cos(z_radian);
                
                double arrowRadian = 90.0 / 360.0 * M_2_PI;
                x_MP.x = end_MP.x - arrowLength * sin(z_radian - arrowRadian);
                x_MP.y = end_MP.y - arrowLength * cos(z_radian - arrowRadian);
                y_MP.x = end_MP.x - arrowLength * sin(z_radian + arrowRadian);
                y_MP.y = end_MP.y - arrowLength * cos(z_radian + arrowRadian);
                
                MKMapPoint mapPoint[4] = {z_MP,x_MP,end_MP,y_MP};
                MKPolygon *polygon = [MKPolygon polygonWithPoints:mapPoint count:4];
                [polygonsToAdd addObject:polygon];
                
                
                lastCoordinate = obj.coordinate;
            }else{
                lastCoordinate = obj.coordinate;
            }
        }];
        
        //NSLog(@"%@",overlaysToAdd);
        [self.myMapView addOverlays:polylinesToAdd];
        [self.myMapView addOverlays:polygonsToAdd];
    }
}

/*
- (void)addLineOverlays{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    maxDistance = 500;
    if (addedAnnotationsWithIndex.count >= 2) {
        // 记录距离信息
        NSMutableArray *distanceArray = [NSMutableArray new];
        totalDistance = 0;
        
        // 添加 MKOverlays
        
        NSMutableArray <MKPolyline *> *polylinesToAdd = [NSMutableArray new];
        NSMutableArray <MKPolygon *> *polygonsToAdd = [NSMutableArray new];
        __block CLLocationCoordinate2D lastCoordinate;
        [addedAnnotationsWithIndex enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= 1) {
                CLLocationCoordinate2D points[2];
                points[0] = lastCoordinate;
                points[1] = obj.coordinate;
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:points count:2];
                polyline.title = [NSString stringWithFormat:@"MKPolyline : %lu",(unsigned long)idx];
                [polylinesToAdd addObject:polyline];
                
                CLLocationDistance subDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
                if (maxDistance < subDistance) maxDistance = subDistance;
                totalDistance += subDistance;
                [distanceArray addObject:[NSNumber numberWithDouble:subDistance]];
                
                MKMapPoint start_MP = MKMapPointForCoordinate(lastCoordinate);
                MKMapPoint end_MP = MKMapPointForCoordinate(obj.coordinate);
                
                MKMapPoint x_MP,y_MP,z_MP;
                CLLocationDistance arrowLength = subDistance;
                
                double z_radian = atan2(end_MP.x - start_MP.x, end_MP.y - start_MP.y);
                z_MP.x = end_MP.x - arrowLength * 0.75 * sin(z_radian);
                z_MP.y = end_MP.y - arrowLength * 0.75 * cos(z_radian);
                
                double arrowRadian = 90.0 / 360.0 * M_2_PI;
                x_MP.x = end_MP.x - arrowLength * sin(z_radian - arrowRadian);
                x_MP.y = end_MP.y - arrowLength * cos(z_radian - arrowRadian);
                y_MP.x = end_MP.x - arrowLength * sin(z_radian + arrowRadian);
                y_MP.y = end_MP.y - arrowLength * cos(z_radian + arrowRadian);
                
                MKMapPoint mapPoint[4] = {z_MP,x_MP,end_MP,y_MP};
                MKPolygon *polygon = [MKPolygon polygonWithPoints:mapPoint count:4];
                [polygonsToAdd addObject:polygon];
                
                
                lastCoordinate = obj.coordinate;
            }else{
                lastCoordinate = obj.coordinate;
            }
        }];
        
        //NSLog(@"%@",overlaysToAdd);
        [self.myMapView addOverlays:polylinesToAdd];
        [self.myMapView addOverlays:polygonsToAdd];
    }
}
*/

- (void)addCircleOverlaysPro:(NSArray <id<MKAnnotation>> *)annotationArray radius:(CLLocationDistance)circleRadius{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    if (annotationArray.count >= 1) {
        
        //__block CLLocationDistance radius = circleRadius;
        
        // 添加 MKOverlays
        
        NSMutableArray <MKCircle *> *circlesToAdd = [NSMutableArray new];
        
        [annotationArray enumerateObjectsUsingBlock:^(id<MKAnnotation> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //if ([obj respondsToSelector:@selector(radius)]) radius = (CLLocationDistance)[[obj performSelector:@selector(radius)] doubleValue];
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:obj.coordinate radius:circleRadius];
            if (circle) [circlesToAdd addObject:circle];
        }];
        
        [self.myMapView addOverlays:circlesToAdd];
    }

}

/*
- (void)addCircleOverlays{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    if (addedAnnotationsWithIndex.count >= 1) {
        
        // 添加 MKOverlays
        
        NSMutableArray <MKCircle *> *circlesToAdd = [NSMutableArray new];
        
        [addedAnnotationsWithIndex enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:obj.coordinate radius:self.settingManager.mergedDistanceForLocation / 2.0];
            if (circle) [circlesToAdd addObject:circle];
        }];
        
        [self.myMapView addOverlays:circlesToAdd];
    }
}
*/

- (void)asyncAddRouteOverlays{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    maxDistance = 500;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (self.addedEWAnnos.count >= 2) {
            // 记录距离信息
            NSMutableArray *distanceArray = [NSMutableArray new];
            totalDistance = 0;
            __block CLLocationCoordinate2D lastCoordinate;
            // 添加 MKOverlays
            
            //NSMutableArray <MKPolyline *> *polylinesToAdd = [NSMutableArray new];
            GCRoutePolylineManager *rpManager = [GCRoutePolylineManager defaultManager];
            
            [self.addedEWAnnos enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx > 0){
                    GCRoutePolyline *foundedRP = [rpManager fetchRoutePolylineWithSource:lastCoordinate destination:obj.coordinate];
                    __block CLLocationDistance subDistance;
                    if (foundedRP) {
                        NSLog(@"foundedRP : %@",foundedRP);
                        //subDistance = foundedRP.routeDistance;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.myMapView addOverlay:foundedRP.polyline];
                        });
                        
                    }else{
                        MKMapItem *lastMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:lastCoordinate addressDictionary:nil]];
                        MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:obj.coordinate addressDictionary:nil]];
                        
                        MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
                        [directionsRequest setSource:lastMapItem];
                        [directionsRequest setDestination:currentMapItem];
                        
                        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
                            MKRoute *route = response.routes.firstObject;
                            
                            subDistance = route.distance;
                            
                            
                            MKPolyline *routePolyline = route.polyline;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(routePolyline) [self.myMapView addOverlay:routePolyline];
                            });
                            
                            if (routePolyline){
                                GCRoutePolyline *newRP = [GCRoutePolyline newRoutePolyline:routePolyline source:lastCoordinate destination:obj.coordinate];
                                newRP.routeDistance = subDistance;
                                NSLog(@"newRP : %@",newRP);
                                [rpManager addRoutePolyline:newRP];
                            }
                            
                            [NSThread sleepForTimeInterval:0.5];
                        }];
                        
                    }
                    
                    if (maxDistance < subDistance) maxDistance = subDistance;
                    totalDistance += subDistance;
                    [distanceArray addObject:[NSNumber numberWithDouble:subDistance]];
                    
                    
                }else{
                    lastCoordinate = obj.coordinate;
                }
                
            }];// 结束循环
            
            NSString *total;
            NSString *totalString = NSLocalizedString(@"Total:", @"总行程:");
            if (totalDistance >=1000) {
                total = [NSString stringWithFormat:@"%@ %.2f km",totalString,totalDistance/1000];
            }else{
                total = [NSString stringWithFormat:@"%@ %.0f m",totalString,totalDistance];
            }
            NSLog(@"%@",total);
            
        }
        
    });
    
}

- (void)updateVisualViewAfterAddAnnotationsAndOverlays{
    
    // 自己的
    if (self.addedEWAnnos.count > 0) {
        
        [self updateMapShowModeBar];
        NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
        [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapShowMode:self.settingManager.mapShowMode];
        
        if (self.settingManager.mapShowMode == MapShowModeLocation){
            maxDistance = self.settingManager.mergedDistanceForLocation * 8.0;
        }
    
        // 移动地图到第一个点
    
        EverywhereMKAnnotation *firstAnnotation = self.addedEWAnnos.firstObject;
        MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstAnnotation.coordinate, maxDistance, maxDistance);
        [self.myMapView setRegion:showRegion animated:NO];
        [self.myMapView selectAnnotation:firstAnnotation animated:YES];
    }
    
    // 分享的
    if (self.addedEWShareAnnos.count > 0) {
        
        //NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
        //[self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapShowMode:self.settingManager.mapShowMode];

        EverywhereShareMKAnnotation *firstShareAnnotation = self.addedEWShareAnnos.firstObject;
        
        if (self.addedEWShareAnnos.count > 1) {
            EverywhereShareMKAnnotation *secondShareAnnotation = self.addedEWShareAnnos[1];
            maxDistance = fabs(MKMetersBetweenMapPoints(MKMapPointForCoordinate(firstShareAnnotation.coordinate), MKMapPointForCoordinate(secondShareAnnotation.coordinate))) * 8.0;
        }
        
        MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstShareAnnotation.coordinate, maxDistance, maxDistance);
        [self.myMapView setRegion:showRegion animated:NO];
        [self.myMapView selectAnnotation:firstShareAnnotation animated:YES];
    }
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
        MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinAV"];
        if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAV"];
        
        pinAV.animatesDrop = NO;
        
        pinAV.pinColor = MKPinAnnotationColorGreen;
        
        pinAV.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGR:)];
        [imageView addGestureRecognizer:imageViewTapGR];
        
        
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:((EverywhereMKAnnotation *)annotation).assetLocalIdentifiers options:options].firstObject;
        if (asset) imageView.image = [asset synchronousFetchUIImageAtTargetSize:CGSizeMake(80, 80)];
        
        UIButton *badgeButton = [UIButton newAutoLayoutView];
        badgeButton.userInteractionEnabled = NO;
        [badgeButton setBackgroundImage:[UIImage imageNamed:@"badge"] forState:UIControlStateNormal];
        [badgeButton setTitle:[NSString stringWithFormat:@"%ld",(long)((EverywhereMKAnnotation *)annotation).assetCount] forState:UIControlStateNormal];
        badgeButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [imageView addSubview:badgeButton];
        [badgeButton autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        //pinAV.image = imageView.image;
        pinAV.leftCalloutAccessoryView = imageView;
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pinAV;
        
        //MKAnnotationView *annoView = (MKAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"annoView"];
        
    }else if ([annotation isKindOfClass:[EverywhereShareMKAnnotation class]]){
        MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinShareAV"];
        if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinShareAV"];
        
        pinAV.animatesDrop = NO;
        
        pinAV.pinColor = MKPinAnnotationColorRed;
        
        pinAV.canShowCallout = YES;
        
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return pinAV;

    }else if([annotation isKindOfClass:[MKUserLocation class]]){
        MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLocation"];
        view.canShowCallout = NO;
        return nil;
    }else{
        return nil;
    }
}

- (void)imageViewTapGR:(UITapGestureRecognizer *)sender{
    AssetDetailVC *showVC = [AssetDetailVC new];
    showVC.edgesForExtendedLayout = UIRectEdgeNone;
    showVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    EverywhereMKAnnotation *annotation = self.myMapView.selectedAnnotations.firstObject;
    showVC.assetLocalIdentifiers = annotation.assetLocalIdentifiers;
    
    /*
    showVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController presentViewController:showVC animated:YES completion:nil];
     */
    
    /*
    showVC.contentSizeInPopup = CGSizeMake(ScreenWidth,ScreenHeight - 40);
    showVC.landscapeContentSizeInPopup = CGSizeMake(ScreenHeight,ScreenWidth);
    popupController = [[STPopupController alloc] initWithRootViewController:showVC];
    popupController.style = STPopupStyleFormSheet;
    popupController.transitionStyle = STPopupTransitionStyleFade;
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
     */
    
    [self presentViewController:showVC animated:YES completion:nil];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if ([view isKindOfClass:[MKPinAnnotationView class]]) {
        //NSLog(@"calloutAccessoryControlTapped:");
        if ([view.annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
            EverywhereMKAnnotation *anno = (EverywhereMKAnnotation *)view.annotation;
            
            PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
            if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
            
            [self updateLocationInfoBarWithAssetInfo:assetInfo];
        }else if ([view.annotation isKindOfClass:[EverywhereShareMKAnnotation class]]){
            EverywhereShareMKAnnotation *shareAnno = (EverywhereShareMKAnnotation *)view.annotation;
            [self updateLocationInfoBarWithCoordinate:shareAnno.coordinate];
        }
        
        if (locationInfoBarIsOutOfVisualView) [self showLocationInfoBar];
        else [self hideLocationInfoBar];
    }
    
}

- (void)updateLocationInfoBarWithAssetInfo:(PHAssetInfo *)assetInfo{
    locationInfoBar.latitude = [assetInfo.latitude_Coordinate_Location doubleValue];
    locationInfoBar.longitude = [assetInfo.longitude_Coordinate_Location doubleValue];
    locationInfoBar.horizontalAccuracy = [assetInfo.horizontalAccuracy_Location doubleValue];
    locationInfoBar.altitude = [assetInfo.altitude_Location doubleValue];
    locationInfoBar.verticalAccuracy = [assetInfo.verticalAccuracy_Location doubleValue];
    locationInfoBar.level = [assetInfo.level_floor_Location integerValue];
    locationInfoBar.address = assetInfo.localizedPlaceString_Placemark;
}

- (void)updateLocationInfoBarWithCoordinate:(CLLocationCoordinate2D)aCoordinate{
    
    locationInfoBar.latitude = aCoordinate.latitude;
    locationInfoBar.longitude = aCoordinate.longitude;
    
    [[CLGeocoder new] reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:aCoordinate.latitude longitude:aCoordinate.longitude]
                                        completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                            
                                            if (!error) {
                                                // 解析成功
                                                CLPlacemark *placemark = placemarks.lastObject;
                                                locationInfoBar.address = [placemark localizedPlaceString];
                                            }else{
                                                // 解析失败
                                                locationInfoBar.address = error.localizedDescription;
                                                
                                            }
                                            
                                        }];

}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth = 1;
        polylineRenderer.strokeColor = [[UIColor brownColor] colorWithAlphaComponent:0.6];
        //NSLog(@"%@",polylineRenderer);
        return polylineRenderer;
    }else if([overlay isKindOfClass:[MKPolygon class]]){
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        polygonRenderer.lineWidth = 1;
        polygonRenderer.strokeColor = [[UIColor brownColor] colorWithAlphaComponent:0.6];
        //polygonRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
        return polygonRenderer;
    }else if ([overlay isKindOfClass:[MKCircle class]]){
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 1;
        circleRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
        circleRenderer.strokeColor = [[UIColor cyanColor] colorWithAlphaComponent:0.6];
        return circleRenderer;
    }
    else{
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    // MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000);
    // [mapView setRegion:showRegion animated:YES];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    self.currentAnnotationIndex = [self.addedIDAnnos indexOfObject:view.annotation];
    
    if ([view.annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
        //self.currentAnnotationIndex = [self.addedEWAnnos indexOfObject:view.annotation];
        
        EverywhereMKAnnotation *anno = (EverywhereMKAnnotation *)view.annotation;
        PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
        if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
        
        [self updateLocationInfoBarWithAssetInfo:assetInfo];
        
    }else if ([view.annotation isKindOfClass:[EverywhereShareMKAnnotation class]]){
        EverywhereShareMKAnnotation *shareAnno = (EverywhereShareMKAnnotation *)view.annotation;
        //self.currentAnnotationIndex = [self.addedEWShareAnnos indexOfObject:shareAnno];
        
        [self updateLocationInfoBarWithCoordinate:shareAnno.coordinate];
    }
}

- (void)setCurrentAnnotationIndex:(NSInteger)currentAnnotationIndex{
    _currentAnnotationIndex = currentAnnotationIndex;
    if (self.addedIDAnnos.count > 0){
        currentAnnotationIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)(currentAnnotationIndex + 1),(unsigned long)self.addedIDAnnos.count];
    }else{
        currentAnnotationIndexLabel.text = @"";
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //MKCoordinateSpan newSpan = mapView.region.span;
    //NSLog(@"%@",NSStringFromCGPoint(CGPointMake(newSpan.latitudeDelta, newSpan.longitudeDelta)));
}

@end
