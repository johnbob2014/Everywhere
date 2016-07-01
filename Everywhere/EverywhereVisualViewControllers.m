//
//  EverywhereVisualViewControllers.m
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereVisualViewControllers.h"
#import "UIView+AutoLayout.h"
#import "CTPImageBrowserVC.h"
#import "PHAsset+Assistant.h"

#pragma mark - MainVC

@implementation MainVC

@end

@import CoreLocation;
@import MapKit;
@import Photos;
#import "WGS84TOGCJ02.h"

#pragma mark - MapVC

@interface EverywhereMKAnnotation : NSObject <MKAnnotation>
@property (strong,nonatomic) CLLocation *locaton;
@property (strong,nonatomic) UIImage *thumbnailImage;
@property (strong,nonatomic) NSURL *assetURL;

@property (assign,nonatomic) NSInteger assetCount;
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;
@property (strong,nonatomic) NSString *annotationTitle;

@end

@implementation EverywhereMKAnnotation
@synthesize coordinate;

//- (void)setLocaton:(CLLocation *)locaton{
//    if (locaton) coordinate = self.locaton.coordinate;
//    NSLog(@"EverywhereMKAnnotation : coordinate updated!");
//}

- (CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D originalCoordinate = self.locaton.coordinate;
    return [WGS84TOGCJ02 transformFromWGSToGCJ:originalCoordinate];
}

- (NSString *)title{
    return self.annotationTitle;
}

- (NSInteger)assetCount{
    return self.assetLocalIdentifiers.count;
}

@end

/*
@interface EverywhereMKOverlay : NSObject <MKOverlay>

@end

@implementation EverywhereMKOverlay
@synthesize coordinate;
@synthesize boundingMapRect;

@end
*/

@interface MapVC () <CLLocationManagerDelegate,MKMapViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong,nonatomic) CLLocation *imageLocation;
@end

@implementation MapVC{
    MKMapView *myMapView;
    CLLocationManager *locationManager;
    UILabel *scaleLabel;
}

- (void)loadView{
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor grayColor];
    myMapView = [MKMapView newAutoLayoutView];
    myMapView.delegate = self;
    myMapView.showsUserLocation = YES;
    // myMapView.showsScale = YES;
    // myMapView.showsCompass = YES;
    // myMapView.showsPointsOfInterest = YES;
    [self.view addSubview:myMapView];
    [myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    scaleLabel = [UILabel newAutoLayoutView];
    [self.view addSubview:scaleLabel];
    [scaleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
    [scaleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(action:)];
    
    
}

- (void)action:(id)sender{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[@"public.movie",@"public.image"];
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if ( authorizationStatus == kCLAuthorizationStatusAuthorizedAlways || authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse ) {
        NSLog(@"Location Services Enabled.");
        
    }else{
        NSLog(@"Location Services Disabled.\nrequestWhenInUseAuthorization");
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    //locationManager.distanceFilter = CLLocationDistanceMax;
    [locationManager startUpdatingLocation];
    
}


- (void)didReceiveMemoryWarning{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [info enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"%@ : %@",key,obj);
    }];
    
    NSURL *referenceURL = info[UIImagePickerControllerReferenceURL];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[referenceURL] options:nil];
    PHAsset *asset = fetchResult.firstObject;
    if (asset) self.imageLocation = asset.location;
    
    if (self.imageLocation && self.imageLocation.coordinate.latitude != 0 && self.imageLocation.coordinate.longitude != 0) {
        [locationManager stopUpdatingLocation];
        
        __block UIImage *requestImage = nil;
        PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
        // 设置同步获取图片
        imageRequestOptions.synchronous = YES;
        imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:CGSizeMake(80, 80)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:imageRequestOptions
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    requestImage = result;
                                                }];

        
        //NSLog(@"Locate to : %@",self.imageLocation);
        
        EverywhereMKAnnotation *annotation = [EverywhereMKAnnotation new];
        annotation.locaton = self.imageLocation;
        annotation.assetURL = referenceURL;
        annotation.thumbnailImage = requestImage;
        
        [myMapView addAnnotation:annotation];
        
        CLLocationCoordinate2D points[2];
        points[0] = myMapView.userLocation.coordinate;
        points[1] = annotation.coordinate;
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:points count:2];
        polyline.title = @"Arrow";
        [myMapView addOverlay:polyline];
        //MKCoordinateSpan
        //MKCoordinateRegion aRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500);
        [myMapView setCenterCoordinate:annotation.coordinate animated:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *returnAnnotationView = nil;
    NSLog(@"%@",annotation);
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // 使用系统默认标记
    }else if ([annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
        returnAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"easy"];
        if (!returnAnnotationView)
            returnAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"easy"];
        returnAnnotationView.image = ((EverywhereMKAnnotation *) annotation).thumbnailImage;
    }else{
//        MKPinAnnotationView *pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
//        pinAV.pinTintColor = [UIColor blueColor];
//        returnAnnotationView = pinAV;
    }
    
    return returnAnnotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKOverlayRenderer *overlayRenderer = nil;
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        polylineRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polylineRenderer.lineWidth = 3;
        
        overlayRenderer = polylineRenderer;
    }
    return overlayRenderer;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion aRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000);
    [myMapView setRegion:aRegion animated:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //scaleLabel.text = [NSString stringWithFormat:@"%f",myMapView]
}
@end

