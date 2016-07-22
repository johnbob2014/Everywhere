//
//  LocationInfoBar.m
//  Everywhere
//
//  Created by 张保国 on 16/7/4.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "LocationInfoBar.h"
#import "UIView+AutoLayout.h"



@interface LocationInfoBar ()

@property (assign,nonatomic) CLLocationCoordinate2D currentCoord;
@property (assign,nonatomic) CLLocationCoordinate2D sourceCoord;
@property (assign,nonatomic) CLLocationCoordinate2D destinationCoord;

@end

@implementation LocationInfoBar{
    UIButton *naviToHereButton;
    UIButton *setSourceButton;
    UIButton *setDestinationButton;
    UIButton *getRouteButton;
    NSArray <UIButton *> *buttonArray;
}

- (CLLocationCoordinate2D)currentCoord{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bottomView = [UIView newAutoLayoutView];
        [self addSubview:bottomView];
        [bottomView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 5, 0) excludingEdge:ALEdgeTop];
        [bottomView autoSetDimension:ALDimensionHeight toSize:30];
        
        float buttonWidth = (self.frame.size.width - 5*5) / 4;
        CGSize buttonSize = CGSizeMake(buttonWidth, 30);

        naviToHereButton = [UIButton newAutoLayoutView];
        //[naviToHereButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [naviToHereButton setTitle:@"Navi" forState:UIControlStateNormal];
        [naviToHereButton addTarget:self action:@selector(naviToHereBtnTD) forControlEvents:UIControlEventTouchDown];
        [bottomView addSubview:naviToHereButton];
        [naviToHereButton autoSetDimensionsToSize:buttonSize];
        [naviToHereButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [naviToHereButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        setSourceButton = [UIButton newAutoLayoutView];
        //[setSourceButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [setSourceButton setTitle:@"Set Origin" forState:UIControlStateNormal];
        [setSourceButton addTarget:self action:@selector(setSourceBtnTD) forControlEvents:UIControlEventTouchDown];
        [bottomView addSubview:setSourceButton];
        [setSourceButton autoSetDimensionsToSize:buttonSize];
        [setSourceButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [setSourceButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:naviToHereButton withOffset:5];
        
        setDestinationButton = [UIButton newAutoLayoutView];
        //setDestinationButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        //[setDestinationButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [setDestinationButton setTitle:@"Set Dest." forState:UIControlStateNormal];
        [setDestinationButton addTarget:self action:@selector(setDestinationBtnTD) forControlEvents:UIControlEventTouchDown];
        [bottomView addSubview:setDestinationButton];
        [setDestinationButton autoSetDimensionsToSize:buttonSize];
        [setDestinationButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [setDestinationButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:setSourceButton withOffset:5];
        
        getRouteButton = [UIButton newAutoLayoutView];
        //getRouteButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        //[getRouteButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [getRouteButton setTitle:@"Get Route" forState:UIControlStateNormal];
        [getRouteButton addTarget:self action:@selector(getRouteBtnTD) forControlEvents:UIControlEventTouchDown];
        [bottomView addSubview:getRouteButton];
        [getRouteButton autoSetDimensionsToSize:buttonSize];
        [getRouteButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [getRouteButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:setDestinationButton withOffset:5];
        getRouteButton.enabled = NO;
        
        buttonArray = @[naviToHereButton,setSourceButton,setDestinationButton,getRouteButton];
        [self setupButtonsStyle];

        UILabel *coordlabel = [UILabel newAutoLayoutView];
        coordlabel.numberOfLines = 0;
        coordlabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:coordlabel];
        [coordlabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [coordlabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        self.coordinateLabel = coordlabel;
        
        UILabel *altLabel = [UILabel newAutoLayoutView];
        altLabel.numberOfLines = 0;
        altLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:altLabel];
        //[altLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.coordinateLabel withOffset:5];
        //[altLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [altLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [altLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
        [altLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:coordlabel];
        self.altitudeLabel = altLabel;
        
        UILabel *addlabel = [UILabel newAutoLayoutView];
        addlabel.numberOfLines = 0;
        addlabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:addlabel];
        [addlabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.coordinateLabel withOffset:5];
        [addlabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        [addlabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
        //[addlabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:bottomView withOffset:5];
        self.addressLabel = addlabel;
        
    }
    return self;
}

- (void)setupButtonsStyle{
    [buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat fontSize = ScreenWidth > 320 ? 16 : 10;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        
        button.layer.cornerRadius = 3.0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1;
        
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }];
}


- (void)naviToHereBtnTD{
    [BaiduMap baidumapDirectionFromOrigin:self.userCoord toDestination:self.currentCoord directionMode:BaiduMapDirectionModeDriving];
}

- (void)setSourceBtnTD{
    NSLog(@"%@",NSStringFromSelector(_cmd));;
    self.sourceCoord = self.currentCoord;
    setSourceButton.enabled = NO;
}

- (void)setDestinationBtnTD{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.destinationCoord = self.currentCoord;
    setDestinationButton.enabled = NO;
    getRouteButton.enabled = YES;
}

- (void)getRouteBtnTD{
    getRouteButton.enabled = NO;
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
    MKMapItem *lastMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:self.sourceCoord addressDictionary:nil]];
    MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:self.destinationCoord addressDictionary:nil]];
    
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    [directionsRequest setSource:lastMapItem];
    [directionsRequest setDestination:currentMapItem];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if(!error && self.didGetMKDirectionsResponseHandler) self.didGetMKDirectionsResponseHandler(response);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            setSourceButton.enabled = YES;
            setDestinationButton.enabled = YES;
        });

    }];
    //MKDirectionsHandler
}


