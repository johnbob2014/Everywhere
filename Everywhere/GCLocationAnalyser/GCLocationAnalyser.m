//
//  GCLocationAnalyser.m
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCLocationAnalyser.h"
@import MapKit;

@implementation GCLocationAnalyser

+ (NSDictionary <CLLocation *,NSArray *> *)divideLocationsInOrderToDictionary:(NSArray <id<GCLocationAnalyserProtocol>> *)idArray mergeDistance:(CLLocationDistance)mergeDistance{
    
    if (!mergeDistance) mergeDistance = CLLocationDistanceMax;
    if (!idArray || !idArray.count || mergeDistance < 0) return nil;
    
    __block CLLocation *keyLocation = idArray.firstObject.location;
    if (idArray.count == 1) return @{keyLocation:idArray};
    
    NSMutableDictionary <CLLocation *,NSArray *> *returnMD = [NSMutableDictionary new];
    __block NSMutableArray <id<GCLocationAnalyserProtocol>> *tempArray = [NSMutableArray new];
    __block id<GCLocationAnalyserProtocol> lastId = idArray.firstObject;
    [tempArray addObject:lastId];
    
    [idArray enumerateObjectsUsingBlock:^(id<GCLocationAnalyserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            CLLocationDistance currentDistance = fabs(MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastId.location.coordinate), MKMapPointForCoordinate(obj.location.coordinate)));
            //if(DEBUGMODE) NSLog(@"%.2f",currentDistance);
            if (currentDistance < mergeDistance) {
                [tempArray addObject:obj];
            }else{
                //if(DEBUGMODE) NSLog(@"%@",tempArray);
                [returnMD setObject:tempArray forKey:keyLocation];
                
                // 开始下一轮计算
                keyLocation = obj.location;
                tempArray = [NSMutableArray new];
                [tempArray addObject:obj];
            }
            
            lastId = obj;
            
            if (idx == idArray.count - 1) {
                //if(DEBUGMODE) NSLog(@"%@",tempArray);
                [returnMD setObject:tempArray forKey:keyLocation];
            }
        }
    }];
    
    //if(DEBUGMODE) NSLog(@"%@",returnMD);
    /* 这样就会返回错误，不知何故！！！！！！
    return [NSDictionary dictionaryWithDictionary:returnMD];
    */
    
    return returnMD;
}

+ (NSArray <NSArray *> *)divideLocationsInOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)idArray mergeDistance:(CLLocationDistance)mergeDistance{
    
    if (!mergeDistance) mergeDistance = CLLocationDistanceMax;
    if (!idArray || !idArray.count || mergeDistance < 0) return nil;
    
    __block CLLocation *keyLocation = idArray.firstObject.location;
    if (idArray.count == 1) return @[idArray];
    
    NSMutableArray <NSArray *> *returnMD = [NSMutableArray new];
    __block NSMutableArray <id<GCLocationAnalyserProtocol>> *tempArray = [NSMutableArray new];
    __block id<GCLocationAnalyserProtocol> lastId = idArray.firstObject;
    [tempArray addObject:lastId];
    
    __block id<GCLocationAnalyserProtocol> currentGroupFirstId = idArray.firstObject;
    [idArray enumerateObjectsUsingBlock:^(id<GCLocationAnalyserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            //CLLocationDistance currentDistance = fabs(MKMetersBetweenMapPoints(MKMapPointForCoordinate(lastId.location.coordinate), MKMapPointForCoordinate(obj.location.coordinate)));
            CLLocationDistance distanceToPrevious = fabs([lastId.location distanceFromLocation:obj.location]);
            CLLocationDistance distanceToFirst = fabs([currentGroupFirstId.location distanceFromLocation:obj.location]);
            //if(DEBUGMODE) NSLog(@"%.2f",currentDistance);
            if (distanceToPrevious < mergeDistance && distanceToFirst < mergeDistance) {
                [tempArray addObject:obj];
            }else{
                //if(DEBUGMODE) NSLog(@"%@",tempArray);
                [returnMD addObject:tempArray];
                
                // 开始下一轮计算
                keyLocation = obj.location;
                tempArray = [NSMutableArray new];
                [tempArray addObject:obj];
                currentGroupFirstId = obj;
            }
            
            lastId = obj;
            
            if (idx == idArray.count - 1) {
                //if(DEBUGMODE) NSLog(@"%@",tempArray);
                [returnMD addObject:tempArray];
            }
        }
    }];
    
    return returnMD;
}

+ (NSArray <NSArray *> *)divideLocationsOutOfOrderToArray:(NSArray <id<GCLocationAnalyserProtocol>> *)idArray mergeDistance:(CLLocationDistance)mergeDistance{
    
    if (!mergeDistance) mergeDistance = CLLocationDistanceMax;
    if (!idArray || !idArray.count || mergeDistance < 0) return nil;
    
    //__block CLLocation *keyLocation = idArray.firstObject.location;
    if (idArray.count == 1) return @[idArray];
    
    NSMutableArray <NSArray *> *returnMD = [NSMutableArray new];
    __block NSMutableArray <id<GCLocationAnalyserProtocol>> *tempArray = [NSMutableArray new];
    __block id<GCLocationAnalyserProtocol> lastId = idArray.firstObject;
    [tempArray addObject:lastId];
    
    NSMutableArray *idArrayRest = [NSMutableArray new];
    for (NSUInteger i = 1; i < idArray.count; i++) {
        id<GCLocationAnalyserProtocol> currentId = idArray[i];
        CLLocationDistance currentDistance = fabs([lastId.location distanceFromLocation:currentId.location]);
        if (currentDistance < mergeDistance) {
            [tempArray addObject:currentId];
        }else{
            [idArrayRest addObject:currentId];
        }
    }
    [returnMD addObject:tempArray];
    
    NSArray <NSArray *> *next = [GCLocationAnalyser divideLocationsOutOfOrderToArray:idArrayRest mergeDistance:mergeDistance];
    if (next.count > 0) [returnMD addObjectsFromArray:next];
    //if(DEBUGMODE) NSLog(@"%3ld,%@",(long)next.count,NSStringFromSelector(_cmd));
    return returnMD;
}

@end
