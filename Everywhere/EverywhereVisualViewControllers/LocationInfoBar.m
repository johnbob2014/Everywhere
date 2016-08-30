//
//  LocationInfoBar.m
//  Everywhere
//
//  Created by 张保国 on 16/7/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "LocationInfoBar.h"
#import "GCMaps.h"

@interface LocationInfoBar ()
@property (assign,nonatomic) CLLocationCoordinate2D currentShowCoordinateWGS84;
@property (assign,nonatomic) CLLocationCoordinate2D originCoordinateWGS84;
@property (assign,nonatomic) CLLocationCoordinate2D destinationCoordinateWGS84;

@property (strong,nonatomic) UILabel *coordinateLabel;
@property (strong,nonatomic) UILabel *altitude_speed_Label;
@property (strong,nonatomic) UITextView *addressTextView;

@property (assign,nonatomic) NSInteger userPreferredMap;

@end

@implementation LocationInfoBar{
    UIView *bottomButtonContainer;
    UIView *topButtonContainer;
    
    UIButton *bottomFirstButton;
    UIButton *bottomSecodnButton;
    UIButton *bottomThirdButton;
    
    UIButton *topFirstButton;
    UIButton *topSecondButton;
    UIButton *topThirdButton;
    
    NSArray <UIButton *> *buttonArray;
}

#pragma mark - Getter & Setter
- (CLLocationCoordinate2D)currentShowCoordinateWGS84{
    return CLLocationCoordinate2DMake([self.currentShowCoordinateInfo.latitude doubleValue], [self.currentShowCoordinateInfo.longitude doubleValue]);
}


- (NSInteger)userPreferredMap{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"userPreferredMap"];
}

