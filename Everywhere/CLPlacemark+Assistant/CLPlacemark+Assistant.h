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
 *  获取 本地化地址字符串，以逗号分隔
 *
 *  @param reverseOrder        是否逆序显示
 *  @param inlandWaterAndOcean 是否包含水系信息
 *
 *  @return 本地化地址字符串
 */
- (NSString *)localizedPlaceStringInReverseOrder:(BOOL)reverseOrder withInlandWaterAndOcean:(BOOL)inlandWaterAndOcean;

/**
 *  获取 附近兴趣点字符串，以逗号分隔
 *
 *  @param withIndex 是否带序号
 *
 *  @return 附近兴趣点字符串
 */
- (NSString *)areasOfInterestStringWithIndex:(BOOL)withIndex;

@end

@interface NSString (CLPlacemark_Assistant)

- (NSString *)placemarkBriefName;

@end