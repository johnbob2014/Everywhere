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
@end

@implementation EverywhereMKAnnotation
@synthesize coordinate;

//- (void)setLocaton:(CLLocation *)locaton{
//    if (locaton) coordinate = self.locaton.coordinate;
//    NSLog(@"EverywhereMKAnnotation : coordinate updated!");
//}

-(CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D originalCoordinate = self.locaton.coordinate;
    return [WGS84TOGCJ02 transformFromWGSToGCJ:originalCoordinate];
}

@end

@interface EverywhereMKOverlay : NSObject <MKOverlay>

@end

@implementation EverywhereMKOverlay
@synthesize coordinate;
@synthesize boundingMapRect;

@end

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

#pragma mark - CollectionListTVC
@interface CollectionListTVC()
@end

@implementation CollectionListTVC{
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
    PHCollectionListSubtype collectionListSubype = seg.selectedSegmentIndex == 0 ? PHCollectionListSubtypeMomentListYear : PHCollectionListSubtypeMomentListCluster;
    
    fetchResultArray = [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeMomentList
                                                                                             subtype:collectionListSubype
                                                                                             options:nil];
    NSMutableArray *ma = [NSMutableArray array];
    [fetchResultArray enumerateObjectsUsingBlock:^(PHCollectionList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // NSLog(@"%@",obj);
        if (obj.localizedLocationNames) [ma addObject:obj];
    }];
    
    fetchResultArray = (PHFetchResult <PHCollectionList *> *)ma;
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
    
    cell.textLabel.text = ms;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PHCollectionList *collectionList = fetchResultArray[indexPath.row];
    AssetCollectionTVC *assetCollectionTVC = [AssetCollectionTVC new];
    assetCollectionTVC.collectionList = collectionList;
    [self.navigationController pushViewController:assetCollectionTVC animated:YES];
}
@end

#pragma mark - AssetCollectionTVC

@implementation AssetCollectionTVC{
    PHFetchResult <PHAssetCollection *> *fetchResultArray;
}

- (void)viewDidLoad{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self fetchMoments];
}

- (void)fetchMoments{
    fetchResultArray = [PHAssetCollection fetchMomentsInMomentList:self.collectionList options:nil];
    
    NSMutableArray *ma = [NSMutableArray array];
    [fetchResultArray enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"%@",obj);
        if (obj.localizedLocationNames) [ma addObject:obj];
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
    
    cell.textLabel.text = ms;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [cell layoutSubviews];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AssetTVC *assetTVC = [AssetTVC new];
    assetTVC.assetCollection = fetchResultArray[indexPath.row];
    [self.navigationController pushViewController:assetTVC animated:YES];
}

@end

#pragma mark - AssetTVC

@import AddressBookUI;
#import "CLPlacemark+Assistant.h"

@implementation AssetTVC{
    PHFetchResult <PHAsset *> *fetchResultArray;
}

- (void)viewDidLoad{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    [self fetchAssets];
}

- (void)fetchAssets{
    fetchResultArray = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:nil];
    
    NSMutableArray *ma = [NSMutableArray array];
    [fetchResultArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"%@",obj);
        if (obj.location) [ma addObject:obj];
    }];
    
    fetchResultArray = (PHFetchResult <PHAsset *> *)ma;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fetchResultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    PHAsset *asset = fetchResultArray[indexPath.row];
    
    cell.textLabel.text = asset.description;
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
                           
                           placeInfo = [placemark localizedPlaceString];
                           //placeInfo = [NSString stringWithFormat:@"%@\n%@",[placemark localizedPlaceString],[placemark areasOfInterestStringWithIndex:YES]];
                           
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