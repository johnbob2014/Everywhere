//
//  AssetsMapProVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "AssetsMapProVC.h"
@import Photos;
@import MapKit;

#import "EverywhereMKAnnotation.h"
#import "EverywhereSettingManager.h"

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

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"

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
@property (strong,nonatomic) NSString *placemarkName;

@property (strong,nonatomic) GCPhotoManager *photoManager;
@property (strong,nonatomic) EverywhereCoreDataManager *cdManager;
@property (strong,nonatomic) EverywhereSettingManager *settingManager;

@property (strong,nonatomic) MKMapView *myMapView;
@end

@implementation AssetsMapProVC{
    STPopupController *popupController;
    
    
    NSArray <EverywhereMKAnnotation *> *addedAnnotationsWithIndex;
    
    MapShowModeBar *mapShowModeBar;
    
    LocationInfoBar *locationInfoBar;
    float locationInfoBarHeight;
    BOOL locationInfoBarIsHidden;
    
    PlacemarkInfoBar *placemarkInfoBar;
    float placemarkInfoBarHeight;
    BOOL placemarkInfoBarIsHidden;

    UIView *naviBar;
    UIButton *firstButton;
    UIButton *previousButton;
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *lastButton;
    UILabel *currentAnnotationIndexLabel;
    
    BOOL isPlaying;
    NSTimer *playTimer;
    
    
    __block CLLocationDistance maxDistance;
    __block CLLocationDistance totalDistance;
    __block CLLocationDistance totalArea;
}

#pragma mark - Getter & Setter

- (void)setAssetInfoArray:(NSArray<PHAssetInfo *> *)assetInfoArray{
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
        
        [self updatePlacemarkInfoBar];
    }
}

- (void)setAssetArray:(NSArray<PHAsset *> *)assetArray{
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
    _assetsArray = assetsArray;
    
    [self addAnnotations];
    
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:
            [self addLineOverlays];
            break;
        case MapShowModeLocation:
            [self addCircleOverlays];
            break;
        default:
            break;
    }
    
    // 如果地图已经初始化，才进行更新
    if (self.myMapView) [self updateVisualViewAfterAddAnnotationsAndOverlays];
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.photoManager = [GCPhotoManager defaultManager];
    self.cdManager = [EverywhereCoreDataManager defaultManager];
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    [self initMapView];
    
    [self initData];
    
    [self initMapShowModeBar];
    
    [self initNaviBar];
    
    [self initLocationInfoBar];
    
    // PlacemarkInfoBar 位于 MapShowModeBar 下方10
    [self initPlacemarkInfoBar];
    
    [self initVerticalAccessoriesBar];

    [self initPopupController];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.assetInfoArray = self.assetInfoArray;
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
    
    UITapGestureRecognizer *mapViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    mapViewTapGR.delegate = self;
    //[self.myMapView addGestureRecognizer:mapViewTapGR];
    
    //NSLog(@"%@",self.myMapView.gestureRecognizers);
}

- (void)mapViewTapGR:(id)sender{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    //naviBar.hidden = ! naviBar.hidden;
}

//UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

#pragma mark ModeBar

