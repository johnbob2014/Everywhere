//
//  EverywhereMKAnnotation.m
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereMKAnnotation.h"
#import "WGS84TOGCJ02.h"

@implementation EverywhereMKAnnotation
@synthesize coordinate;

//- (void)setLocaton:(CLLocation *)locaton{
//    if (locaton) coordinate = self.locaton.coordinate;
//    NSLog(@"EverywhereMKAnnotation : coordinate updated!");
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
