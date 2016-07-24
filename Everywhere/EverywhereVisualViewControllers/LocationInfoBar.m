//
//  LocationInfoBar.m
//  Everywhere
//
//  Created by 张保国 on 16/7/4.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "LocationInfoBar.h"
#import "UIView+AutoLayout.h"
#import "WGS84TOGCJ02.h"


@interface LocationInfoBar ()


@property (assign,nonatomic) CLLocationCoordinate2D originCoord;
@property (assign,nonatomic) CLLocationCoordinate2D destinationCoord;

@end

@implementation LocationInfoBar{
    UIButton *bottomFirstButton;
    UIButton *bottomSecodnButton;
    UIButton *bottomThirdButton;
    
    UIButton *topFirstButton;
    UIButton *topSecondButton;
    UIButton *topThirdButton;
    
    NSArray <UIButton *> *buttonArray;
}

- (CLLocationCoordinate2D)currentShowCoord{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}


#define BTSetOrigin @"Set Origin"
#define BTSetDest @"Set Dest."
#define BTGetRoute @"Get Route"
#define BTBaidu @"Baidu ☞"
#define BTNaviToHere @"Navi To Here"
#define BTRouteNavi @"Route Navi"

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        float buttonWidth = (self.frame.size.width - 5*4) / 3;
        float buttonHeight = 30;
        CGSize buttonSize = CGSizeMake(buttonWidth, buttonHeight);
        
        // ⭕️终于摸索出一个好办法！！！
        NSArray <NSString *> *titleArray = @[BTSetOrigin,
                                             BTSetDest,
                                             BTGetRoute,
                                             BTBaidu,
                                             BTNaviToHere,
                                             BTRouteNavi];
        SEL selectorArray[6] = {
            @selector(setOriginBtnTD),
            @selector(setDestinationBtnTD),
            @selector(getRouteBtnTD),
            @selector(baiduBtnTD),
            @selector(naviToHereBtnTD),
            @selector(routeNaviBtnTD)
        };
        
