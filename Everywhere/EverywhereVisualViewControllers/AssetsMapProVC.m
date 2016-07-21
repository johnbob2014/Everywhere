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

#import "EverywhereAnnotation.h"
#import "EverywhereSettingManager.h"
#import "EverywhereShareAnnotation.h"
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
#import "MapModeBar.h"
#import "LocationPickerVC.h"
#import "SettingVC.h"
#import "ShareImageVC.h"
#import "ShareShareRepositoryVC.h"
#import "ShareBar.h"
#import "InAppPurchaseVC.h"
#import "ShareRepositoryPickerVC.h"
#import "ShareAnnotationPickerVC.h"

#import "CLPlacemark+Assistant.h"

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"
#import "CoordinateInfo.h"

#import "GCPolyline.h"
#import "GCRoutePolyline.h"
#import "GCRoutePolylineManager.h"

@interface AssetsMapProVC () <MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic) MKMapView *myMapView;

#pragma mark 数据管理器
@property (strong,nonatomic) EverywhereCoreDataManager *cdManager;
@property (strong,nonatomic) EverywhereSettingManager *settingManager;

#pragma mark 用于更新数据
@property (strong,nonatomic) NSArray <PHAssetInfo *> *assetInfoArray;
@property (strong,nonatomic) NSArray <PHAsset *> *assetArray;
@property (strong,nonatomic) NSArray <NSArray <PHAsset *> *> *assetsArray;

@property (strong,nonatomic) NSDate *startDate;
@property (strong,nonatomic) NSDate *endDate;
@property (strong,nonatomic) NSString *lastPlacemark;

#pragma mark 添加的各种Annos
@property (strong,nonatomic) NSArray <id<MKAnnotation>> *addedIDAnnos;
@property (strong,nonatomic) NSArray <EverywhereAnnotation *> *addedEWAnnos;
@property (strong,nonatomic) NSArray <EverywhereShareAnnotation *> *addedEWShareAnnos;
@property (assign,nonatomic) NSInteger currentAnnotationIndex;

#pragma mark 用于模式转换
@property (assign,nonatomic) BOOL isInMainMode;
@property (assign,nonatomic) BOOL allowBrowserMode;
//@property (assign,nonatomic) BOOL allowRecordMode;

@end

@implementation AssetsMapProVC{
    
#pragma mark 用于模式转换时恢复数据
    NSString *savedTitleForMainMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForMainMode;
    NSArray<id<MKOverlay>> *savedOverlaysForMainMode;
    
    NSString *savedTitleForMomentMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForMomentMode;
    NSArray<id<MKOverlay>> *savedOverlaysForMomentMode;
    
    NSString *savedTitleForLocationMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForLocationMode;
    NSArray<id<MKOverlay>> *savedOverlaysForLocationMode;

#pragma mark 用于RecordMode
    CLLocation *lastRecordLocation;
    NSDate *lastRecordDate;
    NSMutableArray <EverywhereShareAnnotation *> *recordedShareAnnos;

#pragma mark 各种Bar
    STPopupController *popupController;
    
    MapModeBar *msMainModeBar;
    MapModeBar *msExtenedModeBar;
    UIButton *quiteBrowserModeButton;
    
    UIView *recordModeBar;
    UIButton *quiteRecordModeButton;
    UIButton *startPauseRecordButton;
    
    LocationInfoBar *locationInfoBar;
    float locationInfoBarHeight;
    BOOL locationInfoBarIsOutOfVisualView;
    
    PlacemarkInfoBar *placemarkInfoBar;
    float placemarkInfoBarHeight;
    BOOL placemarkInfoBarIsHidden;
    
    ShareBar *shareBar;
    
    UIView *leftVerticalBar;
    UIView *rightVerticalBar;
    UIView *rightSwipeVerticalBar;
    BOOL verticalBarIsAlphaZero;
    
#pragma mark 用于导航
    UIView *naviBar;
    UIButton *firstButton;
    UIButton *previousButton;
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *lastButton;
    UILabel *currentAnnotationIndexLabel;
    BOOL isPlaying;
    NSTimer *playTimer;

#pragma mark 用于更新地图
    __block BOOL allPlaceMarkReverseGeocodeSucceedForThisTime;
    __block CLLocationDistance maxDistance;
    __block CLLocationDistance totalDistance;
    __block CLLocationDistance totalArea;
}

#pragma mark - Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    self.cdManager = [EverywhereCoreDataManager defaultManager];
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    // 更新照片数据
    
    NSInteger addedPHAssetInfoCount = [self.cdManager updatePHAssetInfoFromPhotoLibrary];
    
    self.isInMainMode = YES;
    
    [self initMapView];
    
    [self initMapModeBar];
    
    [self initNaviBar];
    
    [self initLocationInfoBar];
    
    // PlacemarkInfoBar 位于 MapModeBar 下方10
    [self initPlacemarkInfoBar];
    
    [self initButtonsAndVerticalAccessoriesBar];
    
    [self initData];
    
    [self initPopupController];
    
    [self initShareBar];
    
    [self showNotification:addedPHAssetInfoCount];
}

