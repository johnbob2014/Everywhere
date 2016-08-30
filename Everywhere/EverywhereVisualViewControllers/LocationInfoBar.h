//
//  LocationInfoBar.h
//  Everywhere
//
//  Created by 张保国 on 16/7/26.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoordinateInfo.h"

@import CoreLocation;
@import MapKit;

typedef void(^DidGetMKDirectionsResponseHandler)(MKDirectionsResponse *response);

@interface LocationInfoBar : UIView

@property (copy,nonatomic) DidGetMKDirectionsResponseHandler didGetMKDirectionsResponseHandler;


@property (strong,nonatomic) UIButton *naviToHereButton;

/*
 必需，当前显示的CoordinateInfo
 */
@property (strong,nonatomic) CoordinateInfo *currentShowCoordinateInfo;


/*
 导航时需要，当前用户位置座标，GCJ02格式
 */
@property (assign,nonatomic) CLLocationCoordinate2D userCoordinateGCJ02;

@end