#pragma mark 下排按键
        UIView *bottomBtnBar = [UIView newAutoLayoutView];
        [self addSubview:bottomBtnBar];
        [bottomBtnBar autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 5, 0) excludingEdge:ALEdgeTop];
        [bottomBtnBar autoSetDimension:ALDimensionHeight toSize:buttonHeight];

        bottomFirstButton = [UIButton newAutoLayoutView];
        bottomFirstButton.tag = 1;
        //[bottomFirstButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [bottomFirstButton setTitle:titleArray[3] forState:UIControlStateNormal];
        [bottomFirstButton addTarget:self action:selectorArray[3] forControlEvents:UIControlEventTouchDown];
        [bottomBtnBar addSubview:bottomFirstButton];
        [bottomFirstButton autoSetDimensionsToSize:buttonSize];
        [bottomFirstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [bottomFirstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        bottomSecodnButton = [UIButton newAutoLayoutView];
        bottomSecodnButton.tag = 2;
        [bottomSecodnButton setTitle:titleArray[4] forState:UIControlStateNormal];
        [bottomSecodnButton addTarget:self action:selectorArray[4] forControlEvents:UIControlEventTouchDown];
        [bottomBtnBar addSubview:bottomSecodnButton];
        [bottomSecodnButton autoSetDimensionsToSize:buttonSize];
        [bottomSecodnButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [bottomSecodnButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:bottomFirstButton withOffset:5];
        
        bottomThirdButton = [UIButton newAutoLayoutView];
        bottomThirdButton.tag = 2;
        //routeNaviButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        //[routeNaviButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [bottomThirdButton setTitle:titleArray[5] forState:UIControlStateNormal];
        [bottomThirdButton addTarget:self action:selectorArray[5] forControlEvents:UIControlEventTouchDown];
        [bottomBtnBar addSubview:bottomThirdButton];
        [bottomThirdButton autoSetDimensionsToSize:buttonSize];
        [bottomThirdButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [bottomThirdButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:bottomSecodnButton withOffset:5];
        
#pragma mark 上排按键
        UIView *topBtnBar = [UIView newAutoLayoutView];
        [self addSubview:topBtnBar];
        [topBtnBar autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:bottomBtnBar withOffset:-5];
        [topBtnBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [topBtnBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [topBtnBar autoSetDimension:ALDimensionHeight toSize:buttonHeight];

        topFirstButton = [UIButton newAutoLayoutView];
        topFirstButton.tag = 1;
        [topFirstButton setTitle:titleArray[0] forState:UIControlStateNormal];
        [topFirstButton addTarget:self action:selectorArray[0] forControlEvents:UIControlEventTouchDown];
        [topBtnBar addSubview:topFirstButton];
        [topFirstButton autoSetDimensionsToSize:buttonSize];
        [topFirstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [topFirstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        topSecondButton = [UIButton newAutoLayoutView];
        topSecondButton.tag = 2;
        [topSecondButton setTitle:titleArray[1] forState:UIControlStateNormal];
        [topSecondButton addTarget:self action:selectorArray[1] forControlEvents:UIControlEventTouchDown];
        [topBtnBar addSubview:topSecondButton];
        [topSecondButton autoSetDimensionsToSize:buttonSize];
        [topSecondButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [topSecondButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:topFirstButton withOffset:5];
        
        topThirdButton = [UIButton newAutoLayoutView];
        topThirdButton.tag = 2;
        [topThirdButton setTitle:titleArray[2] forState:UIControlStateNormal];
        [topThirdButton addTarget:self action:selectorArray[2] forControlEvents:UIControlEventTouchDown];
        [topBtnBar addSubview:topThirdButton];
        [topThirdButton autoSetDimensionsToSize:buttonSize];
        [topThirdButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [topThirdButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:topSecondButton withOffset:5];
        
        buttonArray = @[topFirstButton,topSecondButton,topThirdButton,bottomFirstButton,bottomSecodnButton,bottomThirdButton];
        [self setupButtonsStyle];

        self.naviToHereButton = [self buttonWithTitle:BTNaviToHere];
        [self buttonWithTitle:BTBaidu].enabled = NO;
        [self buttonWithTitle:BTGetRoute].enabled = NO;
        [self buttonWithTitle:BTRouteNavi].enabled = NO;
        
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

- (UIButton *)buttonWithTitle:(NSString *)title{
    return buttonArray[[self buttonIndexWithTitle:title]];
}

- (NSInteger)buttonIndexWithTitle:(NSString *)title{
    NSInteger index = 0;
    
    for (UIButton *btn in buttonArray) {
        
        if ([btn.titleLabel.text isEqualToString:title]) {
            return index;
        }
        
        index ++;
    }
    
    return 0;
}

- (void)setupButtonsStyle{
    [buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat fontSize = ScreenWidth > 320 ? 16 : 12;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        
        button.layer.cornerRadius = 3.0;
        button.layer.borderColor = button.tag == 1 ? [UIColor whiteColor].CGColor : [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1;
        
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }];
}

- (void)baiduBtnTD{
    //[baiduButton.titleLabel.text isEqualToString:@"☆"] ? [baiduButton setTitle:@"⭐️" forState:UIControlStateNormal] : [baiduButton setTitle:@"☆" forState:UIControlStateNormal];
}

- (void)naviToHereBtnTD{
    [BaiduMap baidumapDirectionFromOrigin:self.userCoord toDestination:self.currentShowCoord directionMode:BaiduMapDirectionModeDriving];
}

- (void)setOriginBtnTD{
    self.originCoord = self.currentShowCoord;
    [self buttonWithTitle:BTSetOrigin].enabled = NO;
}

- (void)setDestinationBtnTD{
    self.destinationCoord = self.currentShowCoord;
    [self buttonWithTitle:BTSetDest].enabled = NO;
    [self buttonWithTitle:BTGetRoute].enabled = YES;
    [self buttonWithTitle:BTRouteNavi].enabled = YES;
}

- (void)getRouteBtnTD{
    bottomSecodnButton.enabled = NO;
    
    MKMapItem *lastMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:self.originCoord addressDictionary:nil]];
    MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:self.destinationCoord addressDictionary:nil]];
    
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    [directionsRequest setSource:lastMapItem];
    [directionsRequest setDestination:currentMapItem];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if(!error && self.didGetMKDirectionsResponseHandler) self.didGetMKDirectionsResponseHandler(response);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self buttonWithTitle:BTSetOrigin].enabled = YES;
            [self buttonWithTitle:BTSetDest].enabled = YES;
        });
        

    }];
    //MKDirectionsHandler
}

- (void)routeNaviBtnTD{
    [BaiduMap baidumapDirectionFromOrigin:self.originCoord toDestination:self.destinationCoord directionMode:BaiduMapDirectionModeDriving];
    [self buttonWithTitle:BTSetOrigin].enabled = YES;
    [self buttonWithTitle:BTSetDest].enabled = YES;
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
