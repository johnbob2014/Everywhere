//
//  EverywhereAnnotation.m
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereAnnotation.h"
#import "WGS84TOGCJ02.h"

@implementation EverywhereAnnotation
//@synthesize coordinate;

//- (void)setLocaton:(CLLocation *)locaton{
//    if (locaton) coordinate = self.locaton.coordinate;
//    NSLog(@"EverywhereAnnotation : coordinate updated!");
//}

- (CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D originalCoordinate = self.location.coordinate;
    return [WGS84TOGCJ02 transformFromWGSToGCJ:originalCoordinate];
}

- (NSString *)title{
    return self.annotationTitle;
}

- (NSInteger)assetCount{
    return self.assetLocalIdentifiers.count;
}

@end