- (void)showNotification:(NSInteger)count{
    //if (count > 0){
        UILocalNotification *noti = [UILocalNotification new];
        
        noti.alertBody = [NSString stringWithFormat:@"%@ %lu",NSLocalizedString(@"Add New Photo : ", @"新添加照片 : "),(long)count];
        noti.alertAction = NSLocalizedString(@"Action", @"");
        noti.soundName = UILocalNotificationDefaultSoundName;
        //noti.applicationIconBadgeNumber = count;
        [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
    //}
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    // 更新地址数据
    if (!allPlaceMarkReverseGeocodeSucceedForThisTime) {
        [self.cdManager asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:^(NSInteger reverseGeocodeSucceedCountForThisTime, NSInteger reverseGeocodeSucceedCountForTotal, NSInteger totalPHAssetInfoCount) {
            allPlaceMarkReverseGeocodeSucceedForThisTime = reverseGeocodeSucceedCountForTotal == totalPHAssetInfoCount;
        }];
    }
    
    if (self.isInMainMode) {
        [self updateBarColor:self.settingManager.color];
        
        [self showVerticalBar];
        
        msMainModeBar.alpha = 1;
        naviBar.alpha = 1;
        locationInfoBar.alpha = 1;
        shareBar.alpha = 0;
        
    }
}

- (void)updateBarColor:(UIColor *)newColor{
    locationInfoBar.backgroundColor = newColor;
    placemarkInfoBar.backgroundColor = newColor;
    naviBar.backgroundColor = newColor;
    shareBar.backgroundColor = newColor;
    
    msMainModeBar.contentViewBackgroundColor = newColor;
    msExtenedModeBar.contentViewBackgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
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
/*
#pragma mark - Photo Data

- (void)updatePhotoData{
    if (!self.photoManager) return;
    
    if (!self.cdManager.lastUpdateDate) {
        // 首次加载照片数据
        [self updateCoreDataFormStartDate:nil toEndDate:nil];
    }else{
        // 更新照片数据
        [self updateCoreDataFormStartDate:self.cdManager.lastUpdateDate toEndDate:nil];
    }
    
    // 更新刷新时间
    self.cdManager.lastUpdateDate = [NSDate date];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:self.cdManager.appMOC];
        [allAssetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj.reverseGeocodeSucceed boolValue]) {
                [PHAssetInfo updatePlacemarkForAssetInfo:obj];
                //NSLog(@"%@",NSStringFromCGPoint(CGPointMake([obj.latitude_Coordinate_Location doubleValue], [obj.longitude_Coordinate_Location doubleValue])));
                [NSThread sleepForTimeInterval:0.5];
            }
        }];
    });

}

- (void)updateCoreDataFormStartDate:(NSDate *)startDate toEndDate:(NSDate *)endDate{
    NSDate *timeTest = [NSDate date];
    __block NSInteger addPhotosCount = 0;
    
    NSDictionary *dic = [self.photoManager fetchAssetsFormStartDate:startDate toEndDate:endDate fromAssetCollectionIDs:@[self.photoManager.GCAssetCollectionID_UserLibrary]];
    NSArray <PHAsset *> *assetArray = dic[self.photoManager.GCAssetCollectionID_UserLibrary];
    
    [assetArray enumerateObjectsUsingBlock:^(PHAsset *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.location){
            if ([self checkCoordinate:obj.location.coordinate]) {
                
                PHAssetInfo *info = [PHAssetInfo newAssetInfoWithPHAsset:obj inManagedObjectContext:self.cdManager.appMOC];
                addPhotosCount++;
                NSLog(@"%@",info.localIdentifier);
            }
        }
    }];
    NSLog(@"Time : %.3f , Add Photo Count : %ld",[[NSDate date] timeIntervalSinceDate:timeTest],(long)addPhotosCount);
}

- (BOOL)checkCoordinate:(CLLocationCoordinate2D)aCoord{
    
    if (aCoord.latitude > -90 && aCoord.latitude < 90) {
        if (aCoord.longitude > - 180 && aCoord.longitude < 180) {
            return YES;
        }
    }
    
    return NO;
}
*/
#pragma mark - Getter & Setter

- (CLLocationManager *)locationManagerForRecording{
    if (!_locationManagerForRecording){
        
        if (![CLLocationManager locationServicesEnabled]){
            // 系统禁止定位
            if(DEBUGMODE) NSLog(@"CLLocationManager locationServicesDisabled!");
            _locationManagerForRecording = nil;
        }else{
            _locationManagerForRecording = [CLLocationManager new];
            _locationManagerForRecording.delegate = self;
            
            _locationManagerForRecording.distanceFilter = 20;
            _locationManagerForRecording.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManagerForRecording.pausesLocationUpdatesAutomatically = NO;
            _locationManagerForRecording.allowsBackgroundLocationUpdates = YES;
            _locationManagerForRecording.activityType = CLActivityTypeAutomotiveNavigation;
            
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
                [_locationManagerForRecording requestAlwaysAuthorization];
            }else if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
                if(DEBUGMODE) NSLog(@"CLLocationManager Denied or Restricted!");
                _locationManagerForRecording = nil;
            }else if (authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse){
                if(DEBUGMODE) NSLog(@"CLLocationManager AuthorizedWhenInUse");
            }else if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways){
                if(DEBUGMODE) NSLog(@"CLLocationManager AuthorizedAlways");
            }
        }
    }
    return _locationManagerForRecording;
}

- (void)setAssetInfoArray:(NSArray<PHAssetInfo *> *)assetInfoArray{
    if (!assetInfoArray) return;
    
    _assetInfoArray = assetInfoArray;
    
    [self updateMapModeBar];
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
        [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapMainMode:self.settingManager.mapMainMode];
    }
}

- (void)setAssetArray:(NSArray<PHAsset *> *)assetArray{
    if (!assetArray) return;
    
    _assetArray = assetArray;
    switch (self.settingManager.mapMainMode) {
        case MapMainModeMoment:
            self.assetsArray = [GCLocationAnalyser divideLocationsInOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)assetArray mergedDistance:self.settingManager.mergedDistanceForMoment];
            break;
        case MapMainModeLocation:
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
    
    switch (self.settingManager.mapMainMode) {
        case MapMainModeMoment:
            [self addLineOverlaysPro:self.addedEWAnnos];
            break;
        case MapMainModeLocation:
            [self addCircleOverlaysPro:self.addedEWAnnos radius:self.settingManager.mergedDistanceForLocation / 2.0];
            break;
        default:
            break;
    }
    
    // 如果地图已经初始化，才进行更新
    if (self.myMapView) [self updateVisualViewForEWAnnos];
}

- (void)setAddedIDAnnos:(NSArray<id<MKAnnotation>> *)addedIDAnnos{
    _addedIDAnnos = addedIDAnnos;
    // 设置导航序号
    self.currentAnnotationIndex = 0;
}



#pragma mark - Init Interface

#pragma mark MapView

