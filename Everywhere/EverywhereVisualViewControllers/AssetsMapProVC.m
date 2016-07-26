//
//  AssetsMapProVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
#define DEBUGMODE 1

#import "AssetsMapProVC.h"
@import Photos;
@import MapKit;

#import "EverywhereAppDelegate.h"

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
#import "LocationInfoWithCoordinateInfoBar.h"
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
#import "ShareRepositoryEditerVC.h"
#import "WGS84TOGCJ02.h"
#import "CLPlacemark+Assistant.h"
#import "RecordModeSettingBar.h"

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"
#import "CoordinateInfo.h"

#import "GCPolyline.h"
#import "GCRoutePolyline.h"
#import "GCRoutePolylineManager.h"

@interface AssetsMapProVC () <MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic) MKMapView *myMapView;
@property (assign,nonatomic) ShowUserLocationMode showUserLocationMode;
@property (strong,nonatomic) CLLocation *userLocationWGS84;
@property (strong,nonatomic) CLLocation *userLocationGCJ02;

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
@property (assign,nonatomic) BOOL isInBaseMode;
@property (assign,nonatomic) BOOL isInRecordMode;
@property (assign,nonatomic) BOOL allowBrowserMode;
//@property (assign,nonatomic) BOOL allowRecordMode;

#pragma mark 用于Record模式的用户设置
@property (assign,nonatomic) CLLocationDistance minDistanceForRecord;
@property (assign,nonatomic) NSTimeInterval minTimeIntervalForRecord;
@end

@implementation AssetsMapProVC{
    
    UIButton *userLocationButton;
    
#pragma mark 用于模式转换时恢复数据
    NSString *savedTitleForBaseMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForBaseMode;
    NSArray<id<MKAnnotation>> *savedShareAnnotationsForBaseMode;
    NSArray<id<MKOverlay>> *savedOverlaysForBaseMode;
    
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
    
    MapModeBar *msBaseModeBar;
    MapModeBar *msExtenedModeBar;
    UIButton *quiteBrowserModeButton;
    
    UIView *recordModeBar;
    UIButton *startPauseRecordButton;
    UILabel *velocityLabel;
    
    LocationInfoWithCoordinateInfoBar *locationInfoWithCoordinateInfoBar;
    float locationInfoWithCoordinateInfoBarHeight;
    BOOL locationInfoWithCoordinateInfoBarIsOutOfVisualView;
    
    PlacemarkInfoBar *placemarkInfoBar;
    float placemarkInfoBarHeight;
    BOOL placemarkInfoBarIsHidden;
    
    ShareBar *shareBar;
    
    UIView *leftVerticalBar;
    UIView *rightVerticalBar;
    UIView *rightSwipeVerticalBar;
    BOOL verticalBarIsAlphaZero;
    
    RecordModeSettingBar *recordModeSettingBar;
    
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
    
    NSNumber *addedPHAssetInfoCountNumber = @([self.cdManager updatePHAssetInfoFromPhotoLibrary]);
    
    self.isInBaseMode = YES;
    
    // 以下顺序不要打乱！！！！！！
    
    [self initMapView];
    
    [self initMapModeBar];
    
    [self initNaviBar];
    
    [self initLocationInfoWithCoordinateInfoBar];
    
    // PlacemarkInfoBar 位于 MapModeBar 下方10
    [self initPlacemarkInfoBar];
    
    [self initVerticalBars];
    
    [self initQuiteBrowserModeButton];
    
    [self initRecordModeBar];
    
    // RecordModeSettingBar 位于 RecordModeBar 下方10
    [self initRecordModeSettingBar];
    
    [self initData];
    
    [self initPopupController];
    
    [self initShareBar];
    
    [self performSelector:@selector(showNotification:) withObject:addedPHAssetInfoCountNumber afterDelay:3.0];
    //[self showNotification:addedPHAssetInfoCount];
}

- (void)showNotification:(NSNumber *)countNumber{
    NSInteger count = [countNumber integerValue];
    if (count > 0){
        UILocalNotification *noti = [UILocalNotification new];
        NSString *message = [NSString stringWithFormat:@"%@ %lu",NSLocalizedString(@"Add New Photo Count: ", @"新添加照片数量 : "),(long)count];
        noti.alertBody = message;
        noti.alertAction = NSLocalizedString(@"Action", @"");
        noti.soundName = UILocalNotificationDefaultSoundName;
        //noti.applicationIconBadgeNumber = count;
        [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
        
        [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"", @"") message:message]
                           animated:YES
                         completion:nil];
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    
    // 更新地址数据
    if (!allPlaceMarkReverseGeocodeSucceedForThisTime) {
        [self.cdManager asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:^(NSInteger reverseGeocodeSucceedCountForThisTime, NSInteger reverseGeocodeSucceedCountForTotal, NSInteger totalPHAssetInfoCount) {
            allPlaceMarkReverseGeocodeSucceedForThisTime = reverseGeocodeSucceedCountForTotal == totalPHAssetInfoCount;
        }];
    }
    
    EverywhereAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    if (self.isInBaseMode) {
        [self updateBarColor:self.settingManager.baseTintColor];
        
        if (verticalBarIsAlphaZero) [self alphaShowHideVerticalBar];
        
        msBaseModeBar.alpha = 1;
        naviBar.alpha = 1;
        locationInfoWithCoordinateInfoBar.alpha = 1;
        shareBar.alpha = 0;
        
        appDelegate.window.tintColor = self.settingManager.baseTintColor;
        
    }else{
        appDelegate.window.tintColor = self.settingManager.extendedTintColor;
    }
    
}

- (void)updateBarColor:(UIColor *)newColor{
    locationInfoWithCoordinateInfoBar.backgroundColor = newColor;
    placemarkInfoBar.backgroundColor = newColor;
    naviBar.backgroundColor = newColor;
    shareBar.backgroundColor = newColor;
    
    msBaseModeBar.contentViewBackgroundColor = newColor;
    msExtenedModeBar.contentViewBackgroundColor = self.settingManager.extendedTintColor;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        locationInfoWithCoordinateInfoBarHeight = 150;
        locationInfoWithCoordinateInfoBar.frame = CGRectMake(5, -locationInfoWithCoordinateInfoBarHeight - 40, ScreenWidth - 10 , locationInfoWithCoordinateInfoBarHeight);
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        locationInfoWithCoordinateInfoBarHeight = 90;
        locationInfoWithCoordinateInfoBar.frame = CGRectMake(5, -locationInfoWithCoordinateInfoBarHeight - 40, ScreenHeight - 10, locationInfoWithCoordinateInfoBarHeight);
    }
}


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
            _locationManagerForRecording.pausesLocationUpdatesAutomatically = NO;
            _locationManagerForRecording.activityType = CLActivityTypeAutomotiveNavigation;
            if(iOS9) _locationManagerForRecording.allowsBackgroundLocationUpdates = YES;
            
            // 此项根据用户设置自动调整，以节省电量
            _locationManagerForRecording.desiredAccuracy = kCLLocationAccuracyBest;
            
            CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
            if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [_locationManagerForRecording requestAlwaysAuthorization];
                });
                
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

// ⭕️实时更新locationInfoWithCoordinateInfoBar位置信息
- (void)setUserLocationWGS84:(CLLocation *)userLocationWGS84{
    _userLocationWGS84 = userLocationWGS84;
    locationInfoWithCoordinateInfoBar.userCoordinateWGS84 = userLocationWGS84.coordinate;
    CLLocationSpeed velocitymPerSecond = userLocationWGS84.speed;
    CLLocationSpeed velocitykmPerhour = velocitymPerSecond * 3600.0 / 1000.0;
    velocityLabel.text = [NSString stringWithFormat:@"%.2fkm/h %.2fm/s",velocitykmPerhour,velocitymPerSecond];
}