#pragma mark - CollectionListsTVC
@interface CollectionListsTVC()
@end

@implementation CollectionListsTVC{
    PHFetchResult <PHCollectionList *> *fetchResultArray;
    UISegmentedControl *seg;
}

- (void)viewDidLoad{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    seg = [[UISegmentedControl alloc] initWithItems:[@"Year Cluster" componentsSeparatedByString:@" "]];
    seg.selectedSegmentIndex = 1;
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = seg;
    
    [self fetchCollectionLists];
}

- (void)segChanged:(id)sender{
    [self fetchCollectionLists];
    [self.tableView reloadData];
}

- (void)fetchCollectionLists{
    /*
    PHCollectionListSubtype collectionListSubype = seg.selectedSegmentIndex == 0 ? PHCollectionListSubtypeMomentListYear : PHCollectionListSubtypeMomentListCluster;
    
    fetchResultArray = [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeMomentList
                                                                                             subtype:collectionListSubype
                                                                                             options:nil];
     */
    fetchResultArray = [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeSmartFolder subtype:PHCollectionListSubtypeSmartFolderEvents options:nil];
    NSMutableArray *ma = [NSMutableArray array];
    [fetchResultArray enumerateObjectsUsingBlock:^(PHCollectionList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@",obj);
        //if (obj.localizedLocationNames) [ma addObject:obj];
    }];
    
    //fetchResultArray = (PHFetchResult <PHCollectionList *> *)ma;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fetchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    PHCollectionList *collectionList = fetchResultArray[indexPath.row];
    NSMutableString *ms = [NSMutableString new];
    NSInteger index = 0;
    for (NSString *locationName in collectionList.localizedLocationNames) {
        [ms appendFormat:@"%d : %@ ",index++,locationName];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PHCollectionList *collectionList = fetchResultArray[indexPath.row];
    AssetCollectionsTVC *assetCollectionTVC = [AssetCollectionsTVC new];
    assetCollectionTVC.collectionList = collectionList;
    [self.navigationController pushViewController:assetCollectionTVC animated:YES];
}
@end

#pragma mark - AssetCollectionsTVC

@implementation AssetCollectionsTVC{
    PHFetchResult <PHAssetCollection *> *fetchResultArray;
    UISegmentedControl *seg;
}

- (void)viewDidLoad{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    seg = [[UISegmentedControl alloc] initWithItems:[@"Smart Album Moment" componentsSeparatedByString:@" "]];
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    [self fetchAssets];
}

- (void)segChanged:(id)sender{
    [self fetchAssets];
    [self.tableView reloadData];
}

- (void)fetchAssets{
    fetchResultArray = nil;
    
    NSMutableArray *ma = [NSMutableArray array];
    
    switch (seg.selectedSegmentIndex) {
        case 0:
            fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            break;
        case 1:
            fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
            break;
        case 2:{
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
            fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeMoment subtype:PHAssetCollectionSubtypeAny options:options];
        }
            break;
        default:
            break;
    }
    
    //fetchResultArray = [PHAssetCollection fetchMomentsInMomentList:self.collectionList options:nil];
    
    [fetchResultArray enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"%@",obj);
        //if (obj.localizedLocationNames) [ma addObject:obj];
        [ma addObject:obj];
    }];
    
    fetchResultArray = (PHFetchResult <PHAssetCollection *> *)ma;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fetchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    PHAssetCollection *assetCollection = fetchResultArray[indexPath.row];
    NSMutableString *ms = [NSMutableString new];
    NSInteger index = 0;
    for (NSString *locationName in assetCollection.localizedLocationNames) {
        [ms appendFormat:@"%d : %@ ",index++,locationName];
    }
    
    switch (seg.selectedSegmentIndex) {
        case 0:
            cell.textLabel.text = assetCollection.localizedTitle;
            break;
        case 1:
            cell.textLabel.text = [assetCollection.localizedTitle stringByAppendingFormat:@"(%d)",assetCollection.estimatedAssetCount];
            break;
        case 2:{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            
            NSString *dateString = [dateFormatter stringFromDate:assetCollection.startDate];
            NSString *locationString = assetCollection.localizedTitle ? assetCollection.localizedTitle : NSLocalizedString(@"Unknown Location", @"");
            cell.textLabel.text = [locationString stringByAppendingFormat:@" %@",dateString];
        }
            break;
        default:
            break;
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //AssetsTVC *showVC = [AssetsTVC new];
    AssetsMapVC *showVC = [AssetsMapVC new];
    
    //showVC.assetCollection = fetchResultArray[indexPath.row];
    [self.navigationController pushViewController:showVC animated:YES];
}

