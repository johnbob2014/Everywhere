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

@property (strong,nonatomic) NSString *assetLocalIdentifier;
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
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"localizedTitle" ascending:YES]];
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
    
    showVC.assetCollection = fetchResultArray[indexPath.row];
    [self.navigationController pushViewController:showVC animated:YES];
}

@end

#pragma mark - AssetsTVC

@import AddressBookUI;
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
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
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

#pragma mark -
@interface AssetsMapVC() <MKMapViewDelegate>

@end

@implementation AssetsMapVC{
    PHFetchResult <PHAsset *> *fetchResultArray;
    MKMapView *myMapView;
}

//- (void)loadView{
//    
//}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initMapView];
    
    [self fetchAssets];
}

- (void)initMapView{
    myMapView = [MKMapView newAutoLayoutView];
    myMapView.delegate = self;
    myMapView.showsUserLocation = YES;
    
    [self.view addSubview:myMapView];
    [myMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)fetchAssets{
    if (self.assetCollection) {
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期降序排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        // 排除没有地址信息的PHAsset
        /*
        options.predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            PHAsset *asset = (PHAsset *)evaluatedObject;
            if (asset.location) return YES;
            else return NO;
        }];
         */
        
        fetchResultArray = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
        
        // 添加 MKAnnotations
        [myMapView removeAnnotations:myMapView.annotations];
        
        NSMutableArray <EverywhereMKAnnotation *> *annotationsToAdd = [NSMutableArray new];
        [fetchResultArray enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.location) {
                EverywhereMKAnnotation *anno = [EverywhereMKAnnotation new];
                anno.locaton = obj.location;
                anno.assetLocalIdentifier = obj.localIdentifier;
                anno.annotationTitle = [NSString stringWithFormat:@"MKAnnotation : %lu",idx];
                [annotationsToAdd addObject:anno];
            }
        }];
        
        if (annotationsToAdd.count >= 1) {
            [myMapView addAnnotations:annotationsToAdd];
            
            EverywhereMKAnnotation *lastAnnotation = (EverywhereMKAnnotation *) myMapView.annotations.lastObject;
            MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(lastAnnotation.coordinate, 10000, 10000);
            [myMapView setRegion:showRegion animated:YES];
            
            if (annotationsToAdd.count >= 2) {
                // 记录距离信息
                NSMutableArray *distanceArray = [NSMutableArray new];
                __block CLLocationDistance totalDistance = 0;
                
                // 添加 MKOverlays
                [myMapView removeOverlays:myMapView.overlays];
                NSMutableArray <MKPolyline *> *overlaysToAdd = [NSMutableArray new];
                __block CLLocationCoordinate2D lastCoordinate;
                [annotationsToAdd enumerateObjectsUsingBlock:^(EverywhereMKAnnotation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx >= 1) {
                        CLLocationCoordinate2D points[2];
                        points[0] = lastCoordinate;
                        points[1] = obj.coordinate;
                        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:points count:2];
                        polyline.title = [NSString stringWithFormat:@"MKPolyline : %lu",idx];
                        [overlaysToAdd addObject:polyline];
                        
                        CLLocationDistance subDistance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastCoordinate), MKMapPointForCoordinate(obj.coordinate));
                        totalDistance += subDistance;
                        [distanceArray addObject:[NSNumber numberWithDouble:subDistance]];
                        
                        lastCoordinate = obj.coordinate;
                    }else{
                        lastCoordinate = obj.coordinate;
                    }
                }];
                
                NSLog(@"%@",overlaysToAdd);
                [myMapView addOverlays:overlaysToAdd];
                
                NSString *totalString = NSLocalizedString(@"Total:", @"总行程:");
                if (totalDistance >=1000) {
                    self.title = [NSString stringWithFormat:@"%@ %.2f km",totalString,totalDistance/1000];
                }else{
                    self.title = [NSString stringWithFormat:@"%@ %.0f m",totalString,totalDistance];
                }
            }
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[EverywhereMKAnnotation class]]) {
        MKPinAnnotationView *pinAV = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pinAV"];
        if (!pinAV) pinAV = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAV"];
        pinAV.animatesDrop = YES;
        pinAV.canShowCallout = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[((EverywhereMKAnnotation *)annotation).assetLocalIdentifier] options:nil].lastObject;
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
        showVC.assetLocalIdentifier = annotation.assetLocalIdentifier;
        [self.navigationController pushViewController:showVC animated:YES];
    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth = 2;
        polylineRenderer.strokeColor = [UIColor greenColor];
        NSLog(@"%@",polylineRenderer);
        return polylineRenderer;
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

@end

@implementation AssetDetailVC{
    PHAsset *asset;
    UIImageView *imageView;
}

- (void)viewDidLoad{
    asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.assetLocalIdentifier] options:nil].lastObject;
    
    imageView = [UIImageView newAutoLayoutView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [PHAsset synchronousFetchUIImageFromPHAsset:asset targetSize:PHImageManagerMaximumSize];
    [self.view addSubview:imageView];
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
}

@end