- (void)setUserLocationGCJ02:(CLLocation *)userLocationGCJ02{
    _userLocationGCJ02 = userLocationGCJ02;
    //locationInfoWithCoordinateInfoBar.userCoordinateWGS84 = userLocationGCJ02.coordinate;
}

- (CLLocationDistance)minDistanceForRecord{
    if (_minDistanceForRecord == 0) {
        _minDistanceForRecord = self.settingManager.minDistanceForRecord;
    }
    return _minDistanceForRecord;
}

- (NSTimeInterval)minTimeIntervalForRecord{
    if (_minTimeIntervalForRecord) {
        _minTimeIntervalForRecord = self.settingManager.minTimeIntervalForRecord;
    }
    return _minTimeIntervalForRecord;
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
        [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapBaseMode:self.settingManager.mapBaseMode];
    }
}

- (void)setAssetArray:(NSArray<PHAsset *> *)assetArray{
    if (!assetArray) return;
    
    _assetArray = assetArray;
    switch (self.settingManager.mapBaseMode) {
        case MapBaseModeMoment:
            self.assetsArray = [GCLocationAnalyser divideLocationsInOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)assetArray mergeDistance:self.settingManager.mergeDistanceForMoment];
            break;
        case MapBaseModeLocation:
            self.assetsArray = [GCLocationAnalyser divideLocationsOutOfOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)assetArray mergeDistance:self.settingManager.mergeDistanceForLocation];
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
    
    switch (self.settingManager.mapBaseMode) {
        case MapBaseModeMoment:
            [self addLineOverlaysPro:self.addedEWAnnos];
            break;
        case MapBaseModeLocation:
            [self addCircleOverlaysPro:self.addedEWAnnos radius:self.settingManager.mergeDistanceForLocation / 2.0];
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
    self.myMapView.rotateEnabled = NO;
    
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
    mapViewTapGR.numberOfTouchesRequired = 1;
    [self.myMapView addGestureRecognizer:mapViewTapGR];
    
    /*
    UITapGestureRecognizer *mapViewDoubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewDoubleTapGR:)];
    mapViewDoubleTapGR.delegate = self;
    mapViewDoubleTapGR.numberOfTouchesRequired = 2;
    [self.myMapView addGestureRecognizer:mapViewDoubleTapGR];
    
    UITapGestureRecognizer *mapViewThreeTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewThreeTapGR:)];
    mapViewThreeTapGR.delegate = self;
    mapViewThreeTapGR.numberOfTouchesRequired = 3;
    [self.myMapView addGestureRecognizer:mapViewThreeTapGR];
*/
    //NSLog(@"%@",self.myMapView.gestureRecognizers);
}

- (void)mapViewTapGR:(id)sender{
    [self alphaShowHideVerticalBar];
    self.settingManager.praiseCount++;
    NSLog(@"praiseCount : %lu",(long)self.settingManager.praiseCount);
    if (self.settingManager.praiseCount == 60) {
        [self askForPraise];
        self.settingManager.praiseCount = 0;
    }
}

- (void)askForPraise{
    NSString *alertTitle = NSLocalizedString(@"AlbumMaps", @"相册地图");
    NSString *alertMessage = NSLocalizedString(@"Praise me , please!", @"没有广告是不是很清爽？作者也不容易，抽空给个好评呗！🙏");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"去给好评") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:AppDownloadURLString]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"残忍拒绝") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    alertController.preferredAction = okAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)mapViewThreeTapGR:(id)sender{
    //self.settingManager.hasPurchasedRecord = !self.settingManager.hasPurchasedRecord;
    //self.settingManager.hasPurchasedShare = !self.settingManager.hasPurchasedShare;
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
    
    msBaseModeBar = [[MapModeBar alloc]initWithModeSegItems:[NSLocalizedString(@"MomentMode LocationMode",@"") componentsSeparatedByString:@" "]
                                                selectedSegIndex:self.settingManager.mapBaseMode
                                                 leftButtonImage:[UIImage imageNamed:@"IcoMoon_Calendar"]
                                                rightButtonImage:[UIImage imageNamed:@"IcoMoon_Dribble3"]];
    msBaseModeBar.modeSegEnabled = YES;
    
    [self.view addSubview:msBaseModeBar];
    [msBaseModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msBaseModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msBaseModeBar.mapBaseModeChangedHandler = ^(UISegmentedControl *sender){
        // 记录当前地图模式
        weakSelf.settingManager.mapBaseMode = sender.selectedSegmentIndex;
        [weakSelf changeToBaseMode:sender.selectedSegmentIndex];
    };
    
    msBaseModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        [weakSelf showDatePicker];
    };
    
    msBaseModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        [weakSelf showLocationPicker];
    };
    
    msExtenedModeBar = [[MapModeBar alloc]initWithModeSegItems:[NSLocalizedString(@"BrowserMode RecordMode",@"") componentsSeparatedByString:@" "]
                                                    selectedSegIndex:self.settingManager.mapExtendedMode
                                                     leftButtonImage:[UIImage imageNamed:@"IcoMoon_DrawerFull"]
                                                    rightButtonImage:[UIImage imageNamed:@"IcoMoon_DrawerEmpty"]];
    
    
    [self.view addSubview:msExtenedModeBar];
    [msExtenedModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msExtenedModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msExtenedModeBar.mapBaseModeChangedHandler = ^(UISegmentedControl *sender){
        weakSelf.settingManager.mapExtendedMode = sender.selectedSegmentIndex;
        // 扩展模式切换
        if (sender.selectedSegmentIndex == MapExtendedModeBrowser) {
            [weakSelf enterBrowserMode];
        }else{
            [weakSelf enterRecordMode];
        }
    };
    
    msExtenedModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        if (weakSelf.settingManager.hasPurchasedShare && weakSelf.settingManager.hasPurchasedRecord) [weakSelf showShareRepositoryPickerAllType];
        else if (weakSelf.settingManager.hasPurchasedShare) [weakSelf showShareRepositoryPickerSendedReceived];
        else [weakSelf showPurchaseShareFunctionAlertController];
    };
    
    msExtenedModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        if (weakSelf.settingManager.hasPurchasedShare && weakSelf.settingManager.hasPurchasedRecord) [weakSelf showShareRepositoryPickerAllType];
        else if (weakSelf.settingManager.hasPurchasedRecord) [weakSelf showShareRepositoryPickerRecordedEdited];
        else [weakSelf showPurchaseRecordFunctionAlertController];
    };
    
    msExtenedModeBar.hidden = YES;
    //msShareEditModeBar.modeSegEnabled = NO;

}