@end

#pragma mark - PeriodAssetCollectionsTVC

#import "VCFloatingActionButton.h"
#import "NSDate+Assistant.h"
@interface PeriodAssetCollectionsTVC()<floatMenuDelegate>
@end

@implementation PeriodAssetCollectionsTVC{
    NSMutableDictionary <NSString *,NSArray *> *assetsDictionary;
    UISegmentedControl *seg;
    VCFloatingActionButton *addButton;
}

- (void)viewDidLoad{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    seg = [[UISegmentedControl alloc] initWithItems:[@"Day Month Year" componentsSeparatedByString:@" "]];
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    [self asyncFetchAssets];
    
    //CGRect floatFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44 - 20, [UIScreen mainScreen].bounds.size.height - 44 - 20 - 64 , 44, 44);
    /*
    addButton = [VCFloatingActionButton newAutoLayoutView];
    addButton.imageArray = @[@"fb-icon",@"twitter-icon",@"google-icon",@"linkedin-icon"];
    addButton.labelArray = @[@"Facebook",@"Twitter",@"Google Plus",@"Linked in"];
    addButton.hideWhileScrolling = NO;
    addButton.delegate = self;
    
    //NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    [self.view insertSubview:addButton aboveSubview:self.tableView];
    [addButton autoSetDimensionsToSize:CGSizeMake(44, 44)];
    [addButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
    [addButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    NSLog(@"%@",NSStringFromCGRect(addButton.frame));
     */
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //NSLog(@"%@",NSStringFromCGRect(addButton.frame));
    //[addButton setNormalImage:[UIImage imageNamed:@"plus"] andPressedImage:[UIImage imageNamed:@"cross"] withScrollview:nil];

}

- (void)didSelectMenuOptionAtIndex:(NSInteger)row{
    NSLog(@"Floating action tapped index %tu",row);
}

- (void)segChanged:(id)sender{
    [self asyncFetchAssets];
}