- (void)initMapShowModeBar{
    mapShowModeBar = [MapShowModeBar newAutoLayoutView];
    [self.view addSubview:mapShowModeBar];
    [mapShowModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [mapShowModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    mapShowModeBar.mapShowMode = self.settingManager.mapShowMode;
    
    WEAKSELF(weakSelf);
    mapShowModeBar.mapShowModeChangedHandler = ^(UISegmentedControl *sender){
        // 记录当前地图模式
        weakSelf.settingManager.mapShowMode = sender.selectedSegmentIndex;
        /*
        switch (sender.selectedSegmentIndex) {
            case MapShowModeMoment:{
                weakSelf.startDate = [NOW dateAtStartOfToday];
                weakSelf.endDate = [NOW dateAtEndOfToday];
                weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:weakSelf.startDate toEndDate:weakSelf.endDate inManagedObjectContext:[EverywhereCoreDataManager defaultManager].appMOC];
                
            }
                break;
            case MapShowModeLocation:{
                weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:@"," inManagedObjectContext:[EverywhereCoreDataManager defaultManager].appMOC];
                weakSelf.placemarkName = NSLocalizedString(@"All Locations", @"所有地点");
            }
                break;
            default:
                break;
        }
        */
        weakSelf.assetInfoArray = nil;
        [weakSelf.myMapView removeAnnotations:weakSelf.myMapView.annotations];
        [weakSelf.myMapView removeOverlays:weakSelf.myMapView.overlays];
    };
    
    mapShowModeBar.datePickerTouchDownHandler = ^(UIButton *sender) {
        [weakSelf showDatePicker];
    };
    
    mapShowModeBar.locaitonPickerTouchDownHandler = ^(UIButton *sender){
        [weakSelf showLocationPicker];
    };
}

- (void)updateMapShowModeBar{
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:
            mapShowModeBar.info = [[self.startDate stringWithFormat:@"yyyy-MM-dd ~ "] stringByAppendingString:[self.endDate stringWithFormat:@"yyyy-MM-dd"]];
            break;
        case MapShowModeLocation:
            mapShowModeBar.info = self.placemarkName;
            break;
        default:
            break;
    }
}

- (void)showDatePicker{
    DatePickerVC *datePickerVC = [DatePickerVC new];
    datePickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    datePickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    
    __weak AssetsMapProVC *weakSelf = self;
    
    datePickerVC.dateModeChangedHandler = ^(DateMode choosedDateMode){
        [EverywhereSettingManager defaultManager].dateMode = choosedDateMode;
    };
    
    datePickerVC.dateRangeChangedHandler = ^(NSDate *choosedStartDate,NSDate *choosedEndDate){
        //settingManager.mapShowMode = MapShowModeMoment;
        weakSelf.startDate = choosedStartDate;
        weakSelf.endDate = choosedEndDate;
        weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:weakSelf.startDate toEndDate:weakSelf.endDate inManagedObjectContext:weakSelf.cdManager.appMOC];
    };
    
    popupController = [[STPopupController alloc] initWithRootViewController:datePickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showLocationPicker{
    WEAKSELF(weakSelf);
    LocationPickerVC *locationPickerVC = [LocationPickerVC new];
    NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:weakSelf.cdManager.appMOC];
    locationPickerVC.placemarkInfoDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:allAssetInfoArray];
    locationPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    locationPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    
    locationPickerVC.locationDidChangeHandler = ^(NSString *choosedLocation){
        weakSelf.placemarkName = choosedLocation;
        weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:choosedLocation inManagedObjectContext:weakSelf.cdManager.appMOC];
    };
    
    popupController = [[STPopupController alloc] initWithRootViewController:locationPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

#pragma mark Navigation Bar

- (void)initNaviBar{
    
    naviBar = [UIView newAutoLayoutView];
    [naviBar setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    [self.view addSubview:naviBar];
    [naviBar autoSetDimension:ALDimensionHeight toSize:44];
    [naviBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 20, 5) excludingEdge:ALEdgeTop];
    
    firstButton = [UIButton newAutoLayoutView];
    [firstButton setTitle:@"⏪" forState:UIControlStateNormal];
    firstButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:2.0];
    [firstButton addTarget:self action:@selector(firstButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:firstButton];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [firstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    //[firstButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    previousButton = [UIButton newAutoLayoutView];
    [previousButton setTitle:@"⬅️" forState:UIControlStateNormal];
    previousButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:2.0];
    [previousButton addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:previousButton];
    [previousButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:firstButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [previousButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setTitle:@"▶️" forState:UIControlStateNormal];
    playButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:2.0];
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:playButton];
    [playButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [playButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    nextButton = [UIButton newAutoLayoutView];
    [nextButton setTitle:@"➡️" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:2.0];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:nextButton];
    [nextButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:playButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [nextButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    lastButton = [UIButton newAutoLayoutView];
    [lastButton setTitle:@"⏩" forState:UIControlStateNormal];
    lastButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:2.0];
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
    EverywhereMKAnnotation *ida = addedAnnotationsWithIndex.firstObject;
    [self.myMapView setCenterCoordinate:ida.coordinate animated:NO];
    [self.myMapView selectAnnotation:ida animated:YES];
}

- (void)previousButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = self.myMapView.selectedAnnotations.firstObject;
    if (!ida && self.currentAnnotationIndex) {
        ida = addedAnnotationsWithIndex[self.currentAnnotationIndex];
    }
    if (ida) {
        NSInteger index = [addedAnnotationsWithIndex indexOfObject:ida];
        if (--index >= 0) {
            [self.myMapView deselectAnnotation:ida animated:YES];
            ida = addedAnnotationsWithIndex[index];
            [self.myMapView setCenterCoordinate:ida.coordinate animated:NO];
            [self.myMapView selectAnnotation:ida animated:YES];
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
    EverywhereMKAnnotation *ida = self.myMapView.selectedAnnotations.firstObject;
    if (!ida && self.currentAnnotationIndex) {
        ida = addedAnnotationsWithIndex[self.currentAnnotationIndex];
    }
    if (ida) {
        NSInteger index = [addedAnnotationsWithIndex indexOfObject:ida];
        if (++index < addedAnnotationsWithIndex.count) {
            [self.myMapView deselectAnnotation:ida animated:YES];
            ida = addedAnnotationsWithIndex[index];
            
            [self.myMapView setCenterCoordinate:ida.coordinate animated:NO];
            [self.myMapView selectAnnotation:ida animated:YES];
        }
        if (index == addedAnnotationsWithIndex.count) {
            [self playButtonPressed:playButton];
        }
    }
}

- (void)lastButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = addedAnnotationsWithIndex.lastObject;
    [self.myMapView setCenterCoordinate:ida.coordinate animated:NO];
    [self.myMapView selectAnnotation:ida animated:YES];
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
    [locationInfoBar setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    locationInfoBarIsHidden = YES;
    
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(locationInfoBarSwipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [locationInfoBar addGestureRecognizer:swipeUpGR];
}

- (void)locationInfoBarSwipeUp:(UISwipeGestureRecognizer *)sender{
    [self hideLocationInfoBar];
}

- (void)showLocationInfoBar{
    
    if (mapShowModeBar.alpha || placemarkInfoBar.alpha) {
        [UIView animateWithDuration:0.2 animations:^{
            mapShowModeBar.alpha = 0;
            placemarkInfoBar.alpha = 0;
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
                                  locationInfoBarIsHidden = NO;
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
                                  locationInfoBarIsHidden = YES;
                                  [UIView animateWithDuration:0.2 animations:^{
                                      mapShowModeBar.alpha = 1;
                                      placemarkInfoBar.alpha = 1;
                                  }];
                              }];
    
}

#pragma mark Placemark Info Bar

- (void)initPlacemarkInfoBar{
    placemarkInfoBarHeight = 80;
    placemarkInfoBar = [PlacemarkInfoBar newAutoLayoutView];
    [self.view addSubview:placemarkInfoBar];
    [placemarkInfoBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:mapShowModeBar withOffset:10];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [placemarkInfoBar autoSetDimension:ALDimensionHeight toSize:placemarkInfoBarHeight];
    
    // 设为隐藏
    [self showHidePlacemarkInfoBar];
    
    [self updatePlacemarkInfoBar];
}

- (void)updatePlacemarkInfoBar{
    // 更新统计信息
    NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
    placemarkInfoBar.countryCount = placemarkDictionary[kCountryArray].count;
    placemarkInfoBar.administrativeAreaCount = placemarkDictionary[kAdministrativeAreaArray].count;
    placemarkInfoBar.localityCount = placemarkDictionary[kLocalityArray].count;
    placemarkInfoBar.subLocalityCount = placemarkDictionary[kSubLocalityArray].count;
    placemarkInfoBar.thoroughfareCount = placemarkDictionary[kThoroughfareArray].count;
    
    switch (self.settingManager.mapShowMode) {
        case 0:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Distance", @"");
            placemarkInfoBar.totalDistance = totalDistance;
        }
            break;
        case 1:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Area", @"");
            totalArea = addedAnnotationsWithIndex.count * M_PI * pow(self.settingManager.mergedDistanceForLocation,2);
            placemarkInfoBar.totalArea = totalArea;
        }
            break;
        default:
            break;
    }

}

#pragma mark Vertical Accessories Bar

#define VerticalViewHeight 240.0
#define ButtionSize CGSizeMake(44, 44)

- (void)initVerticalAccessoriesBar{
    
    UIView *leftVerticalView = [UIView newAutoLayoutView];
    leftVerticalView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:leftVerticalView];
    [leftVerticalView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [leftVerticalView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [leftVerticalView autoSetDimensionsToSize:CGSizeMake(44, VerticalViewHeight)];
    
    UIButton *leftBtn1 = [UIButton newAutoLayoutView];
    leftBtn1.alpha = 0.6;
    [leftBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share_WBG"] forState:UIControlStateNormal];
    leftBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn1 addTarget:self action:@selector(showShareVC) forControlEvents:UIControlEventTouchDown];
    [leftVerticalView addSubview:leftBtn1];
    [leftBtn1 autoSetDimensionsToSize:ButtionSize];
    [leftBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    

    UIButton *leftBtn2 = [UIButton newAutoLayoutView];
    leftBtn2.alpha = 0.6;
    [leftBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Glasses_WBG"] forState:UIControlStateNormal];
    leftBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn2 addTarget:self action:@selector(showHideMapShowModeBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalView addSubview:leftBtn2];
    [leftBtn2 autoSetDimensionsToSize:ButtionSize];
    [leftBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn1 withOffset:15];
    
    UIButton *leftBtn3 = [UIButton newAutoLayoutView];
    leftBtn3.alpha = 0.6;
    [leftBtn3 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_StatisticBar1_WBG"] forState:UIControlStateNormal];
    leftBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn3 addTarget:self action:@selector(showHidePlacemarkInfoBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalView addSubview:leftBtn3];
    [leftBtn3 autoSetDimensionsToSize:ButtionSize];
    [leftBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn2 withOffset:15];
    
    UIButton *leftBtn4 = [UIButton newAutoLayoutView];
    leftBtn4.alpha = 0.6;
    [leftBtn4 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Trophy_WBG"] forState:UIControlStateNormal];
    leftBtn4.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn4 addTarget:self action:@selector(showHideNaviBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalView addSubview:leftBtn4];
    [leftBtn4 autoSetDimensionsToSize:ButtionSize];
    [leftBtn4 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn4 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn3 withOffset:15];
    
    //[leftVerticalView.subviews autoDistributeViewsAlongAxis:ALAxisVertical withFixedSize:44 insetSpacing:YES alignment:NSLayoutFormatAlignAllLeft];
    
    UIView *rightVerticalView = [UIView newAutoLayoutView];
    rightVerticalView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:rightVerticalView];
    [rightVerticalView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightVerticalView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [rightVerticalView autoSetDimensionsToSize:CGSizeMake(44, VerticalViewHeight)];
    
    UIButton *rightBtn1 = [UIButton newAutoLayoutView];
    rightBtn1.alpha = 0.6;
    [rightBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Setting_WBG"] forState:UIControlStateNormal];
    rightBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn1 addTarget:self action:@selector(showSettingVC:) forControlEvents:UIControlEventTouchDown];
    [rightVerticalView addSubview:rightBtn1];
    [rightBtn1 autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [rightBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];

    UIView *swipeScaleBackgroundView = [UIView newAutoLayoutView];
    swipeScaleBackgroundView.backgroundColor = [UIColor clearColor];//[[UIColor cyanColor] colorWithAlphaComponent:0.6];
    [rightVerticalView addSubview:swipeScaleBackgroundView];
    [swipeScaleBackgroundView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [swipeScaleBackgroundView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:rightVerticalView withMultiplier:0.75];
    
    
    UIImageView *swipeImageView = [UIImageView newAutoLayoutView];
    swipeImageView.alpha = 0.6;
    swipeImageView.image = [UIImage imageNamed:@"IcoMoon_SlideBar_Long"];
    swipeImageView.contentMode = UIViewContentModeScaleAspectFit;
    swipeImageView.layer.cornerRadius = 10.0;
    [swipeScaleBackgroundView addSubview:swipeImageView];
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
    [swipeScaleBackgroundView addSubview:swipeScaleView];
    [swipeScaleView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

    
    
    
    //[self.view addSubview:showHidePlacemarkInfoBarBtn];
    //[showHidePlacemarkInfoBarBtn autoSetDimensionsToSize:CGSizeMake(40, 40)];
    //[showHidePlacemarkInfoBarBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:80];
    //[showHidePlacemarkInfoBarBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    
    /*
    UIButton *placemarkInfoBtn = [UIButton newAutoLayoutView];
    [placemarkInfoBtn primaryStyle];
    [placemarkInfoBtn setTitle:@"PlaceInfo" forState:UIControlStateNormal];
    [placemarkInfoBtn autoSetDimensionsToSize:CGSizeMake(100, 40)];
    placemarkInfoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [placemarkInfoBtn addTarget:self action:@selector(showPlacemarkInfoBar:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:placemarkInfoBtn];
    
    [placemarkInfoBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:80];
    [placemarkInfoBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:180];
     */
}

- (void)showShareVC{
    
}

- (void)showHideMapShowModeBar{
    [UIView animateWithDuration:0.3 animations:^{
        mapShowModeBar.alpha = (mapShowModeBar.alpha == 1) ? 0 : 1;
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

- (void)showSettingVC:(id)sender{
    SettingVC *settingVC = [SettingVC new];
    settingVC.edgesForExtendedLayout = UIRectEdgeNone;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
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

#pragma mark - Init Data

- (void)initData{
    NSDate *now = [NSDate date];
    
    switch (self.settingManager.dateMode) {
        case DateModeDay:{
            self.startDate = [now dateAtStartOfToday];
            self.endDate = [now dateAtEndOfToday];
        }
            break;
        case DateModeWeek:{
            self.startDate = [now dateAtStartOfThisWeek];
            self.endDate = [now dateAtEndOfThisWeek];
        }
            break;
        case DateModeMonth:{
            self.startDate = [now dateAtStartOfThisMonth];
            self.endDate = [now dateAtEndOfThisMonth];
        }
            break;
        case DateModeYear:{
            self.startDate = [now dateAtStartOfThisYear];
            self.endDate = [now dateAtEndOfThisYear];
        }
            break;
        case DateModeAll:{
            self.startDate = nil;
            self.endDate = nil;
        }
            break;
        default:{
            self.startDate = [now dateAtStartOfThisMonth];
            self.endDate = [now dateAtEndOfThisMonth];
        }
            break;
    }
    
    switch (self.settingManager.mapShowMode) {
        case MapShowModeMoment:
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:self.startDate toEndDate:self.endDate inManagedObjectContext:self.cdManager.appMOC];
            break;
        case MapShowModeLocation:
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:self.settingManager.defaultPlacemark inManagedObjectContext:self.cdManager.appMOC];
            break;
        default:
            break;
    }
    
}

#pragma mark - Add Annotations And Overlays

- (void)addAnnotations{
    // 清理数组
    addedAnnotationsWithIndex = nil;
    NSMutableArray <EverywhereMKAnnotation *> *annotationsToAdd = [NSMutableArray new];
    
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
    }];
    
    if (!annotationsToAdd || !annotationsToAdd.count) return;
    [self.myMapView addAnnotations:annotationsToAdd];
    addedAnnotationsWithIndex = annotationsToAdd;
}

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

- (void)asyncAddRouteOverlays{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    maxDistance = 500;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (addedAnnotationsWithIndex.count >= 2) {
            // 记录距离信息
            NSMutableArray *distanceArray = [NSMutableArray new];
            totalDistance = 0;
            __block CLLocationCoordinate2D lastCoordinate;
            // 添加 MKOverlays
            
            //NSMutableArray <MKPolyline *> *polylinesToAdd = [NSMutableArray new];
            GCRoutePolylineManager *rpManager = [GCRoutePolylineManager defaultManager];
            
            [addedAnnotationsWithIndex enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    /*
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [self asyncAddRouteOverlays];
     });
     */
    [self updateMapShowModeBar];
    [self updatePlacemarkInfoBar];
    
    if (self.settingManager.mapShowMode == MapShowModeLocation){
        maxDistance = self.settingManager.mergedDistanceForLocation * 4.0;
    }
    
    // 移动地图到第一个点
    if (addedAnnotationsWithIndex.count > 0) {
        EverywhereMKAnnotation *firstAnnotation = addedAnnotationsWithIndex.firstObject;
        MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstAnnotation.coordinate, maxDistance, maxDistance);
        [self.myMapView setRegion:showRegion animated:YES];
        [self.myMapView selectAnnotation:firstAnnotation animated:YES];
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
        
        
        EverywhereMKAnnotation *anno = (EverywhereMKAnnotation *)view.annotation;
        
        PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
        if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
        if (locationInfoBarIsHidden) [self showLocationInfoBar];
        else [self hideLocationInfoBar];
        
        [self updateLocationInfoBarWithAssetInfo:assetInfo];
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
    self.currentAnnotationIndex = [addedAnnotationsWithIndex indexOfObject:view.annotation];
    
    EverywhereMKAnnotation *anno = (EverywhereMKAnnotation *)view.annotation;
    PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
    if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
    [self updateLocationInfoBarWithAssetInfo:assetInfo];
}

- (void)setCurrentAnnotationIndex:(NSInteger)currentAnnotationIndex{
    _currentAnnotationIndex = currentAnnotationIndex;
    if (addedAnnotationsWithIndex.count > 0){
        currentAnnotationIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)(currentAnnotationIndex + 1),(unsigned long)addedAnnotationsWithIndex.count];
    }else{
        currentAnnotationIndexLabel.text = @"";
    }
    
    
    /*
     if (currentAnnotationIndex == 0) {
     firstButton.enabled = NO;
     previousButton.enabled = NO;
     
     playButton.enabled = YES;
     nextButton.enabled = YES;
     lastButton.enabled = YES;
     
     }else if (currentAnnotationIndex == addedAnnotationsWithIndex.count - 1) {
     
     playButton.enabled = NO;
     nextButton.enabled = NO;
     lastButton.enabled = NO;
     
     firstButton.enabled = YES;
     previousButton.enabled = YES;
     
     }else{
     firstButton.enabled = YES;
     previousButton.enabled = YES;
     playButton.enabled = YES;
     nextButton.enabled = YES;
     lastButton.enabled = YES;
     }
     */
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    MKCoordinateSpan newSpan = mapView.region.span;
    NSLog(@"%@",NSStringFromCGPoint(CGPointMake(newSpan.latitudeDelta, newSpan.longitudeDelta)));
}

@end
