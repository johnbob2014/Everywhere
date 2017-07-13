//
//  AssetsMapProVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define MKOverlayTitleForMapModeColor @"MKOverlayTitleForMapModeColor"
#define MKOverlayTitleForRandomColor @"MKOverlayTitleForRandomColor"
#define MKOverlayTitleForRedColor @"MKOverlayTitleForRedColor"

#define ContentSizeInPopup_Big CGSizeMake(ScreenWidth - 10, ScreenHeight - 10 - 80)
#define LandscapeContentSizeInPopup_Big CGSizeMake(ScreenHeight - 10 - 80, ScreenWidth - 10)

#define NaviBarButtonSize CGSizeMake(44, 44)
//#define NaviBarButtonOffset ScreenWidth > 375 ? 30 : 15
#define NaviBarButtonOffset (ScreenWidth - 44 * 5 - 10 - 20)/4.0

#define ButtionSize (ScreenHeight > 568 ? CGSizeMake(44, 44) : CGSizeMake(36, 36))
#define ButtonEdgeLength (ScreenHeight > 568 ? 44 : 36)
#define ButtonOffset (ScreenHeight > 568 ? 16 : 12)

#import "AssetsMapProVC.h"
@import Photos;
@import MapKit;

#import "EverywhereAppDelegate.h"
#import "EverywhereCoreDataHeader.h"

#import "EverywhereAnnotation.h"
#import "EverywhereSettingManager.h"
#import "FootprintAnnotation.h"
#import "FootprintsRepository.h"

#import "SimpleImageBrowser.h"

#import "GCStarAnnotationView.h"
#import "GCLocationAnalyser.h"
#import <STPopup.h>
#import "GCLocationAnalyser.h"
#import "GCPhotoManager.h"
#import "LocationInfoBar.h"
#import "PlacemarkInfoBar.h"
#import "CLPlacemark+Assistant.h"
#import "DatePickerProVC.h"
#import "AssetDetailVC.h"
#import "UIButton+Assistant.h"
#import "MapModeBar.h"
#import "LocationPickerVC.h"
#import "SettingVC.h"
#import "ShareImageVC.h"
#import "ShareFootprintsRepositoryVC.h"
#import "ShareBar.h"
#import "InAppPurchaseVC.h"
#import "FootprintsRepositoryPickerVC.h"
#import "FootprintAnnotationPickerVC.h"
#import "CLPlacemark+Assistant.h"
#import "RecordModeSettingBar.h"

#import "EverywhereCoreDataManager.h"
#import "PHAssetInfo.h"
#import "CoordinateInfo.h"

/*
#import "GCPolyline.h"
#import "GCRoutePolyline.h"
#import "GCRoutePolylineManager.h"
*/

@interface AssetsMapProVC () <MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic) MKMapView *myMapView;
@property (assign,nonatomic) ShowUserLocationMode showUserLocationMode;
@property (strong,nonatomic) CLLocation *userLocationWGS84;
@property (strong,nonatomic) CLLocation *userLocationGCJ02;

#pragma mark 数据管理器
//@property (strong,nonatomic) EverywhereCoreDataManager *cdManager;
@property (strong,nonatomic) EverywhereSettingManager *settingManager;

#pragma mark 用于更新数据
@property (strong,nonatomic) NSArray <PHAssetInfo *> *assetInfoArray;
@property (strong,nonatomic) NSArray <PHAsset *> *assetArray;
@property (strong,nonatomic) NSArray <NSArray <PHAsset *> *> *assetsArray;

@property (strong,nonatomic) NSDate *startDate;
@property (strong,nonatomic) NSDate *endDate;
@property (strong,nonatomic) NSString *lastPlacemark;

@property (strong,nonatomic) NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary;

#pragma mark 添加的各种Annos
@property (strong,nonatomic) NSArray <id<MKAnnotation>> *addedIDAnnotations;
@property (strong,nonatomic) NSArray <EverywhereAnnotation *> *addedEWAnnotations;
@property (strong,nonatomic) NSArray <FootprintAnnotation *> *addedEWFootprintAnnotations;
@property (assign,nonatomic) NSInteger currentAnnotationIndex;

/**
 *  收藏的地点数组
 */
@property (strong,nonatomic) NSArray <CoordinateInfo *> *favoriteCoordinateInfoArray;

#pragma mark 用于模式转换
@property (assign,nonatomic) BOOL isInBaseMode;
@property (assign,nonatomic) BOOL isInRecordMode;
//@property (assign,nonatomic) BOOL allowBrowserMode;
@property (strong,nonatomic) UIColor *currentTintColor;

#pragma mark 用于Record模式的用户设置
@property (assign,nonatomic) CLLocationDistance minDistanceForRecord;
@property (assign,nonatomic) NSTimeInterval minTimeIntervalForRecord;
/**
 *  当前显示的足迹包
 */
@property (strong,nonatomic) FootprintsRepository *currentShowEWFR;
@end

@implementation AssetsMapProVC{
    
    CLLocationManager *locationManagerForUserLocation;
    NSTimer *checkAuthorizationStatusTimer;
    /**
     *  最后一次接收的足迹包
     */
    FootprintsRepository *lastReceivedEWFR;
    
#pragma mark 用于模式转换时恢复数据
    NSString *savedTitleForBaseMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForBaseMode;
    NSArray<id<MKAnnotation>> *savedFootprintAnnotationsForBaseMode;
    NSArray<id<MKOverlay>> *savedOverlaysForBaseMode;
    //NSDate *savedStartDateForBaseMode;
    //NSDate *savedEndDateForBaseMode;
    
    /*
    NSString *savedTitleForMomentMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForMomentMode;
    NSArray<id<MKOverlay>> *savedOverlaysForMomentMode;
    NSDate *savedStartDateForMomentMode;
    NSDate *savedEndDateForMomentMode;
    
    NSString *savedTitleForLocationMode;
    NSArray<id<MKAnnotation>> *savedAnnotationsForLocationMode;
    NSArray<id<MKOverlay>> *savedOverlaysForLocationMode;
    NSDate *savedStartDateForLocationMode;
    NSDate *savedEndDateForLocationMode;
    */

#pragma mark 用于RecordMode
    CLLocation *lastRecordLocation;
    NSDate *lastRecordDate;
    NSMutableArray <FootprintAnnotation *> *recordedFootprintAnnotations;
    NSTimer *timerForRecord;
    NSMutableArray <MKPolyline *> *savedPolylineForRecord;

#pragma mark 各种Bar
    STPopupController *popupController;
    
    MapModeBar *msBaseModeBar;
    MapModeBar *msExtenedModeBar;
    UIButton *quiteBrowserModeButton;
    
    UIView *recordModeBar;
    UIButton *startPauseRecordButton;
    UILabel *speedLabelInRMB;
    UILabel *distanceAndFPCountLabelInRMB;
    CLLocationDistance totalDistanceForRecord;
    
    LocationInfoBar *locationInfoBar;
    float locationInfoBarHeight;
    BOOL locationInfoBarIsOutOfVisualView;
    
    PlacemarkInfoBar *placemarkInfoBar;
    float placemarkInfoBarHeight;
    BOOL placemarkInfoBarIsHidden;
    
    ShareBar *shareBar;
    
    UIButton *changeOverlayStyleButton;
    UIButton *userLocationButton;
    
    UIView *leftBottomVerticalBar;
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
    //__block CLLocationDistance maxDistance;
    __block CLLocationDistance totalDistance;
    __block CLLocationDistance totalArea;
    
    UIColor *lastRandomColor;
}

#pragma mark - Life Cycle

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning{
    /*
    [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Receive Memory Warning.AlbumMaps will clear map data.", @"足迹点较多，收到内存警告提醒，相册地图将进行内存清理，请重新选择日期或地点！")]
                       animated:YES
                     completion:nil];
     */
    
    //[self clearMapData];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //EverywhereCoreDataManager = [EverywhereCoreDataManager defaultManager];
    self.settingManager = [EverywhereSettingManager defaultManager];
    
    self.isInBaseMode = YES;
    
    // 以下顺序不要打乱！！！！！！
    
    [self initMapView];
    
    [self initMapModeBar];
    
    [self initNaviBar];
    
    [self initLocationInfoBar];
    
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
    
    [self performSelector:@selector(checkFirstLaunch) withObject:nil afterDelay:20.0];
    
    [self performSelector:@selector(checkNewVersion) withObject:nil afterDelay:60.0];
}

- (void)checkFirstLaunch{
    // 首次启动
    if(!self.settingManager.everLaunched){
        NSLog(@"首次启动!!!");
        self.settingManager.everLaunched = YES;
        
        self.settingManager.trialCountForShareAndBrowse = 10;
        self.settingManager.trialCountForRecordAndEdit = 10;
        
        UIAlertController *alert = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Welcome to Album Maps", @"欢迎使用《相册地图》") message:NSLocalizedString(@"Open User Guide?", @"是否需要查看使用指南？") okActionHandler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.settingManager.appUserGuideURLString]];
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)checkNewVersion{
    int currentVersion = [self.settingManager.appVersion stringByReplacingOccurrencesOfString:@"." withString:@""].intValue;
    int lastVersion = [self.settingManager.lastAppVersion stringByReplacingOccurrencesOfString:@"." withString:@""].intValue;
    if (currentVersion > lastVersion) {
        
        UIAlertController *alert = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"温馨提示") message:NSLocalizedString(@"Album Maps for macOS is available now.", @"Mac版本《相册地图》已经上线，欢迎使用！")];
        [self presentViewController:alert animated:YES completion:nil];
        
        self.settingManager.lastAppVersion = self.settingManager.appVersion;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(DEBUGMODE) NSLog(@"AssetsMapProVC: %@",NSStringFromSelector(_cmd));
    
    EverywhereAppDelegate *appDelegate = (EverywhereAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (self.isInBaseMode) {
        self.currentTintColor = self.settingManager.baseTintColor;
        
        [self updateBarColor:self.currentTintColor];
        
        if (verticalBarIsAlphaZero) [self alphaShowHideVerticalBar];
        
        msBaseModeBar.alpha = 1;
        naviBar.alpha = 1;
        locationInfoBar.alpha = 1;
        shareBar.alpha = 0;
        
        appDelegate.window.tintColor = self.settingManager.baseTintColor;
        
    }else{
        self.currentTintColor = self.settingManager.extendedTintColor;
        appDelegate.window.tintColor = self.settingManager.extendedTintColor;
    }
    
    [[CoordinateInfo fetchAllCoordinateInfosInManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]] enumerateObjectsUsingBlock:^(CoordinateInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addRemoveCoordinateInfoAnnotation:obj];
    }];
}

- (void)updateBarColor:(UIColor *)newColor{
    locationInfoBar.backgroundColor = newColor;
    placemarkInfoBar.backgroundColor = newColor;
    naviBar.backgroundColor = newColor;
    currentAnnotationIndexLabel.backgroundColor = newColor;
    shareBar.backgroundColor = newColor;
    
    msBaseModeBar.contentViewBackgroundColor = newColor;
    msExtenedModeBar.contentViewBackgroundColor = self.settingManager.extendedTintColor;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([self checkPHAuthorizationStatus]){
        // 更新照片数据
        [self showNotification:@([EverywhereCoreDataManager updatePHAssetInfoFromPhotoLibrary])];
    }
    
    // 更新地址数据
    if (!allPlaceMarkReverseGeocodeSucceedForThisTime) {
        [EverywhereCoreDataManager asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:^(NSInteger reverseGeocodeSucceedCountForThisTime, NSInteger reverseGeocodeSucceedCountForTotal, NSInteger totalPHAssetInfoCount) {
            allPlaceMarkReverseGeocodeSucceedForThisTime = reverseGeocodeSucceedCountForTotal == totalPHAssetInfoCount;
        }];
    }
}

- (BOOL)checkPHAuthorizationStatus{
    BOOL authorized = YES;
    
    PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
    
    if (authorizationStatus == PHAuthorizationStatusDenied || authorizationStatus == PHAuthorizationStatusRestricted){
        authorized = NO;
        
       UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")
                                                                                        message:NSLocalizedString(@"You denied AlbumMaps to access your album so it can not show your album footprints.Please change the authorization status in iOS Settings.", @"您未允许相册地图访问您的相册，无法显示您的相册足迹，请前往设置更改。")
                                                                                      okActionHandler:^(UIAlertAction *action) {
                                                                                           NSURL*url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                                           [[UIApplication sharedApplication] openURL:url];
        }];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else if(authorizationStatus == PHAuthorizationStatusNotDetermined){
        authorized = NO;
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
        
        checkAuthorizationStatusTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(observePHAuthorizationStatus) userInfo:nil repeats:YES];
    }
    
    return authorized;

}

- (void)observePHAuthorizationStatus{
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized ){
        
        [self showNotification:@([EverywhereCoreDataManager updatePHAssetInfoFromPhotoLibrary])];
        
        [checkAuthorizationStatusTimer invalidate];
        checkAuthorizationStatusTimer = nil;
    }
}

- (void)showNotification:(NSNumber *)countNumber{
    NSInteger count = [countNumber integerValue];
    if (count > 0){
        NSString *secondLastUpdateDateString = nil;
        if (EverywhereCoreDataManager.secondLastUpdateDate)
            secondLastUpdateDateString = [NSString stringWithFormat:@"%@ : %@",NSLocalizedString(@"Last update time", @"上次更新时间"),[EverywhereCoreDataManager.secondLastUpdateDate stringWithFormat:@"yyyy-MM-dd hh:mm:ss"]];
        
        UILocalNotification *noti = [UILocalNotification new];
        
        NSMutableString *messageMS = [NSMutableString new];
        [messageMS appendFormat:@"%@ : %lu",NSLocalizedString(@"Added New Photo Count", @"新增照片数量"),(long)count];
        if (secondLastUpdateDateString) [messageMS appendFormat:@"\n%@",secondLastUpdateDateString];
        
        noti.alertBody = messageMS;
        noti.alertAction = NSLocalizedString(@"Action", @"操作");
        noti.soundName = UILocalNotificationDefaultSoundName;
        //noti.applicationIconBadgeNumber = count;
        [[UIApplication sharedApplication] presentLocalNotificationNow:noti];

        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"AlbumMaps Notes", @"相册地图提示") message:messageMS]
                           animated:YES
                         completion:nil];
    }
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
            if (authorizationStatus == kCLAuthorizationStatusNotDetermined || authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
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
        locationInfoBar.naviToHereButton.enabled = self.myMapView.showsUserLocation;
        
        // if (self.isInBaseMode) self.locationManagerForRecording.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
    }else{
        // 如果没有用户授权，申请使用GPS数据
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            locationManagerForUserLocation = [CLLocationManager new];
            [locationManagerForUserLocation requestWhenInUseAuthorization];
        });
    }
}

// ⭕️实时更新locationInfoBar位置信息
- (void)setUserLocationWGS84:(CLLocation *)userLocationWGS84{
    _userLocationWGS84 = userLocationWGS84;
    //locationInfoBar.userCoordinateWGS84 = userLocationWGS84.coordinate;
    CLLocationSpeed speedmPerSecond = userLocationWGS84.speed;
    CLLocationSpeed speedkmPerhour = speedmPerSecond * 3600.0 / 1000.0;
    //speedLabelInRMB.text = [NSString stringWithFormat:@"%.2fkm/h %.2fm/s",speedkmPerhour,speedmPerSecond];
    speedLabelInRMB.text = [NSString stringWithFormat:@"%.2fkm/h",speedkmPerhour];
}