- (void)asyncFetchAssets{
    assetsDictionary = [NSMutableDictionary new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchAssets];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)fetchAssets{
    
    PHFetchResult <PHAssetCollection *> *fetchResultArray = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHAssetCollection *CameraRoll = fetchResultArray.firstObject;
    if (!CameraRoll) return;
    
    //NSLog(@"%ld,%@\,%@",CameraRoll.estimatedAssetCount,CameraRoll.startDate,CameraRoll.endDate);
    NSInteger i = 365;
    if (seg.selectedSegmentIndex == 1)
        i = 120;
    else if (seg.selectedSegmentIndex ==2)
        i = 10;
    
    NSDate *now = [NSDate date];
    NSDate *lastEndDate = [now dateAtEndOfToday];
    if (seg.selectedSegmentIndex == 1)
        lastEndDate = [now dateAtEndOfThisMonth];
    else if (seg.selectedSegmentIndex ==2)
        lastEndDate = [now dateAtEndOfThisYear];
    PHFetchOptions *options = [PHFetchOptions new];
    
    while (i > 0) {
        i--;
        
        NSDate *startDate = [lastEndDate dateAtStartOfToday];
        
        if (seg.selectedSegmentIndex == 1)
            startDate = [lastEndDate dateAtStartOfThisMonth];
        else if (seg.selectedSegmentIndex ==2)
            startDate = [lastEndDate dateAtStartOfThisYear];
        
        options.predicate = [NSPredicate predicateWithFormat:@" (creationDate > %@) && (creationDate < %@)",startDate,lastEndDate];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult <PHAsset *> *assetArray = [PHAsset fetchAssetsInAssetCollection:CameraRoll options:options];
        NSMutableArray <NSString *> *assetIDArray = [NSMutableArray new];
        [assetArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.location && obj.localIdentifier) [assetIDArray addObject:obj.localIdentifier];
        }];
        
        if (assetIDArray.count > 0) {
            NSString *assetIDArrayName = [startDate stringWithFormat:@"yyyy-MM-dd"];
            if (seg.selectedSegmentIndex == 1)
                assetIDArrayName = [startDate stringWithFormat:@"yyyy-MM"];
            else if (seg.selectedSegmentIndex ==2)
                assetIDArrayName = [startDate stringWithFormat:@"yyyy"];
            
            if (assetIDArrayName) [assetsDictionary setValue:assetIDArray forKey:assetIDArrayName];
            //NSLog(@"%ld",assetArray.count);
        }
        
        lastEndDate = [lastEndDate dateBySubtractingDays:1];
        if (seg.selectedSegmentIndex == 1){
            lastEndDate = [lastEndDate dateBySubtractingMonths:1];
            lastEndDate = [lastEndDate dateAtEndOfThisMonth];
        }
        else if (seg.selectedSegmentIndex ==2)
            lastEndDate = [lastEndDate dateBySubtractingYears:1];
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [assetsDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    */
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    NSArray *keyArray = assetsDictionary.allKeys;
    keyArray = [keyArray sortedArrayUsingSelector:@selector(localizedCompare:)].reverseObjectEnumerator.allObjects;
    cell.textLabel.text = keyArray[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)(assetsDictionary.count - indexPath.row)];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //AssetsTVC *showVC = [AssetsTVC new];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    AssetsMapVC *showVC = [AssetsMapVC new];
    showVC.assetLocalIdentifiers = assetsDictionary[cell.textLabel.text];
    [self.navigationController pushViewController:showVC animated:YES];
}


@end

#pragma mark - AssetsTVC

//@import AddressBookUI;
#import "CLPlacemark+Assistant.h"

@implementation AssetsTVC{
    PHFetchResult <PHAsset *> *fetchResultArray;
}

- (void)viewDidLoad{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self fetchAssets];
}

- (void)fetchAssets{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    fetchResultArray = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
    
    NSMutableArray *ma = [NSMutableArray array];
    [fetchResultArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"%@",obj);
        if (obj.location) [ma addObject:obj];
    }];
    
    //fetchResultArray = (PHFetchResult <PHAsset *> *)ma;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fetchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    //PHAsset *asset = fetchResultArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = fetchResultArray[indexPath.row];
    
    __block UIImage *requestImage = nil;
    PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
    // 设置同步获取图片
    imageRequestOptions.synchronous = YES;
    imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)
                                              contentMode:PHImageContentModeAspectFill
                                                  options:imageRequestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                requestImage = result;
                                            }];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:asset.location
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       NSString *placeInfo;
                       if (!error) {
                           CLPlacemark *placemark = placemarks.lastObject;
                           
                           placeInfo = [placemark localizedPlaceStringInReverseOrder:YES withInlandWaterAndOcean:NO];
                           
                           //placeInfo = [placeInfo stringByAppendingString:ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES)];
                       }else{
                           placeInfo = error.localizedDescription;
                       }
                       
                       CTPMultiImage *multiImage = [CTPMultiImage initWithSdImage:nil hdImage:requestImage placeholderImage:nil sdURL:nil hdURL:nil imageDetail:placeInfo];
                       CTPImageBrowserVC *browser = [CTPImageBrowserVC new];
                       browser.multiImageArray = @[multiImage];
                       browser.imageCount = 1;
                       browser.currentImageIndex = 0;
                       
                       [self presentViewController:browser animated:YES completion:nil];

                       
    }];
}
@end

