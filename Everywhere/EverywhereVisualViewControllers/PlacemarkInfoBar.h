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

/**
 *  统计标题
 */
@property (strong,nonatomic) NSString *totalTitle;

/**
 *  总距离
 */
@property (assign,nonatomic) double totalDistance;

/**
 *  总面积
 */
@property (assign,nonatomic) double totalArea;

/**
 *  统计内容
 */
@property (strong,nonatomic) NSString *totalContent;

@end