- (void)setUserLocationGCJ02:(CLLocation *)userLocationGCJ02{
    _userLocationGCJ02 = userLocationGCJ02;
    locationInfoBar.userCoordinateGCJ02 = userLocationGCJ02.coordinate;
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

- (void)setPlacemarkDictionary:(NSDictionary<NSString *,NSArray<NSString *> *> *)placemarkDictionary{
    _placemarkDictionary = placemarkDictionary;
    //if(DEBUGMODE) NSLog(@"SubThoroughfareArray count : %lu",placemarkDictionary[kSubThoroughfareArray].count);
    [self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary];
}

- (void)setAssetInfoArray:(NSArray<PHAssetInfo *> *)assetInfoArray{
    if (!assetInfoArray) return;
    
    _assetInfoArray = assetInfoArray;
    
    [self updateMapModeBar];
    currentAnnotationIndexLabel.text = @"";
    
    // 更新Placemark信息
    self.placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:assetInfoArray];
    
    BOOL noAsset = YES;
    if (assetInfoArray.count > 0) {
        
        NSMutableArray *assetIDArry = [NSMutableArray new];
        [assetInfoArray enumerateObjectsUsingBlock:^(PHAssetInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(![obj.eliminateThisAsset boolValue])
                [assetIDArry addObject:obj.localIdentifier];
        }];
        
        if (assetIDArry.count > 0){
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Reading Photo Album...", @"正在读取相册...")];
            PHFetchOptions *options = [PHFetchOptions new];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            PHFetchResult <PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:assetIDArry options:options];
            
            self.startDate = fetchResult.firstObject.creationDate;
            self.endDate = fetchResult.lastObject.creationDate;
            
            self.assetArray = (NSArray <PHAsset *> *)fetchResult;
            if (self.assetArray.count > 0) noAsset = NO;
        }
    }
    
    if (noAsset){
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"No photos in selected date range or location", @"所选日期或地点没有照片")];
        [SVProgressHUD dismissWithDelay:2.0];
    }
}

- (void)setAssetArray:(NSArray<PHAsset *> *)assetArray{
    if (!assetArray || assetArray.count == 0) return;
    
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Dividing into groups...", @"正在分组...")];
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
    if (!assetsArray || assetsArray.count == 0) return;
    
    _assetsArray = assetsArray;
    
    self.addedEWAnnotations = nil;
    self.addedEWFootprintAnnotations = nil;
    [self addAnnotations];
    
    if (self.settingManager.mapBaseMode == MapBaseModeMoment){
        [self addLineOverlaysPro:self.addedEWAnnotations];
    }else{
        [self addCircleOverlaysPro:self.addedEWAnnotations radius:self.settingManager.mergeDistanceForLocation / 2.0];
    }
    
    [self updatePlacemarkInfoBarTotolInfo];
}

- (void)setAddedIDAnnotations:(NSArray<id<MKAnnotation>> *)addedIDAnnotations{
    _addedIDAnnotations = addedIDAnnotations;
    self.currentAnnotationIndex = 0;
    
    if (addedIDAnnotations){
        [self.myMapView showAnnotations:addedIDAnnotations animated:NO];
        [self.myMapView selectAnnotation:addedIDAnnotations.firstObject animated:YES];
    }//[self moveMapViewToFirstAnnotationWithDistance:0];
}

- (void)setIsInBaseMode:(BOOL)isInBaseMode{
    _isInBaseMode = isInBaseMode;
    if (isInBaseMode) self.currentTintColor = self.settingManager.baseTintColor;
    else self.currentTintColor = self.settingManager.extendedTintColor;
}

- (NSArray<CoordinateInfo *> *)favoriteCoordinateInfoArray{
    return [CoordinateInfo fetchFavoriteCoordinateInfosInManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
}

#pragma mark - Init Interface

#pragma mark MapView

- (void)initMapView{
    self.myMapView = [MKMapView newAutoLayoutView];
    self.myMapView.delegate = self;
    
    self.myMapView.mapType = MKMapTypeStandard;
    // 禁止旋转
    self.myMapView.rotateEnabled = NO;
    // 禁止倾斜
    self.myMapView.pitchEnabled = NO;
    
    //if(iOS9) self.myMapView.showsScale = YES;
    
    [self.view addSubview:self.myMapView];
    [self.myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    UITapGestureRecognizer *mapViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapGR:)];
    mapViewTapGR.numberOfTapsRequired = 1;
    [self.myMapView addGestureRecognizer:mapViewTapGR];
    
    /*
    UITapGestureRecognizer *mapViewThreeTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewThreeTapGR:)];
    mapViewThreeTapGR.delegate = self;
    mapViewThreeTapGR.numberOfTouchesRequired = 3;
    mapViewThreeTapGR.numberOfTapsRequired = 1;
    [self.myMapView addGestureRecognizer:mapViewThreeTapGR];
     */
    
    [self.myMapView addAnnotations:self.favoriteCoordinateInfoArray];
}

- (void)mapViewTapGR:(id)sender{
    
    if (self.myMapView.selectedAnnotations.count == 0){
        [self alphaShowHideVerticalBar];
    }
    
    
    self.settingManager.praiseCount++;
    if(DEBUGMODE) NSLog(@"praiseCount : %lu",(long)self.settingManager.praiseCount);
    if (self.settingManager.praiseCount == 50) {
        [self askForPraise];
        self.settingManager.praiseCount = 0;
    }
}

/*
- (void)mapViewThreeTapGR:(id)sender{
    [self changeToRouteOverlays];
}
*/