#pragma mark - AssetsMapVC

@interface AssetsMapVC() <MKMapViewDelegate>

@end

@implementation AssetsMapVC{
    PHFetchResult <PHAsset *> *assetArray;
    NSMutableArray <PHAsset *> *assetArrayWithLocation;
    NSMutableArray <NSNumber *> *distanceToPreviousArray;
    MKMapView *myMapView;
    NSArray <EverywhereMKAnnotation *> *addedAnnotationsWithIndex;
}

- (void)setNearestAnnotationDistance:(CLLocationDistance)nearestAnnotationDistance{
    _nearestAnnotationDistance = nearestAnnotationDistance;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if (!self.nearestAnnotationDistance) self.nearestAnnotationDistance = 200;
    
    [self initMapView];
    
    [self updateAssetArray];
    
    [self initAnnotationsAndOverlays];
    
    [self initNaviBar];
}

- (void)initMapView{
    myMapView = [MKMapView newAutoLayoutView];
    myMapView.delegate = self;
    myMapView.showsUserLocation = YES;
    
    [self.view addSubview:myMapView];
    [myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)updateAssetArray{
    if (self.assetLocalIdentifiers) {
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        
        assetArray = [PHAsset fetchAssetsWithLocalIdentifiers:self.assetLocalIdentifiers options:options];
        
        assetArrayWithLocation = [NSMutableArray new];
        distanceToPreviousArray = [NSMutableArray new];
        
        __block CLLocationCoordinate2D lastCoordinate;
        [assetArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.location){
                [assetArrayWithLocation addObject:obj];
                if (idx > 0) {
                    CLLocationCoordinate2D newCoordinate = obj.location.coordinate;
                    CLLocationDistance distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(newCoordinate));
                    [distanceToPreviousArray addObject:[NSNumber numberWithDouble:distance]];
                    lastCoordinate = newCoordinate;
                }else{
                    // 记录第一个位置的座标
                    lastCoordinate = obj.location.coordinate;
                    [distanceToPreviousArray addObject:[NSNumber numberWithDouble:0]];
                }
            }
        }];
        //NSLog(@"distanceToPreviousArray :\n%@",distanceToPreviousArray);
    }
}

