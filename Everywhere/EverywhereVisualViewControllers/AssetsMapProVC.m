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

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"

#import "GCPolyline.h"
#import "GCRoutePolyline.h"
#import "GCRoutePolylineManager.h"

@interface AssetsMapProVC () <MKMapViewDelegate,UIGestureRecognizerDelegate>
//@property (assign,nonatomic) MapShowMode mapShowMode;
//@property (assign,nonatomic) CLLocationDistance nearestDistanceForMoment;
//@property (assign,nonatomic) CLLocationDistance nearestDistanceForLocation;
@property (strong,nonatomic) NSArray <PHAssetInfo *> *assetInfoArray;
@property (strong,nonatomic) NSArray <PHAsset *> *assetArray;
@property (strong,nonatomic) NSArray <NSArray <PHAsset *> *> *assetsArray;
@property (assign,nonatomic) NSInteger currentAnnotationIndex;
@end

@implementation AssetsMapProVC{
    STPopupController *popupController;
    
    MKMapView *myMapView;
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
    
    NSDate *startDate;
    NSDate *endDate;
    
    GCPhotoManager *photoManager;
    EverywhereCoreDataManager *cdManager;
    EverywhereSettingManager *settingManager;
    
    __block CLLocationDistance maxDistance;
    __block CLLocationDistance totalDistance;
    __block CLLocationDistance totalArea;
}

#pragma mark - Getter & Setter

- (void)setAssetInfoArray:(NSArray<PHAssetInfo *> *)assetInfoArray{
    _assetInfoArray = assetInfoArray;
    
    switch (settingManager.mapShowMode) {
        case MapShowModeMoment:
            mapShowModeBar.info = [[startDate stringWithFormat:@"yyyy-MM-dd ~ "] stringByAppendingString:[endDate stringWithFormat:@"yyyy-MM-dd"]];
            break;
        case MapShowModeLocation:
            mapShowModeBar.info = @"中国";
            break;
        default:
            break;
    }
    // 只有当存在照片数据的时候，才更新视图
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
    switch (settingManager.mapShowMode) {
        case MapShowModeMoment:
            self.assetsArray = [GCLocationAnalyser divideLocationsInOrderToArray:self.assetArray nearestDistance:settingManager.nearestDistanceForMoment];
            break;
        case MapShowModeLocation:
            self.assetsArray = [GCLocationAnalyser divideLocationsOutOfOrderToArray:self.assetArray nearestDistance:settingManager.nearestDistanceForLocation];
            break;
        default:
            break;
    }
}

- (void)setAssetsArray:(NSArray<NSArray<PHAsset *> *> *)assetsArray{
    _assetsArray = assetsArray;
    
    [self addAnnotations];
    
    switch (settingManager.mapShowMode) {
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
    if (myMapView) [self updateVisualViewAfterAddAnnotationsAndOverlays];
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    photoManager = [GCPhotoManager defaultManager];
    cdManager = [EverywhereCoreDataManager defaultManager];
    settingManager = [EverywhereSettingManager defaultManager];
    
    [self initMapView];
    
    [self initData];
    
    [self initMapShowModeBar];
    
    [self initNaviBar];
    
    [self initLocationInfoBar];
    
    // PlacemarkInfoBar 位于 MapShowModeBar 下方10
    [self initPlacemarkInfoBar];
    
    [self initVerticalAccessories];

    [self initPopupController];
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        locationInfoBarHeight = 150;
        locationInfoBar.frame = CGRectMake(0, -locationInfoBarHeight, ScreenWidth , locationInfoBarHeight);
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        locationInfoBarHeight = 90;
        locationInfoBar.frame = CGRectMake(0, -locationInfoBarHeight, ScreenHeight , locationInfoBarHeight);
    }
}

/*
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    
}
*/

#pragma mark - Init Interface

#pragma mark MapView

