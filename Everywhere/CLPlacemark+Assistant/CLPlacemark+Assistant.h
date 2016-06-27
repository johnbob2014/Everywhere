//
//  CLPlacemark+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/6/27.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLPlacemark (Assistant)

/**
 返回本地化地址字符串，以逗号分隔 - CLPlacemark+Assistant
 */
- (NSString *)localizedPlaceString;

/**
 返回附近兴趣点字符串，以逗号分隔，可指定是否带序号 - CLPlacemark+Assistant
 */
- (NSString *)areasOfInterestStringWithIndex:(BOOL)withIndex;

@end