- (void)initMapView{
    self.myMapView = [MKMapView newAutoLayoutView];
    self.myMapView.delegate = self;
    //self.myMapView.showsUserLocation = YES;
    
    [self.view addSubview:self.myMapView];
    [self.myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    //NSLog(@"%@",self.myMapView.gestureRecognizers);
    
    /*
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    longPressGR.minimumPressDuration = 2.0;
    [self.myMapView addGestureRecognizer:longPressGR];
    */
    
    UITapGestureRecognizer *mapViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    mapViewTapGR.delegate = self;
    mapViewTapGR.numberOfTouchesRequired = 3;
    [self.myMapView addGestureRecognizer:mapViewTapGR];
    
    
    //NSLog(@"%@",self.myMapView.gestureRecognizers);
}

- (void)mapViewTapGR:(id)sender{
    /*
    if (verticalBarIsAlphaZero) [self showVerticalBar];
    else [self hideVerticalBar];
     */
    self.settingManager.hasPurchasedRecord = !self.settingManager.hasPurchasedRecord;
    self.settingManager.hasPurchasedShare = !self.settingManager.hasPurchasedShare;
}

/*
//UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}
*/

#pragma mark ModeBar

- (void)initMapModeBar{
    WEAKSELF(weakSelf);
    
    msMainModeBar = [[MapModeBar alloc]initWithModeSegItems:[NSLocalizedString(@"MomentMode LocationMode",@"") componentsSeparatedByString:@" "]
                                                selectedSegIndex:self.settingManager.mapMainMode
                                                 leftButtonImage:[UIImage imageNamed:@"IcoMoon_Calendar"]
                                                rightButtonImage:[UIImage imageNamed:@"IcoMoon_Dribble3"]];
    msMainModeBar.modeSegEnabled = YES;
    
    [self.view addSubview:msMainModeBar];
    [msMainModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msMainModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msMainModeBar.mapMainModeChangedHandler = ^(UISegmentedControl *sender){
        // 记录当前地图模式
        weakSelf.settingManager.mapMainMode = sender.selectedSegmentIndex;
        [weakSelf changeToMainMode:sender.selectedSegmentIndex];
    };
    
    msMainModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        [weakSelf showDatePicker];
    };
    
    msMainModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        [weakSelf showLocationPicker];
    };
    
    msExtenedModeBar = [[MapModeBar alloc]initWithModeSegItems:[NSLocalizedString(@"BrowserMode RecordMode",@"") componentsSeparatedByString:@" "]
                                                    selectedSegIndex:self.settingManager.mapExtendedMode
                                                     leftButtonImage:[UIImage imageNamed:@"IcoMoon_DrawerFull"]
                                                    rightButtonImage:[UIImage imageNamed:@"IcoMoon_DrawerEmpty"]];
    
    
    [self.view addSubview:msExtenedModeBar];
    [msExtenedModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msExtenedModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msExtenedModeBar.mapMainModeChangedHandler = ^(UISegmentedControl *sender){
        weakSelf.settingManager.mapExtendedMode = sender.selectedSegmentIndex;
        // 扩展模式切换
        if (sender.selectedSegmentIndex == MapExtendedModeBrowser) {
            [weakSelf enterBrowserMode];
        }else{
            [weakSelf enterRecordMode];
        }
    };
    
    msExtenedModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        if (weakSelf.settingManager.hasPurchasedShare) [weakSelf showShareRepositoryPicker];
        else [weakSelf showPurchaseShareFunctionAlertController];
    };
    
    msExtenedModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        if (weakSelf.settingManager.hasPurchasedRecord) [weakSelf showShareAnnotationPicker];
        else [weakSelf showPurchaseRecordFunctionAlertController];
    };
    
    msExtenedModeBar.hidden = YES;
    //msShareEditModeBar.modeSegEnabled = NO;

}

- (void)changeToMainMode:(MapMainMode)mapMainMode{
    // 保存现有数据
    if (mapMainMode == MapMainModeMoment) {
        // 保存LocationMode数据
        savedTitleForLocationMode = msMainModeBar.info;
        savedAnnotationsForLocationMode = self.addedEWAnnos;
        savedOverlaysForLocationMode = self.myMapView.overlays;
    }else{
        // 保存MomentMode数据
        savedTitleForMomentMode = msMainModeBar.info;
        savedAnnotationsForMomentMode = self.addedEWAnnos;
        savedOverlaysForMomentMode = self.myMapView.overlays;
    }
    
    [self clearMapData];
    
    // 恢复之前的数据
    if (mapMainMode == MapMainModeMoment){
        // 恢复MomentMode数据
        msMainModeBar.info = savedTitleForMomentMode;
        self.addedEWAnnos = savedAnnotationsForMomentMode;
        self.addedIDAnnos = savedAnnotationsForMomentMode;
        [self.myMapView addAnnotations:self.addedEWAnnos];
        [self.myMapView addOverlays:savedOverlaysForMomentMode];
    }else{
        // 恢复LocationMode数据
        msMainModeBar.info = savedTitleForLocationMode;
        self.addedEWAnnos = savedAnnotationsForLocationMode;
        self.addedIDAnnos = savedAnnotationsForLocationMode;
        [self.myMapView addAnnotations:self.addedEWAnnos];
        [self.myMapView addOverlays:savedOverlaysForLocationMode];
    }
    
    [self updateVisualViewForEWAnnos];
}

- (void)clearMapData{
    self.assetInfoArray = nil;
    self.assetArray = nil;
    self.assetsArray = nil;
    
    self.addedEWAnnos = nil;
    self.addedEWShareAnnos = nil;
    self.addedIDAnnos = nil;
    
    self.endDate = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.lastPlacemark = @"";
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
}


