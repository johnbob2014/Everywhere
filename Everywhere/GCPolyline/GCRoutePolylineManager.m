//
//  GCRoutePolylineManager.m
//  Everywhere
//
//  Created by BobZhang on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCRoutePolylineManager.h"

@interface GCRoutePolylineManager ()
@property (strong,nonatomic) NSMutableArray <NSData *> *routePolylineArray;
@end

@implementation GCRoutePolylineManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (NSMutableArray<NSData *> *)routePolylineArray{
    if(!_routePolylineArray){
        NSArray *tempArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"routePolylineArray"];
        if (tempArray) {
            _routePolylineArray = [NSMutableArray arrayWithArray:tempArray];
        }
        if (!_routePolylineArray) {
            _routePolylineArray = [NSMutableArray new];
        }
    }
    return _routePolylineArray;
}

/*
@synthesize routePolylineArray;
+ (NSMutableArray <NSData *> *)routePolylineArray{
    
    NSMutableArray <NSData *> *routePolylineArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"routePolylineArray"];
    if (!routePolylineArray) {
        routePolylineArray = [NSMutableArray new];
    }
    return routePolylineArray;
}
*/

- (void)addRoutePolyline:(GCRoutePolyline *)routePolyline{
    //NSLog(@"%@",self.routePolylineArray);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:routePolyline];
    [self.routePolylineArray addObject:data];
    [[NSUserDefaults standardUserDefaults] setValue:self.routePolylineArray forKey:@"routePolylineArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (GCRoutePolyline *)fetchRoutePolylineWithSource:(CLLocationCoordinate2D)sourceCoord destination:(CLLocationCoordinate2D)destinationCoord{
    __block GCRoutePolyline *result = nil;
    [self.routePolylineArray enumerateObjectsUsingBlock:^(NSData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSLog(@"\n%f\n%f\n%f\n%f",obj.source.latitude,sourceCoord.latitude,obj.source.longitude,sourceCoord.longitude);
        GCRoutePolyline *routePolyline = (GCRoutePolyline *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (routePolyline.source.latitude == sourceCoord.latitude && routePolyline.source.longitude == sourceCoord.longitude){
            if (routePolyline.destination.latitude == destinationCoord.latitude && routePolyline.destination.longitude == destinationCoord.longitude){
                result = routePolyline;
            }
        }        
    }];
    return result;
}
@end