- (void)setUserPreferredMap:(NSInteger)userPreferredMap{
    if (userPreferredMap < 0 || userPreferredMap > 2) return;
    
    switch (userPreferredMap) {
        case 0:
            [bottomFirstButton setTitle:NSLocalizedString(@"iOS Maps ☞",@"iOS地图 ☞") forState:UIControlStateNormal];
            break;
        case 1:
            [bottomFirstButton setTitle:NSLocalizedString(@"Baidu Map ☞",@"百度地图 ☞") forState:UIControlStateNormal];
            break;
        case 2:
            [bottomFirstButton setTitle:NSLocalizedString(@"AutoNavi Map ☞",@"高德地图 ☞") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:userPreferredMap forKey:@"userPreferredMap"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)setCurrentShowCoordinateInfo:(CoordinateInfo *)currentShowCoordinateInfo{
    _currentShowCoordinateInfo = currentShowCoordinateInfo;
    
    // updateCoordinateLabel
    NSMutableString *ma = [NSMutableString new];
    [ma appendString:[self.currentShowCoordinateInfo.latitude doubleValue] > 0 ? NSLocalizedString(@"N. ", @"北纬 "):NSLocalizedString(@"S. ", @"南纬 ")];
    [ma appendString:[LocationInfoBar dmsStringWithDegrees:[self.currentShowCoordinateInfo.latitude doubleValue]]];
    [ma appendFormat:@" - %.4f°",fabs([self.currentShowCoordinateInfo.latitude doubleValue])];
    [ma appendFormat:@"\n"];
    [ma appendString:[self.currentShowCoordinateInfo.longitude doubleValue] > 0 ? NSLocalizedString(@"E. ", @"东经 "):NSLocalizedString(@"W. ", @"西经 ")];
    [ma appendString:[LocationInfoBar dmsStringWithDegrees:[self.currentShowCoordinateInfo.longitude doubleValue]]];
    [ma appendFormat:@" - %.4f°",fabs([self.currentShowCoordinateInfo.longitude doubleValue])];
    self.coordinateLabel.text = ma;
    
    // updateAltitudeLabel
    ma = [NSMutableString new];
    if ([self.currentShowCoordinateInfo.altitude doubleValue] > 0) {
        //[ma appendString:NSLocalizedString(@"Altitude", @"高度")];
        [ma appendFormat:@"%.2fm",[self.currentShowCoordinateInfo.altitude doubleValue]];
    }
    if ([self.currentShowCoordinateInfo.speed doubleValue] > 0){
        [ma appendFormat:@"\n%.2fkm/h",[self.currentShowCoordinateInfo.altitude doubleValue] * 3.6];
    }
    
    self.altitude_speed_Label.text = ma;
    
    // updateAddressLabel
    self.addressTextView.text = self.currentShowCoordinateInfo.localizedPlaceString_Placemark;
}

/*
-(void)updateCoordinateLabel{
    }

- (void)updateAltitudeLabel{
    NSMutableString *ma = [NSMutableString new];
    
 
     if (self.currentShowCoordinateInfo.level != 0) {
     [ma appendFormat:@"\n"];
     [ma appendString:NSLocalizedString(@"Floor : ", @"")];
     [ma appendFormat:@"%ld",(long)self.currentShowCoordinateInfo.level];
     }
 
    self.altitudeLabel.text = ma;
}

- (void)updateAddressLabel{
 
}
*/
#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        float buttonWidth = (self.frame.size.width - 5*4) / 3;
        float buttonHeight = 30;
        CGSize buttonSize = CGSizeMake(buttonWidth, buttonHeight);
        
        // ⭕️这样写变换按钮位置的时候更快捷一点！缺点是如果按钮需要交互时，名称不直观。
        NSArray <NSString *> *titleArray = @[NSLocalizedString(@"Set Origin",@"设置起点"),
                                             NSLocalizedString(@"Set Dest.",@"设置终点"),
                                             NSLocalizedString(@"Get Route",@"获取路线"),
                                             NSLocalizedString(@"External Map ☞",@"外部地图 ☞"),
                                             NSLocalizedString(@"Navi To Here",@"导航到这里"),
                                             NSLocalizedString(@"Origin To Dest.",@"起点至终点")];
        SEL selectorArray[6] = {
            @selector(setOriginBtnTD),
            @selector(setDestinationBtnTD),
            @selector(getRouteBtnTD),
            @selector(mapBtnTD),
            @selector(naviToHereBtnTD),
            @selector(routeNaviBtnTD)
        };
        
#pragma mark 下排按键
        bottomButtonContainer = [UIView newAutoLayoutView];
        [self addSubview:bottomButtonContainer];
        [bottomButtonContainer autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 5, 0) excludingEdge:ALEdgeTop];
        [bottomButtonContainer autoSetDimension:ALDimensionHeight toSize:buttonHeight];

        bottomFirstButton = [UIButton newAutoLayoutView];
        bottomFirstButton.tag = 1;
        //[bottomFirstButton setBackgroundImage:[UIImage imageNamed:@"IcoMoon_Flag_WBG"] forState:UIControlStateNormal];
        [bottomFirstButton setTitle:titleArray[3] forState:UIControlStateNormal];
        [bottomFirstButton addTarget:self action:selectorArray[3] forControlEvents:UIControlEventTouchDown];
        [bottomButtonContainer addSubview:bottomFirstButton];
        [bottomFirstButton autoSetDimensionsToSize:buttonSize];
        [bottomFirstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [bottomFirstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        bottomSecodnButton = [UIButton newAutoLayoutView];
        bottomSecodnButton.tag = 2;
        [bottomSecodnButton setTitle:titleArray[4] forState:UIControlStateNormal];
        [bottomSecodnButton addTarget:self action:selectorArray[4] forControlEvents:UIControlEventTouchDown];
        [bottomButtonContainer addSubview:bottomSecodnButton];
        [bottomSecodnButton autoSetDimensionsToSize:buttonSize];
        [bottomSecodnButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [bottomSecodnButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:bottomFirstButton withOffset:5];
        
        bottomThirdButton = [UIButton newAutoLayoutView];
        bottomThirdButton.tag = 2;
        [bottomThirdButton setTitle:titleArray[5] forState:UIControlStateNormal];
        [bottomThirdButton addTarget:self action:selectorArray[5] forControlEvents:UIControlEventTouchDown];
        [bottomButtonContainer addSubview:bottomThirdButton];
        [bottomThirdButton autoSetDimensionsToSize:buttonSize];
        [bottomThirdButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [bottomThirdButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:bottomSecodnButton withOffset:5];
        
#pragma mark 上排按键
        topButtonContainer = [UIView newAutoLayoutView];
        [self addSubview:topButtonContainer];
        [topButtonContainer autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:bottomButtonContainer withOffset:-5];
        [topButtonContainer autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [topButtonContainer autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [topButtonContainer autoSetDimension:ALDimensionHeight toSize:buttonHeight];

        topFirstButton = [UIButton newAutoLayoutView];
        topFirstButton.tag = 1;
        [topFirstButton setTitle:titleArray[0] forState:UIControlStateNormal];
        [topFirstButton addTarget:self action:selectorArray[0] forControlEvents:UIControlEventTouchDown];
        [topButtonContainer addSubview:topFirstButton];
        [topFirstButton autoSetDimensionsToSize:buttonSize];
        [topFirstButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [topFirstButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        topSecondButton = [UIButton newAutoLayoutView];
        topSecondButton.tag = 2;
        [topSecondButton setTitle:titleArray[1] forState:UIControlStateNormal];
        [topSecondButton addTarget:self action:selectorArray[1] forControlEvents:UIControlEventTouchDown];
        [topButtonContainer addSubview:topSecondButton];
        [topSecondButton autoSetDimensionsToSize:buttonSize];
        [topSecondButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [topSecondButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:topFirstButton withOffset:5];
        
        topThirdButton = [UIButton newAutoLayoutView];
        topThirdButton.tag = 2;
        [topThirdButton setTitle:titleArray[2] forState:UIControlStateNormal];
        [topThirdButton addTarget:self action:selectorArray[2] forControlEvents:UIControlEventTouchDown];
        [topButtonContainer addSubview:topThirdButton];
        [topThirdButton autoSetDimensionsToSize:buttonSize];
        [topThirdButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [topThirdButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:topSecondButton withOffset:5];
        
        buttonArray = @[topFirstButton,topSecondButton,topThirdButton,bottomFirstButton,bottomSecodnButton,bottomThirdButton];
        [self setupButtonsStyle];

        self.naviToHereButton = bottomSecodnButton;
        topThirdButton.enabled = NO;
        bottomThirdButton.enabled = NO;
        
#pragma mark 标签
        UILabel *coordlabel = [UILabel newAutoLayoutView];
        coordlabel.numberOfLines = 0;
        coordlabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:coordlabel];
        [coordlabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [coordlabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        self.coordinateLabel = coordlabel;
        
        UILabel *altLabel = [UILabel newAutoLayoutView];
        altLabel.numberOfLines = 0;
        altLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:altLabel];
        [altLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [altLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
        [altLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:coordlabel];
        self.altitude_speed_Label = altLabel;
        
        UITextView *addTV = [UITextView newAutoLayoutView];
        addTV.font = [UIFont bodyFontWithSizeMultiplier:1.0];
        addTV.editable = NO;
        addTV.backgroundColor = [UIColor clearColor];
        addTV.textAlignment = NSTextAlignmentLeft;
        [self addSubview:addTV];
        [addTV autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.coordinateLabel withOffset:5];
        [addTV autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:topButtonContainer withOffset:-5];
        [addTV autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [addTV autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        
        self.addressTextView = addTV;
        
        self.userPreferredMap = self.userPreferredMap;
    }
    return self;
}


- (void)setupButtonsStyle{
    [buttonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat fontSize = ScreenWidth > 375 ? 16 : 12;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
        
        button.layer.cornerRadius = 3.0;
        button.layer.borderColor = button.tag == 1 ? [UIColor whiteColor].CGColor : [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1;
        
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    }];
}

#pragma mark - 按钮动作

- (void)setOriginBtnTD{
    self.originCoordinateWGS84 = self.currentShowCoordinateWGS84;
    topFirstButton.enabled = NO;
}

- (void)setDestinationBtnTD{
    self.destinationCoordinateWGS84 = self.currentShowCoordinateWGS84;
    topSecondButton.enabled = NO;
    topThirdButton.enabled = YES;
    bottomThirdButton.enabled = YES;
}

- (void)getRouteBtnTD{
    bottomSecodnButton.enabled = NO;
    
    MKMapItem *lastMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:[GCCoordinateTransformer transformToMarsFromEarth:self.originCoordinateWGS84] addressDictionary:nil]];
    MKMapItem *currentMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:[GCCoordinateTransformer transformToMarsFromEarth:self.destinationCoordinateWGS84] addressDictionary:nil]];
    
    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
    [directionsRequest setSource:lastMapItem];
    [directionsRequest setDestination:currentMapItem];
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if(!error && self.didGetMKDirectionsResponseHandler) self.didGetMKDirectionsResponseHandler(response);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            topFirstButton.enabled = YES;
            topSecondButton.enabled = YES;
        });
        
        
    }];
}

- (void)mapBtnTD{
    NSInteger userPreferredMap = self.userPreferredMap;
    userPreferredMap++;
    if (userPreferredMap == 3) userPreferredMap = 0;
    self.userPreferredMap = userPreferredMap;
}

- (void)naviToHereBtnTD{
    
    [self naviFromSourceGCJ02:self.userCoordinateGCJ02 toDestinationGCJ02:[GCCoordinateTransformer transformToMarsFromEarth:self.currentShowCoordinateWGS84]];
}

- (void)routeNaviBtnTD{
    
    [self naviFromSourceGCJ02:[GCCoordinateTransformer transformToMarsFromEarth:self.originCoordinateWGS84] toDestinationGCJ02:[GCCoordinateTransformer transformToMarsFromEarth:self.destinationCoordinateWGS84]];
    topFirstButton.enabled = YES;
    topSecondButton.enabled = YES;
}

- (void)naviFromSourceGCJ02:(CLLocationCoordinate2D)sourceGCJ02 toDestinationGCJ02:(CLLocationCoordinate2D)destinationGCJ02{
    switch (self.userPreferredMap) {
        case 0:
            [GCMaps mkmapFromSource:sourceGCJ02 toDestination:destinationGCJ02 directionsMode:MKLaunchOptionsDirectionsModeDriving];
            break;
        case 1:
            [GCMaps baidumapDirectionFromOrigin:[GCCoordinateTransformer transformToBaiduFromMars:sourceGCJ02] toDestination:[GCCoordinateTransformer transformToBaiduFromMars:destinationGCJ02] directionsMode:BaiduMapDirectionsModeDriving];
            break;
        case 2:
            [GCMaps iosamapPathFromSource:sourceGCJ02 toDestination:destinationGCJ02 tMode:0 mOption:0];
            break;
        default:
            break;
    }
}

@end