- (void)updateMapModeBar{
    switch (self.settingManager.mapMainMode) {
        case MapMainModeMoment:
            msMainModeBar.info = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
            break;
        case MapMainModeLocation:
            msMainModeBar.info = self.lastPlacemark;
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
        //settingManager.mapMainMode = MapMainModeMoment;
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
    //shareRepositoryPickerVC.shareRepositoryArray = [EverywhereShareRepositoryManager shareRepositoryArray];
    shareRepositoryPickerVC.shareRepositoryDidChangeHandler = ^(EverywhereShareRepository *choosedShareRepository){
        [weakSelf showShareRepository:choosedShareRepository];
    };
    
    shareRepositoryPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    shareRepositoryPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:shareRepositoryPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showShareAnnotationPicker{
    //WEAKSELF(weakSelf);
    
    ShareAnnotationPickerVC *shareAnnotationPickerVC = [ShareAnnotationPickerVC new];
    shareAnnotationPickerVC.shareAnnos = recordedShareAnnos;
    shareAnnotationPickerVC.shareAnnotationsDidChangeHandler = ^(NSArray <EverywhereShareAnnotation *> *changedShareAnnos){
        
    };
    
    shareAnnotationPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    shareAnnotationPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:shareAnnotationPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

#pragma mark Navigation Bar
#define NaviBarButtonSize CGSizeMake(30, 30)
#define NaviBarButtonOffset ScreenWidth > 320 ? 30 : 15

- (void)initNaviBar{
    
    naviBar = [UIView newAutoLayoutView];
    
    [self.view addSubview:naviBar];
    [naviBar autoSetDimension:ALDimensionHeight toSize:44];
    [naviBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 20, 5) excludingEdge:ALEdgeTop];
    
    firstButton = [UIButton newAutoLayoutView];
    [firstButton setImage:[UIImage imageNamed:@"IcoMoon_Arrow-Left_WBG"] forState:UIControlStateNormal];
    firstButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [firstButton addTarget:self action:@selector(firstButtonPressed:) forControlEvents:UIControlEventTouchDown];
    firstButton.alpha = 0.6;
    [naviBar addSubview:firstButton];
    [firstButton autoSetDimensionsToSize:NaviBarButtonSize];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [firstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    //[firstButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    previousButton = [UIButton newAutoLayoutView];
    [previousButton setImage:[UIImage imageNamed:@"IcoMoon_Arrow-Top_WBG"] forState:UIControlStateNormal];
    previousButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [previousButton addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
    previousButton.alpha = 0.6;
    [naviBar addSubview:previousButton];
    [previousButton autoSetDimensionsToSize:NaviBarButtonSize];
    [previousButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:firstButton withOffset:NaviBarButtonOffset];
    [previousButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    playButton = [UIButton newAutoLayoutView];
    [playButton setImage:[UIImage imageNamed:@"IcoMoon_Play-Rect_WBG"] forState:UIControlStateNormal];
    playButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [playButton addTarget:self action:@selector(playButtonPressed:) forControlEvents:UIControlEventTouchDown];
    playButton.alpha = 0.6;
    [naviBar addSubview:playButton];
    [playButton autoSetDimensionsToSize:NaviBarButtonSize];
    [playButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousButton withOffset:NaviBarButtonOffset];
    [playButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    nextButton = [UIButton newAutoLayoutView];
    [nextButton setImage:[UIImage imageNamed:@"IcoMoon_Arrow-Bottom_WBG"] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
    nextButton.alpha = 0.6;
    [naviBar addSubview:nextButton];
    [nextButton autoSetDimensionsToSize:NaviBarButtonSize];
    [nextButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:playButton withOffset:NaviBarButtonOffset];
    [nextButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    lastButton = [UIButton newAutoLayoutView];
    [lastButton setImage:[UIImage imageNamed:@"IcoMoon_Arrow-Right_WBG"] forState:UIControlStateNormal];
    lastButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [lastButton addTarget:self action:@selector(lastButtonPressed:) forControlEvents:UIControlEventTouchDown];
    lastButton.alpha = 0.6;
    [naviBar addSubview:lastButton];
    [lastButton autoSetDimensionsToSize:NaviBarButtonSize];
    [lastButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:nextButton withOffset:NaviBarButtonOffset];
    [lastButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    currentAnnotationIndexLabel = [UILabel newAutoLayoutView];
    currentAnnotationIndexLabel.textColor = [UIColor whiteColor];
    [naviBar addSubview:currentAnnotationIndexLabel];
    [currentAnnotationIndexLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [currentAnnotationIndexLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    //[currentAnnotationIndexLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:lastButton withOffset:10];
    
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
        //[sender setTitle:@"▶️" forState:UIControlStateNormal];
        [playTimer invalidate];
        playTimer = nil;
    }else{
        // 开始播放
        //[sender setTitle:@"⏸" forState:UIControlStateNormal];
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
    
    if (msMainModeBar.alpha || placemarkInfoBar.alpha) {
        [UIView animateWithDuration:0.2 animations:^{
            msMainModeBar.alpha = 0;
            placemarkInfoBar.alpha = 0;
        }];
    }
    
    if (!msExtenedModeBar.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            msExtenedModeBar.alpha = 0;
            quiteBrowserModeButton.alpha = 0;
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
                                      msMainModeBar.alpha = 1;
                                      placemarkInfoBar.alpha = 1;
                                  }];
                                  
                                  if (!msExtenedModeBar.hidden) {
                                      [UIView animateWithDuration:0.2 animations:^{
                                          msExtenedModeBar.alpha = 1;
                                          quiteBrowserModeButton.alpha = 0.6;
                                      }];
                                  }

                              }];
    
}

#pragma mark Placemark Info Bar

- (void)initPlacemarkInfoBar{
    placemarkInfoBarHeight = 80;
    placemarkInfoBar = [PlacemarkInfoBar newAutoLayoutView];
    [self.view addSubview:placemarkInfoBar];
    [placemarkInfoBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msMainModeBar withOffset:10];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [placemarkInfoBar autoSetDimension:ALDimensionHeight toSize:placemarkInfoBarHeight];
    
    NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
    [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapMainMode:self.settingManager.mapMainMode];
}

- (void)updatePlacemarkInfoBarWithPlacemarkDictionary:(NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkDictionary mapMainMode:(enum MapMainMode)mapMainMode{
    // 更新统计信息
   
    placemarkInfoBar.countryCount = placemarkDictionary[kCountryArray].count;
    placemarkInfoBar.administrativeAreaCount = placemarkDictionary[kAdministrativeAreaArray].count;
    placemarkInfoBar.localityCount = placemarkDictionary[kLocalityArray].count;
    placemarkInfoBar.subLocalityCount = placemarkDictionary[kSubLocalityArray].count;
    placemarkInfoBar.thoroughfareCount = placemarkDictionary[kThoroughfareArray].count;
    
    switch (mapMainMode) {
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
    [leftBtn2 addTarget:self action:@selector(showHideMapModeBar) forControlEvents:UIControlEventTouchDown];
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
    [leftBtn4 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Play_WBG"] forState:UIControlStateNormal];
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
    [rightBtn1 autoSetDimensionsToSize:ButtionSize];
    [rightBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
    
    UIButton *rightBtn2 = [UIButton newAutoLayoutView];
    rightBtn2.alpha = 0.6;
    [rightBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share2_WBG"] forState:UIControlStateNormal];
    rightBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn2 addTarget:self action:@selector(showShareShareRepositoryVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn2];
    [rightBtn2 autoSetDimensionsToSize:ButtionSize];
    [rightBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn1 withOffset:16];
    
    UIButton *rightBtn3 = [UIButton newAutoLayoutView];
    rightBtn3.alpha = 0.6;
    [rightBtn3 setBackgroundImage:[UIImage imageNamed:@"ExtendedMode"] forState:UIControlStateNormal];
    rightBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn3 addTarget:self action:@selector(intelligentlyEnterExtendedMode) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn3];
    [rightBtn3 autoSetDimensionsToSize:ButtionSize];
    [rightBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn2 withOffset:16];
    
#pragma mark quiteBrowserModeButton
    quiteBrowserModeButton = [UIButton newAutoLayoutView];
    quiteBrowserModeButton.alpha = 0.6;
    [quiteBrowserModeButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    quiteBrowserModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quiteBrowserModeButton addTarget:self action:@selector(showQuiteBrowserModeAlertController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:quiteBrowserModeButton];
    [quiteBrowserModeButton autoSetDimensionsToSize:ButtionSize];
    [quiteBrowserModeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msExtenedModeBar withOffset:10];
    [quiteBrowserModeButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    quiteBrowserModeButton.hidden = YES;

#pragma mark recordModeBar
    recordModeBar = [UIView newAutoLayoutView];
    recordModeBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:recordModeBar];
    [recordModeBar autoSetDimensionsToSize:CGSizeMake(ButtonPlaceholderHeight * 2, ButtionEdgeLength)];
    [recordModeBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msExtenedModeBar withOffset:10];
    [recordModeBar autoAlignAxisToSuperviewAxis:ALAxisVertical];
    recordModeBar.hidden = YES;
    
    quiteRecordModeButton = [UIButton newAutoLayoutView];
    quiteRecordModeButton.alpha = 0.6;
    [quiteRecordModeButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    quiteRecordModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quiteRecordModeButton addTarget:self action:@selector(showQuiteRecordModeAlertController) forControlEvents:UIControlEventTouchDown];
    [recordModeBar addSubview:quiteRecordModeButton];
    [quiteRecordModeButton autoSetDimensionsToSize:ButtionSize];
    [quiteRecordModeButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [quiteRecordModeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:8];
    
    startPauseRecordButton = [UIButton newAutoLayoutView];
    startPauseRecordButton.alpha = 0.6;
    [startPauseRecordButton setBackgroundImage:[UIImage imageNamed:@"Paused"] forState:UIControlStateNormal];
    startPauseRecordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [startPauseRecordButton addTarget:self action:@selector(startPauseRecord) forControlEvents:UIControlEventTouchDown];
    [recordModeBar addSubview:startPauseRecordButton];
    [startPauseRecordButton autoSetDimensionsToSize:ButtionSize];
    [startPauseRecordButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [startPauseRecordButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:8];
    
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

- (void)showHideMapModeBar{
    [UIView animateWithDuration:0.3 animations:^{
        msMainModeBar.alpha = (msMainModeBar.alpha == 1) ? 0 : 1;
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
    shareBar.rightImage = [UIImage imageNamed:@"1136142337"];
    shareBar.rightText = NSLocalizedString(@"ScanToDL", @"扫描下载");
    [self.view addSubview:shareBar];
    [shareBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [shareBar autoSetDimension:ALDimensionHeight toSize:150];
    //[shareBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view withMultiplier:0.2];
}

#pragma mark Data

- (void)initData{
    switch (self.settingManager.mapMainMode) {
        case MapMainModeMoment:{
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
        case MapMainModeLocation:{
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
    msMainModeBar.alpha = 0;
    placemarkInfoBar.alpha = 0;
    naviBar.alpha = 0;
    locationInfoBar.alpha = 0;
    
    NSMutableString *ms = [NSMutableString new];
    
    if (self.settingManager.mapMainMode == MapMainModeMoment) {
        NSString *dateString = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
        if (dateString) [ms appendFormat:@"%@ ",dateString];
        [ms appendString:NSLocalizedString(@"I have my footprints over ", @"我的足迹遍布 ")];
    }else{
        [ms appendString:NSLocalizedString(@"I have been in ", @"我到了 ")];
        [ms appendFormat:@"%@",self.lastPlacemark];
        [ms appendString:NSLocalizedString(@" for ", @" 的 ")];
    }
    
    if (placemarkInfoBar.countryCount > 1) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.countryCount];
        [ms appendString:NSLocalizedString(@" States,", @"xx个国家,")];
    }
    if (placemarkInfoBar.administrativeAreaCount > 1) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.administrativeAreaCount];
        [ms appendString:NSLocalizedString(@" Prov.s,", @"xx个省,")];//AdministrativeAreas
    }
    if (placemarkInfoBar.localityCount > 1){
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.localityCount];
        [ms appendString:NSLocalizedString(@" Cities,", @"xx个市,")];
    }
    if (placemarkInfoBar.subLocalityCount > 1) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.subLocalityCount];
        [ms appendString:NSLocalizedString(@" Dist.s,", @"xx个县区,")];//SubLocalities
    }
    if (placemarkInfoBar.thoroughfareCount > 1) {
        [ms appendFormat:@"%ld",(long)placemarkInfoBar.thoroughfareCount];
        [ms appendString:NSLocalizedString(@" St.s", @"xx个村镇街道")];//Thoroughfares
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

#pragma mark - Purchase Alert Controllers

- (void)showPurchaseAllFunctionsAlertController{
    NSString *alertTitle = NSLocalizedString(@"Can not enter extended mode",@"无法进入扩展模式");
    NSString *alertMessage = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Please choose a purchase item", @"请选择购买项目")];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *purchaseShareFunctionAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase Share Function",@"购买 分享功能")
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            [self showPurchaseShareFunctionAlertController];
                                                                        }];
    UIAlertAction *purchaseRecordFunctionAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase footprints Record Function",@"购买 足迹记录功能")
                                                                           style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             [self showPurchaseRecordFunctionAlertController];
                                                                         }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:purchaseShareFunctionAction];
    [alertController addAction:purchaseRecordFunctionAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPurchaseShareFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"Purchase Share Function",@"购买分享功能");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Share your footprints to others", @"1.将足迹分享给他人"),NSLocalizedString(@"2.Store footprints shared by others and lookup anytime", @"2.存储足迹，并实时查看"),NSLocalizedString(@"Cost $0.99,continue?", @"价格6元，是否购买？")];
    
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:0];
}

- (void)showPurchaseRecordFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"Purchase Record Function",@"购买足迹记录功能");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Record your footprints", @"1.记录你的运动足迹"),NSLocalizedString(@"2.Smart edit your footprints", @"2.足迹智能编辑"),NSLocalizedString(@"Cost $0.99,continue?", @"价格6元，是否购买？")];
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:1];
}

- (void)showPurchaseAlertControllerWithTitle:(NSString *)title message:(NSString *)message productIndex:(NSInteger)productIndex{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self showPurchaseVC:productIndex];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPurchaseVC:(NSInteger)productIndex{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    inAppPurchaseVC.transactionType = TransactionTypePurchase;
    inAppPurchaseVC.productIndex = productIndex;
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

#pragma mark - Extended Mode

#pragma mark Share and Receive

- (void)showShareShareRepositoryVC{
    // 如果没有分享功能
    if (!self.settingManager.hasPurchasedShare) {
        [self showPurchaseShareFunctionAlertController];
        return;
    }
    
    if (!self.addedEWShareAnnos) return;
    
    // 生成分享对象
    EverywhereShareRepository *shareRepository = [EverywhereShareRepository new];
    shareRepository.shareAnnos = self.addedEWShareAnnos;
    if (self.settingManager.mapMainMode == MapMainModeMoment) shareRepository.radius = 0;
    else shareRepository.radius = self.settingManager.mergedDistanceForLocation / 2.0;
    shareRepository.creationDate = NOW;
    shareRepository.shareRepositoryType = ShareRepositoryTypeSended;
    
    if (self.settingManager.mapMainMode == MapMainModeMoment) shareRepository.title = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
    else shareRepository.title = self.lastPlacemark;
    
    ShareShareRepositoryVC *ssVC = [ShareShareRepositoryVC new];
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

- (void)didReceiveShareRepositoryString:(NSString *)receivedString{
    NSString *shareRepositoryString = nil;
    //CLLocationDistance sharedRadius = 0;
    
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",WXAppID];
    
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
    shareRepository.shareRepositoryType = ShareRepositoryTypeReceived;
    
    // 新接收到，先保存shareRepository，如果用户选择丢弃，再删除掉
    [EverywhereShareRepositoryManager addShareRepository:shareRepository];
    if (DEBUGMODE) NSLog(@"shareRepositoryArray count : %lu",(unsigned long)[EverywhereShareRepositoryManager shareRepositoryArray].count);
    
    // 显示主界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *alertTitle = NSLocalizedString(@"Receive Shared Footprints",@"收到分享的足迹");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@ %lu %@%@",shareRepository.title,NSLocalizedString(@"There are", @"该足迹共有"),(unsigned long)shareRepository.shareAnnos.count,NSLocalizedString(@"footprints.", @"个足迹点，"), NSLocalizedString(@"Would you like to accept the footprints and enter Browser Mode?", @"是否接收足迹并进入浏览模式？")];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [self enterExtendedMode];
                                                         // 注意这里
                                                         // 不要使用[self enterBrowserMode];
                                                         // msExtenedModeBar是扩展模式转换控制器，它来调用enterBrowserMode 和 enterRecordMode 方法
                                                         msExtenedModeBar.selectedSegmentIndex = 0;
                                                         [self enterBrowserMode];
                                                         [self showShareRepository:shareRepository];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Enter Quite Mode

- (void)intelligentlyEnterExtendedMode{
    if (!self.settingManager.hasPurchasedShare && !self.settingManager.hasPurchasedRecord) {
        [self showPurchaseAllFunctionsAlertController];
        return;
    }
    
    /*
    if (!self.settingManager.hasPurchasedShare) {
        self.settingManager.mapExtendedMode = MapExtendedModeRecord;
        self.allowBrowserMode = NO;
    }
    
    if (!self.settingManager.hasPurchasedRecord) {
        self.settingManager.mapExtendedMode = MapExtendedModeBrowser;
        self.allowRecordMode = NO;
    }
    */
    
    [self enterExtendedMode];
    
    if (self.settingManager.mapExtendedMode == MapExtendedModeBrowser) [self enterBrowserMode];
    else [self enterRecordMode];
}

- (void)enterExtendedMode{
    if(DEBUGMODE) NSLog(@"进入扩展模式");
    self.isInMainMode = NO;
    
    // 保存MainMode数据
    savedTitleForMainMode = msMainModeBar.info;
    savedAnnotationsForMainMode = self.addedEWAnnos;
    savedOverlaysForMainMode = self.myMapView.overlays;
    
    // 清理MainMode地图
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    self.addedEWShareAnnos = nil;
    self.addedIDAnnos = nil;

    msMainModeBar.hidden = YES;
    placemarkInfoBar.hidden = YES;
    leftVerticalBar.hidden = YES;
    rightVerticalBar.hidden = YES;
    
    msExtenedModeBar.hidden = NO;
    
    naviBar.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
    locationInfoBar.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
    
}

- (void)quiteExtendedMode{
    msMainModeBar.hidden = NO;
    placemarkInfoBar.hidden = NO;
    leftVerticalBar.hidden = NO;
    rightVerticalBar.hidden = NO;
    
    msExtenedModeBar.hidden = YES;
    
    naviBar.backgroundColor = self.settingManager.color;
    locationInfoBar.backgroundColor = self.settingManager.color;
    
    // 清理Extended Mode地图
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    self.addedEWShareAnnos = nil;
    
    // 恢复Main Mode地图
    msMainModeBar.info = savedTitleForMainMode;
    [self.myMapView addAnnotations:savedAnnotationsForMainMode];
    [self.myMapView addOverlays:savedOverlaysForMainMode];
    self.addedIDAnnos = savedAnnotationsForMainMode;
    
    [self updateVisualViewForEWAnnos];
    
    self.isInMainMode = YES;
    if(DEBUGMODE) NSLog(@"退出扩展模式");
}

- (void)enterBrowserMode{
    
    [self quiteRecordMode];
    if(DEBUGMODE) NSLog(@"进入浏览模式");
    
    quiteBrowserModeButton.hidden = NO;
    
}

- (void)showShareRepository:(EverywhereShareRepository *)shareRepository{
    // 清理地图
    self.addedEWAnnos = nil;
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    
    // 添加接收到的ShareAnnotations
    [self.myMapView addAnnotations:shareRepository.shareAnnos];
    
    // 设置addedIDAnnos，用于导航
    self.addedIDAnnos = shareRepository.shareAnnos;
    self.addedEWShareAnnos = shareRepository.shareAnnos;
    
    // 添加Overlays
    if (shareRepository.radius == 0){
        // 时刻模式 分享的足迹
        [self addLineOverlaysPro:shareRepository.shareAnnos];
    }else{
        // 地点模式 分享的足迹
        [self addCircleOverlaysPro:shareRepository.shareAnnos radius:shareRepository.radius];
    }
    
    [self updateVisualViewForEWShareAnnos];
}

- (void)showQuiteBrowserModeAlertController{
    
    if (self.settingManager.hasPurchasedShare) {
        // 如果已经购买了分享功能，直接退出（内容已经保存），不再询问
        [self quiteBrowserMode];
        [self quiteExtendedMode];
        return;
    }
    
    NSString *alertTitle = NSLocalizedString(@"Quite Extended Mode",@"退出扩展模式");
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
                                                               [self showPurchaseVC:0];
                                                           }];
    UIAlertAction *dropAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Drop",@"丢弃")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           // 用户选择丢弃，则删除保存的shareRepository
                                                           [EverywhereShareRepositoryManager removeLastAddedShareRepository];
                                                           [self quiteBrowserMode];
                                                           [self quiteExtendedMode];
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:purchaseAction];
    [alertController addAction:dropAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)quiteBrowserMode{
    if(DEBUGMODE) NSLog(@"退出浏览模式");
    quiteBrowserModeButton.hidden = YES;
    
}

- (void)enterRecordMode{
    
    [self quiteBrowserMode];
    if(DEBUGMODE) NSLog(@"进入记录模式");
    
    msExtenedModeBar.leftButtonEnabled = NO;
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];

    naviBar.hidden = YES;
    recordModeBar.hidden = NO;
    self.myMapView.showsUserLocation = YES;

    // 重置记录数据
    self.isRecording = NO;
    lastRecordLocation = nil;
    lastRecordDate = nil;
    recordedShareAnnos = [NSMutableArray new];

}

- (void)startPauseRecord{
    if (!self.settingManager.hasPurchasedRecord){
        [self showPurchaseRecordFunctionAlertController];
        return;
    }
    
    self.isRecording = !self.isRecording;
}

- (void)setIsRecording:(BOOL)isRecording{
    _isRecording = isRecording;
    if (self.isRecording) {
        // 开始记录
        if(DEBUGMODE) NSLog(@"开始记录");
        [self.locationManagerForRecording startUpdatingLocation];
        
        msExtenedModeBar.info = NSLocalizedString(@"Recording", @"记录中");
        self.allowBrowserMode = NO;
        
        [startPauseRecordButton setBackgroundImage:[UIImage imageNamed:@"Recording"] forState:UIControlStateNormal];
        
    }else{
        // 暂停记录
        msExtenedModeBar.info = NSLocalizedString(@"Paused", @"已暂停");
        if(DEBUGMODE) NSLog(@"暂停记录");
        [self.locationManagerForRecording stopUpdatingLocation];
        
        //msExtenedModeBar.modeSegEnabled = YES;
        [startPauseRecordButton setBackgroundImage:[UIImage imageNamed:@"Paused"] forState:UIControlStateNormal];
    }
}

- (void)setAllowBrowserMode:(BOOL)allowBrowserMode{
    _allowBrowserMode = allowBrowserMode;
    if (allowBrowserMode) {
        if(DEBUGMODE) NSLog(@"允许BrowserMode");
        msExtenedModeBar.modeSegEnabled = YES;
        msExtenedModeBar.leftButtonEnabled = YES;
    }else{
        if(DEBUGMODE) NSLog(@"禁止BrowserMode");
        msExtenedModeBar.modeSegEnabled = NO;
        msExtenedModeBar.leftButtonEnabled = NO;
    }
}

/*
- (void)setAllowRecordMode:(BOOL)allowRecordMode{
    _allowRecordMode = allowRecordMode;
    if (allowRecordMode) {
        if(DEBUGMODE) NSLog(@"允许RecordMode");
        msExtenedModeBar.modeSegEnabled = YES;
        msExtenedModeBar.rightButtonEnabled = YES;
    }else{
        if(DEBUGMODE) NSLog(@"禁止RecordMode");
        msExtenedModeBar.modeSegEnabled = NO;
        msExtenedModeBar.rightButtonEnabled = NO;
    }
}
*/

- (void)showQuiteRecordModeAlertController{
    
    if (!recordedShareAnnos || recordedShareAnnos.count == 0){
        self.allowBrowserMode = YES;
        [self quiteRecordMode];
        [self quiteExtendedMode];
        return;
    }
    
    NSString *alertTitle = NSLocalizedString(@"Quite Extended Mode",@"退出扩展模式");
    NSString *alertMessage = NSLocalizedString(@"Save the recorded footprints?", @"是否保存足迹?");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
     UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save",@"保存")
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self intelligentlySaveRecordedShareAnnos];
                                                             self.allowBrowserMode = YES;
                                                             [self quiteRecordMode];
                                                             [self quiteExtendedMode];
                                                         }];
    UIAlertAction *dropAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Drop",@"丢弃")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           self.allowBrowserMode = YES;
                                                           [self quiteRecordMode];
                                                           [self quiteExtendedMode];
                                                       }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:saveAction];
    [alertController addAction:dropAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)quiteRecordMode{
    
    msExtenedModeBar.leftButtonEnabled = YES;
    
    naviBar.hidden = NO;
    recordModeBar.hidden = YES;
    
    self.myMapView.showsUserLocation = NO;
    
    //[self intelligentlySaveRecordedShareAnnos];
    if(DEBUGMODE) NSLog(@"退出记录模式");
}

// 智能保存
- (void)intelligentlySaveRecordedShareAnnos{
    if (!recordedShareAnnos || recordedShareAnnos.count == 0) return;
    
    //if (recordedShareAnnos.count > 1){}
    EverywhereShareRepository *shareRepository = [EverywhereShareRepository new];
    shareRepository.shareAnnos = recordedShareAnnos;
    shareRepository.creationDate = NOW;
    shareRepository.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Record", @"记录"),[shareRepository.creationDate stringWithDefaultFormat]];
    shareRepository.shareRepositoryType = ShareRepositoryTypeRecorded;
    
    [EverywhereShareRepositoryManager addShareRepository:shareRepository];
    if(DEBUGMODE) NSLog(@"记录已经保存");
    
    // 设置保存为空
    recordedShareAnnos = nil;
}

/*
- (void)changeToExtendedMode:(MapExtendedMode)mapExtendedMode{
    if (mapExtendedMode == MapExtendedModeBrowser) {
        [self enterBrowserMode];
    }else{
        [self enterRecordMode];
    }
}
*/

#pragma mark - Add Annotations And Overlays

- (void)addAnnotations{
    // 清理数组
    self.addedEWAnnos = nil;
    self.addedEWShareAnnos = nil;
    NSMutableArray <EverywhereAnnotation *> *annotationsToAdd = [NSMutableArray new];
    NSMutableArray <EverywhereShareAnnotation *> *shareAnnotationsToAdd = [NSMutableArray new];
    // 添加 MKAnnotations
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    
    [self.assetsArray enumerateObjectsUsingBlock:^(NSArray<PHAsset *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EverywhereAnnotation *anno = [EverywhereAnnotation new];
        PHAsset *firstAsset = obj.firstObject;
        PHAsset *lastAsset = obj.lastObject;
        anno.location = firstAsset.location;
        
        if (self.settingManager.mapMainMode == MapMainModeMoment) {
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
        
        EverywhereShareAnnotation *shareAnno = [EverywhereShareAnnotation new];
        shareAnno.annotationCoordinate = firstAsset.location.coordinate;
        shareAnno.startDate = firstAsset.creationDate;
        if (self.settingManager.mapMainMode == MapMainModeLocation) shareAnno.endDate = lastAsset.creationDate;
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
                /*
                CLLocationCoordinate2D points[2];
                points[0] = lastCoordinate;
                points[1] = obj.coordinate;
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:points count:2];
                //polyline.title = [NSString stringWithFormat:@"MKPolyline : %lu",(unsigned long)idx];
                */
                
                MKPolyline *polyline = [AssetsMapProVC createLineMKPolylineBetweenStartCoordinate:lastCoordinate endCoordinate:obj.coordinate];
                [polylinesToAdd addObject:polyline];
                
                CLLocationDistance subDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
                if (maxDistance < subDistance) maxDistance = subDistance;
                totalDistance += subDistance;
                [distanceArray addObject:[NSNumber numberWithDouble:subDistance]];
                
                /*
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
                 */
                
                MKPolygon *polygon = [AssetsMapProVC createArrowMKPolygonBetweenStartCoordinate:lastCoordinate endCoordinate:obj.coordinate];
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

+ (MKPolyline *)createLineMKPolylineBetweenStartCoordinate:(CLLocationCoordinate2D)startCoord endCoordinate:(CLLocationCoordinate2D)endCoord{
    CLLocationCoordinate2D coordinates[2];
    coordinates[0] = startCoord;
    coordinates[1] = endCoord;
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:2];
    return polyline;
}

+ (MKPolygon *)createArrowMKPolygonBetweenStartCoordinate:(CLLocationCoordinate2D)startCoord endCoordinate:(CLLocationCoordinate2D)endCoord{
    MKMapPoint start_MP = MKMapPointForCoordinate(startCoord);
    MKMapPoint end_MP = MKMapPointForCoordinate(endCoord);
    
    MKMapPoint x_MP,y_MP,z_MP;
    CLLocationDistance arrowLength =  MKMetersBetweenMapPoints(MKMapPointForCoordinate(startCoord), MKMapPointForCoordinate(endCoord));

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
    return polygon;
}


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
            
            [self.addedEWAnnos enumerateObjectsUsingBlock:^(EverywhereAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)updateVisualViewForEWAnnos{
    // 自己的
    if (self.addedEWAnnos.count > 0) {
        
        [self updateMapModeBar];
        NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
        [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapMainMode:self.settingManager.mapMainMode];
        
        if (self.settingManager.mapMainMode == MapMainModeLocation){
            maxDistance = self.settingManager.mergedDistanceForLocation * 8.0;
        }
    
        // 移动地图到第一个点
        NSLog(@"self.addedEWAnnos.count : %lu",(unsigned long)self.addedEWAnnos.count);
    
        EverywhereAnnotation *firstAnnotation = self.addedEWAnnos.firstObject;
        MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstAnnotation.coordinate, maxDistance, maxDistance);
        [self.myMapView setRegion:showRegion animated:NO];
        [self.myMapView selectAnnotation:firstAnnotation animated:YES];
    }
    
}

- (void)updateVisualViewForEWShareAnnos{
    // 分享的
    if (self.addedEWShareAnnos.count > 0) {
        NSLog(@"self.addedEWShareAnnos.count : %lu",(unsigned long)self.addedEWShareAnnos.count);
        //NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
        //[self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapMainMode:self.settingManager.mapMainMode];
        
        EverywhereShareAnnotation *firstShareAnnotation = self.addedEWShareAnnos.firstObject;
        
        if (self.addedEWShareAnnos.count > 1) {
            EverywhereShareAnnotation *secondShareAnnotation = self.addedEWShareAnnos[1];
            maxDistance = fabs(MKMetersBetweenMapPoints(MKMapPointForCoordinate(firstShareAnnotation.coordinate), MKMapPointForCoordinate(secondShareAnnotation.coordinate))) * 8.0;
        }
        
        MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstShareAnnotation.coordinate, maxDistance, maxDistance);
        [self.myMapView setRegion:showRegion animated:NO];
        [self.myMapView selectAnnotation:firstShareAnnotation animated:YES];
    }

}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[EverywhereAnnotation class]]) {
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
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:((EverywhereAnnotation *)annotation).assetLocalIdentifiers options:options].firstObject;
        if (asset) imageView.image = [asset synchronousFetchUIImageAtTargetSize:CGSizeMake(80, 80)];
        
        UIButton *badgeButton = [UIButton newAutoLayoutView];
        badgeButton.userInteractionEnabled = NO;
        [badgeButton setBackgroundImage:[UIImage imageNamed:@"badge"] forState:UIControlStateNormal];
        [badgeButton setTitle:[NSString stringWithFormat:@"%ld",(long)((EverywhereAnnotation *)annotation).assetCount] forState:UIControlStateNormal];
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
        
    }else if ([annotation isKindOfClass:[EverywhereShareAnnotation class]]){
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
    EverywhereAnnotation *annotation = self.myMapView.selectedAnnotations.firstObject;
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
        if ([view.annotation isKindOfClass:[EverywhereAnnotation class]]) {
            EverywhereAnnotation *anno = (EverywhereAnnotation *)view.annotation;
            
            PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
            if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
            
            [self updateLocationInfoBarWithAssetInfo:assetInfo];
        }else if ([view.annotation isKindOfClass:[EverywhereShareAnnotation class]]){
            EverywhereShareAnnotation *shareAnno = (EverywhereShareAnnotation *)view.annotation;
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
    [mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    self.currentAnnotationIndex = [self.addedIDAnnos indexOfObject:view.annotation];
    
    if ([view.annotation isKindOfClass:[EverywhereAnnotation class]]) {
        //self.currentAnnotationIndex = [self.addedEWAnnos indexOfObject:view.annotation];
        
        EverywhereAnnotation *anno = (EverywhereAnnotation *)view.annotation;
        PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
        if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
        
        [self updateLocationInfoBarWithAssetInfo:assetInfo];
        
    }else if ([view.annotation isKindOfClass:[EverywhereShareAnnotation class]]){
        EverywhereShareAnnotation *shareAnno = (EverywhereShareAnnotation *)view.annotation;
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (!lastRecordLocation) {
        lastRecordLocation = locations.lastObject;
        lastRecordDate = NOW;
        [self addRecordedShareAnnosWithLocation:lastRecordLocation];
    }
    
    CLLocation *currentLocation = locations.lastObject;
    // 满足最小记录距离条件
    if ([currentLocation distanceFromLocation:lastRecordLocation] > self.settingManager.shortestDistanceForRecord) {
        // 满足最小记录时间条件
        if([NOW timeIntervalSinceDate:lastRecordDate] > self.settingManager.shortestTimeIntervalForRecord){
            [self addRecordedShareAnnosWithLocation:currentLocation];
            
            // 记录新足迹点后，再更新
            lastRecordLocation = currentLocation;
            lastRecordDate = NOW;
        }
       
    }
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)addRecordedShareAnnosWithLocation:(CLLocation *)newLocation{
    EverywhereShareAnnotation *shareAnno = [EverywhereShareAnnotation new];
    shareAnno.annotationCoordinate = newLocation.coordinate;
    shareAnno.startDate = NOW;
    shareAnno.customTitle = [NSString stringWithFormat:@"Footprint %u",recordedShareAnnos.count + 1];
    [recordedShareAnnos addObject:shareAnno];
    [self.myMapView addAnnotation:shareAnno];
    
    if (recordedShareAnnos.count > 1){
        //NSInteger lastIndex = [recordedShareAnnos indexOfObject:shareAnno];
        EverywhereShareAnnotation *lastAnno = recordedShareAnnos[recordedShareAnnos.count - 2];
        [self.myMapView addOverlay:[AssetsMapProVC createLineMKPolylineBetweenStartCoordinate:lastAnno.coordinate endCoordinate:shareAnno.coordinate]];
        [self.myMapView addOverlay:[AssetsMapProVC createArrowMKPolygonBetweenStartCoordinate:lastAnno.coordinate endCoordinate:shareAnno.coordinate]];
    }
}



@end