- (void)changeToBaseMode:(MapBaseMode)mapBaseMode{
    // 保存现有数据
    if (mapBaseMode == MapBaseModeMoment) {
        // 保存LocationMode数据
        savedTitleForLocationMode = msBaseModeBar.info;
        savedAnnotationsForLocationMode = self.addedEWAnnos;
        savedOverlaysForLocationMode = self.myMapView.overlays;
    }else{
        // 保存MomentMode数据
        savedTitleForMomentMode = msBaseModeBar.info;
        savedAnnotationsForMomentMode = self.addedEWAnnos;
        savedOverlaysForMomentMode = self.myMapView.overlays;
    }
    
    [self clearMapData];
    
    // 恢复之前的数据
    if (mapBaseMode == MapBaseModeMoment){
        // 恢复MomentMode数据
        msBaseModeBar.info = savedTitleForMomentMode;
        self.addedEWAnnos = savedAnnotationsForMomentMode;
        self.addedIDAnnos = savedAnnotationsForMomentMode;
        [self.myMapView addAnnotations:self.addedEWAnnos];
        [self.myMapView addOverlays:savedOverlaysForMomentMode];
    }else{
        // 恢复LocationMode数据
        msBaseModeBar.info = savedTitleForLocationMode;
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
    switch (self.settingManager.mapBaseMode) {
        case MapBaseModeMoment:
            msBaseModeBar.info = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
            break;
        case MapBaseModeLocation:
            msBaseModeBar.info = self.lastPlacemark;
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
        //settingManager.mapBaseMode = MapBaseModeMoment;
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

- (void)showShareRepositoryPickerAllType{
    [self showShareRepositoryPicker:ShareRepositoryTypeSended|ShareRepositoryTypeReceived|ShareRepositoryTypeRecorded|ShareRepositoryTypeEdited];
}

- (void)showShareRepositoryPickerSendedReceived{
    [self showShareRepositoryPicker:ShareRepositoryTypeSended|ShareRepositoryTypeReceived];
}

- (void)showShareRepositoryPickerRecordedEdited{
    [self showShareRepositoryPicker:ShareRepositoryTypeRecorded|ShareRepositoryTypeEdited];
}

- (void)showShareRepositoryPicker:(NSUInteger)showShareRepositoryType{
    WEAKSELF(weakSelf);
    
    ShareRepositoryPickerVC *shareRepositoryPickerVC = [ShareRepositoryPickerVC new];
    shareRepositoryPickerVC.showShareRepositoryType = showShareRepositoryType;
    shareRepositoryPickerVC.shareRepositoryDidChangeHandler = ^(EverywhereShareRepository *choosedShareRepository){
        [weakSelf showShowShareRepositoryAlertController:choosedShareRepository];
    };
    
    shareRepositoryPickerVC.contentSizeInPopup = CGSizeMake(300, 400);
    shareRepositoryPickerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:shareRepositoryPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

/*
- (void)showShareAnnotationPicker{
    //WEAKSELF(weakSelf);
    
    ShareRepositoryEditerVC *shareRepositoryEditerVC = [ShareRepositoryEditerVC new];
    shareRepositoryEditerVC.shareRepository = nil;
    
    shareRepositoryEditerVC.contentSizeInPopup = CGSizeMake(300, 400);
    shareRepositoryEditerVC.landscapeContentSizeInPopup = CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:shareRepositoryEditerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}
*/
#pragma mark Navigation Bar
#define NaviBarButtonSize CGSizeMake(30, 30)
#define NaviBarButtonOffset ScreenWidth > 375 ? 30 : 15

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
    
    if (!idAnno) idAnno = self.addedIDAnnos.firstObject;
    
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

- (void)initLocationInfoWithCoordinateInfoBar{
    locationInfoWithCoordinateInfoBarHeight = 170;
    locationInfoWithCoordinateInfoBar = [[LocationInfoWithCoordinateInfoBar alloc] initWithFrame:CGRectMake(5, -locationInfoWithCoordinateInfoBarHeight - 40, ScreenWidth - 10, locationInfoWithCoordinateInfoBarHeight)];
    [self.view addSubview:locationInfoWithCoordinateInfoBar];
    locationInfoWithCoordinateInfoBarIsOutOfVisualView = YES;
    
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(locationInfoWithCoordinateInfoBarSwipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [locationInfoWithCoordinateInfoBar addGestureRecognizer:swipeUpGR];
    
    
    WEAKSELF(weakSelf);
    locationInfoWithCoordinateInfoBar.didGetMKDirectionsResponseHandler = ^(MKDirectionsResponse *response){
        MKRoute *route = response.routes.firstObject;
        MKPolyline *routePolyline = route.polyline;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(routePolyline) [weakSelf.myMapView addOverlay:routePolyline];
        });
    };
    
    locationInfoWithCoordinateInfoBar.naviToHereButton.enabled = NO;
}

- (void)locationInfoWithCoordinateInfoBarSwipeUp:(UISwipeGestureRecognizer *)sender{
    [self hideLocationInfoWithCoordinateInfoBar];
}

- (void)showHideLocationInfoWithCoordinateInfoBar{
    if (locationInfoWithCoordinateInfoBarIsOutOfVisualView) [self showLocationInfoWithCoordinateInfoBar];
    else [self hideLocationInfoWithCoordinateInfoBar];
}

- (void)showLocationInfoWithCoordinateInfoBar{
    if (locationInfoWithCoordinateInfoBar.hidden) locationInfoWithCoordinateInfoBar.hidden = NO;
    
    if (msBaseModeBar.alpha || placemarkInfoBar.alpha) {
        [UIView animateWithDuration:0.2 animations:^{
            msBaseModeBar.alpha = 0;
            placemarkInfoBar.alpha = 0;
        }];
    }
    
    if (!msExtenedModeBar.hidden) {
        [UIView animateWithDuration:0.2 animations:^{
            msExtenedModeBar.alpha = 0;
            quiteBrowserModeButton.alpha = 0;
            recordModeBar.alpha = 0;
            recordModeSettingBar.alpha = 0;
        }];
    }
    
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.4 animations:^{
                                      locationInfoWithCoordinateInfoBar.frame = CGRectMake(5, 20 + 10, ScreenWidth - 10, locationInfoWithCoordinateInfoBarHeight);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.3 animations:^{
                                      locationInfoWithCoordinateInfoBar.frame = CGRectMake(5, 20, ScreenWidth - 10, locationInfoWithCoordinateInfoBarHeight);
                                  }];
                                  
                              }
                              completion:^(BOOL finished) {
                                  locationInfoWithCoordinateInfoBarIsOutOfVisualView = NO;
                              }];

}

- (void)hideLocationInfoWithCoordinateInfoBar{
    [UIView animateKeyframesWithDuration:1
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionBeginFromCurrentState
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.3 animations:^{
                                      locationInfoWithCoordinateInfoBar.frame = CGRectMake(5, 20 + 10, ScreenWidth - 10, locationInfoWithCoordinateInfoBarHeight);
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.3 relativeDuration:0.4 animations:^{
                                      locationInfoWithCoordinateInfoBar.frame = CGRectMake(5, -locationInfoWithCoordinateInfoBarHeight, ScreenWidth - 10, locationInfoWithCoordinateInfoBarHeight);
                                  }];
                                  
                              }
                              completion:^(BOOL finished) {
                                  locationInfoWithCoordinateInfoBarIsOutOfVisualView = YES;
                                  [UIView animateWithDuration:0.2 animations:^{
                                      msBaseModeBar.alpha = 1;
                                      placemarkInfoBar.alpha = 1;
                                  }];
                                  
                                  if (!msExtenedModeBar.hidden) {
                                      [UIView animateWithDuration:0.2 animations:^{
                                          msExtenedModeBar.alpha = 1;
                                          quiteBrowserModeButton.alpha = 0.6;
                                          recordModeBar.alpha = 1;
                                      }];
                                  }

                              }];
    
}

#pragma mark Placemark Info Bar

- (void)initPlacemarkInfoBar{
    placemarkInfoBarHeight = 70;
    placemarkInfoBar = [PlacemarkInfoBar newAutoLayoutView];
    [self.view addSubview:placemarkInfoBar];
    [placemarkInfoBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msBaseModeBar withOffset:10];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [placemarkInfoBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [placemarkInfoBar autoSetDimension:ALDimensionHeight toSize:placemarkInfoBarHeight];
    
    NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
    [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapBaseMode:self.settingManager.mapBaseMode];
}

- (void)updatePlacemarkInfoBarWithPlacemarkDictionary:(NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkDictionary mapBaseMode:(enum MapBaseMode)mapBaseMode{
    // 更新统计信息
   
    placemarkInfoBar.countryCount = placemarkDictionary[kCountryArray].count;
    placemarkInfoBar.administrativeAreaCount = placemarkDictionary[kAdministrativeAreaArray].count;
    placemarkInfoBar.localityCount = placemarkDictionary[kLocalityArray].count;
    placemarkInfoBar.subLocalityCount = placemarkDictionary[kSubLocalityArray].count;
    placemarkInfoBar.thoroughfareCount = placemarkDictionary[kThoroughfareArray].count;
    
    switch (mapBaseMode) {
        case 0:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Distance", @"");
            placemarkInfoBar.totalDistance = totalDistance;
        }
            break;
        case 1:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Area", @"");
            totalArea = self.addedEWAnnos.count * M_PI * pow(self.settingManager.mergeDistanceForLocation,2);
            placemarkInfoBar.totalArea = totalArea;
        }
            break;
        default:
            break;
    }
}

