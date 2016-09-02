//
//  EverywhereAnnotation.m
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereAnnotation.h"

@implementation EverywhereAnnotation

- (CLLocationCoordinate2D)coordinate{
    return [GCCoordinateTransformer transformToMarsFromEarth:self.location.coordinate];
}

- (NSString *)title{
    return self.annotationTitle;
}

- (NSString *)subtitle{
    return self.annotationSubtitle;
}

- (NSInteger)assetCount{
    return self.assetLocalIdentifiers.count;
}

@end
