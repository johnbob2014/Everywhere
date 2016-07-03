//
//  AssetsMapProVC.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "AssetsMapProVC.h"
@import Photos;
@import MapKit;
#import "EverywhereMKAnnotation.h"
#import "NSDate+Assistant.h"
#import "UIView+AutoLayout.h"
#import "PHAsset+Assistant.h"
#import "UIFont+Assistant.h"
#import "EverywhereVisualViewControllers.h"
#import "GCLocationAnalyser.h"

@interface AssetsMapProVC () <MKMapViewDelegate>
@property (assign,nonatomic) NSInteger currentAnnotationIndex;
@end

@implementation AssetsMapProVC{
    MKMapView *myMapView;
    NSArray <EverywhereMKAnnotation *> *addedAnnotationsWithIndex;
    
    UIView *naviBar;
    UIButton *firstButton;
    UIButton *previousButton;
    UIButton *playButton;
    UIButton *nextButton;
    UIButton *lastButton;
    UILabel *currentAnnotationIndexLabel;
    
    BOOL isPlaying;
    NSTimer *playTimer;

}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initMapView];
    
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

- (void)initAnnotationsAndOverlays{
    
    // 添加 MKAnnotations
    [myMapView removeAnnotations:myMapView.annotations];
    
    NSMutableArray <EverywhereMKAnnotation *> *annotationsToAdd = [NSMutableArray new];
    
    [self.assetsArray enumerateObjectsUsingBlock:^(NSArray<PHAsset *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = obj.firstObject;
        NSMutableArray *ids = [NSMutableArray new];
        [obj enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ids addObject:obj.localIdentifier];
        }];
        EverywhereMKAnnotation *anno = [EverywhereMKAnnotation new];
        anno.locaton = asset.location;
        anno.annotationTitle = [asset.creationDate stringWithDefaultFormat];
        anno.assetLocalIdentifiers = ids;
        [annotationsToAdd addObject:anno];
    }];
    
    if (!annotationsToAdd || !annotationsToAdd.count) return;
    [myMapView addAnnotations:annotationsToAdd];
    addedAnnotationsWithIndex = annotationsToAdd;
    //NSLog(@"%@",addedAnnotationsWithIndex);
    
    EverywhereMKAnnotation *firstAnnotation = addedAnnotationsWithIndex.firstObject;
    MKCoordinateRegion showRegion = MKCoordinateRegionMakeWithDistance(firstAnnotation.coordinate, 1000, 1000);
    [myMapView setRegion:showRegion animated:YES];
    [myMapView selectAnnotation:firstAnnotation animated:YES];
    
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
    [playButton setTitle:@"⭕️" forState:UIControlStateNormal];
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
        [sender setTitle:@"⭕️" forState:UIControlStateNormal];
        [playTimer invalidate];
        playTimer = nil;
    }else{
        // 开始播放
        [sender setTitle:@"❌" forState:UIControlStateNormal];
        playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(nextButtonPressed:) userInfo:nil repeats:YES];
    }
    isPlaying = !isPlaying;
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
        imageView.userInteractionEnabled = YES;
        PHFetchOptions *options = [PHFetchOptions new];
        // 按日期排列
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:((EverywhereMKAnnotation *)annotation).assetLocalIdentifiers options:options].firstObject;
        if (asset) imageView.image = [PHAsset synchronousFetchUIImageFromPHAsset:asset targetSize:CGSizeMake(80, 80)];
        
        UIButton *badgeButton = [UIButton newAutoLayoutView];
        [badgeButton setBackgroundImage:[UIImage imageNamed:@"badge"] forState:UIControlStateNormal];
        [badgeButton setTitle:[NSString stringWithFormat:@"%ld",((EverywhereMKAnnotation *)annotation).assetCount] forState:UIControlStateNormal];
        badgeButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [imageView addSubview:badgeButton];
        [badgeButton autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        pinAV.leftCalloutAccessoryView = imageView;
        pinAV.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return pinAV;
    }else{
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if ([view isKindOfClass:[MKPinAnnotationView class]]) {
        NSLog(@"control: %@",control);
        EverywhereMKAnnotation *annotation = (EverywhereMKAnnotation *) view.annotation;
        //UIButton *btn = (UIButton *) control;
        
        //PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[((EverywhereMKAnnotation *)annotation).assetLocalIdentifier] options:nil].lastObject;
        
        AssetDetailVC *showVC = [AssetDetailVC new];
        showVC.edgesForExtendedLayout = UIRectEdgeNone;
        showVC.assetLocalIdentifiers = annotation.assetLocalIdentifiers;
        showVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.navigationController presentViewController:showVC animated:YES completion:nil];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    self.currentAnnotationIndex = [addedAnnotationsWithIndex indexOfObject:view.annotation];
}

- (void)setCurrentAnnotationIndex:(NSInteger)currentAnnotationIndex{
    _currentAnnotationIndex= currentAnnotationIndex;
    currentAnnotationIndexLabel.text = [NSString stringWithFormat:@"%ld / %ld",currentAnnotationIndex + 1,addedAnnotationsWithIndex.count];
    
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