- (void)initMapView{
    myMapView = [MKMapView newAutoLayoutView];
    myMapView.delegate = self;
    //myMapView.showsUserLocation = YES;
    
    [self.view addSubview:myMapView];
    [myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    //NSLog(@"%@",myMapView.gestureRecognizers);
    
    UITapGestureRecognizer *mapViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    mapViewTapGR.delegate = self;
    //[myMapView addGestureRecognizer:mapViewTapGR];
    
    //NSLog(@"%@",myMapView.gestureRecognizers);
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
    mapShowModeBar.mapShowMode = settingManager.mapShowMode;
    mapShowModeBar.info = [[startDate stringWithFormat:@"yyyy-MM-dd ~ "] stringByAppendingString:[endDate stringWithFormat:@"yyyy-MM-dd"]];
    
    __weak AssetsMapProVC *weakSelf = self;
    mapShowModeBar.mapShowModeChangedHandler = ^(UISegmentedControl *sender){
        [EverywhereSettingManager defaultManager].mapShowMode = sender.selectedSegmentIndex;
    };
    
    mapShowModeBar.datePickerTouchDownHandler = ^(UIButton *sender) {
        [weakSelf showDatePicker];
    };
    
    mapShowModeBar.locaitonPickerTouchDownHandler = ^(UIButton *sender){
        [weakSelf showLocationPicker];
    };
}

- (void)showDatePicker{
    DatePickerVC *datePickerVC = [DatePickerVC new];
    datePickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    datePickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    
    datePickerVC.dateModeChangedHandler = ^(DateMode choosedDateMode){
        [EverywhereSettingManager defaultManager].dateMode = choosedDateMode;
    };
    
    datePickerVC.dateRangeChangedHandler = ^(NSDate *choosedStartDate,NSDate *choosedEndDate){
        //settingManager.mapShowMode = MapShowModeMoment;
        startDate = choosedStartDate;
        endDate = choosedEndDate;
        self.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:startDate toEndDate:endDate inManagedObjectContext:cdManager.appMOC];
    };
    
    popupController = [[STPopupController alloc] initWithRootViewController:datePickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showLocationPicker{
    LocationPickerVC *locationPickerVC = [LocationPickerVC new];
    NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:cdManager.appMOC];
    locationPickerVC.placemarkInfoDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:allAssetInfoArray];
    locationPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    locationPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 200);
    
    locationPickerVC.locationDidChangeHandler = ^(NSString *choosedLocation){
        self.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:choosedLocation inManagedObjectContext:cdManager.appMOC];
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
    [firstButton addTarget:self action:@selector(firstButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:firstButton];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    previousButton = [UIButton newAutoLayoutView];
    [previousButton setTitle:@"⬅️" forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:previousButton];
    [previousButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:firstButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [previousButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setTitle:@"▶️" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:playButton];
    [playButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [playButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    nextButton = [UIButton newAutoLayoutView];
    [nextButton setTitle:@"➡️" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:nextButton];
    [nextButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:playButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [nextButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    lastButton = [UIButton newAutoLayoutView];
    [lastButton setTitle:@"⏩" forState:UIControlStateNormal];
    [lastButton addTarget:self action:@selector(lastButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:lastButton];
    [lastButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:nextButton withOffset:30 relation:NSLayoutRelationLessThanOrEqual];
    [lastButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    currentAnnotationIndexLabel = [UILabel newAutoLayoutView];
    currentAnnotationIndexLabel.textColor = [UIColor whiteColor];
    [naviBar addSubview:currentAnnotationIndexLabel];
    [currentAnnotationIndexLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [currentAnnotationIndexLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:lastButton];
    [currentAnnotationIndexLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastButton withOffset:10 relation:NSLayoutRelationGreaterThanOrEqual];
    self.currentAnnotationIndex = 0;
    isPlaying = NO;
}

- (void)firstButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = addedAnnotationsWithIndex.firstObject;
    [myMapView setCenterCoordinate:ida.coordinate animated:YES];
    [myMapView selectAnnotation:ida animated:YES];
}

- (void)previousButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = myMapView.selectedAnnotations.firstObject;
    if (!ida && self.currentAnnotationIndex) {
        ida = addedAnnotationsWithIndex[self.currentAnnotationIndex];
    }
    if (ida) {
        NSInteger index = [addedAnnotationsWithIndex indexOfObject:ida];
        if (--index >= 0) {
            [myMapView deselectAnnotation:ida animated:YES];
            ida = addedAnnotationsWithIndex[index];
            [myMapView setCenterCoordinate:ida.coordinate animated:YES];
            [myMapView selectAnnotation:ida animated:YES];
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
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(nextButtonPressed:) userInfo:nil repeats:YES];
    }
    isPlaying = !isPlaying;
}

- (void)nextButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = myMapView.selectedAnnotations.firstObject;
    if (!ida && self.currentAnnotationIndex) {
        ida = addedAnnotationsWithIndex[self.currentAnnotationIndex];
    }
    if (ida) {
        NSInteger index = [addedAnnotationsWithIndex indexOfObject:ida];
        if (++index < addedAnnotationsWithIndex.count) {
            [myMapView deselectAnnotation:ida animated:YES];
            ida = addedAnnotationsWithIndex[index];
            
            [myMapView setCenterCoordinate:ida.coordinate animated:YES];
            [myMapView selectAnnotation:ida animated:YES];
        }
        if (index == addedAnnotationsWithIndex.count) {
            [self playButtonPressed:playButton];
        }
    }
}

- (void)lastButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = addedAnnotationsWithIndex.lastObject;
    [myMapView setCenterCoordinate:ida.coordinate animated:YES];
    [myMapView selectAnnotation:ida animated:YES];
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
    locationInfoBar = [[LocationInfoBar alloc] initWithFrame:CGRectMake(0, -locationInfoBarHeight, ScreenWidth , locationInfoBarHeight)];
    [self.view addSubview:locationInfoBar];
    [locationInfoBar setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    locationInfoBarIsHidden = YES;
    
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [locationInfoBar addGestureRecognizer:swipeUpGR];
}

- (void)swipeUp:(UISwipeGestureRecognizer *)sender{
    [self hideLocationInfoBar];
}

- (void)showLocationInfoBar{
    placemarkInfoBar.hidden = YES;
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.4 animations:^{
                                      locationInfoBar.frame = CGRectMake(0, 20 + 10, ScreenWidth, locationInfoBarHeight);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.3 animations:^{
                                      locationInfoBar.frame = CGRectMake(0, 20, ScreenWidth, locationInfoBarHeight);
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
                                      locationInfoBar.frame = CGRectMake(0, 20 + 10, ScreenWidth, locationInfoBarHeight);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.4 animations:^{
                                      locationInfoBar.frame = CGRectMake(0, -locationInfoBarHeight, ScreenWidth , locationInfoBarHeight);
                                  }];
                                  
                              }
                              completion:^(BOOL finished) {
                                  locationInfoBarIsHidden = YES;
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
    [placemarkInfoBar setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    placemarkInfoBar.hidden = YES;
    
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
    
    switch (settingManager.mapShowMode) {
        case 0:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Distance", @"");
            placemarkInfoBar.totalDistance = totalDistance;
        }
            break;
        case 1:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Area", @"");
            totalArea = addedAnnotationsWithIndex.count * M_PI * sqrt(settingManager.nearestDistanceForLocation);
            placemarkInfoBar.totalArea = totalArea;
        }
            break;
        default:
            break;
    }

}

#pragma mark Vertical Accessories

- (void)initVerticalAccessories{
    
    UIButton *placemarkInfoBarBtn = [UIButton newAutoLayoutView];
    [placemarkInfoBarBtn setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    placemarkInfoBarBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [placemarkInfoBarBtn addTarget:self action:@selector(showHidePlacemarkInfoBar:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:placemarkInfoBarBtn];
    [placemarkInfoBarBtn autoSetDimensionsToSize:CGSizeMake(40, 40)];
    [placemarkInfoBarBtn autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:80];
    [placemarkInfoBarBtn autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    
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

- (void)showHidePlacemarkInfoBar:(UIButton *)sender{
    placemarkInfoBar.hidden = !placemarkInfoBar.hidden;
    
    
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
    
    switch (settingManager.dateMode) {
        case DateModeDay:{
            startDate = [now dateAtStartOfToday];
            endDate = [now dateAtEndOfToday];
        }
            break;
        case DateModeWeek:{
            startDate = [now dateAtStartOfThisWeek];
            endDate = [now dateAtEndOfThisWeek];
        }
            break;
        case DateModeMonth:{
            startDate = [now dateAtStartOfThisMonth];
            endDate = [now dateAtEndOfThisMonth];
        }
            break;
        case DateModeYear:{
            startDate = [now dateAtStartOfThisYear];
            endDate = [now dateAtEndOfThisYear];
        }
            break;
        case DateModeAll:{
            startDate = nil;
            endDate = nil;
        }
            break;
        default:{
            startDate = [now dateAtStartOfThisMonth];
            endDate = [now dateAtEndOfThisMonth];
        }
            break;
    }
    
    switch (settingManager.mapShowMode) {
        case MapShowModeMoment:
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:startDate toEndDate:endDate inManagedObjectContext:cdManager.appMOC];
            break;
        case MapShowModeLocation:
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:settingManager.defaultPlacemark inManagedObjectContext:cdManager.appMOC];
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
    [myMapView removeAnnotations:myMapView.annotations];
    
    [self.assetsArray enumerateObjectsUsingBlock:^(NSArray<PHAsset *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = obj.firstObject;
        NSMutableArray *ids = [NSMutableArray new];
        [obj enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ids addObject:obj.localIdentifier];
        }];
        EverywhereMKAnnotation *anno = [EverywhereMKAnnotation new];
        anno.location = asset.location;
        anno.annotationTitle = [asset.creationDate stringWithDefaultFormat];
        anno.assetLocalIdentifiers = ids;
        [annotationsToAdd addObject:anno];
        [myMapView addAnnotation:anno];
    }];
    
    if (!annotationsToAdd || !annotationsToAdd.count) return;
    //[myMapView addAnnotations:annotationsToAdd];
    addedAnnotationsWithIndex = annotationsToAdd;
}

- (void)addLineOverlays{
    [myMapView removeOverlays:myMapView.overlays];
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
        [myMapView addOverlays:polylinesToAdd];
        [myMapView addOverlays:polygonsToAdd];
    }
}

- (void)addCircleOverlays{
    [myMapView removeOverlays:myMapView.overlays];
    
    if (addedAnnotationsWithIndex.count >= 1) {
        
        // 添加 MKOverlays
        
        NSMutableArray <MKCircle *> *circlesToAdd = [NSMutableArray new];
        
        [addedAnnotationsWithIndex enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:obj.coordinate radius:settingManager.nearestDistanceForLocation / 2.0];
            if (circle) [circlesToAdd addObject:circle];
        }];
        
        [myMapView addOverlays:circlesToAdd];
    }
}

- (void)asyncAddRouteOverlays{
    [myMapView removeOverlays:myMapView.overlays];
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
                            [myMapView addOverlay:foundedRP.polyline];
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
                                if(routePolyline) [myMapView addOverlay:routePolyline];
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
    
    [self updatePlacemarkInfoBar];
    
    if (settingManager.mapShowMode == MapShowModeLocation){
        maxDistance = settingManager.nearestDistanceForLocation * 4.0;
    }
    
    // 移动地图到第一个点
    if (addedAnnotationsWithIndex.count > 0) {
        EverywhereMKAnnotation *firstAnnotation = addedAnnotationsWithIndex.firstObject;
        MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstAnnotation.coordinate, maxDistance, maxDistance);
        [myMapView setRegion:showRegion animated:YES];
        [myMapView selectAnnotation:firstAnnotation animated:YES];
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
        MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinAV"];
        if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAV"];
        pinAV.pinColor = MKPinAnnotationColorPurple;
        pinAV.animatesDrop = YES;
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
        if (asset) imageView.image = [PHAsset synchronousFetchUIImageFromPHAsset:asset targetSize:CGSizeMake(80, 80)];
        
        //UIButton *transparentButton = [UIButton newAutoLayoutView];
        
        
        UIButton *badgeButton = [UIButton newAutoLayoutView];
        badgeButton.userInteractionEnabled = NO;
        [badgeButton setBackgroundImage:[UIImage imageNamed:@"badge"] forState:UIControlStateNormal];
        [badgeButton setTitle:[NSString stringWithFormat:@"%ld",(long)((EverywhereMKAnnotation *)annotation).assetCount] forState:UIControlStateNormal];
        badgeButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [imageView addSubview:badgeButton];
        [badgeButton autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        pinAV.leftCalloutAccessoryView = imageView;
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
    EverywhereMKAnnotation *annotation = myMapView.selectedAnnotations.firstObject;
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
        
        PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:cdManager.appMOC];
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
    PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:cdManager.appMOC];
    if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
    [self updateLocationInfoBarWithAssetInfo:assetInfo];
}

- (void)setCurrentAnnotationIndex:(NSInteger)currentAnnotationIndex{
    _currentAnnotationIndex = currentAnnotationIndex;
    currentAnnotationIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",currentAnnotationIndex + 1,(unsigned long)addedAnnotationsWithIndex.count];
    
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

@end