#pragma mark Vertical Bars

#define ButtonPlaceholderHeight (ScreenHeight > 568 ? 60 : 43)
#define ButtionSize (ScreenHeight > 568 ? CGSizeMake(44, 44) : CGSizeMake(36, 36))
#define ButtionEdgeLength (ScreenHeight > 568 ? 44 : 36)
#define VerticalButtonOffset (ScreenHeight > 568 ? 16 : 8)

- (void)initVerticalBars{

#pragma mark userLocationButton 屏幕左下方，naviBar上方
    userLocationButton = [UIButton newAutoLayoutView];
    userLocationButton.alpha = 0.6;
    [userLocationButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_User"] forState:UIControlStateNormal];
    userLocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [userLocationButton addTarget:self action:@selector(changeShowUserLocationMode) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:userLocationButton];
    [userLocationButton autoSetDimensionsToSize:ButtionSize];
    //[userLocationButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [userLocationButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [userLocationButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    
#pragma mark leftVerticalBar 屏幕左下方，userLocationButton上方，包含设置、显示隐藏等4个按钮
    
    leftVerticalBar = [UIView newAutoLayoutView];
    leftVerticalBar.backgroundColor = [UIColor clearColor];//[[UIColor cyanColor] colorWithAlphaComponent:0.3];//
    [self.view addSubview:leftVerticalBar];
    [leftVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [leftVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:userLocationButton withOffset:-10];
    [leftVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtionEdgeLength, ButtonPlaceholderHeight * 5)];
    
    UIButton *leftBtn1 = [UIButton newAutoLayoutView];
    leftBtn1.alpha = 0.6;
    [leftBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Setting_WBG"] forState:UIControlStateNormal];
    leftBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn1 addTarget:self action:@selector(showSettingVC) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn1];
    [leftBtn1 autoSetDimensionsToSize:ButtionSize];
    [leftBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    UIButton *leftBtn2 = [UIButton newAutoLayoutView];
    leftBtn2.alpha = 0.6;
    [leftBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_MapMarker"] forState:UIControlStateNormal];
    leftBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn2 addTarget:self action:@selector(showHideLocationInfoWithCoordinateInfoBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn2];
    [leftBtn2 autoSetDimensionsToSize:ButtionSize];
    [leftBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn1 withOffset:VerticalButtonOffset];
    
    UIButton *leftBtn3 = [UIButton newAutoLayoutView];
    leftBtn3.alpha = 0.6;
    [leftBtn3 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Glasses_WBG"] forState:UIControlStateNormal];
    leftBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn3 addTarget:self action:@selector(showHideMapModeBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn3];
    [leftBtn3 autoSetDimensionsToSize:ButtionSize];
    [leftBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn2 withOffset:VerticalButtonOffset];
    
    UIButton *leftBtn4 = [UIButton newAutoLayoutView];
    leftBtn4.alpha = 0.6;
    [leftBtn4 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_StatisticBar1_WBG"] forState:UIControlStateNormal];
    leftBtn4.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn4 addTarget:self action:@selector(showHidePlacemarkInfoBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn4];
    [leftBtn4 autoSetDimensionsToSize:ButtionSize];
    [leftBtn4 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn4 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn3 withOffset:VerticalButtonOffset];
    
    UIButton *leftBtn5 = [UIButton newAutoLayoutView];
    leftBtn5.alpha = 0.6;
    [leftBtn5 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Play_WBG"] forState:UIControlStateNormal];
    leftBtn5.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn5 addTarget:self action:@selector(showHideNaviBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn5];
    [leftBtn5 autoSetDimensionsToSize:ButtionSize];
    [leftBtn5 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn5 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn4 withOffset:VerticalButtonOffset];
    //[leftVerticalView.subviews autoDistributeViewsAlongAxis:ALAxisVertical withFixedSize:44 insetSpacing:YES alignment:NSLayoutFormatAlignAllLeft];
    
#pragma mark rightSwipeVerticalBar 屏幕右下方，naviBar上方
    
    rightSwipeVerticalBar = [UIView newAutoLayoutView];
    rightSwipeVerticalBar.backgroundColor = [UIColor clearColor];//[[UIColor cyanColor] colorWithAlphaComponent:0.3];//
    [self.view addSubview:rightSwipeVerticalBar];
    [rightSwipeVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightSwipeVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [rightSwipeVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtionEdgeLength, ButtonPlaceholderHeight * 3)];
    
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
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swipeScaleViewSingleTap:)];
    singleTapGR.numberOfTapsRequired = 1;
    [swipeScaleView addGestureRecognizer:singleTapGR];
    [rightSwipeVerticalBar addSubview:swipeScaleView];
    [swipeScaleView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

#pragma mark rightVerticalBar 屏幕右下方，rightSwipeVerticalBar上方，包含分享截图、分享足迹、进入扩展模式3个按钮
    
    rightVerticalBar = [UIView newAutoLayoutView];
    rightVerticalBar.backgroundColor = [UIColor clearColor];//[[UIColor brownColor] colorWithAlphaComponent:0.3];//
    [self.view addSubview:rightVerticalBar];
    [rightVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:rightSwipeVerticalBar withOffset:(VerticalButtonOffset / 2.0)];
    [rightVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtionEdgeLength, ButtonPlaceholderHeight * 3)];
    
    UIButton *rightBtn1 = [UIButton newAutoLayoutView];
    rightBtn1.alpha = 0.6;
    [rightBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share_WBG"] forState:UIControlStateNormal];
    rightBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn1 addTarget:self action:@selector(showShareImageVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn1];
    [rightBtn1 autoSetDimensionsToSize:ButtionSize];
    [rightBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn1 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    UIButton *rightBtn2 = [UIButton newAutoLayoutView];
    rightBtn2.alpha = 0.6;
    [rightBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share2_WBG"] forState:UIControlStateNormal];
    rightBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn2 addTarget:self action:@selector(showShareShareRepositoryVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn2];
    [rightBtn2 autoSetDimensionsToSize:ButtionSize];
    [rightBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn1 withOffset:VerticalButtonOffset];
    
    UIButton *rightBtn3 = [UIButton newAutoLayoutView];
    rightBtn3.alpha = 0.6;
    [rightBtn3 setBackgroundImage:[UIImage imageNamed:@"ExtendedMode"] forState:UIControlStateNormal];
    rightBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn3 addTarget:self action:@selector(intelligentlyEnterExtendedMode) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn3];
    [rightBtn3 autoSetDimensionsToSize:ButtionSize];
    [rightBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn2 withOffset:VerticalButtonOffset];

}

- (void)alphaShowHideVerticalBar{
    leftVerticalBar.alpha = leftVerticalBar.alpha == 1 ?  0 : 1;
    rightVerticalBar.alpha = rightVerticalBar.alpha == 1 ? 0 : 1;
    
    rightSwipeVerticalBar.alpha = rightSwipeVerticalBar.alpha == 1 ? 0 : 1;
    userLocationButton.hidden = userLocationButton.hidden ? NO : YES;
    
    verticalBarIsAlphaZero = verticalBarIsAlphaZero ? NO : YES;
}

- (void)showHideMapModeBar{
    [UIView animateWithDuration:0.3 animations:^{
        msBaseModeBar.alpha = (msBaseModeBar.alpha == 1) ? 0 : 1;
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
    [self scaleMapView:1.0 / (self.settingManager.mapViewScaleRate * 3.0)];
}

- (void)swipeScaleViewSwipeDown:(UISwipeGestureRecognizer *)sender{
    [self scaleMapView:(self.settingManager.mapViewScaleRate * 3.0)];
}

- (void)swipeScaleViewSingleTap:(UITapGestureRecognizer *)sender{
    CGPoint tapPoint = [sender locationInView:sender.view];
    if (tapPoint.y < sender.view.bounds.size.height / 2.0) {
        [self scaleMapView:1.0 / self.settingManager.mapViewScaleRate];
    }else{
        [self scaleMapView:self.settingManager.mapViewScaleRate];
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

- (void)changeShowUserLocationMode{
    NSInteger mode = self.showUserLocationMode;
    mode++;
    if (mode == 3) mode = 0;
    
    // ⭕️如果正在记录轨迹，则不允许关闭地址显示
    if (self.isRecording && mode == 2) mode = 0;
    
    self.showUserLocationMode = mode;
}

- (void)setShowUserLocationMode:(ShowUserLocationMode)showUserLocationMode{
    _showUserLocationMode = showUserLocationMode;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        
        switch (showUserLocationMode) {
            case ShowUserLocationModeOn:
                self.myMapView.showsUserLocation = YES;
                [userLocationButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_User-On"] forState:UIControlStateNormal];
                break;
            case ShowUserLocationModeFollow:
                self.myMapView.showsUserLocation = YES;
                [userLocationButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_User-Follow"] forState:UIControlStateNormal];
                break;
            case ShowUserLocationModeOff:
                self.myMapView.showsUserLocation = NO;
                [userLocationButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_User"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        
        // ⭕️决定导航键是否可用
        locationInfoWithCoordinateInfoBar.naviToHereButton.enabled = self.myMapView.showsUserLocation;
        
    }else{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[CLLocationManager new] requestWhenInUseAuthorization];
        });
    }
}

#pragma mark QuiteBrowserModeButton

- (void)initQuiteBrowserModeButton{
    quiteBrowserModeButton = [UIButton newAutoLayoutView];
    quiteBrowserModeButton.alpha = 0.6;
    [quiteBrowserModeButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    quiteBrowserModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quiteBrowserModeButton addTarget:self action:@selector(showQuiteBrowserModeAlertController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:quiteBrowserModeButton];
    [quiteBrowserModeButton autoSetDimensionsToSize:ButtionSize];
    [quiteBrowserModeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msExtenedModeBar withOffset:VerticalButtonOffset];
    [quiteBrowserModeButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    quiteBrowserModeButton.hidden = YES;
}

#pragma mark Record Mode Bar

- (void)initRecordModeBar{
    // 需要外部引用，用于显示隐藏
    recordModeBar = [UIView newAutoLayoutView];
    recordModeBar.backgroundColor = [UIColor clearColor];//[UIColor cyanColor]; //
    [self.view addSubview:recordModeBar];
    [recordModeBar autoSetDimensionsToSize:CGSizeMake(ButtonPlaceholderHeight * 5, ButtionEdgeLength + 30)];
    [recordModeBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msExtenedModeBar withOffset:10];
    [recordModeBar autoAlignAxisToSuperviewAxis:ALAxisVertical];
    recordModeBar.hidden = YES;
    
    UIView *recordModeBarButtonContainer = [UIView newAutoLayoutView];
    recordModeBarButtonContainer.backgroundColor = [UIColor clearColor];
    [recordModeBar addSubview:recordModeBarButtonContainer];
    [recordModeBarButtonContainer autoSetDimensionsToSize:CGSizeMake(ButtonPlaceholderHeight * 4, ButtionEdgeLength)];
    [recordModeBarButtonContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    // 需要外部引用，用于改变图片
    startPauseRecordButton = [UIButton newAutoLayoutView];
    startPauseRecordButton.alpha = 0.6;
    [startPauseRecordButton setBackgroundImage:[UIImage imageNamed:@"Paused"] forState:UIControlStateNormal];
    startPauseRecordButton.translatesAutoresizingMaskIntoConstraints = NO;
    [startPauseRecordButton addTarget:self action:@selector(startPauseRecord) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:startPauseRecordButton];
    [startPauseRecordButton autoSetDimensionsToSize:ButtionSize];
    [startPauseRecordButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [startPauseRecordButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:VerticalButtonOffset / 2.0];
    
    UIButton *manullyAddFootprintButton = [UIButton newAutoLayoutView];
    manullyAddFootprintButton.alpha = 0.6;
    [manullyAddFootprintButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Plus_WBG"] forState:UIControlStateNormal];
    manullyAddFootprintButton.translatesAutoresizingMaskIntoConstraints = NO;
    [manullyAddFootprintButton addTarget:self action:@selector(manullyAddFootprint) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:manullyAddFootprintButton];
    [manullyAddFootprintButton autoSetDimensionsToSize:ButtionSize];
    [manullyAddFootprintButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [manullyAddFootprintButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:startPauseRecordButton withOffset:VerticalButtonOffset];
    
    UIButton *showHideRecordModeSettingBarButton = [UIButton newAutoLayoutView];
    showHideRecordModeSettingBarButton.alpha = 0.6;
    [showHideRecordModeSettingBarButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Setting_WBG"] forState:UIControlStateNormal];
    showHideRecordModeSettingBarButton.translatesAutoresizingMaskIntoConstraints = NO;
    [showHideRecordModeSettingBarButton addTarget:self action:@selector(alphaShowHideRecordModeSettingBar) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:showHideRecordModeSettingBarButton];
    [showHideRecordModeSettingBarButton autoSetDimensionsToSize:ButtionSize];
    [showHideRecordModeSettingBarButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [showHideRecordModeSettingBarButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:manullyAddFootprintButton withOffset:VerticalButtonOffset];
    
    UIButton *saveCurrentRecordingFootprintsButton = [UIButton newAutoLayoutView];
    saveCurrentRecordingFootprintsButton.alpha = 0.6;
    [saveCurrentRecordingFootprintsButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Download_WBG"] forState:UIControlStateNormal];
    saveCurrentRecordingFootprintsButton.translatesAutoresizingMaskIntoConstraints = NO;
    [saveCurrentRecordingFootprintsButton addTarget:self action:@selector(saveCurrentRecordingFootprints) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:saveCurrentRecordingFootprintsButton];
    [saveCurrentRecordingFootprintsButton autoSetDimensionsToSize:ButtionSize];
    [saveCurrentRecordingFootprintsButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [saveCurrentRecordingFootprintsButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:showHideRecordModeSettingBarButton withOffset:VerticalButtonOffset];
    
    UIButton *quiteRecordModeButton = [UIButton newAutoLayoutView];
    quiteRecordModeButton.alpha = 0.6;
    [quiteRecordModeButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    quiteRecordModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quiteRecordModeButton addTarget:self action:@selector(showQuiteRecordModeAlertController) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:quiteRecordModeButton];
    [quiteRecordModeButton autoSetDimensionsToSize:ButtionSize];
    [quiteRecordModeButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [quiteRecordModeButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:saveCurrentRecordingFootprintsButton withOffset:VerticalButtonOffset];
    
    
    velocityLabel = [UILabel newAutoLayoutView];
    velocityLabel.layer.backgroundColor = self.settingManager.extendedTintColor.CGColor;
    velocityLabel.layer.borderColor = self.settingManager.extendedTintColor.CGColor;
    velocityLabel.layer.borderWidth = 1;
    velocityLabel.layer.cornerRadius = 0.4;
    velocityLabel.text = NSLocalizedString(@"Current Velocity", @"当前速度");
    velocityLabel.textAlignment = NSTextAlignmentCenter;
    velocityLabel.textColor = [UIColor whiteColor];
    velocityLabel.font = [UIFont bodyFontWithSizeMultiplier:1.2];
    [recordModeBar addSubview:velocityLabel];
    [velocityLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [velocityLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
}

- (void)manullyAddFootprint{
    //[self.locationManagerForRecording requestLocation];
    if (self.userLocationWGS84) [self addRecordedShareAnnosWithLocation:self.userLocationWGS84 isUserManuallyAdded:YES];
}

- (void)alphaShowHideRecordModeSettingBar{
    [UIView animateWithDuration:0.3 animations:^{
        recordModeSettingBar.alpha = recordModeSettingBar.alpha ==1 ? 0 : 1;
    }];
}

#pragma mark RecordModeSettingBar

- (void)initRecordModeSettingBar{
    recordModeSettingBar = [RecordModeSettingBar new];
    recordModeSettingBar.customMinDistance = self.settingManager.minDistanceForRecord;
    recordModeSettingBar.customMinTimeInterval = self.settingManager.minTimeIntervalForRecord;
    recordModeSettingBar.backgroundColor = self.settingManager.extendedTintColor;
    [self.view addSubview:recordModeSettingBar];
    [recordModeSettingBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:recordModeBar withOffset:10];
    [recordModeSettingBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [recordModeSettingBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [recordModeSettingBar autoSetDimension:ALDimensionHeight toSize:100];
    recordModeSettingBar.hidden = YES;
    recordModeSettingBar.alpha = 0;
    
    WEAKSELF(weakSelf);
    recordModeSettingBar.minDistanceOrTimeIntervalDidChangeHanlder = ^(CLLocationDistance selectedMinDistance , NSTimeInterval selectedMinTimeInterval){
        
        if (selectedMinDistance != 0) {
            // 减小记录点数量，节省内存
            weakSelf.minDistanceForRecord = selectedMinDistance;
            
            // 减少GPS调用，以节省电量
            if (selectedMinDistance <= 100) {
                weakSelf.locationManagerForRecording.desiredAccuracy = kCLLocationAccuracyBest;
            }else if (selectedMinDistance > 100 && selectedMinDistance <= 1000){
                weakSelf.locationManagerForRecording.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            }else if (selectedMinDistance > 1000){
                weakSelf.locationManagerForRecording.desiredAccuracy = kCLLocationAccuracyKilometer;
            }
        }
        
        if (selectedMinTimeInterval != 0) {
            weakSelf.minTimeIntervalForRecord = selectedMinTimeInterval;
        }
    };
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
    shareBar.title =  NSLocalizedString(@"Measure the world by footprints.",@"用相册记录人生，用足迹丈量世界");
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
    switch (self.settingManager.mapBaseMode) {
        case MapBaseModeMoment:{
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
        case MapBaseModeLocation:{
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
    if (!verticalBarIsAlphaZero) [self alphaShowHideVerticalBar];
    msBaseModeBar.alpha = 0;
    placemarkInfoBar.alpha = 0;
    naviBar.alpha = 0;
    locationInfoWithCoordinateInfoBar.alpha = 0;
    
    NSMutableString *ms = [NSMutableString new];
    NSString *titleString = msBaseModeBar.info;
    
    if (self.settingManager.mapBaseMode == MapBaseModeMoment) {
        //NSString *dateString = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
        
        if (titleString) [ms appendFormat:@"%@ ",titleString];
        [ms appendString:NSLocalizedString(@"I have my footprints over ", @"我的足迹遍布 ")];
    }else{
        [ms appendString:NSLocalizedString(@"I have been in ", @"我到了 ")];
        [ms appendFormat:@"%@",titleString];
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
    ssVC.contentSizeInPopup = CGSizeMake(ScreenWidth - 10, ScreenHeight - 10 - 80);
    ssVC.landscapeContentSizeInPopup = CGSizeMake(ScreenHeight - 10 - 80, ScreenWidth - 10);

    popupController = [[STPopupController alloc] initWithRootViewController:ssVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

#pragma mark - Purchase

/*
- (void)showPurchaseAllFunctionsAlertController{
    NSString *alertTitle = NSLocalizedString(@"Can not enter extended mode",@"无法进入扩展模式");
    NSString *alertMessage = [NSString stringWithFormat:@"%@",NSLocalizedString(@"Please choose a purchase item", @"请选择购买项目")];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *purchaseShareFunctionAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase ShareFunctionAndBrowserMode",@"购买 分享功能和浏览模式")
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction * action) {
                                                                            [self showPurchaseShareFunctionAlertController];
                                                                        }];
    UIAlertAction *purchaseRecordFunctionAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase RecordFuntionAndRecordMode",@"购买 记录功能和记录模式")
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
*/

- (void)showPurchaseShareFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"ShareFunctionAndBrowserMode",@"分享功能和浏览模式");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Share your footprints to others", @"1.将足迹分享给他人"),NSLocalizedString(@"2.Store footprints both sended by you and shared by others", @"2.存储足迹，包括自己发送的和别人分享的"),NSLocalizedString(@"3.Unlock Browser Mode and  lookup stored footprints anytime", @"3.解锁浏览模式，随时查看分享足迹"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:0];
}

- (void)showPurchaseRecordFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"RecordFuntionAndRecordMode",@"足迹记录和记录模式");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Record your footprints, support background recording", @"1.记录你的运动足迹"),NSLocalizedString(@"2.Intelligently edit your footprints", @"2.足迹智能编辑"),NSLocalizedString(@"3.Unlock Record Mode to manage your recorded footprints", @"3.解锁记录模式，管理你记录的足迹"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:1];
}

- (void)showPurchaseAlertControllerWithTitle:(NSString *)title message:(NSString *)message productIndex:(NSInteger)productIndex{
    WEAKSELF(weakSelf);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [weakSelf showPurchaseVC:productIndex transactionType:TransactionTypePurchase];
                                                     }];
    UIAlertAction *restoreAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restore",@"恢复")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [weakSelf showPurchaseVC:productIndex transactionType:TransactionTypeRestore];
                                                           }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:purchaseAction];
    [alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)showPurchaseVC:(NSInteger)productIndex transactionType:(enum TransactionType)transactionType{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    inAppPurchaseVC.productIDs = ProductIDs;
    inAppPurchaseVC.productIndex = productIndex;
    inAppPurchaseVC.transactionType = transactionType;
    
    WEAKSELF(weakSelf);
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(BOOL succeeded,NSInteger productIndex,enum TransactionType transactionType){
        if (succeeded) {
            if (productIndex == 0) weakSelf.settingManager.hasPurchasedShare = YES;
            if (productIndex == 1) weakSelf.settingManager.hasPurchasedRecord = YES;
        }
        NSLog(@"%@",succeeded? @"用户购买成功！" : @"用户购买失败！");
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
    
    if (!self.addedEWShareAnnos || self.addedEWShareAnnos.count == 0) {
        [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"No footprints yet.Please choose a date or a location to add your album footprints.", @"您还没有添加足迹点，请选择日期或地址添加您的相册足迹。")]
                           animated:YES completion:nil];
        
        return;
    }
    
    // 生成分享对象
    EverywhereShareRepository *shareRepository = [EverywhereShareRepository new];
    shareRepository.shareAnnos = self.addedEWShareAnnos;
    if (self.settingManager.mapBaseMode == MapBaseModeMoment) shareRepository.radius = 0;
    else shareRepository.radius = self.settingManager.mergeDistanceForLocation / 2.0;
    shareRepository.creationDate = NOW;
    shareRepository.shareRepositoryType = ShareRepositoryTypeSended;
    
    if (self.settingManager.mapBaseMode == MapBaseModeMoment) shareRepository.title = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate];
    else shareRepository.title = self.lastPlacemark;
    
    ShareShareRepositoryVC *ssVC = [ShareShareRepositoryVC new];
    ssVC.shareRepository = shareRepository;
    NSData *thumbImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"地球_300_300"], 0.5);
    ssVC.shareThumbImageData = thumbImageData;
    
    ssVC.contentSizeInPopup = CGSizeMake(ScreenWidth * 0.8, 200);
    ssVC.landscapeContentSizeInPopup = CGSizeMake(200, ScreenWidth * 0.8);
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
                                                         [self showShowShareRepositoryAlertController:shareRepository];
                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Enter And Quite Mode

- (void)intelligentlyEnterExtendedMode{
    /*
    if (!self.settingManager.hasPurchasedShare) {
        [self showPurchaseShareFunctionAlertController];
    }else if (!self.settingManager.hasPurchasedRecord){
        [self showPurchaseRecordFunctionAlertController];
    }
    */
    
    [self enterExtendedMode];
    
    if (self.settingManager.mapExtendedMode == MapExtendedModeBrowser) [self enterBrowserMode];
    else [self enterRecordMode];
}

- (void)enterExtendedMode{
    if(DEBUGMODE) NSLog(@"进入扩展模式");
    self.isInBaseMode = NO;
    
    if (!locationInfoWithCoordinateInfoBarIsOutOfVisualView) locationInfoWithCoordinateInfoBar.hidden = YES;
    
    // 保存BaseMode数据
    savedTitleForBaseMode = msBaseModeBar.info;
    savedAnnotationsForBaseMode = self.addedEWAnnos;
    savedShareAnnotationsForBaseMode = self.addedEWShareAnnos;
    savedOverlaysForBaseMode = self.myMapView.overlays;
    
    // 清理BaseMode地图
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    self.addedEWShareAnnos = nil;
    self.addedIDAnnos = nil;

    msBaseModeBar.hidden = YES;
    placemarkInfoBar.hidden = YES;
    leftVerticalBar.hidden = YES;
    rightVerticalBar.hidden = YES;
    
    msExtenedModeBar.hidden = NO;
    
    naviBar.backgroundColor = self.settingManager.extendedTintColor;
    locationInfoWithCoordinateInfoBar.backgroundColor = self.settingManager.extendedTintColor;
    recordModeSettingBar.backgroundColor = self.settingManager.extendedTintColor;
    velocityLabel.layer.backgroundColor = self.settingManager.extendedTintColor.CGColor;
    velocityLabel.layer.borderColor = self.settingManager.extendedTintColor.CGColor;
}

- (void)quiteExtendedMode{
    msBaseModeBar.hidden = NO;
    placemarkInfoBar.hidden = NO;
    leftVerticalBar.hidden = NO;
    rightVerticalBar.hidden = NO;
    
    msExtenedModeBar.hidden = YES;
    
    naviBar.backgroundColor = self.settingManager.baseTintColor;
    locationInfoWithCoordinateInfoBar.backgroundColor = self.settingManager.baseTintColor;
    
    // 清理Extended Mode地图
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    self.addedEWShareAnnos = nil;
    
    // 恢复Main Mode地图
    msBaseModeBar.info = savedTitleForBaseMode;
    [self.myMapView addAnnotations:savedAnnotationsForBaseMode];
    self.addedEWShareAnnos = (NSArray <EverywhereShareAnnotation*> *)savedShareAnnotationsForBaseMode;
    [self.myMapView addOverlays:savedOverlaysForBaseMode];
    self.addedIDAnnos = savedAnnotationsForBaseMode;
    
    [self updateVisualViewForEWAnnos];
    
    self.isInBaseMode = YES;
    if(DEBUGMODE) NSLog(@"退出扩展模式");
}

- (void)enterBrowserMode{
    
    [self quiteRecordMode];
    if(DEBUGMODE) NSLog(@"进入浏览模式");
    
    msExtenedModeBar.selectedSegmentIndex = 0;
    msExtenedModeBar.rightButtonEnabled = NO;
    
    quiteBrowserModeButton.hidden = NO;
    
}

- (void)showShowShareRepositoryAlertController:(EverywhereShareRepository *)shareRepository{
    
    if (!recordedShareAnnos || recordedShareAnnos.count == 0) {
        [self showShareRepository:shareRepository];
        return;
    }else if (self.isInRecordMode) {
        UIAlertController *okCancelAlertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Alert", @"警告")  message:NSLocalizedString(@"There are recorded footprints now and they will be cleared if show selected footprints.Show or not?", @"当前处于记录模式并且有记录的足迹点，如需显示所选足迹，记录的足迹点将被清空，是否显示？") okHandler:^(UIAlertAction *action) {
            [self showShareRepository:shareRepository];
        }];
        
        [self presentViewController:okCancelAlertController animated:YES completion:nil];
    }
    
}

- (void)showShareRepository:(EverywhereShareRepository *)shareRepository{
    // 清理地图
    self.addedEWAnnos = nil;
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    
    // 添加要显示的ShareAnnotations
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
    
    if (!self.addedEWShareAnnos || self.addedEWShareAnnos.count == 0){
        [self quiteBrowserMode];
        [self quiteExtendedMode];
        return;
    }
    
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
                                                               [self showPurchaseShareFunctionAlertController];
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
    
    self.isInRecordMode = YES;
    
    msExtenedModeBar.selectedSegmentIndex = 1;
    msExtenedModeBar.leftButtonEnabled = NO;
    
    [self.myMapView removeAnnotations:self.myMapView.annotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];

    naviBar.hidden = YES;
    recordModeBar.hidden = NO;
    recordModeSettingBar.hidden = NO;
    self.showUserLocationMode = ShowUserLocationModeFollow;
    
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

- (void)saveCurrentRecordingFootprints{
    if (self.isRecording) {
        [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Recording now.Please pause recording before save footprints.", @"正在记录足迹中，为确保数据完整性，请先选择暂停记录再保存。")]
                           animated:YES completion:nil];
        return;
    }
    
    [self intelligentlySaveRecordedShareAnnosAndClearCatche];
    self.allowBrowserMode = YES;
    recordedShareAnnos = [NSMutableArray new];
    
    [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"The recorded footprints has been saved.", @"足迹保存成功。")]
                       animated:YES completion:nil];
}

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
                                                             [self intelligentlySaveRecordedShareAnnosAndClearCatche];
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

// 智能保存
- (void)intelligentlySaveRecordedShareAnnosAndClearCatche{
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

- (void)quiteRecordMode{
    
    msExtenedModeBar.leftButtonEnabled = YES;
    
    naviBar.hidden = NO;
    recordModeBar.hidden = YES;
    recordModeSettingBar.hidden = YES;
    
    self.showUserLocationMode = ShowUserLocationModeOff;
    
    self.isInRecordMode = NO;
    if(DEBUGMODE) NSLog(@"退出记录模式");
}

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
        
        if (self.settingManager.mapBaseMode == MapBaseModeMoment) {
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
        shareAnno.coordinateWGS84 = firstAsset.location.coordinate;
        shareAnno.startDate = firstAsset.creationDate;
        if (self.settingManager.mapBaseMode == MapBaseModeLocation) shareAnno.endDate = lastAsset.creationDate;
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
        [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapBaseMode:self.settingManager.mapBaseMode];
        
        if (self.settingManager.mapBaseMode == MapBaseModeLocation){
            maxDistance = self.settingManager.mergeDistanceForLocation * 8.0;
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
        //[self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapBaseMode:self.settingManager.mapBaseMode];
        
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
        
        EverywhereShareAnnotation *shareAnno = (EverywhereShareAnnotation *)annotation;
        
        pinAV.animatesDrop = NO;
        
        pinAV.pinColor = shareAnno.isUserManuallyAdded ? MKPinAnnotationColorRed : MKPinAnnotationColorPurple;
        
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
            
            [self updateLocationInfoWithCoordinateInfoBarWithPHAssetInfo:assetInfo];
        }else if ([view.annotation isKindOfClass:[EverywhereShareAnnotation class]]){
            EverywhereShareAnnotation *shareAnno = (EverywhereShareAnnotation *)view.annotation;
            //[self updateLocationInfoWithCoordinateInfoBarWithGCJCoordinate:shareAnno.coordinate];
            [self updateLocationInfoWithCoordinateInfoBarWithWSG84Coordinate:shareAnno.coordinateWGS84];
        }
        
        [self showHideLocationInfoWithCoordinateInfoBar];
        
    }
    
}

- (void)updateLocationInfoWithCoordinateInfoBarWithPHAssetInfo:(PHAssetInfo *)assetInfo{
    CoordinateInfo *coordinateInfo = [CoordinateInfo coordinateInfoWithPHAssetInfo:assetInfo inManagedObjectContext:[EverywhereCoreDataManager defaultManager].appMOC];
    
    if (!coordinateInfo.reverseGeocodeSucceed) {
        [CoordinateInfo updatePlacemarkForCoordinateInfo:coordinateInfo];
        [NSThread sleepForTimeInterval:0.3];
    }
    
    locationInfoWithCoordinateInfoBar.currentShowCoordinateInfo = coordinateInfo;
}

- (void)updateLocationInfoWithCoordinateInfoBarWithWSG84Coordinate:(CLLocationCoordinate2D)aCoordinate{
    CoordinateInfo *coordinateInfo = [CoordinateInfo coordinateInfoWithLatitude:aCoordinate.latitude longitude:aCoordinate.longitude inManagedObjectContext:[EverywhereCoreDataManager defaultManager].appMOC];
    
    if (!coordinateInfo.reverseGeocodeSucceed) {
        [CoordinateInfo updatePlacemarkForCoordinateInfo:coordinateInfo];
        [NSThread sleepForTimeInterval:0.3];
    }
    
    locationInfoWithCoordinateInfoBar.currentShowCoordinateInfo = coordinateInfo;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        MKPolyline *polyline = (MKPolyline *)overlay;
        
        if (polyline.pointCount > 2) {
            // 查找的路线
            polylineRenderer.lineWidth = 3;
            polylineRenderer.strokeColor = [[UIColor magentaColor] colorWithAlphaComponent:0.6];
            polylineRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.6];
        }else{
            // 箭头路线
            polylineRenderer.lineWidth = 1;
            polylineRenderer.strokeColor = [[UIColor brownColor] colorWithAlphaComponent:0.6];
        }

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
    CLLocation *checkedUserLocation = userLocation.location;
    
    if (![self checkCoordinate:checkedUserLocation.coordinate]) return;
    
    self.userLocationGCJ02 = checkedUserLocation;
    
    if (self.showUserLocationMode == ShowUserLocationModeFollow) {
        [mapView setCenterCoordinate:checkedUserLocation.coordinate animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    self.currentAnnotationIndex = [self.addedIDAnnos indexOfObject:view.annotation];
    
    if ([view.annotation isKindOfClass:[EverywhereAnnotation class]]) {
        //self.currentAnnotationIndex = [self.addedEWAnnos indexOfObject:view.annotation];
        
        EverywhereAnnotation *anno = (EverywhereAnnotation *)view.annotation;
        PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:self.cdManager.appMOC];
        if (![assetInfo.reverseGeocodeSucceed boolValue]) [PHAssetInfo updatePlacemarkForAssetInfo:assetInfo];
        
        [self updateLocationInfoWithCoordinateInfoBarWithPHAssetInfo:assetInfo];
        
    }else if ([view.annotation isKindOfClass:[EverywhereShareAnnotation class]]){
        EverywhereShareAnnotation *shareAnno = (EverywhereShareAnnotation *)view.annotation;
        //self.currentAnnotationIndex = [self.addedEWShareAnnos indexOfObject:shareAnno];
        
        //[self updateLocationInfoWithCoordinateInfoBarWithGCJCoordinate:shareAnno.coordinate];
        [self updateLocationInfoWithCoordinateInfoBarWithWSG84Coordinate:shareAnno.coordinateWGS84];
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
- (BOOL)checkCoordinate:(CLLocationCoordinate2D)aCoord{
    
    if (aCoord.latitude > -90 && aCoord.latitude < 90) {
        if (aCoord.longitude > - 180 && aCoord.longitude < 180) {
            if (aCoord.latitude != 0 && aCoord.longitude != 0) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *lastLocation = locations.lastObject;
    
    // 地址不准确，直接返回
    if (![self checkCoordinate:lastLocation.coordinate]) return;
    
    self.userLocationWGS84 = lastLocation;
    
    if (!lastRecordLocation) {
        lastRecordLocation = lastLocation;
        lastRecordDate = NOW;
        [self addRecordedShareAnnosWithLocation:lastRecordLocation isUserManuallyAdded:NO];
    }
    
    CLLocation *currentLocation = lastLocation;
    // 满足最小记录距离条件
    if ([currentLocation distanceFromLocation:lastRecordLocation] > self.minDistanceForRecord) {
        // 满足最小记录时间条件
        if([NOW timeIntervalSinceDate:lastRecordDate] > self.minTimeIntervalForRecord){
            [self addRecordedShareAnnosWithLocation:currentLocation isUserManuallyAdded:NO];
            
            // 记录新足迹点后，再更新
            lastRecordLocation = currentLocation;
            lastRecordDate = NOW;
        }
       
    }
    //NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)addRecordedShareAnnosWithLocation:(CLLocation *)newLocation isUserManuallyAdded:(BOOL)isUserManuallyAdded{
    EverywhereShareAnnotation *shareAnno = [EverywhereShareAnnotation new];
    shareAnno.coordinateWGS84 = newLocation.coordinate;
    shareAnno.startDate = NOW;
    shareAnno.customTitle = [NSString stringWithFormat:@"Footprint %lu",(unsigned long)(recordedShareAnnos.count + 1)];
    shareAnno.isUserManuallyAdded = isUserManuallyAdded;
    [recordedShareAnnos addObject:shareAnno];
    [self.myMapView addAnnotation:shareAnno];
    
    if (recordedShareAnnos.count > 1){
        //NSInteger lastIndex = [recordedShareAnnos indexOfObject:shareAnno];
        EverywhereShareAnnotation *lastAnno = recordedShareAnnos[recordedShareAnnos.count - 2];
        [self.myMapView addOverlay:[AssetsMapProVC createLineMKPolylineBetweenStartCoordinate:lastAnno.coordinate endCoordinate:shareAnno.coordinate]];
        [self.myMapView addOverlay:[AssetsMapProVC createArrowMKPolygonBetweenStartCoordinate:lastAnno.coordinate endCoordinate:shareAnno.coordinate]];
    }
    
    // 如果达到设置最大数据，重新开始一条新的记录，用于节省内存，防止崩溃
    if (recordedShareAnnos.count == self.settingManager.maxFootprintsCountForRecord) {
        [self intelligentlySaveRecordedShareAnnosAndClearCatche];
        recordedShareAnnos = [NSMutableArray new];
    }
}

@end
