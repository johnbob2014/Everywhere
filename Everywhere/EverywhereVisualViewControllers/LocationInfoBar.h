//
//  LocationInfoBar.h
//  Everywhere
//
//  Created by 张保国 on 16/7/4.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import MapKit;

typedef void(^DidGetMKDirectionsResponseHandler)(MKDirectionsResponse *response);

@interface LocationInfoBar : UIView

@property (copy,nonatomic) DidGetMKDirectionsResponseHandler didGetMKDirectionsResponseHandler;
@property (strong,nonatomic) UIButton *naviToHereButton;

@property (assign,nonatomic) CLLocationCoordinate2D currentShowCoordinateWGS84;


// 2016-07-24 均为GCJ02座标
@property (assign,nonatomic) CLLocationDegrees latitude;
@property (assign,nonatomic) CLLocationDegrees longitude;
@property (assign,nonatomic) CLLocationDistance horizontalAccuracy;
@property (strong,nonatomic) UILabel *coordinateLabel;

@property (assign,nonatomic) CLLocationDistance altitude;
@property (assign,nonatomic) CLLocationDistance verticalAccuracy;
@property (assign,nonatomic) NSInteger level;
@property (strong,nonatomic) UILabel *altitudeLabel;

@property (strong,nonatomic) NSString *address;
@property (strong,nonatomic) UILabel *addressLabel;

@property (assign,nonatomic) CLLocationCoordinate2D userCoord;

@end
