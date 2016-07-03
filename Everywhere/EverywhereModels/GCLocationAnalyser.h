//
//  GCLocationAnalyser.h
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol GCLocationAnalyserProtocol <NSObject>
@required
@property (strong,nonatomic) CLLocation *location;
@end

@interface GCLocationAnalyser : NSObject

+ (NSDictionary <CLLocation *,NSArray *> *)analyseLocationsToDictionary:(NSArray <id<GCLocationAnalyserProtocol>> *)idArray nearestDistance:(CLLocationDistance)nearestDistance;

+ (NSArray <NSArray *> *)analyseLocationsToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)idArray nearestDistance:(CLLocationDistance) nearestDistance;

@end
