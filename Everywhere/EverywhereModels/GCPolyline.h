//
//  GCPolyline.h
//  Everywhere
//
//  Created by BobZhang on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GCPolyline : NSObject <NSCoding>
@property (strong,nonatomic,readonly) MKPolyline *polyline;
+ (instancetype)newPolyline:(MKPolyline *)polyline;
- (instancetype)initWithPolyline:(MKPolyline *)polyline;
@end