- (void)initAnnotationsAndOverlays{
    if (!assetArrayWithLocation || !assetArrayWithLocation.count) return;
    
    // 添加 MKAnnotations
    [myMapView removeAnnotations:myMapView.annotations];
    
    NSMutableArray <EverywhereMKAnnotation *> *annotationsToAdd = [NSMutableArray new];
    
    if (assetArrayWithLocation.count == 1) {
        PHAsset *asset = assetArrayWithLocation.firstObject;
        EverywhereMKAnnotation *onlyOne = [EverywhereMKAnnotation new];
        onlyOne.locaton = asset.location;
        onlyOne.assetLocalIdentifiers = @[asset.localIdentifier];
        onlyOne.annotationTitle = [NSString stringWithFormat:@"%@ %@",@"1 Photo",[asset.creationDate stringWithDefaultFormat]];
        [annotationsToAdd addObject:onlyOne];
    }else if (assetArrayWithLocation.count > 1){
        
        //__block NSUInteger startIdx = 0;
        //__block NSUInteger endIdx = 0;
        __block NSMutableArray <NSString *> *tempAssetLocalIdentifiers = [NSMutableArray new];
        __block NSMutableArray <PHAsset *> *tempAssets = [NSMutableArray new];
        NSUInteger count = assetArrayWithLocation.count;
        NSLog(@"assetArrayWithLocation.count : %ld",count);
        
        [assetArrayWithLocation enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (([distanceToPreviousArray[idx] doubleValue] < self.nearestAnnotationDistance) && (idx <= count-2)) {
                
                [tempAssets addObject:obj];
                [tempAssetLocalIdentifiers addObject:obj.localIdentifier];
            }else{
                EverywhereMKAnnotation *lastAnno = nil;
                
                if (idx == count - 1) {
                    if ([distanceToPreviousArray[idx] doubleValue] < self.nearestAnnotationDistance) {
                        [tempAssets addObject:obj];
                        [tempAssetLocalIdentifiers addObject:obj.localIdentifier];
                    }else{
                        lastAnno = [EverywhereMKAnnotation new];
                        lastAnno.locaton = obj.location;
                        lastAnno.assetLocalIdentifiers = @[obj.localIdentifier];
                        lastAnno.annotationTitle = [NSString stringWithFormat:@"%@ %@",@"1 Photo",[obj.creationDate stringWithDefaultFormat]];
                    }
                }
                
                if (tempAssetLocalIdentifiers.count > 0) {
                    EverywhereMKAnnotation *anno = [EverywhereMKAnnotation new];
                    anno.locaton = tempAssets.firstObject.location;
                    anno.assetLocalIdentifiers = tempAssetLocalIdentifiers;
                    NSMutableString *titleMS = [NSMutableString new];
                    [titleMS appendString:tempAssetLocalIdentifiers.count == 1 ? @"1 Photo": [NSString stringWithFormat:@" %lu Photos",tempAssetLocalIdentifiers.count]];
                    [titleMS appendFormat:@" %@",[tempAssets.firstObject.creationDate stringWithDefaultFormat]];
                    anno.annotationTitle = titleMS;
                    [annotationsToAdd addObject:anno];
                    
                    // 重新开始记录
                    tempAssets = [NSMutableArray new];
                    tempAssetLocalIdentifiers = [NSMutableArray new];
                    // 加上当前的obj信息（新一个位置开始）
                    [tempAssets addObject:obj];
                    [tempAssetLocalIdentifiers addObject:obj.localIdentifier];
                }
                
                if (lastAnno) [annotationsToAdd addObject:lastAnno];
                
            }
        }];
    }
    
    if (!annotationsToAdd || !annotationsToAdd.count) return;
    [myMapView addAnnotations:annotationsToAdd];
    addedAnnotationsWithIndex = annotationsToAdd;
    
    __block CLLocationDistance maxDistance = 500;
    [distanceToPreviousArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (maxDistance < obj.doubleValue) maxDistance = obj.doubleValue;
    }];
    EverywhereMKAnnotation *lastAnnotation = (EverywhereMKAnnotation *) myMapView.annotations.lastObject;
    MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(lastAnnotation.coordinate, maxDistance, maxDistance);
    [myMapView setRegion:showRegion animated:YES];
    
    if (annotationsToAdd.count >= 2) {
        // 记录距离信息
        NSMutableArray *distanceArray = [NSMutableArray new];
        __block CLLocationDistance totalDistance = 0;
        
        // 添加 MKOverlays
        [myMapView removeOverlays:myMapView.overlays];
        NSMutableArray <MKPolyline *> *polylinesToAdd = [NSMutableArray new];
        NSMutableArray <MKPolygon *> *polygonsToAdd = [NSMutableArray new];
        __block CLLocationCoordinate2D lastCoordinate;
        [annotationsToAdd enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= 1) {
                CLLocationCoordinate2D points[2];
                points[0] = lastCoordinate;
                points[1] = obj.coordinate;
                MKPolyline *polyline = [MKPolyline polylineWithCoordinates:points count:2];
                polyline.title = [NSString stringWithFormat:@"MKPolyline : %lu",idx];
                [polylinesToAdd addObject:polyline];
                
                CLLocationDistance subDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
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
        
        NSString *totalString = NSLocalizedString(@"Total:", @"总行程:");
        if (totalDistance >=1000) {
            self.title = [NSString stringWithFormat:@"%@ %.2f km",totalString,totalDistance/1000];
        }else{
            self.title = [NSString stringWithFormat:@"%@ %.0f m",totalString,totalDistance];
        }
    }

}