- (void)askForPraise{
    NSString *alertTitle = NSLocalizedString(@"AlbumMaps", @"相册地图");
    NSString *alertMessage = NSLocalizedString(@"Is it cool without any advertisements? The author is toil and moil. So take a little time to praise me, please!🙏", @"没有广告是不是很清爽？作者也不容易，抽空给个好评呗！🙏");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Praise",@"去给好评") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.settingManager.appURLString]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"I'm busy.",@"残忍拒绝") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = okAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ModeBar

- (void)initMapModeBar{
    WEAKSELF(weakSelf);
    
    NSArray *baseItems = [NSLocalizedString(@"Moment Mode,Location Mode",@"时刻模式,地点模式") componentsSeparatedByString:@","];
    msBaseModeBar = [[MapModeBar alloc]initWithModeSegItems:baseItems
                                                selectedSegIndex:self.settingManager.mapBaseMode
                                                 leftButtonImage:[UIImage imageNamed:@"IcoMoon_Calendar"]
                                                rightButtonImage:[UIImage imageNamed:@"IcoMoon_Dribble3"]];
    msBaseModeBar.modeSegEnabled = YES;
    
    [self.view addSubview:msBaseModeBar];
    [msBaseModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msBaseModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msBaseModeBar.modeChangedHandler = ^(UISegmentedControl *sender){
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
    
    NSArray *extenedItems = [NSLocalizedString(@"Browser Mode,Record Mode",@"浏览模式,记录模式") componentsSeparatedByString:@","];
    msExtenedModeBar = [[MapModeBar alloc]initWithModeSegItems:extenedItems
                                                    selectedSegIndex:self.settingManager.mapExtendedMode
                                                     leftButtonImage:[UIImage imageNamed:@"IcoMoon_DrawerFull"]
                                                    rightButtonImage:[UIImage imageNamed:@"IcoMoon_DrawerEmpty"]];
    
    
    [self.view addSubview:msExtenedModeBar];
    [msExtenedModeBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(20, 5, 0, 5) excludingEdge:ALEdgeBottom];
    [msExtenedModeBar autoSetDimension:ALDimensionHeight toSize:60];
    
    msExtenedModeBar.modeChangedHandler = ^(UISegmentedControl *sender){
        weakSelf.settingManager.mapExtendedMode = sender.selectedSegmentIndex;
        // msExtenedModeBar.info = extenedItems[sender.selectedSegmentIndex];
        
        // 扩展模式切换
        if (sender.selectedSegmentIndex == MapExtendedModeBrowser) {
            
            [weakSelf enterBrowserMode];
        }else{
            [weakSelf enterRecordMode];
        }
    };
    
    msExtenedModeBar.leftButtonTouchDownHandler = ^(UIButton *sender) {
        if (weakSelf.settingManager.hasPurchasedShareAndBrowse && weakSelf.settingManager.hasPurchasedRecordAndEdit) [weakSelf showFootprintsRepositoryPickerAllType];
        else if (weakSelf.settingManager.hasPurchasedShareAndBrowse || weakSelf.settingManager.trialCountForShareAndBrowse > 0 || weakSelf.settingManager.trialCountForRecordAndEdit > 0) [weakSelf showFootprintsRepositoryPickerSentReceived];
        else [weakSelf showPurchaseShareFunctionAlertController];
    };
    
    msExtenedModeBar.rightButtonTouchDownHandler = ^(UIButton *sender){
        if (weakSelf.settingManager.hasPurchasedShareAndBrowse && weakSelf.settingManager.hasPurchasedRecordAndEdit) [weakSelf showFootprintsRepositoryPickerAllType];
        else if (weakSelf.settingManager.hasPurchasedRecordAndEdit || weakSelf.settingManager.trialCountForRecordAndEdit > 0) [weakSelf showFootprintsRepositoryPickerRecordedEdited];
        else [weakSelf showPurchaseRecordFunctionAlertController];
    };
    
    msExtenedModeBar.hidden = YES;
    //msShareEditModeBar.modeSegEnabled = NO;

}

- (void)changeToBaseMode:(MapBaseMode)mapBaseMode{
    /*
    // 保存现有数据
    if (mapBaseMode == MapBaseModeMoment) {
        // 保存LocationMode数据
        savedTitleForLocationMode = msBaseModeBar.info;
        savedAnnotationsForLocationMode = self.addedEWAnnos;
        savedOverlaysForLocationMode = self.myMapView.overlays;
        savedStartDateForLocationMode = self.startDate;
        savedEndDateForBaseMode = self.endDate;
    }else{
        // 保存MomentMode数据
        savedTitleForMomentMode = msBaseModeBar.info;
        savedAnnotationsForMomentMode = self.addedEWAnnos;
        savedOverlaysForMomentMode = self.myMapView.overlays;
        savedStartDateForMomentMode = self.startDate;
        savedEndDateForMomentMode = self.endDate;
    }
    */
    
    [self clearMapData];
    
    /*
    // 恢复之前的数据
    if (mapBaseMode == MapBaseModeMoment){
        // 恢复MomentMode数据
        msBaseModeBar.info = savedTitleForMomentMode;
        self.startDate = savedStartDateForMomentMode;
        self.endDate = savedEndDateForMomentMode;
        self.addedEWAnnos = savedAnnotationsForMomentMode;
        self.addedIDAnnos = savedAnnotationsForMomentMode;
        [self.myMapView addAnnotations:self.addedEWAnnos];
        [self.myMapView addOverlays:savedOverlaysForMomentMode];
    }else{
        // 恢复LocationMode数据
        msBaseModeBar.info = savedTitleForLocationMode;
        self.startDate = savedStartDateForLocationMode;
        self.endDate = savedEndDateForLocationMode;
        self.addedEWAnnos = savedAnnotationsForLocationMode;
        self.addedIDAnnos = savedAnnotationsForLocationMode;
        [self.myMapView addAnnotations:self.addedEWAnnos];
        [self.myMapView addOverlays:savedOverlaysForLocationMode];
    }
    */
    
    //[self updateVisualViewForEWAnnos];
}

- (void)clearMapData{
    [self.myMapView removeAnnotations:self.addedIDAnnotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];

    self.assetInfoArray = nil;
    self.assetArray = nil;
    self.assetsArray = nil;
    
    self.addedEWAnnotations = nil;
    self.addedEWFootprintAnnotations = nil;
    self.addedIDAnnotations = nil;
    
    self.endDate = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.lastPlacemark = @"";
    
    self.placemarkDictionary = nil;
}


- (void)updateMapModeBar{
    switch (self.settingManager.mapBaseMode) {
        case MapBaseModeMoment:
            msBaseModeBar.info = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate firstDayOfWeek:self.settingManager.firstDayOfWeek];
            //savedTitleForMomentMode = msBaseModeBar.info;
            break;
        case MapBaseModeLocation:
            msBaseModeBar.info = self.lastPlacemark;
            //savedTitleForLocationMode = msBaseModeBar.info;
            break;
        default:
            break;
    }
}


- (void)showDatePicker{
    DatePickerProVC *datePickerProVC = [DatePickerProVC new];
    datePickerProVC.dateMode = self.settingManager.dateMode;
    datePickerProVC.firstDayOfWeek = self.settingManager.firstDayOfWeek;
    
    WEAKSELF(weakSelf);
    
    datePickerProVC.dateModeChangedHandler = ^(DateMode choosedDateMode){
        weakSelf.settingManager.dateMode = choosedDateMode;
    };
    
    datePickerProVC.dateRangeChangedHandler = ^(NSDate *choosedStartDate,NSDate *choosedEndDate){
        //settingManager.mapBaseMode = MapBaseModeMoment;
        weakSelf.startDate = choosedStartDate;
        weakSelf.endDate = choosedEndDate;
        
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Reading data...", @"正在解析数据...")];
        weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:weakSelf.startDate toEndDate:weakSelf.endDate inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
    };
    
    popupController = [[STPopupController alloc] initWithRootViewController:datePickerProVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showLocationPicker{
    WEAKSELF(weakSelf);
    LocationPickerVC *locationPickerVC = [LocationPickerVC new];
    locationPickerVC.initLocationMode = self.settingManager.locationMode;
    
    NSArray <PHAssetInfo *> *allAssetInfoArray = [PHAssetInfo fetchAllAssetInfosInManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
    locationPickerVC.placemarkInfoDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:allAssetInfoArray];
    
    locationPickerVC.locationModeDidChangeHandler = ^(LocationMode choosedLocationMode){
        weakSelf.settingManager.locationMode = choosedLocationMode;
    };
    
    locationPickerVC.locationDidChangeHandler = ^(NSString *choosedLocation){
        weakSelf.settingManager.lastPlacemark = choosedLocation;
        weakSelf.lastPlacemark = choosedLocation;
        
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Reading data...", @"正在解析数据...")];
        weakSelf.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:choosedLocation inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
    };
    
    locationPickerVC.contentSizeInPopup = ContentSizeInPopup_Big;
    locationPickerVC.landscapeContentSizeInPopup = LandscapeContentSizeInPopup_Big;
    popupController = [[STPopupController alloc] initWithRootViewController:locationPickerVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}

- (void)showFootprintsRepositoryPickerAllType{
    [self showFootprintsRepositoryPicker:FootprintsRepositoryTypeSent|FootprintsRepositoryTypeReceived|FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited];
}

- (void)showFootprintsRepositoryPickerSentReceived{
    [self showFootprintsRepositoryPicker:FootprintsRepositoryTypeSent|FootprintsRepositoryTypeReceived];
}

- (void)showFootprintsRepositoryPickerRecordedEdited{
    [self showFootprintsRepositoryPicker:FootprintsRepositoryTypeRecorded|FootprintsRepositoryTypeEdited];
}

- (void)showFootprintsRepositoryPicker:(NSUInteger)showFootprintsRepositoryType{
    WEAKSELF(weakSelf);
    
    FootprintsRepositoryPickerVC *footprintsRepositoryPickerVC = [FootprintsRepositoryPickerVC new];
    footprintsRepositoryPickerVC.showFootprintsRepositoryType = showFootprintsRepositoryType;
    footprintsRepositoryPickerVC.footprintsRepositoryDidChangeHandler = ^(FootprintsRepository *choosedFootprintsRepository){
        [weakSelf checkBeforeShowFootprintsRepository:choosedFootprintsRepository];
    };
   
    footprintsRepositoryPickerVC.contentSizeInPopup = ContentSizeInPopup_Big;//CGSizeMake(300, 400);
    footprintsRepositoryPickerVC.landscapeContentSizeInPopup = LandscapeContentSizeInPopup_Big;//CGSizeMake(400, 320);
    popupController = [[STPopupController alloc] initWithRootViewController:footprintsRepositoryPickerVC];
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
    [firstButton setImage:[UIImage imageNamed:@"IcoMoon_Arrow-Left_WBG"] forState:UIControlStateNormal];
    firstButton.titleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
    [firstButton addTarget:self action:@selector(firstButtonPressed:) forControlEvents:UIControlEventTouchDown];
    firstButton.alpha = 0.6;
    [naviBar addSubview:firstButton];
    [firstButton autoSetDimensionsToSize:NaviBarButtonSize];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [firstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
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
    [currentAnnotationIndexLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-5];
    [currentAnnotationIndexLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    self.currentAnnotationIndex = 0;
    
    isPlaying = NO;
}

- (void)firstButtonPressed:(UIButton *)sender{
    
    [sender performZoomAnimationWithXScale:1.2 yScale:1.2 zoomInDuration:0.15 zoomOutDuration:0.1];
    
    id<MKAnnotation> idAnno = self.addedIDAnnotations.firstObject;
    [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
    [self.myMapView selectAnnotation:idAnno animated:YES];
}

- (void)previousButtonPressed:(UIButton *)sender{
    [sender performZoomAnimationWithXScale:1.2 yScale:1.2 zoomInDuration:0.15 zoomOutDuration:0.1];
    
    id<MKAnnotation> idAnno = self.myMapView.selectedAnnotations.firstObject;
    
    // 导航不适用于GCStarAnnotationView
    if ([idAnno isKindOfClass:[CoordinateInfo class]]) return;
    
    if (!idAnno && self.currentAnnotationIndex) {
        idAnno = self.addedIDAnnotations[self.currentAnnotationIndex];
    }
    if (idAnno) {
        NSInteger index = [self.addedIDAnnotations indexOfObject:idAnno];
        if (--index >= 0) {
            [self.myMapView deselectAnnotation:idAnno animated:YES];
            idAnno = self.addedIDAnnotations[index];
            [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
            [self.myMapView selectAnnotation:idAnno animated:YES];
        }
    }
}

- (void)playButtonPressed:(UIButton *)sender{
    if (isPlaying) {
        // 暂停播放
        playButton.transform = CGAffineTransformIdentity;
        [playTimer invalidate];
        playTimer = nil;
    }else{
        // 开始播放
        playButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
        playTimer = [NSTimer scheduledTimerWithTimeInterval:self.settingManager.playTimeInterval target:self selector:@selector(nextButtonPressed:) userInfo:nil repeats:YES];
    }
    isPlaying = !isPlaying;
}

- (void)nextButtonPressed:(UIButton *)sender{
    if([sender isKindOfClass:[UIButton class]]) [sender performZoomAnimationWithXScale:1.2 yScale:1.2 zoomInDuration:0.15 zoomOutDuration:0.1];
    
    id<MKAnnotation> idAnno = self.myMapView.selectedAnnotations.firstObject;
    
    // 导航不适用于GCStarAnnotationView
    if ([idAnno isKindOfClass:[CoordinateInfo class]]) return;
    
    if (!idAnno && self.currentAnnotationIndex) {
        idAnno = self.addedIDAnnotations[self.currentAnnotationIndex];
    }
    
    if (!idAnno) idAnno = self.addedIDAnnotations.firstObject;
    
    if (idAnno) {
        NSInteger index = [self.addedIDAnnotations indexOfObject:idAnno];
        if (++index < self.addedIDAnnotations.count) {
            [self.myMapView deselectAnnotation:idAnno animated:YES];
            idAnno = self.addedIDAnnotations[index];
            
            [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
            [self.myMapView selectAnnotation:idAnno animated:YES];
        }
    }
}

- (void)lastButtonPressed:(UIButton *)sender{
    [sender performZoomAnimationWithXScale:1.2 yScale:1.2 zoomInDuration:0.15 zoomOutDuration:0.1];
    id<MKAnnotation> idAnno = self.addedIDAnnotations.lastObject;
    [self.myMapView setCenterCoordinate:idAnno.coordinate animated:NO];
    [self.myMapView selectAnnotation:idAnno animated:YES];
}

- (CLLocation *)averageLocationForLocations:(NSArray <CLLocation *> *)locations{
    
    CLLocationCoordinate2D resultCoordinate = CLLocationCoordinate2DMake(0, 0);
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
    locationInfoBarHeight = 200;
    locationInfoBar = [[LocationInfoBar alloc] initWithFrame:CGRectMake(5, -locationInfoBarHeight - 40, ScreenWidth - 10, locationInfoBarHeight)];
    [self.view addSubview:locationInfoBar];
    locationInfoBarIsOutOfVisualView = YES;
    
    UISwipeGestureRecognizer *swipeUpGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(locationInfoBarSwipeUp:)];
    swipeUpGR.direction = UISwipeGestureRecognizerDirectionUp;
    [locationInfoBar addGestureRecognizer:swipeUpGR];
    
    
    WEAKSELF(weakSelf);
    locationInfoBar.didGetMKDirectionsResponseHandler = ^(MKDirectionsResponse *response){
        MKRoute *route = response.routes.firstObject;
        MKPolyline *routePolyline = route.polyline;
        routePolyline.title = MKOverlayTitleForRedColor;
        dispatch_async(dispatch_get_main_queue(), ^{
            if(routePolyline) [weakSelf.myMapView addOverlay:routePolyline];
        });
    };
    
    locationInfoBar.didChangeFavoritePropertyHandler = ^(CoordinateInfo *coordinateInfo){
        [weakSelf addRemoveCoordinateInfoAnnotation:coordinateInfo];
    };
    
    locationInfoBar.didTouchDownRetractButtonHandler = ^(){
        [weakSelf showHideLocationInfoBar];
    };
    
    locationInfoBar.naviToHereButton.enabled = NO;
}

/**
 *  从地图上添加或删除指定的CoordinateInfo
 */
- (void)addRemoveCoordinateInfoAnnotation:(CoordinateInfo *)coordinateInfo{
    NSArray *annotations = self.myMapView.annotations;
    if ([coordinateInfo.favorite boolValue] && ![annotations containsObject:coordinateInfo]){
        [self.myMapView addAnnotation:coordinateInfo];
    }
    
    if (![coordinateInfo.favorite boolValue] && [annotations containsObject:coordinateInfo]){
        [self.myMapView removeAnnotation:coordinateInfo];
    }
}

- (void)locationInfoBarSwipeUp:(UISwipeGestureRecognizer *)sender{
    [self hideLocationInfoBar];
}

- (void)showHideLocationInfoBar{
    if (locationInfoBarIsOutOfVisualView) [self showLocationInfoBar];
    else [self hideLocationInfoBar];
}

- (void)showLocationInfoBar{
    if (locationInfoBar.hidden) locationInfoBar.hidden = NO;
    
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
    
    //NSDictionary <NSString *,NSArray<NSString *> *> *placemarkDictionary = [PHAssetInfo placemarkInfoFromAssetInfos:self.assetInfoArray];
    //[self updatePlacemarkInfoBarWithPlacemarkDictionary:placemarkDictionary mapBaseMode:self.settingManager.mapBaseMode];
}

- (void)updatePlacemarkInfoBarWithPlacemarkDictionary:(NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkDictionary{
    // 更新统计信息
   
    placemarkInfoBar.countryCount = placemarkDictionary[kCountryArray].count;
    placemarkInfoBar.administrativeAreaCount = placemarkDictionary[kAdministrativeAreaArray].count;
    placemarkInfoBar.localityCount = placemarkDictionary[kLocalityArray].count;
    placemarkInfoBar.subLocalityCount = placemarkDictionary[kSubLocalityArray].count;
    placemarkInfoBar.thoroughfareCount = placemarkDictionary[kThoroughfareArray].count;
    
}

- (void)updatePlacemarkInfoBarTotolInfo{
    switch (self.settingManager.mapBaseMode) {
        case 0:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Distance", @"里程");
            placemarkInfoBar.totalDistance = totalDistance;
        }
            break;
        case 1:{
            placemarkInfoBar.totalTitle = NSLocalizedString(@"Area", @"面积");
            totalArea = self.addedEWAnnotations.count * M_PI * pow(self.settingManager.mergeDistanceForLocation,2);
            placemarkInfoBar.totalArea = totalArea;
        }
            break;
        default:
            break;
    }
}

#pragma mark Vertical Bars

- (void)initVerticalBars{

#pragma mark leftBottomVerticalBar 屏幕左下方，naviBar上方 包括 userLocationButton 和 changeOverlayStyleButton
    
    leftBottomVerticalBar = [UIView newAutoLayoutView];
    leftBottomVerticalBar.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
    [self.view addSubview:leftBottomVerticalBar];
    [leftBottomVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [leftBottomVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [leftBottomVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength, ButtonEdgeLength * 2 + ButtonOffset)];
    
    changeOverlayStyleButton = [UIButton newAutoLayoutView];
    changeOverlayStyleButton.alpha = 0.6;
    [changeOverlayStyleButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Repeat_WBG"] forState:UIControlStateNormal];
    changeOverlayStyleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [changeOverlayStyleButton addTarget:self action:@selector(changeOverlayStyle:) forControlEvents:UIControlEventTouchDown];
    changeOverlayStyleButton.tag = 0;
    [leftBottomVerticalBar addSubview:changeOverlayStyleButton];
    [changeOverlayStyleButton autoSetDimensionsToSize:ButtionSize];
    [changeOverlayStyleButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [changeOverlayStyleButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    userLocationButton = [UIButton newAutoLayoutView];
    userLocationButton.alpha = 0.6;
    [userLocationButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_User"] forState:UIControlStateNormal];
    userLocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    [userLocationButton addTarget:self action:@selector(changeShowUserLocationMode) forControlEvents:UIControlEventTouchDown];
    [leftBottomVerticalBar addSubview:userLocationButton];
    [userLocationButton autoSetDimensionsToSize:ButtionSize];
    [userLocationButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [userLocationButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:changeOverlayStyleButton withOffset:ButtonOffset];
    
#pragma mark leftVerticalBar 屏幕左下方，userLocationButton上方，包含设置、显示隐藏等4个按钮
    
    leftVerticalBar = [UIView newAutoLayoutView];
    leftVerticalBar.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
    [self.view addSubview:leftVerticalBar];
    [leftVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [leftVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:leftBottomVerticalBar withOffset:-ButtonOffset];
    [leftVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength, ButtonEdgeLength * 5 + ButtonOffset * 4)];
    
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
    [leftBtn2 addTarget:self action:@selector(showHideLocationInfoBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn2];
    [leftBtn2 autoSetDimensionsToSize:ButtionSize];
    [leftBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn1 withOffset:ButtonOffset];
    
    UIButton *leftBtn3 = [UIButton newAutoLayoutView];
    leftBtn3.alpha = 0.6;
    [leftBtn3 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Glasses_WBG"] forState:UIControlStateNormal];
    leftBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn3 addTarget:self action:@selector(alphaShowHideMapModeBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn3];
    [leftBtn3 autoSetDimensionsToSize:ButtionSize];
    [leftBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn2 withOffset:ButtonOffset];
    
    UIButton *leftBtn4 = [UIButton newAutoLayoutView];
    leftBtn4.alpha = 0.6;
    [leftBtn4 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_StatisticBar1_WBG"] forState:UIControlStateNormal];
    leftBtn4.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn4 addTarget:self action:@selector(alphaShowHidePlacemarkInfoBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn4];
    [leftBtn4 autoSetDimensionsToSize:ButtionSize];
    [leftBtn4 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn4 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn3 withOffset:ButtonOffset];
    
    UIButton *leftBtn5 = [UIButton newAutoLayoutView];
    leftBtn5.alpha = 0.6;
    [leftBtn5 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Play_WBG"] forState:UIControlStateNormal];
    leftBtn5.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn5 addTarget:self action:@selector(alphaShowHideNaviBar) forControlEvents:UIControlEventTouchDown];
    [leftVerticalBar addSubview:leftBtn5];
    [leftBtn5 autoSetDimensionsToSize:ButtionSize];
    [leftBtn5 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [leftBtn5 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:leftBtn4 withOffset:ButtonOffset];
    //[leftVerticalView.subviews autoDistributeViewsAlongAxis:ALAxisVertical withFixedSize:44 insetSpacing:YES alignment:NSLayoutFormatAlignAllLeft];
    
#pragma mark rightSwipeVerticalBar 屏幕右下方，naviBar上方
    
    rightSwipeVerticalBar = [UIView newAutoLayoutView];
    rightSwipeVerticalBar.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
    [self.view addSubview:rightSwipeVerticalBar];
    [rightSwipeVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightSwipeVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:naviBar withOffset:-10];
    [rightSwipeVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength, ButtonEdgeLength * 3 + ButtonOffset * 2 - 20)];
    
    UIImageView *swipeImageView = [UIImageView newAutoLayoutView];
    swipeImageView.alpha = 0.4;
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
    rightVerticalBar.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
    [self.view addSubview:rightVerticalBar];
    [rightVerticalBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [rightVerticalBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:rightSwipeVerticalBar withOffset: - 20 - ButtonOffset];
    [rightVerticalBar autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength, ButtonEdgeLength * 4 + ButtonOffset * 3)];
    
    UIButton *rightBtn0 = [UIButton newAutoLayoutView];
    rightBtn0.alpha = 0.6;
    [rightBtn0 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Monitor_WBG"] forState:UIControlStateNormal];
    rightBtn0.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn0 addTarget:self action:@selector(changeMapViewMapType) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn0];
    [rightBtn0 autoSetDimensionsToSize:ButtionSize];
    [rightBtn0 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn0 autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    
    UIButton *rightBtn1 = [UIButton newAutoLayoutView];
    rightBtn1.alpha = 0.6;
    [rightBtn1 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share2_WBG"] forState:UIControlStateNormal];
    rightBtn1.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn1 addTarget:self action:@selector(checkBeforeShowShareFootprintsRepositoryVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn1];
    [rightBtn1 autoSetDimensionsToSize:ButtionSize];
    [rightBtn1 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn1 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn0 withOffset:ButtonOffset];
    
    UIButton *rightBtn2 = [UIButton newAutoLayoutView];
    rightBtn2.alpha = 0.6;
    [rightBtn2 setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Share_WBG"] forState:UIControlStateNormal];
    rightBtn2.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn2 addTarget:self action:@selector(showShareImageVC) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn2];
    [rightBtn2 autoSetDimensionsToSize:ButtionSize];
    [rightBtn2 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn2 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn1 withOffset:ButtonOffset];
    
    UIButton *rightBtn3 = [UIButton newAutoLayoutView];
    rightBtn3.alpha = 0.6;
    [rightBtn3 setBackgroundImage:[UIImage imageNamed:@"ExtendedMode"] forState:UIControlStateNormal];
    rightBtn3.translatesAutoresizingMaskIntoConstraints = NO;
    [rightBtn3 addTarget:self action:@selector(intelligentlyEnterExtendedMode) forControlEvents:UIControlEventTouchDown];
    [rightVerticalBar addSubview:rightBtn3];
    [rightBtn3 autoSetDimensionsToSize:ButtionSize];
    [rightBtn3 autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [rightBtn3 autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:rightBtn2 withOffset:ButtonOffset];

}

- (void)changeMapViewMapType{
    /* 5种类型相互转换
    NSUInteger currentMapType = self.myMapView.mapType;
    currentMapType++;
    if (currentMapType == 5) currentMapType = 0;
    
    self.myMapView.mapType = currentMapType;
    */
    
    if (self.myMapView.mapType == MKMapTypeStandard){
        self.myMapView.mapType = MKMapTypeHybrid;
    }else{
        self.myMapView.mapType = MKMapTypeStandard;
    }
}

- (void)alphaShowHideVerticalBar{
    // 基础模式专用栏
    leftVerticalBar.alpha = leftVerticalBar.alpha == 1 ? 0 : 1;
    rightVerticalBar.alpha = rightVerticalBar.alpha == 1 ? 0 : 1;
    
    // 通用栏
    leftBottomVerticalBar.alpha = leftBottomVerticalBar.alpha == 1 ? 0 : 1;
    rightSwipeVerticalBar.alpha = rightSwipeVerticalBar.alpha == 1 ? 0 : 1;
    
    // userLocationButton的alpha是0.6，所以不能用alpha
    // userLocationButton.hidden = userLocationButton.hidden ? NO : YES;
    
    verticalBarIsAlphaZero = verticalBarIsAlphaZero ? NO : YES;
}

- (void)alphaShowHideMapModeBar{
    [UIView animateWithDuration:0.3 animations:^{
        msBaseModeBar.alpha = (msBaseModeBar.alpha == 1) ? 0 : 1;
    }];
    
}

- (void)alphaShowHidePlacemarkInfoBar{
    [UIView animateWithDuration:0.3 animations:^{
        placemarkInfoBar.alpha = (placemarkInfoBar.alpha == 1) ? 0 : 1;
    }];
    
}

- (void)alphaShowHideNaviBar{
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

- (void)changeOverlayStyle:(UIButton *)sender{
    NSString *status;
    if (self.isInBaseMode && self.settingManager.mapBaseMode == MapBaseModeLocation){
        status = NSLocalizedString(@"Now in Location Mode. Can not change route style between simulation and line.", @"当前为地点模式，无法进行模拟路线与箭头路线的相互转化。");
        [SVProgressHUD showErrorWithStatus:status];//NSLocalizedString(@"Can't change route style.", @"当前无法转化路线")];
        return;
    }
    
    if (!self.isInBaseMode && self.currentShowEWFR.radius > 0){
        status = NSLocalizedString(@"The footprints repository is created in Location Mode. Can not change route style between simulation and line.", @"足迹包从地点模式生成，无法进行模拟路线与箭头路线的相互转化。");
        [SVProgressHUD showErrorWithStatus:status];//[SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Can't change route style.", @"当前无法转化路线")];
        //[SVProgressHUD dismissWithDelay:3.0];
        return;
    }
    
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    if (sender.tag == 1){
        sender.enabled = NO;
        
        // 直线路线转化为模拟路线
        [self asyncAddRouteOverlays:self.addedIDAnnotations completionBlock:^(NSInteger routePolylineCount, CLLocationDistance routeTotalDistance) {
            totalDistance = routeTotalDistance;
            [self updatePlacemarkInfoBarTotolInfo];
            sender.enabled = YES;
        }];
        
    }else{
        sender.enabled = NO;
        
        // 模拟路线转化为直线路线
        [self addLineOverlaysPro:self.addedIDAnnotations];
        [self updatePlacemarkInfoBarTotolInfo];
        
        sender.enabled = YES;
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

#pragma mark QuiteBrowserModeButton

- (void)initQuiteBrowserModeButton{
    quiteBrowserModeButton = [UIButton newAutoLayoutView];
    quiteBrowserModeButton.alpha = 0.6;
    [quiteBrowserModeButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    quiteBrowserModeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [quiteBrowserModeButton addTarget:self action:@selector(showQuiteBrowserModeAlertController) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:quiteBrowserModeButton];
    [quiteBrowserModeButton autoSetDimensionsToSize:ButtionSize];
    [quiteBrowserModeButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msExtenedModeBar withOffset:ButtonOffset];
    [quiteBrowserModeButton autoAlignAxisToSuperviewAxis:ALAxisVertical];
    quiteBrowserModeButton.hidden = YES;
}

#pragma mark Record Mode Bar

- (void)initRecordModeBar{
    // 需要外部引用，用于显示隐藏
    recordModeBar = [UIView newAutoLayoutView];
    recordModeBar.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
    [self.view addSubview:recordModeBar];
    [recordModeBar autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength * 5 + ButtonOffset * 4, ButtonEdgeLength + 30)];
    //[recordModeBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:msExtenedModeBar withOffset:10];
    [recordModeBar autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
    [recordModeBar autoAlignAxisToSuperviewAxis:ALAxisVertical];
    recordModeBar.hidden = YES;
    
    UIView *recordModeBarButtonContainer = [UIView newAutoLayoutView];
    recordModeBarButtonContainer.backgroundColor = [UIColor clearColor];
    [recordModeBar addSubview:recordModeBarButtonContainer];
    [recordModeBarButtonContainer autoSetDimensionsToSize:CGSizeMake(ButtonEdgeLength * 5 + ButtonOffset * 4, ButtonEdgeLength)];
    [recordModeBarButtonContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    
    UIButton *firstButtonInRMB = [UIButton newAutoLayoutView];
    firstButtonInRMB.alpha = 0.6;
    [firstButtonInRMB setBackgroundImage:[UIImage imageNamed:@"Paused"] forState:UIControlStateNormal];
    firstButtonInRMB.translatesAutoresizingMaskIntoConstraints = NO;
    [firstButtonInRMB addTarget:self action:@selector(startPauseRecord) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:firstButtonInRMB];
    [firstButtonInRMB autoSetDimensionsToSize:ButtionSize];
    [firstButtonInRMB autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [firstButtonInRMB autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    
    UIButton *secondButtonInRMB = [UIButton newAutoLayoutView];
    secondButtonInRMB.alpha = 0.6;
    [secondButtonInRMB setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Download_WBG"] forState:UIControlStateNormal];
    secondButtonInRMB.translatesAutoresizingMaskIntoConstraints = NO;
    [secondButtonInRMB addTarget:self action:@selector(saveRecordedFootprintAnnotationsBtnTD) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:secondButtonInRMB];
    [secondButtonInRMB autoSetDimensionsToSize:ButtionSize];
    [secondButtonInRMB autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [secondButtonInRMB autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:firstButtonInRMB withOffset:ButtonOffset];
    
    UIButton *thirdButtonInRMB = [UIButton newAutoLayoutView];
    thirdButtonInRMB.alpha = 0.6;
    [thirdButtonInRMB setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
    thirdButtonInRMB.translatesAutoresizingMaskIntoConstraints = NO;
    [thirdButtonInRMB addTarget:self action:@selector(showQuiteRecordModeAlertController) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:thirdButtonInRMB];
    [thirdButtonInRMB autoSetDimensionsToSize:ButtionSize];
    [thirdButtonInRMB autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [thirdButtonInRMB autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:secondButtonInRMB withOffset:ButtonOffset];
    
    UIButton *fourthButtonInRMB = [UIButton newAutoLayoutView];
    fourthButtonInRMB.alpha = 0.6;
    [fourthButtonInRMB setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Setting_WBG"] forState:UIControlStateNormal];
    fourthButtonInRMB.translatesAutoresizingMaskIntoConstraints = NO;
    [fourthButtonInRMB addTarget:self action:@selector(alphaShowHideRecordModeSettingBar) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:fourthButtonInRMB];
    [fourthButtonInRMB autoSetDimensionsToSize:ButtionSize];
    [fourthButtonInRMB autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [fourthButtonInRMB autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:thirdButtonInRMB withOffset:ButtonOffset];
    
    UIButton *fifthButtonInRMB = [UIButton newAutoLayoutView];
    fifthButtonInRMB.alpha = 0.6;
    [fifthButtonInRMB setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Plus_WBG"] forState:UIControlStateNormal];
    fifthButtonInRMB.translatesAutoresizingMaskIntoConstraints = NO;
    [fifthButtonInRMB addTarget:self action:@selector(manullyAddFootprint) forControlEvents:UIControlEventTouchDown];
    [recordModeBarButtonContainer addSubview:fifthButtonInRMB];
    [fifthButtonInRMB autoSetDimensionsToSize:ButtionSize];
    [fifthButtonInRMB autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [fifthButtonInRMB autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:fourthButtonInRMB withOffset:ButtonOffset];
    
    // 需要外部引用，用于改变图片
    startPauseRecordButton = firstButtonInRMB;
    
    speedLabelInRMB = [UILabel newAutoLayoutView];
    speedLabelInRMB.layer.backgroundColor = self.settingManager.extendedTintColor.CGColor;
    speedLabelInRMB.layer.borderColor = self.settingManager.extendedTintColor.CGColor;
    speedLabelInRMB.layer.borderWidth = 1;
    speedLabelInRMB.layer.cornerRadius = 0.4;
    speedLabelInRMB.text = NSLocalizedString(@"Paused", @"已暂停");
    speedLabelInRMB.textAlignment = NSTextAlignmentCenter;
    speedLabelInRMB.textColor = [UIColor whiteColor];
    speedLabelInRMB.font = [UIFont bodyFontWithSizeMultiplier:1.2];
    [recordModeBar addSubview:speedLabelInRMB];
    [speedLabelInRMB autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [speedLabelInRMB autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    
    distanceAndFPCountLabelInRMB = [UILabel newAutoLayoutView];
    distanceAndFPCountLabelInRMB.layer.backgroundColor = self.settingManager.extendedTintColor.CGColor;
    distanceAndFPCountLabelInRMB.layer.borderColor = self.settingManager.extendedTintColor.CGColor;
    distanceAndFPCountLabelInRMB.layer.borderWidth = 1;
    distanceAndFPCountLabelInRMB.layer.cornerRadius = 0.4;
    distanceAndFPCountLabelInRMB.text = NSLocalizedString(@"Distance,Count", @"里程,点数");
    distanceAndFPCountLabelInRMB.textAlignment = NSTextAlignmentCenter;
    distanceAndFPCountLabelInRMB.textColor = [UIColor whiteColor];
    distanceAndFPCountLabelInRMB.font = [UIFont bodyFontWithSizeMultiplier:1.2];
    [recordModeBar addSubview:distanceAndFPCountLabelInRMB];
    [distanceAndFPCountLabelInRMB autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [distanceAndFPCountLabelInRMB autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
}

- (void)manullyAddFootprint{
    //[self.locationManagerForRecording requestLocation];
    if (!(self.settingManager.hasPurchasedRecordAndEdit || self.settingManager.trialCountForRecordAndEdit > 0)){
        [self showPurchaseRecordFunctionAlertController];
        return;
    }
    
    if (self.userLocationWGS84) [self addRecordedFootprintAnnotationsWithLocation:self.userLocationWGS84 isUserManuallyAdded:YES];
    else{
        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Is not recording or haven't got current location.", @"当前未开始记录或者未定位，无法手动添加足迹点。")]
                           animated:YES
                         completion:nil];
    }
}

- (void)alphaShowHideRecordModeSettingBar{
    [UIView animateWithDuration:0.3 animations:^{
        recordModeSettingBar.alpha = recordModeSettingBar.alpha ==1 ? 0 : 1;
        
        
        if (recordModeSettingBar.alpha == 1 && !verticalBarIsAlphaZero){
            [self alphaShowHideVerticalBar];
        }
        
    }];
}

#pragma mark RecordModeSettingBar

- (void)initRecordModeSettingBar{
    recordModeSettingBar = [RecordModeSettingBar new];
    recordModeSettingBar.backgroundColor = self.settingManager.extendedTintColor;
    [self.view addSubview:recordModeSettingBar];
    //[recordModeSettingBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:recordModeBar withOffset:10];
    [recordModeSettingBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:recordModeBar withOffset:-10];
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
    shareBar.sideViewShrinkRate = 0.8;//(ScreenWidth > 320 ? 1.0 : 0.8);
    shareBar.title =  NSLocalizedString(@"Measure the world by footprints.",@"用相册记录人生，用足迹丈量世界");
    shareBar.titleFont = [UIFont bodyFontWithSizeMultiplier:1.0];
    shareBar.leftImage = [UIImage imageNamed:@"地球_300_300"];
    shareBar.leftText = NSLocalizedString(@"AlbumMaps", @"相册地图");
    shareBar.rightImage = self.settingManager.appQRCodeImage; //[UIImage imageNamed:@"1136142337"];
    shareBar.rightText = NSLocalizedString(@"ScanToDL", @"扫码下载");
    [self.view addSubview:shareBar];
    [shareBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 0, 5) excludingEdge:ALEdgeBottom];
    CGFloat shareBarHeight = (ScreenWidth > 320 ? 170 : 150);
    [shareBar autoSetDimension:ALDimensionHeight toSize:shareBarHeight];
    //[shareBar autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.view withMultiplier:0.2];
}

#pragma mark Data

- (void)initData{
    switch (self.settingManager.mapBaseMode) {
        case MapBaseModeMoment:{
            // 时刻模式初始化
            self.startDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomStartDate];
            self.endDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomEndDate];
            
            /*
            switch (self.settingManager.dateMode) {
                case DateModeDay:{
                    self.startDate = [NOW dateAtStartOfToday];
                    self.endDate = [NOW dateAtEndOfToday];
                }
                    break;
                case DateModeWeek:{
                    self.startDate = [NOW dateAtStartOfThisWeek:self.settingManager.firstDayOfWeek];
                    self.endDate = [NOW dateAtEndOfThisWeek:self.settingManager.firstDayOfWeek];
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
                case DateModeCustom:{
                    self.startDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomStartDate];
                    self.endDate = [[NSUserDefaults standardUserDefaults] valueForKey:DatePickerCustomEndDate];
                }
                    break;
                default:
                    break;
            }
            */
            
            self.assetInfoArray = [PHAssetInfo fetchAssetInfosFormStartDate:self.startDate toEndDate:self.endDate inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        }
            break;
            
        case MapBaseModeLocation:{
            // 位置模式初始化
            self.lastPlacemark = self.settingManager.lastPlacemark;
            if(self.lastPlacemark){
                self.assetInfoArray = [PHAssetInfo fetchAssetInfosContainsPlacemark:self.settingManager.lastPlacemark inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
            }
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Scene Change

- (void)showSettingVC{
    SettingVC *settingVC = [SettingVC new];
    settingVC.view.backgroundColor = self.settingManager.backgroundColor;
    settingVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    WEAKSELF(weakSelf);
    settingVC.didSelectCoordinateInfo = ^(CoordinateInfo *selectedCoordinateInfo){
        [weakSelf.myMapView setCenterCoordinate:selectedCoordinateInfo.coordinate];
        [weakSelf.myMapView selectAnnotation:selectedCoordinateInfo animated:YES];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showShareImageVC{
    if (!self.addedEWFootprintAnnotations || self.addedEWFootprintAnnotations.count == 0) {
        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"No footprints yet.Please choose a date or a location to add your album footprints.", @"您还没有添加足迹点，请选择日期或地址添加您的相册足迹。")]
                           animated:YES completion:nil];
        
        return;
    }

    if (!verticalBarIsAlphaZero) [self alphaShowHideVerticalBar];
    msBaseModeBar.alpha = 0;
    placemarkInfoBar.alpha = 0;
    naviBar.alpha = 0;
    locationInfoBar.alpha = 0;
    
    NSMutableString *ms = [NSMutableString new];
    /*
    if (self.settingManager.mapBaseMode == MapBaseModeMoment) {
        [ms appendFormat:@"%@ ",msBaseModeBar.info];
        [ms appendString:NSLocalizedString(@"I went to ", @"我到了 ")];
    }else{
        [ms appendString:NSLocalizedString(@"I've been in ", @"我到过 ")];
    }
    */
    NSString *dateString = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate firstDayOfWeek:self.settingManager.firstDayOfWeek];
    if (dateString) [ms appendFormat:@"%@ ",dateString];
    
    [ms appendString:NSLocalizedString(@"I went to ", @"我到了 ")];
    
    [ms appendString:[EverywhereCoreDataManager placemarkInfoStringForPlacemarkDictionary:self.placemarkDictionary]];
    if (placemarkInfoBar.totalTitle){
        [ms appendString:NSLocalizedString(@"\nTotal ", @"\n总")];
        [ms appendFormat:@"%@ %@",placemarkInfoBar.totalTitle,placemarkInfoBar.totalContent];
    }
    
    shareBar.middleText = ms;
    // 设置字体大小
    shareBar.middleFont = [UIFont bodyFontWithSizeMultiplier:0.9];
    // 显示出来，以便进行截图
    shareBar.alpha = 1;

    UIGraphicsBeginImageContext(CGSizeMake(ScreenWidth, naviBar.frame.origin.y + naviBar.frame.size.height));
    
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:YES];
    
    UIImage *contentImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //CGFloat resizeRate = (ScreenWidth > 320 ? 0.2 : 0.3);
    
    // 生成缩略图
    //UIImage *thumbImage = [contentImage resizableImageWithCapInsets:UIEdgeInsetsMake(contentImage.size.height * resizeRate, contentImage.size.width * resizeRate , contentImage.size.height * resizeRate, contentImage.size.width * resizeRate) resizingMode:UIImageResizingModeStretch];
    
    UIImage *thumbImage = [UIImage thumbImageFromImage:contentImage limitSize:CGSizeMake(200, 350)];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, 0.5);
    
    ShareImageVC *ssVC = [ShareImageVC new];
    ssVC.view.backgroundColor = self.settingManager.backgroundColor;
    ssVC.shareImage = contentImage;
    ssVC.shareThumbData = thumbImageData;
    ssVC.contentSizeInPopup = ContentSizeInPopup_Big;
    ssVC.landscapeContentSizeInPopup = LandscapeContentSizeInPopup_Big;

    popupController = [[STPopupController alloc] initWithRootViewController:ssVC];
    popupController.containerView.layer.cornerRadius = 4;
    [popupController presentInViewController:self];
}


#pragma mark - Purchase

- (void)showPurchaseShareFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"ShareAndBrowse",@"分享和浏览");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Share your footprints to others through MFR or GPX files without footprints count restriction", @"1.通过MFR或GPX文件分享您的足迹，没有足迹点个数限制"),NSLocalizedString(@"2.Store footprints both sent and received", @"2.存储发送和接收的足迹"),NSLocalizedString(@"3.Unlock Browser Mode to lookup stored footprints anytime", @"3.解锁浏览模式，随时查看存储的足迹"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:0];
}

- (void)showPurchaseRecordFunctionAlertController{
    NSString *alertTitle = NSLocalizedString(@"RecordAndEdit",@"记录和编辑");
    NSString *alertMessage = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",NSLocalizedString(@"You can get utilities below:", @"您将获得如下功能："),NSLocalizedString(@"1.Record your footprints , support background record, automatically save and manually add footprints", @"1.记录足迹，支持后台记录、自动保存、手动加点"),NSLocalizedString(@"2.Intelligently edit your footprints , support merge footprints by moment or location with custom merge distance and reserve manually added footprints", @"2.足迹智能编辑功能，支持按时刻、地点模式进行足迹点合并，可设置分组距离、是否保留手动加点"),NSLocalizedString(@"3.Unlock Record Mode to manage your recorded and edited footprints", @"3.解锁记录模式，管理记录和编辑的足迹"),NSLocalizedString(@"Cost $1.99,continue?", @"价格 ￥12元，是否购买？")];
    [self showPurchaseAlertControllerWithTitle:alertTitle message:alertMessage productIndex:1];
}

- (void)showPurchaseAlertControllerWithTitle:(NSString *)title message:(NSString *)message productIndex:(NSInteger)productIndex{
    WEAKSELF(weakSelf);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase",@"购买")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [weakSelf showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(productIndex)]];
                                                     }];
    /*
    UIAlertAction *restoreAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restore",@"恢复")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [weakSelf showPurchaseVC:productIndex transactionType:TransactionTypeRestore];
                                                           }];
    */
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:purchaseAction];
    //[alertController addAction:restoreAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = purchaseAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showPurchaseVC:(enum TransactionType)transactionType productIndexArray:(NSArray <NSNumber *> *)productIndexArray{
    InAppPurchaseVC *inAppPurchaseVC = [InAppPurchaseVC new];
    inAppPurchaseVC.edgesForExtendedLayout = UIRectEdgeNone;
    
    inAppPurchaseVC.productIDArray = self.settingManager.appProductIDArray;
    inAppPurchaseVC.transactionType = transactionType;
    inAppPurchaseVC.productIndexArray = productIndexArray;
    
    WEAKSELF(weakSelf);
    inAppPurchaseVC.inAppPurchaseCompletionHandler = ^(enum TransactionType transactionType,NSInteger productIndex,BOOL succeeded){
        if (succeeded) {
            switch (productIndex) {
                case 0:
                    weakSelf.settingManager.hasPurchasedShareAndBrowse = YES;
                    break;
                case 1:
                    weakSelf.settingManager.hasPurchasedRecordAndEdit = YES;
                    break;
                case 2:
                    weakSelf.settingManager.hasPurchasedImportAndExport = YES;
                    break;
                case 3:
                    weakSelf.settingManager.hasPurchasedShareAndBrowse = YES;
                    weakSelf.settingManager.hasPurchasedRecordAndEdit = YES;
                    weakSelf.settingManager.hasPurchasedImportAndExport = YES;
                    break;
                default:
                    break;
            }
        }
        if(DEBUGMODE) NSLog(@"%@ %@",self.settingManager.appProductIDArray[productIndex],succeeded? @"成功！" : @"用失败！");
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:inAppPurchaseVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Extended Mode

#pragma mark Share and Receive

- (void)checkBeforeShowShareFootprintsRepositoryVC{
    
    if (!self.addedEWFootprintAnnotations || self.addedEWFootprintAnnotations.count == 0) {
        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"No footprints yet.Please choose a date or a location to add your album footprints.", @"您还没有添加足迹点，请选择日期或地址添加您的相册足迹。")]
                           animated:YES completion:nil];
        
        return;
    }
    
    NSUInteger thumbnailCount = [self calculateThumbnailCountForAddedEWFootprintAnnotations];
    if (thumbnailCount > 100){
        NSString *alertMessage = [NSString stringWithFormat:@"%@: %lu\n%@",NSLocalizedString(@"Thumbnail Count", @"缩略图数量"),(unsigned long)thumbnailCount,NSLocalizedString(@"Too many thumbnials. Due to memory stress, the footprint repository may cannot be created and tha app may crash. Continue anyway?", @"缩略图较多，容易因内存紧张而无法创建足迹包，甚至导致应用崩溃。是否继续？")];
        
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:alertMessage okActionHandler:^(UIAlertAction *action) {
            [self showShareFootprintsRepositoryVC];
        }];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self showShareFootprintsRepositoryVC];
    }
    
}

- (void)showShareFootprintsRepositoryVC{
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Creating footprints repository for share...", @"正在创建分享足迹包...")];
    
    // 更新缩略图信息，比较耗时！！
    [self updateThumbnailForAddedEWFootprintAnnotations];
    
    // placemarkInfo信息
    NSMutableString *ms = [NSMutableString new];
    NSString *placemarkInfoString = [EverywhereCoreDataManager placemarkInfoStringForPlacemarkDictionary:self.placemarkDictionary];
    if (placemarkInfoString && ![placemarkInfoString isEqualToString:@""])
        [ms appendFormat:@"%@,",placemarkInfoString];
    [ms appendString:NSLocalizedString(@"Total ", @"总")];
    [ms appendFormat:@"%@ %@",placemarkInfoBar.totalTitle,placemarkInfoBar.totalContent];
    
    // 生成分享对象
    FootprintsRepository *footprintsRepository = [FootprintsRepository new];
    footprintsRepository.footprintAnnotations = [NSMutableArray arrayWithArray:self.addedEWFootprintAnnotations];
    if (self.settingManager.mapBaseMode == MapBaseModeMoment) footprintsRepository.radius = 0;
    else footprintsRepository.radius = self.settingManager.mergeDistanceForLocation / 2.0;
    footprintsRepository.creationDate = NOW;
    footprintsRepository.footprintsRepositoryType = FootprintsRepositoryTypeSent;
    footprintsRepository.placemarkStatisticalInfo = ms;
    
    footprintsRepository.title = [NSDate localizedStringWithFormat:@"yyyy-MM-dd" startDate:self.startDate endDate:self.endDate firstDayOfWeek:self.settingManager.firstDayOfWeek];
    if (self.settingManager.mapBaseMode == MapBaseModeLocation) footprintsRepository.title = [footprintsRepository.title stringByAppendingFormat:@" %@",self.lastPlacemark];
    
    ShareFootprintsRepositoryVC *shareFRVC = [ShareFootprintsRepositoryVC new];
    shareFRVC.footprintsRepository = footprintsRepository;
    shareFRVC.thumbImage = [UIImage imageNamed:@"地球_300_300"];
    
    WEAKSELF(weakSelf);
    shareFRVC.userDidSelectedPurchaseShareFunctionHandler = ^(){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        [weakSelf showPurchaseShareFunctionAlertController];
    };
    
    popupController = [[STPopupController alloc] initWithRootViewController:shareFRVC];
    popupController.containerView.layer.cornerRadius = 4;
    
    [popupController presentInViewController:self completion:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)didReceiveFootprintsRepository:(FootprintsRepository *)footprintsRepository{
    if (!footprintsRepository) return;
    // 成功获取分享的数据
    lastReceivedEWFR = footprintsRepository;
    
    // 修改属性
    footprintsRepository.footprintsRepositoryType = FootprintsRepositoryTypeReceived;
    
    // 显示主界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *alertTitle = NSLocalizedString(@"Receive Shared Footprints",@"收到分享的足迹");
    
    NSMutableString *ms = [NSMutableString new];
    [ms appendFormat:@"\n%@ : %@\n%@ : %lu\n",NSLocalizedString(@"Title", @"标题"),footprintsRepository.title,NSLocalizedString(@"Footprints Count", @"足迹点数"),(unsigned long)footprintsRepository.footprintAnnotations.count];
    if (footprintsRepository.placemarkStatisticalInfo) [ms appendFormat:@"%@ : %@",NSLocalizedString(@"Statistics Info", @"统计信息"),footprintsRepository.placemarkStatisticalInfo];
    [ms appendFormat:@"\n%@\n",NSLocalizedString(@"Would you like to accept the footprints and enter Browser Mode?", @"是否接收足迹并进入浏览模式？")];
    NSString *alertMessage = ms;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Receive",@"接收")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         
                                                         if (self.settingManager.hasPurchasedShareAndBrowse || self.settingManager.trialCountForShareAndBrowse > 0){
                                                             // 用户选择接收，则保存footprintsRepository
                                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                                 [EverywhereCoreDataManager addEWFR:lastReceivedEWFR];
                                                                 // 保存完成，置空
                                                                 lastReceivedEWFR = nil;
                                                             });
                                                         }
                                                         
                                                         if (self.isInBaseMode){
                                                             [self enterExtendedMode];
                                                             [self enterBrowserMode];
                                                             msExtenedModeBar.selectedSegmentIndex = 0;
                                                         }
                                                         
                                                         [self checkBeforeShowFootprintsRepository:footprintsRepository];

                                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消")
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               //lastReceivedEWFR = nil;
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Enter And Quite Mode

- (void)intelligentlyEnterExtendedMode{
    
    [self enterExtendedMode];
    
    if (self.settingManager.mapExtendedMode == MapExtendedModeBrowser) [self enterBrowserMode];
    else [self enterRecordMode];
}

- (void)enterExtendedMode{
    if(DEBUGMODE) NSLog(@"进入扩展模式");
    self.isInBaseMode = NO;
    
    if (!locationInfoBarIsOutOfVisualView) locationInfoBar.hidden = YES;
    
    // 保存BaseMode数据
    savedTitleForBaseMode = msBaseModeBar.info;
    savedAnnotationsForBaseMode = self.addedEWAnnotations;
    savedFootprintAnnotationsForBaseMode = self.addedEWFootprintAnnotations;
    savedOverlaysForBaseMode = self.myMapView.overlays;
    //savedStartDateForBaseMode = self.startDate;
    //savedEndDateForBaseMode = self.endDate;
    
    // 清理BaseMode地图
    [self.myMapView removeAnnotations:self.addedIDAnnotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    self.addedEWFootprintAnnotations = nil;
    self.addedIDAnnotations = nil;

    msBaseModeBar.hidden = YES;
    placemarkInfoBar.hidden = YES;
    leftVerticalBar.hidden = YES;
    rightVerticalBar.hidden = YES;
    
    msExtenedModeBar.hidden = NO;
    
    naviBar.backgroundColor = self.settingManager.extendedTintColor;
    currentAnnotationIndexLabel.backgroundColor = self.settingManager.extendedTintColor;
    locationInfoBar.backgroundColor = self.settingManager.extendedTintColor;
    
    /*
    recordModeSettingBar.backgroundColor = self.settingManager.extendedTintColor;
    speedLabelInRMB.layer.backgroundColor = self.settingManager.extendedTintColor.CGColor;
    speedLabelInRMB.layer.borderColor = self.settingManager.extendedTintColor.CGColor;
    distanceAndFPCountLabelInRMB.layer.backgroundColor = self.settingManager.extendedTintColor.CGColor;
    distanceAndFPCountLabelInRMB.layer.borderColor = self.settingManager.extendedTintColor.CGColor;
     */
}

- (void)quiteExtendedMode{
    // 设置颜色，所以这一句要放在最前面
    self.isInBaseMode = YES;
    
    msBaseModeBar.hidden = NO;
    placemarkInfoBar.hidden = NO;
    leftVerticalBar.hidden = NO;
    rightVerticalBar.hidden = NO;
    
    msExtenedModeBar.hidden = YES;
    
    naviBar.backgroundColor = self.settingManager.baseTintColor;
    currentAnnotationIndexLabel.backgroundColor = self.settingManager.baseTintColor;
    locationInfoBar.backgroundColor = self.settingManager.baseTintColor;
    
    // 清理Extended Mode地图
    [self.myMapView removeAnnotations:self.addedIDAnnotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    self.addedEWFootprintAnnotations = nil;
    
    // 恢复Main Mode地图
    msBaseModeBar.info = savedTitleForBaseMode;
    [self.myMapView addAnnotations:savedAnnotationsForBaseMode];
    self.addedEWFootprintAnnotations = (NSArray <FootprintAnnotation*> *)savedFootprintAnnotationsForBaseMode;
    [self.myMapView addOverlays:savedOverlaysForBaseMode];
    self.addedIDAnnotations = savedAnnotationsForBaseMode;
    //self.startDate = savedStartDateForBaseMode;
    //self.endDate = savedEndDateForBaseMode;
    
    if(DEBUGMODE) NSLog(@"退出扩展模式");
}

- (void)enterBrowserMode{
    
    [self quiteRecordMode];
    if(DEBUGMODE) NSLog(@"进入浏览模式");
    
    msExtenedModeBar.selectedSegmentIndex = 0;
    msExtenedModeBar.rightButtonEnabled = NO;
    
    quiteBrowserModeButton.hidden = NO;
    
}

- (void)checkBeforeShowFootprintsRepository:(FootprintsRepository *)footprintsRepository{
    
    if (!recordedFootprintAnnotations || recordedFootprintAnnotations.count == 0) {
        [self showFootprintsRepository:footprintsRepository];
        return;
    }else if (self.isRecording) {
        /*
 
        UIAlertController *okCancelAlertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Attention", @"警告")  message:NSLocalizedString(@"There are recorded footprints now and they will be cleared if show selected footprints.Show or not?", @"当前处于记录模式并且有记录的足迹点，如需显示所选足迹，记录的足迹点将被清空，是否显示？") okActionHandler:^(UIAlertAction *action) {
            [self showFootprintsRepository:footprintsRepository];
        }];
        
        [self presentViewController:okCancelAlertController animated:YES completion:nil];
 */
        
        UIAlertController *okCancelAlertController = [UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")  message:NSLocalizedString(@"There are recorded footprints now and can not show footprints repository.", @"当前处于记录模式并且有记录的足迹点，无法显示足迹包。")];
        
        [self presentViewController:okCancelAlertController animated:YES completion:nil];
    }
    
}


- (void)showFootprintsRepository:(FootprintsRepository *)footprintsRepository{
    // 清理地图
    [self.myMapView removeAnnotations:self.addedIDAnnotations];
    self.addedEWAnnotations = nil;
    
    self.currentShowEWFR = footprintsRepository;
    
    // 添加要显示的FootprintAnnotations
    [self.myMapView addAnnotations:footprintsRepository.footprintAnnotations];
    
    msExtenedModeBar.info = footprintsRepository.title;
    
    // 设置addedIDAnnos，用于导航
    self.addedIDAnnotations = footprintsRepository.footprintAnnotations;
    self.addedEWFootprintAnnotations = footprintsRepository.footprintAnnotations;
    
    // 添加Overlays
    if (footprintsRepository.radius == 0){
        // 时刻模式 分享的足迹
        [self addLineOverlaysPro:footprintsRepository.footprintAnnotations];
    }else{
        // 地点模式 分享的足迹
        [self addCircleOverlaysPro:footprintsRepository.footprintAnnotations radius:footprintsRepository.radius];
    }
    
}

- (void)showQuiteBrowserModeAlertController{
    
    if (!lastReceivedEWFR || self.settingManager.hasPurchasedShareAndBrowse || self.settingManager.trialCountForShareAndBrowse > 0){
        // 如果没有接收的足迹包 或者 已经购买了分享功能，直接退出（用户有分享功能，则选择接收时已经进行了保存），不再询问
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
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Purchase ShareAndBrowse Function",@"购买 分享和浏览 功能")
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self showPurchaseShareFunctionAlertController];
                                                           }];
    UIAlertAction *dropAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Drop",@"丢弃")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           lastReceivedEWFR = nil;
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
    
    [self.myMapView removeAnnotations:self.addedIDAnnotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];

    naviBar.hidden = YES;
    recordModeBar.hidden = NO;
    recordModeSettingBar.hidden = NO;
    self.showUserLocationMode = ShowUserLocationModeFollow;
    
    // 重置记录数据
    self.isRecording = NO;
    lastRecordLocation = nil;
    lastRecordDate = nil;
    recordedFootprintAnnotations = [NSMutableArray new];
    totalDistanceForRecord = 0;

}

- (void)startPauseRecord{
    if (!(self.settingManager.hasPurchasedRecordAndEdit || self.settingManager.trialCountForRecordAndEdit > 0)){
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
        // 防止自动锁屏
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        // 开始检查时间
        timerForRecord = [NSTimer scheduledTimerWithTimeInterval:60 * 2 target:self selector:@selector(checkUserForgetStopRecording) userInfo:nil repeats:YES];
        
        [self.locationManagerForRecording startUpdatingLocation];
        
        msExtenedModeBar.alpha = 0;
        
        [startPauseRecordButton setBackgroundImage:[UIImage imageNamed:@"Recording"] forState:UIControlStateNormal];
        
    }else{
        // 暂停记录
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [timerForRecord invalidate];
        timerForRecord = nil;
        
        speedLabelInRMB.text = NSLocalizedString(@"Paused", @"已暂停");
        msExtenedModeBar.alpha = 1;
        
        if(DEBUGMODE) NSLog(@"暂停记录");
        [self.locationManagerForRecording stopUpdatingLocation];
        
        //msExtenedModeBar.modeSegEnabled = YES;
        [startPauseRecordButton setBackgroundImage:[UIImage imageNamed:@"Paused"] forState:UIControlStateNormal];
    }
}

- (void)checkUserForgetStopRecording{
    if ([NOW timeIntervalSinceDate:lastRecordDate] > 600){
        // 提醒通知
        UILocalNotification *noti = [UILocalNotification new];
        
        noti.alertBody = NSLocalizedString(@"It has past 10 minutes since last record time.Please pause recording to save energy.", @"已经超过10分钟没有新记录点，请及时暂停记录以节省电量。");
        noti.alertAction = NSLocalizedString(@"Action", @"操作");
        noti.soundName = UILocalNotificationDefaultSoundName;
        //noti.applicationIconBadgeNumber = count;
        [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
        
        lastRecordDate = NOW;
    }
}

- (void)saveRecordedFootprintAnnotationsBtnTD{
    if (!(self.settingManager.hasPurchasedRecordAndEdit || self.settingManager.trialCountForRecordAndEdit > 0)){
        [self showPurchaseRecordFunctionAlertController];
        return;
    }
    
    if (!recordedFootprintAnnotations || recordedFootprintAnnotations.count == 0) {
        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"There are no recorded footprints yet.", @"当前没有记录的足迹点。")]
                           animated:YES completion:nil];
        return;
    }
    
    [self intelligentlySaveRecordedFootprintAnnotationsAndClearCatche];
    
    [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"The recorded footprints has been saved.", @"足迹保存成功。")]
                       animated:YES completion:nil];
    
    self.isRecording = NO;
}

- (void)showQuiteRecordModeAlertController{
    
    if (!recordedFootprintAnnotations || recordedFootprintAnnotations.count == 0){
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
                                                             [self intelligentlySaveRecordedFootprintAnnotationsAndClearCatche];
                                                             [self quiteRecordMode];
                                                             [self quiteExtendedMode];
                                                         }];
    
    /*
    UIAlertAction *dropAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Drop",@"丢弃")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           self.allowBrowserMode = YES;
                                                           [self quiteRecordMode];
                                                           [self quiteExtendedMode];
                                                       }];
    */
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        //[self intelligentlySaveRecordedFootprintAnnotationsAndClearCatche];
        [self quiteRecordMode];
        [self quiteExtendedMode];
    }];
    
    [alertController addAction:saveAction];
    //[alertController addAction:dropAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = saveAction;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 智能保存
- (void)intelligentlySaveRecordedFootprintAnnotationsAndClearCatche{
    if (!recordedFootprintAnnotations || recordedFootprintAnnotations.count == 0) return;
    
    // 保存前先暂停
    self.isRecording = NO;
    
    FootprintsRepository *footprintsRepository = [FootprintsRepository new];
    footprintsRepository.footprintAnnotations = recordedFootprintAnnotations;
    footprintsRepository.creationDate = NOW;
    footprintsRepository.title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Record", @"记录"),[footprintsRepository.creationDate stringWithDefaultFormat]];
    footprintsRepository.footprintsRepositoryType = FootprintsRepositoryTypeRecorded;
    [EverywhereCoreDataManager  addEWFR:footprintsRepository];
    if(DEBUGMODE) NSLog(@"记录已经保存");
    
    // 显示保存通知
    UILocalNotification *noti = [UILocalNotification new];
    
    NSMutableString *messageMS = [NSMutableString new];
    [messageMS appendFormat:@"%@ : %@\n%@ : %lu",NSLocalizedString(@"Recorded footprints has been sucessfully saved", @"记录保存成功"),footprintsRepository.title,NSLocalizedString(@"Footprints Count", @"足迹点数"),(long)recordedFootprintAnnotations.count];
    
    noti.alertBody = messageMS;
    noti.alertAction = NSLocalizedString(@"Action", @"操作");
    noti.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
    
    if (!self.settingManager.hasPurchasedRecordAndEdit && self.settingManager.trialCountForRecordAndEdit > 0){
        NSInteger trialCount = self.settingManager.trialCountForRecordAndEdit;
        trialCount--;
        self.settingManager.trialCountForRecordAndEdit = trialCount;
        
        NSString *leftTrialCountString;
        if(trialCount > 0) leftTrialCountString = [NSString stringWithFormat:@"%@ : %ld",NSLocalizedString(@"Left trial count for RecordAndEdit function", @"记录和编辑功能剩余试用次数"),(long)trialCount];
        else leftTrialCountString = NSLocalizedString(@"RecordAndEdit function trial has finished.", @"记录和编辑功能试用结束！");
        
        NSString *purchaseString = NSLocalizedString(@"Purchase now?", @"是否购买？");
        
        UIAlertController *alertController = [UIAlertController okCancelAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示")
                                                                                         message:[NSString stringWithFormat:@"%@\n%@\n%@",messageMS,leftTrialCountString,purchaseString]
                                                                                 okActionHandler:^(UIAlertAction *action) {
                                                                                     [self showPurchaseVC:TransactionTypePurchase productIndexArray:@[@(1)]];
                                                                                 }];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    // 清理地图
    [self.myMapView removeAnnotations:recordedFootprintAnnotations];
    [self.myMapView removeOverlays:self.myMapView.overlays];
    
    // 把刚刚保存的轨迹显示到地图上
    CLLocationCoordinate2D coordinates[recordedFootprintAnnotations.count];
    NSInteger i = 0;
    for (FootprintAnnotation *fpAnnotation in recordedFootprintAnnotations) {
        coordinates[i++] = fpAnnotation.coordinate;
    }
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:recordedFootprintAnnotations.count];
    polyline.title = MKOverlayTitleForRandomColor;
    
    if (!savedPolylineForRecord) savedPolylineForRecord = [NSMutableArray new];
    [savedPolylineForRecord addObject:polyline];
    
    [self.myMapView addOverlays:savedPolylineForRecord];

    // 清空存储的足迹点
    //FootprintAnnotation *lastfpAnnotation = recordedFootprintAnnotations.lastObject;
    recordedFootprintAnnotations = [NSMutableArray new];
    //[recordedFootprintAnnotations addObject:lastfpAnnotation];
    
    totalDistanceForRecord = 0;
    
    // 保存完成，继续记录
    self.isRecording = YES;
}

- (void)quiteRecordMode{
    self.isRecording = NO;
    
    recordedFootprintAnnotations = nil;
    savedPolylineForRecord = nil;
    
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
    [self.myMapView removeAnnotations:self.addedIDAnnotations];
    self.addedEWAnnotations = nil;
    self.addedEWFootprintAnnotations = nil;
    
    // 添加 MKAnnotations
    NSMutableArray <EverywhereAnnotation *> *annotationsToAdd = [NSMutableArray new];
    NSMutableArray <FootprintAnnotation *> *footprintAnnotationsToAdd = [NSMutableArray new];
    
    [self.assetsArray enumerateObjectsUsingBlock:^(NSArray<PHAsset *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *status = [NSString stringWithFormat:@"%@\n%lu/%lu",NSLocalizedString(@"Adding footprints...", @"正在添加足迹点..."),(unsigned long)(idx + 1),(unsigned long)self.assetsArray.count];
        [SVProgressHUD showInfoWithStatus:status];
        
        EverywhereAnnotation *anno = [EverywhereAnnotation new];
        PHAsset *firstAsset = obj.firstObject;
        PHAsset *lastAsset = obj.lastObject;
        anno.location = firstAsset.location;
        
        PHAssetInfo *firstAssetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:firstAsset.localIdentifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        
        
        if (self.settingManager.mapBaseMode == MapBaseModeMoment) {
            anno.annotationSubtitle = [NSString stringWithFormat:@"%@",[firstAsset.creationDate stringWithDefaultFormat]];
        }else{
            anno.annotationSubtitle = [NSString stringWithFormat:@"%@ ~ %@",[firstAsset.creationDate stringWithFormat:@"yyyy-MM-dd"],[lastAsset.creationDate stringWithFormat:@"yyyy-MM-dd"]];
        }
        
        NSString *placeName = [firstAssetInfo.localizedPlaceString_Placemark placemarkBriefName];
        if (!placeName) {
            //placeName = NSLocalizedString(@"(Parsing location)",@"（正在解析位置）");
            placeName = anno.annotationSubtitle;
        }
        //下面注释的这一行同时显示序号和名称，后来发现不好用
        //anno.annotationTitle = [NSString stringWithFormat:@"%lu/%lu %@",(unsigned long)(idx + 1),(unsigned long)(self.assetsArray.count),placeName];
        anno.annotationTitle = [NSString stringWithFormat:@"%@",placeName];
        
        FootprintAnnotation *footprintAnnotation = [FootprintAnnotation new];
        footprintAnnotation.customTitle = anno.annotationTitle;
        footprintAnnotation.coordinateWGS84 = firstAsset.location.coordinate;
        footprintAnnotation.altitude = firstAsset.location.altitude;
        footprintAnnotation.speed = firstAsset.location.speed;
        footprintAnnotation.startDate = firstAsset.creationDate;
        if (self.settingManager.mapBaseMode == MapBaseModeLocation) footprintAnnotation.endDate = lastAsset.creationDate;

        NSMutableArray *ids = [NSMutableArray new];
        [obj enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
            [ids addObject:asset.localIdentifier];
        }];
        anno.assetLocalIdentifiers = ids;
        
        [annotationsToAdd addObject:anno];
        
        [footprintAnnotationsToAdd addObject:footprintAnnotation];
        
        [self.myMapView addAnnotation:anno];
    }];
    
    //[SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Finish adding footprints", @"足迹点添加完成")];
    [SVProgressHUD dismissWithDelay:1.0];
    
    self.addedIDAnnotations = annotationsToAdd;
    self.addedEWAnnotations = annotationsToAdd;
    self.addedEWFootprintAnnotations = footprintAnnotationsToAdd;
    
}


/**
 计算以当前足迹点生成足迹包时，将要产生的缩略图数量

 @return 缩略图数量
 */
- (NSUInteger)calculateThumbnailCountForAddedEWFootprintAnnotations{
    NSUInteger resultCount = 0;
    
    if (self.settingManager.autoUseFirstAssetAsThumbnail){
        // 如果用户选择自动添加第一张照片作为缩略图
        resultCount = self.addedEWAnnotations.count;
    }else if(self.settingManager.autoUseAllAssetsAsThumbnail){
        // 如果用户选择自动添加全部照片作为缩略图
        for (EverywhereAnnotation *everywhereAnnotation in self.addedEWAnnotations) {
            resultCount += everywhereAnnotation.assetLocalIdentifiers.count;
        }
    }else{
        // actAsThumbnail属性为真
        // 均添加该PHAssetInfo对应的缩略图
        for (EverywhereAnnotation *everywhereAnnotation in self.addedEWAnnotations) {
            for (NSString *assetLocalIdentifier in everywhereAnnotation.assetLocalIdentifiers) {
                PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:assetLocalIdentifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
                if ([assetInfo.actAsThumbnail boolValue]) resultCount++;
            }
        }
    }
    
    return resultCount;
}


- (void)updateThumbnailForAddedEWFootprintAnnotations{
    
    @try {
        //NSMutableArray <FootprintAnnotation *> *footprintAnnotationsToAdd = [NSMutableArray new];
        NSInteger faIndex = 0;
        // 第1层循环
        for (EverywhereAnnotation *everywhereAnnotation in self.addedEWAnnotations) {
            FootprintAnnotation *footprintAnnotation = self.addedEWFootprintAnnotations[faIndex++];
            
            // 如果用户选择自动添加第一张照片作为缩略图
            if (self.settingManager.autoUseFirstAssetAsThumbnail){
                NSString *firstID = everywhereAnnotation.assetLocalIdentifiers.firstObject;
                NSData *imageDate = [self thumbnailDataWithLocalIdentifier:firstID];
                footprintAnnotation.thumbnailArray = [NSMutableArray arrayWithObject:imageDate];
                continue;
            }
            
            // 否则，开始第2层循环，添加actAsThumbnail属性为真的PHAssetInfo对应的缩略图
            NSMutableArray *ma = [NSMutableArray new];
            for (NSString *assetLocalIdentifier in everywhereAnnotation.assetLocalIdentifiers) {
                PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:assetLocalIdentifier inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
                
                if (self.settingManager.autoUseAllAssetsAsThumbnail || [assetInfo.actAsThumbnail boolValue]){
                    // 如果用户选择自动添加全部照片作为缩略图
                    // 或者actAsThumbnail属性为真
                    // 均添加该PHAssetInfo对应的缩略图
                    NSData *imageDate = [self thumbnailDataWithLocalIdentifier:assetInfo.localIdentifier];
                    [ma addObject:imageDate];
                }
                
            }
            
            footprintAnnotation.thumbnailArray = ma;
        }

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

- (NSData *)thumbnailDataWithLocalIdentifier:(NSString *)localIdentifier{
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
    UIImage *image = [asset synchronousFetchUIImageAtTargetSize:CGSizeMake(asset.pixelWidth * self.settingManager.thumbnailScaleRate, asset.pixelHeight * self.settingManager.thumbnailScaleRate)];
    NSData *imageDate = self.settingManager.thumbnailCompressionQuality == 1.0 ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image,self.settingManager.thumbnailCompressionQuality);
    return imageDate;
}

- (void)addLineOverlaysPro:(NSArray <id<MKAnnotation>> *)annotationArray{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    //maxDistance = 500;
    if (annotationArray.count >= 2) {
        // 将tag置为1，下次点击按钮时添加模拟路线
        changeOverlayStyleButton.tag = 1;
        
        // 记录距离信息
        NSMutableArray *distanceArray = [NSMutableArray new];
        totalDistance = 0;
        
        // 添加 MKOverlays
        
        //NSMutableArray <MKPolyline *> *polylinesToAdd = [NSMutableArray new];
        //NSMutableArray <MKPolygon *> *polygonsToAdd = [NSMutableArray new];
        __block CLLocationCoordinate2D lastCoordinate;
        [annotationArray enumerateObjectsUsingBlock:^(id<MKAnnotation> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= 1) {
                
                //float progress = (float)(idx+1)/(float)annotationArray.count;
                NSString *status = [NSString stringWithFormat:@"%@\n%lu/%lu",NSLocalizedString(@"Adding line route", @"正在添加箭头路线"),(unsigned long)(idx + 1),(unsigned long)annotationArray.count];
                [SVProgressHUD showInfoWithStatus:status];
                
                MKPolyline *polyline = [AssetsMapProVC createLineMKPolylineBetweenStartCoordinate:lastCoordinate endCoordinate:obj.coordinate];
                //[polylinesToAdd addObject:polyline];
                polyline.title = self.settingManager.routeColorIsMonochrome? MKOverlayTitleForMapModeColor : MKOverlayTitleForRandomColor;
                
                CLLocationDistance subDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
                //if (maxDistance < subDistance) maxDistance = subDistance;
                totalDistance += subDistance;
                [distanceArray addObject:[NSNumber numberWithDouble:subDistance]];
                
                MKPolygon *polygon = [AssetsMapProVC createArrowMKPolygonBetweenStartCoordinate:lastCoordinate endCoordinate:obj.coordinate];
                //[polygonsToAdd addObject:polygon];
                polygon.title = self.settingManager.routeColorIsMonochrome? MKOverlayTitleForMapModeColor : MKOverlayTitleForRandomColor;
                
                [self.myMapView addOverlays:@[polyline,polygon]];
                
                lastCoordinate = obj.coordinate;
            }else{
                lastCoordinate = obj.coordinate;
            }
        }];
        
        //[SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Finish adding line route", @"箭头路线添加完成")];
        [SVProgressHUD dismissWithDelay:1.0];
        //if(DEBUGMODE) NSLog(@"%@",overlaysToAdd);
        //[self.myMapView addOverlays:polylinesToAdd];
        //[self.myMapView addOverlays:polygonsToAdd];
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
        [annotationArray enumerateObjectsUsingBlock:^(id<MKAnnotation> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //float progress = (float)(idx+1)/(float)annotationArray.count;
            NSString *status = [NSString stringWithFormat:@"%@\n%lu/%lu",NSLocalizedString(@"Adding range circle", @"正在添加范围圆圈"),(unsigned long)(idx + 1),(unsigned long)annotationArray.count];
            [SVProgressHUD showInfoWithStatus:status];
            
            MKCircle *circle = [MKCircle circleWithCenterCoordinate:obj.coordinate radius:circleRadius];
            circle.title = self.settingManager.routeColorIsMonochrome? MKOverlayTitleForMapModeColor : MKOverlayTitleForRandomColor;
            if (circle) [self.myMapView addOverlay:circle];//[circlesToAdd addObject:circle];
        }];
        
        //[SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Finish adding range circle", @"范围圆圈添加完成")];
        [SVProgressHUD dismissWithDelay:1.0];
        
    }

}

/**
 *  异步添加模拟路线
 *
 *  @param annotationArray MKAnnotation数组
 *  @param completionBlock 添加完成块
 */
- (void)asyncAddRouteOverlays:(NSArray <id<MKAnnotation>> *)annotationArray completionBlock:(void(^)(NSInteger routePolylineCount,CLLocationDistance routeTotalDistance))completionBlock{
    [self.myMapView removeOverlays:self.myMapView.overlays];
    //maxDistance = 0;
    
    if (annotationArray.count < 2){
        if(completionBlock) completionBlock(0,0);
        return;
    }
    
    // 将tag置为0，下次点击按钮时添加箭头路线
    changeOverlayStyleButton.tag = 0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // 记录距离信息
        __block CLLocationDistance routeTotalDistance = 0;
        __block NSInteger routePolylineCount = 0;
        __block CLLocationCoordinate2D lastCoordinate;
        
        [annotationArray enumerateObjectsUsingBlock:^(id<MKAnnotation> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx > 0){
                float progress = (float)(idx+1)/(float)annotationArray.count;
                NSString *status = [NSString stringWithFormat:@"%@\n%lu/%lu",NSLocalizedString(@"Adding simulation route", @"正在添加模拟路线"),(unsigned long)(idx + 1),(unsigned long)annotationArray.count];
                [SVProgressHUD showProgress:progress status:status];
                [AssetsMapProVC asyncCreateRouteMKPolylineBetweenStartCoordinate:lastCoordinate
                                                                   endCoordinate:obj.coordinate
                                                                 completionBlock:^(BOOL succeeded, MKPolyline *routePolyline, CLLocationDistance routeDistance) {
                    MKPolyline *newPolyline;
                    if (succeeded){
                        routePolylineCount++;
                        routeTotalDistance += routeDistance;
                        newPolyline = routePolyline;
                    }else{
                        newPolyline = [AssetsMapProVC createLineMKPolylineBetweenStartCoordinate:lastCoordinate endCoordinate:obj.coordinate];
                        routeTotalDistance += MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
                    }
                     
                    newPolyline.title = self.settingManager.routeColorIsMonochrome? MKOverlayTitleForMapModeColor : MKOverlayTitleForRandomColor;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.myMapView addOverlay:newPolyline];
                    });
                }];
                
                [NSThread sleepForTimeInterval:0.2];
                
                if (idx % 50 == 0){
                    [NSThread sleepForTimeInterval:1.0];
                }
                
                lastCoordinate = obj.coordinate;
            }else{
                lastCoordinate = obj.coordinate;
            }
            
        }];// 结束循环
        
        if (completionBlock){
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(routePolylineCount,routeTotalDistance);
                //[SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Finish adding simulation route", @"模拟路线添加完成")];
                [SVProgressHUD dismissWithDelay:1.0];
            });
        }
    });
}

+ (void)asyncCreateRouteMKPolylineBetweenStartCoordinate:(CLLocationCoordinate2D)startCoord endCoordinate:(CLLocationCoordinate2D)endCoord completionBlock:(void(^)(BOOL succeeded,MKPolyline *routePolyline,CLLocationDistance routeDistance))completionBlock{
    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:startCoord addressDictionary:nil]];
    MKMapItem *endCoordMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:endCoord addressDictionary:nil]];
    
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    [directionsRequest setSource:startMapItem];
    [directionsRequest setDestination:endCoordMapItem];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    
    // 解析路线有可能崩溃！
    @try {
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
            MKRoute *route = response.routes.firstObject;
            if (route){
                MKPolyline *randomColorPolyline = route.polyline;
                randomColorPolyline.title = MKOverlayTitleForRandomColor;
                completionBlock(YES,randomColorPolyline,route.distance);
            }else{
                completionBlock(NO,nil,0);
            }
        }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
}

/*
- (void)moveMapViewToFirstAnnotationWithDistance:(CLLocationDistance)regionDistance{
    
    id<MKAnnotation> firstAnnotation = self.addedIDAnnotations.firstObject;
    
    if (regionDistance == 0){
        if (self.addedIDAnnotations.count <= 1){
            regionDistance = 1000;
        }else if (self.addedIDAnnotations.count > 1){
            
            __block CLLocationDistance maxDistance = 0;
            __block CLLocationCoordinate2D lastCoordinate;
            [self.addedIDAnnotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx > 0){
                    CLLocationDistance currentDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(obj.coordinate), MKMapPointForCoordinate(lastCoordinate));
                    if (maxDistance < currentDistance) maxDistance = currentDistance;
                }else{
                    lastCoordinate = obj.coordinate;
                }
            }];
            
            regionDistance = maxDistance;
        }
    }
    
    MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstAnnotation.coordinate, regionDistance, regionDistance);
    [self.myMapView setRegion:showRegion animated:NO];
    [self.myMapView selectAnnotation:firstAnnotation animated:YES];
}
*/

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annotationView = [MKAnnotationView new];
    //UITapGestureRecognizer *annotationViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(annotationViewTapGR:)];
    //[annotationView addGestureRecognizer:annotationViewTapGR];
    
    if ([annotation isKindOfClass:[EverywhereAnnotation class]]) {
        //MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinAV"];
        //if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAV"];
        MKPinAnnotationView *pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAV"];
        pinAV.animatesDrop = NO;
        
        if(iOS9) pinAV.pinTintColor = self.currentTintColor;//[UIColor greenColor];
        else pinAV.pinColor = MKPinAnnotationColorGreen;
        
        pinAV.canShowCallout = YES;
        
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:((EverywhereAnnotation *)annotation).assetLocalIdentifiers options:options].firstObject;
        
        
        UIImageView *imageView = [AssetsMapProVC badgeImageViewWithFrame:CGRectMake(0, 0, 40, 40)
                                                                   image:[asset synchronousFetchUIImageAtTargetSize:CGSizeMake(40, 40)]
                                                                   title:[NSString stringWithFormat:@"%ld",(long)((EverywhereAnnotation *)annotation).assetCount]];
        UITapGestureRecognizer *imageViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGR:)];
        [imageView addGestureRecognizer:imageViewTapGR];

        //pinAV.image = imageView.image;
        pinAV.leftCalloutAccessoryView = imageView;
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        annotationView = pinAV;
    }else if ([annotation isKindOfClass:[FootprintAnnotation class]]){
        
        //MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinShareAV"];
        //if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinShareAV"];
        MKPinAnnotationView *pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinShareAV"];
        
        FootprintAnnotation *footprintAnnotation = (FootprintAnnotation *)annotation;
        
        pinAV.animatesDrop = NO;
        
        if(iOS9) pinAV.pinTintColor = footprintAnnotation.isUserManuallyAdded ? [UIColor redColor] : self.currentTintColor;
        else pinAV.pinColor = footprintAnnotation.isUserManuallyAdded ? MKPinAnnotationColorRed : MKPinAnnotationColorGreen;
        
        pinAV.canShowCallout = YES;
        
        if (footprintAnnotation.thumbnailArray.count > 0){
            id first = footprintAnnotation.thumbnailArray.firstObject;
            UIImage *image = [first isKindOfClass:[UIImage class]] ? first : [UIImage imageWithData:first];
            
            UIImageView *imageView = [AssetsMapProVC badgeImageViewWithFrame:CGRectMake(0, 0, 40, 40)
                                                                       image:image
                                                                       title:[NSString stringWithFormat:@"%ld",(long)footprintAnnotation.thumbnailArray.count]];
            UITapGestureRecognizer *imageViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGR:)];
            [imageView addGestureRecognizer:imageViewTapGR];
            pinAV.leftCalloutAccessoryView = imageView;
        }else{
            pinAV.leftCalloutAccessoryView = nil;
        }
        
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        annotationView = pinAV;

    }else if ([annotation isKindOfClass:[CoordinateInfo class]]){
        GCStarAnnotationView *starView = [[GCStarAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GCStarAnnotationView"];
        starView.canShowCallout = YES;
        starView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        starView.starBackColor = self.currentTintColor;
        return starView;
    }else if([annotation isKindOfClass:[MKUserLocation class]]){
        annotationView = nil;
    }else{
        annotationView = nil;
    }
    return annotationView;
}

+ (UIImageView *)badgeImageViewWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = YES;
    imageView.image = image;
    
    UIButton *badgeButton = [UIButton newAutoLayoutView];
    badgeButton.userInteractionEnabled = NO;
    [badgeButton setBackgroundImage:[UIImage imageNamed:@"badge"] forState:UIControlStateNormal];
    [badgeButton setTitle:title forState:UIControlStateNormal];
    badgeButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [imageView addSubview:badgeButton];
    [badgeButton autoSetDimensionsToSize:CGSizeMake(20, 20)];
    [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    return imageView;
}

- (void)imageViewTapGR:(UITapGestureRecognizer *)sender{
    id<MKAnnotation> firstSelectedAnnotation = self.myMapView.selectedAnnotations.firstObject;
    if ([firstSelectedAnnotation isKindOfClass:[EverywhereAnnotation class]]){
        AssetDetailVC *showVC = [AssetDetailVC new];
        showVC.showIndexLabel = YES;
        showVC.swipeUpToQuit = YES;
        showVC.edgesForExtendedLayout = UIRectEdgeNone;
        showVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        EverywhereAnnotation *annotation = self.myMapView.selectedAnnotations.firstObject;
        showVC.assetLocalIdentifiers = annotation.assetLocalIdentifiers;
        showVC.eliminateStateDidChangeHandler = ^(){
            self.assetInfoArray = self.assetInfoArray;
        };
        
        
        [self presentViewController:showVC animated:YES completion:nil];
    }else if ([firstSelectedAnnotation isKindOfClass:[FootprintAnnotation class]]){
        FootprintAnnotation *footprintAnnotation = (FootprintAnnotation *)self.myMapView.selectedAnnotations.firstObject;
        
        if (footprintAnnotation.thumbnailArray.count <= 0) return;
        
        SimpleImageBrowser *imageVC = [[SimpleImageBrowser alloc] initWithImageArray:footprintAnnotation.thumbnailArray];
        imageVC.title = footprintAnnotation.customTitle;
        imageVC.contentSizeInPopup = ContentSizeInPopup_Big;
        imageVC.landscapeContentSizeInPopup = LandscapeContentSizeInPopup_Big;
        
        popupController = [[STPopupController alloc] initWithRootViewController:imageVC];
        popupController.containerView.layer.cornerRadius = 4;
        [popupController presentInViewController:self];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    [self updateLocationInfoBarWithAnnotationView:view];
    [self showHideLocationInfoBar];
    if(DEBUGMODE) NSLog(@"calloutAccessoryControlTapped: %@",control);
}

- (void)updateLocationInfoBarWithAnnotationView:(MKAnnotationView *)view{
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) return;

    CoordinateInfo *coordinateInfo;
    if ([view.annotation isKindOfClass:[EverywhereAnnotation class]]) {
        EverywhereAnnotation *anno = (EverywhereAnnotation *)view.annotation;
        PHAssetInfo *assetInfo = [PHAssetInfo fetchAssetInfoWithLocalIdentifier:anno.assetLocalIdentifiers.firstObject inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
        
        coordinateInfo = [CoordinateInfo coordinateInfoWithPHAssetInfo:assetInfo
                                                                inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
    }else if ([view.annotation isKindOfClass:[FootprintAnnotation class]]){
        FootprintAnnotation *footprintAnnotation = (FootprintAnnotation *)view.annotation;
        coordinateInfo = [CoordinateInfo coordinateInfoWithCLLocation:footprintAnnotation.location
                                                               inManagedObjectContext:[EverywhereCoreDataManager appDelegateMOC]];
    }else if ([view isKindOfClass:[GCStarAnnotationView class]]){
        coordinateInfo = view.annotation;
    }
    
    if (![coordinateInfo.reverseGeocodeSucceed boolValue]) {
        [CoordinateInfo updatePlacemarkForCoordinateInfo:coordinateInfo completionBlock:^(NSString *localizedPlaceString) {
            locationInfoBar.currentShowCoordinateInfo = coordinateInfo;
        }];
    }
    
    locationInfoBar.currentShowCoordinateInfo = coordinateInfo;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth = 2;
        
        if ([overlay.title isEqualToString:MKOverlayTitleForMapModeColor]) {
            // 与地图主题颜色相同
            polylineRenderer.strokeColor = self.currentTintColor;
        }else if ([overlay.title isEqualToString:MKOverlayTitleForRandomColor]) {
            // 随机颜色
            lastRandomColor = [RandomFlatColorInArray([AssetsMapProVC preferredOverlayColors]) colorWithAlphaComponent:0.8];
            polylineRenderer.strokeColor = lastRandomColor;
        }else if ([overlay.title isEqualToString:MKOverlayTitleForRedColor]) {
            // 红色
            polylineRenderer.strokeColor = [FlatRed colorWithAlphaComponent:0.8];
        }

        return polylineRenderer;
    }else if([overlay isKindOfClass:[MKPolygon class]]){
        // 箭头
        MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        polygonRenderer.lineWidth = 2;
        
        if ([overlay.title isEqualToString:MKOverlayTitleForMapModeColor]) {
            // 与地图主题颜色相同
            polygonRenderer.strokeColor = self.currentTintColor;
        }else if ([overlay.title isEqualToString:MKOverlayTitleForRandomColor]) {
            // 随机颜色
            polygonRenderer.strokeColor = lastRandomColor;
        }else if ([overlay.title isEqualToString:MKOverlayTitleForRedColor]) {
            // 红色
        }
        
        return polygonRenderer;
    }else if ([overlay isKindOfClass:[MKCircle class]]){
        // 范围圆圈
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth = 1;
        
        UIColor *circleColor;
        
        if ([overlay.title isEqualToString:MKOverlayTitleForMapModeColor]) {
            // 与地图主题颜色相同
            circleColor = self.currentTintColor;
        }else if ([overlay.title isEqualToString:MKOverlayTitleForRandomColor]) {
            // 随机颜色
            circleColor = RandomFlatColorInArray([AssetsMapProVC preferredOverlayColors]);
        }else if ([overlay.title isEqualToString:MKOverlayTitleForRedColor]) {
            // 红色
        }
        
        circleRenderer.fillColor = [circleColor colorWithAlphaComponent:0.3];
        
        circleRenderer.strokeColor = [circleColor colorWithAlphaComponent:0.4];
        
        return circleRenderer;
    }
    else{
        return nil;
    }
}

+ (NSArray <UIColor *> *)preferredAnnotationViewColors{
    return @[FlatSkyBlue,FlatPink,FlatGray,FlatPlum,FlatBrown,FlatForestGreen,FlatOrange,FlatWatermelon];
}

+ (NSArray <UIColor *> *)preferredOverlayColors{
    //不适合显示的颜色 @[FlatSand,FlatSandDark]
    return @[FlatOrangeDark,FlatYellowDark,FlatMagentaDark,FlatTeal,FlatTealDark,FlatSkyBlueDark,FlatGreen,FlatGreenDark,FlatMint,FlatMintDark,FlatForestGreenDark,FlatPurple,FlatPurpleDark,FlatBrownDark,FlatPlumDark,FlatWatermelonDark,FlatLime,FlatLimeDark,FlatPinkDark,FlatMaroon,FlatMaroonDark,FlatCoffee,FlatCoffeeDark];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if ([view isKindOfClass:[MKPinAnnotationView class]]){
        self.currentAnnotationIndex = [self.addedIDAnnotations indexOfObject:view.annotation];
    }else if ([view isKindOfClass:[GCStarAnnotationView class]]){
        [view setNeedsDisplay];
        currentAnnotationIndexLabel.text = NSLocalizedString(@"Favorite Location", @"收藏的地点");
    }
    
    [self updateLocationInfoBarWithAnnotationView:view];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    if ([view isKindOfClass:[GCStarAnnotationView class]]){
        [view setNeedsDisplay];
    }
}

- (void)setCurrentAnnotationIndex:(NSInteger)currentAnnotationIndex{
    if (currentAnnotationIndex < 0) return;
    
    _currentAnnotationIndex = currentAnnotationIndex;
    if (self.addedIDAnnotations.count > 0){
        currentAnnotationIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)(currentAnnotationIndex + 1),(unsigned long)self.addedIDAnnotations.count];
    }else{
        currentAnnotationIndexLabel.text = @"";
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocation *checkedUserLocation = userLocation.location;
    
    if (![self checkCoordinate:checkedUserLocation.coordinate]) return;
    
    self.userLocationGCJ02 = checkedUserLocation;
    
    if (self.showUserLocationMode == ShowUserLocationModeFollow) {
        if (self.isRecording && recordedFootprintAnnotations.count >=2){
            FootprintAnnotation *lastFP = recordedFootprintAnnotations.lastObject;
            FootprintAnnotation *secondLastFP = recordedFootprintAnnotations[recordedFootprintAnnotations.count - 2];
            CLLocationDistance distance = [lastFP.location distanceFromLocation:secondLastFP.location];
            [mapView setRegion:MKCoordinateRegionMakeWithDistance(checkedUserLocation.coordinate, distance * 6 , distance * 6) animated:YES];
        }else{
            [mapView setCenterCoordinate:checkedUserLocation.coordinate animated:YES];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D center = mapView.region.center;
    MKCoordinateSpan span = mapView.region.span;
    
    CLLocationCoordinate2D leftCoordinate = CLLocationCoordinate2DMake(center.latitude - span.latitudeDelta, center.longitude);
    CLLocationCoordinate2D rightCoordinate = CLLocationCoordinate2DMake(center.latitude + span.latitudeDelta, center.longitude);
    CLLocationDistance leftToRightDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(leftCoordinate), MKMapPointForCoordinate(rightCoordinate));
    
    CLLocationCoordinate2D topCoordinate = CLLocationCoordinate2DMake(center.latitude, center.longitude + span.longitudeDelta);
    CLLocationCoordinate2D bottomCoordinate = CLLocationCoordinate2DMake(center.latitude, center.longitude - span.longitudeDelta);
    CLLocationDistance topToBottomDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(topCoordinate), MKMapPointForCoordinate(bottomCoordinate));
    
    if(DEBUGMODE) NSLog(@"%@",NSStringFromCGPoint(CGPointMake(leftToRightDistance,topToBottomDistance)));
    if(DEBUGMODE) NSLog(@"%@",NSStringFromCGPoint(CGPointMake(leftToRightDistance/span.latitudeDelta,topToBottomDistance/span.longitudeDelta)));

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
    CLLocation *newLocation = locations.lastObject;
    
    // 地址不准确，直接返回
    if (![self checkCoordinate:newLocation.coordinate]) return;
    
    self.userLocationWGS84 = newLocation;
    
    if (!lastRecordLocation) {
        [self addRecordedFootprintAnnotationsWithLocation:newLocation isUserManuallyAdded:NO];
    }
    
    // 满足最小记录距离条件
    if ([newLocation distanceFromLocation:lastRecordLocation] > self.minDistanceForRecord) {
        // 满足最小记录时间条件
        if([NOW timeIntervalSinceDate:lastRecordDate] > self.minTimeIntervalForRecord){
            [self addRecordedFootprintAnnotationsWithLocation:newLocation isUserManuallyAdded:NO];
        }
       
    }
    
}

- (void)addRecordedFootprintAnnotationsWithLocation:(CLLocation *)newLocation isUserManuallyAdded:(BOOL)isUserManuallyAdded{
    FootprintAnnotation *footprintAnnotation = [FootprintAnnotation new];
    footprintAnnotation.coordinateWGS84 = newLocation.coordinate;
    footprintAnnotation.altitude = newLocation.altitude;
    footprintAnnotation.speed = newLocation.speed;
    footprintAnnotation.startDate = NOW;
    //footprintAnnotation.customTitle = [NSString stringWithFormat:@"Footprint %lu",(unsigned long)(recordedFootprintAnnotations.count + 1)];
    footprintAnnotation.isUserManuallyAdded = isUserManuallyAdded;
    [recordedFootprintAnnotations addObject:footprintAnnotation];
    [self.myMapView addAnnotation:footprintAnnotation];
    
    if (recordedFootprintAnnotations.count > 1){
        //NSInteger lastIndex = [recordedFootprintAnnotations indexOfObject:footprintAnnotation];
        // 显示出两点之间的箭头
        FootprintAnnotation *lastAnno = recordedFootprintAnnotations[recordedFootprintAnnotations.count - 2];
        MKPolyline *polyline = [AssetsMapProVC createLineMKPolylineBetweenStartCoordinate:lastAnno.coordinate endCoordinate:footprintAnnotation.coordinate];
        polyline.title = self.settingManager.routeColorIsMonochrome? MKOverlayTitleForMapModeColor : MKOverlayTitleForRandomColor;
        MKPolygon *polygon = [AssetsMapProVC createArrowMKPolygonBetweenStartCoordinate:lastAnno.coordinate endCoordinate:footprintAnnotation.coordinate];
        polygon.title = self.settingManager.routeColorIsMonochrome? MKOverlayTitleForMapModeColor : MKOverlayTitleForRandomColor;
        [self.myMapView addOverlays:@[polyline,polygon]];
    }
    
    totalDistanceForRecord += [newLocation distanceFromLocation:lastRecordLocation];
    if (totalDistanceForRecord > 0){
        distanceAndFPCountLabelInRMB.text = [NSString stringWithFormat:@"%.2fkm,%lufp",totalDistanceForRecord/1000.0,(unsigned long)recordedFootprintAnnotations.count];
    }
    
    // 如果达到设置最大数据，重新开始一条新的记录，用于节省内存，防止崩溃
    if (recordedFootprintAnnotations.count == self.settingManager.maxFootprintsCountForRecord) {
        [self intelligentlySaveRecordedFootprintAnnotationsAndClearCatche];
    }
    
    // 记录新足迹点后，再更新
    lastRecordLocation = newLocation;
    lastRecordDate = NOW;
}

@end
