//
//  LocationInfoBar.h
//  Everywhere
//
//  Created by 张保国 on 16/7/4.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface LocationInfoBar : UIView

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

@end
