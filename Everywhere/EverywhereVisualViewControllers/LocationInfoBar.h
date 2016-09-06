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
typedef void(^DidChangeFavoritePropertyHandler)(CoordinateInfo *coordinateInfo);
typedef void(^DidTouchDownRetractButtonHandler)();

@interface LocationInfoBar : UIView

/*
 *  必需，当前显示的CoordinateInfo
 */
@property (strong,nonatomic) CoordinateInfo *currentShowCoordinateInfo;

/*
 *  导航时需要，当前用户位置座标，GCJ02格式
 */
@property (assign,nonatomic) CLLocationCoordinate2D userCoordinateGCJ02;

/**
 *  导航至此按钮
 */
@property (strong,nonatomic) UIButton *naviToHereButton;

/**
 *  传送获取到的路线
 */
@property (copy,nonatomic) DidGetMKDirectionsResponseHandler didGetMKDirectionsResponseHandler;

/**
 *  传送改变favorite属性的CoordinateInfo
 */
@property (copy,nonatomic) DidChangeFavoritePropertyHandler didChangeFavoritePropertyHandler;

/**
 *  传送收回按钮按下的动作
 */
@property (copy,nonatomic) DidTouchDownRetractButtonHandler didTouchDownRetractButtonHandler;

@end
