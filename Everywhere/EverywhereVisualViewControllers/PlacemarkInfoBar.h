//
//  PlacemarkInfoBar.h
//  Everywhere
//
//  Created by 张保国 on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHAssetInfo.h"

@interface PlacemarkInfoBar : UIView
@property (assign,nonatomic) NSUInteger countryCount;
@property (assign,nonatomic) NSUInteger administrativeAreaCount;
@property (assign,nonatomic) NSUInteger subAdministrativeAreaCount;
@property (assign,nonatomic) NSUInteger localityCount;
@property (assign,nonatomic) NSUInteger subLocalityCount;
@property (assign,nonatomic) NSUInteger thoroughfareCount;
@property (assign,nonatomic) NSUInteger subThoroughfareCount;
@property (assign,nonatomic) double totalDistance;
@end