- (void)setLatitude:(CLLocationDegrees)latitude{
    _latitude = latitude;
    [self updateCoordinateLabel];
}

- (void)setLongitude:(CLLocationDegrees)longitude{
    _longitude = longitude;
    [self updateCoordinateLabel];
}

- (void)setHorizontalAccuracy:(CLLocationDistance)horizontalAccuracy{
    _horizontalAccuracy = horizontalAccuracy;
    [self updateCoordinateLabel];
}

+ (NSString *)dmsStringWithDegrees:(CLLocationDegrees)degrees{
    double degreeFloor = floor(degrees);
    double minutes = (degrees - degreeFloor) * 60.0;
    double minuteFloor = floor(minutes);
    double seconds = (minutes - minuteFloor) * 60.0;
    double secondFloor = floor(seconds);
    NSString *dmsString = [NSString stringWithFormat:@"%.0f°%0.f'%.0f''",degreeFloor,minuteFloor,secondFloor];
    return dmsString;
}

-(void)updateCoordinateLabel{
    NSMutableString *ma = [NSMutableString new];
    [ma appendString:self.latitude > 0 ? NSLocalizedString(@"N. ", @""):NSLocalizedString(@"S. ", @"")];
    [ma appendString:[LocationInfoBar dmsStringWithDegrees:self.latitude]];
    [ma appendFormat:@" (%.4f°)",fabs(self.latitude)];
    [ma appendFormat:@"\n"];
    [ma appendString:self.longitude > 0 ? NSLocalizedString(@"E. ", @""):NSLocalizedString(@"W. ", @"")];
    [ma appendString:[LocationInfoBar dmsStringWithDegrees:self.longitude]];
    [ma appendFormat:@" (%.4f°)",fabs(self.longitude)];
    self.coordinateLabel.text = ma;
}

- (void)setAltitude:(CLLocationDistance)altitude{
    _altitude = altitude;
    [self updateAltitudeLabel];
}

- (void)setVerticalAccuracy:(CLLocationDistance)verticalAccuracy{
    _verticalAccuracy = verticalAccuracy;
    [self updateAltitudeLabel];
}

- (void)setLevel:(NSInteger)level{
    _level = level;
    [self updateAltitudeLabel];
}

- (void)updateAltitudeLabel{
    NSMutableString *ma = [NSMutableString new];
    if (self.altitude != 0) {
        [ma appendString:NSLocalizedString(@"Altitude", @"高度")];
        [ma appendFormat:@"\n%.2f",self.altitude];
    }
    /*
    if (self.level != 0) {
        [ma appendFormat:@"\n"];
        [ma appendString:NSLocalizedString(@"Floor : ", @"")];
        [ma appendFormat:@"%ld",(long)self.level];
    }
     */
    self.altitudeLabel.text = ma;
}

- (void)setAddress:(NSString *)address{
    _address = address;
    self.addressLabel.text = address;
}

@end