- (void)initNaviBar{
    UIView *naviBar = [UIView newAutoLayoutView];
    [naviBar setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]];
    [self.view addSubview:naviBar];
    [naviBar autoSetDimension:ALDimensionHeight toSize:44];
    [naviBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 20, 5) excludingEdge:ALEdgeTop];
    
    UIButton *firstButton = [UIButton newAutoLayoutView];
    [firstButton setTitle:@"First" forState:UIControlStateNormal];
    [firstButton addTarget:self action:@selector(firstButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:firstButton];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [firstButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    UIButton *previousButton = [UIButton newAutoLayoutView];
    [previousButton setTitle:@"Previous" forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:previousButton];
    [previousButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:firstButton withOffset:30];
    [previousButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    UIButton *nextButton = [UIButton newAutoLayoutView];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:nextButton];
    [nextButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:previousButton withOffset:30];
    [nextButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    
    UIButton *lastButton = [UIButton newAutoLayoutView];
    [lastButton setTitle:@"Last" forState:UIControlStateNormal];
    [lastButton addTarget:self action:@selector(lastButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [naviBar addSubview:lastButton];
    [lastButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:nextButton withOffset:30];
    [lastButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
}

- (void)firstButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = addedAnnotationsWithIndex.firstObject;
    [myMapView setCenterCoordinate:ida.coordinate animated:YES];
    [myMapView selectAnnotation:ida animated:YES];
}

- (void)previousButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = myMapView.selectedAnnotations.firstObject;
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

- (void)nextButtonPressed:(id)sender{
    EverywhereMKAnnotation *ida = myMapView.selectedAnnotations.firstObject;
    if (ida) {
        NSInteger index = [addedAnnotationsWithIndex indexOfObject:ida];
        if (++index < addedAnnotationsWithIndex.count) {
            [myMapView deselectAnnotation:ida animated:YES];
            ida = addedAnnotationsWithIndex[index];
            
            [myMapView setCenterCoordinate:ida.coordinate animated:YES];
            [myMapView selectAnnotation:ida animated:YES];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
        MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinAV"];
        if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAV"];
        pinAV.pinColor = MKPinAnnotationColorPurple;
        pinAV.animatesDrop = YES;
        pinAV.canShowCallout = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:((EverywhereMKAnnotation *)annotation).assetLocalIdentifiers options:options].firstObject;
        if (asset) imageView.image = [PHAsset synchronousFetchUIImageFromPHAsset:asset targetSize:CGSizeMake(80, 80)];
        
        pinAV.leftCalloutAccessoryView = imageView;
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pinAV;
    }else{
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if ([view isKindOfClass:[MKPinAnnotationView class]] && [control isKindOfClass:[UIButton class]]) {
        EverywhereMKAnnotation *annotation = (EverywhereMKAnnotation *) view.annotation;
        //UIButton *btn = (UIButton *) control;
        
        //PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[((EverywhereMKAnnotation *)annotation).assetLocalIdentifier] options:nil].lastObject;
        
        AssetDetailVC *showVC = [AssetDetailVC new];
        showVC.edgesForExtendedLayout = UIRectEdgeNone;
        showVC.assetLocalIdentifiers = annotation.assetLocalIdentifiers;
        [self.navigationController pushViewController:showVC animated:YES];
    }
    
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
        polygonRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
        return polygonRenderer;
        
    }else{
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    // MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000);
    // [mapView setRegion:showRegion animated:YES];
}

@end


#pragma mark - AssetDetailVC

@interface AssetDetailVC ()
@property (assign,nonatomic) NSInteger currentIndex;
@end

@implementation AssetDetailVC{
    PHFetchResult <PHAsset *> *assetArray;
    
    UIImageView *imageView;
}


- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex >= 0 && currentIndex <= assetArray.count - 1) {
        _currentIndex = currentIndex;
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            imageView.image = [PHAsset synchronousFetchUIImageFromPHAsset:assetArray[currentIndex] targetSize:PHImageManagerMaximumSize];
        }
                         completion:^(BOOL finished) {
            self.title = [NSString stringWithFormat:@"%ld / %ld",currentIndex + 1,assetArray.count];
        }];
        
    }
}

- (void)viewDidLoad{
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
    
    self.currentIndex = 0;
}

- (void)swipeRight:(UISwipeGestureRecognizer *)sender{
    self.currentIndex--;
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)sender{
    self.currentIndex++;
}
@end

