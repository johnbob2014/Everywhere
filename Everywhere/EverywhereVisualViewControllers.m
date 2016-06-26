//
//  EverywhereVisualViewControllers.m
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereVisualViewControllers.h"
#import "UIView+AutoLayout.h"


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