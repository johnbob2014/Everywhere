//
//  GCMaps.m
//  Everywhere
//
//  Created by 张保国 on 16/8/18.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCMaps.h"
@import MapKit;

@implementation GCMaps

+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionsMode:(NSString *)directionsMode{
    [GCMaps baidumapDirectionFromOrigin:origin toDestination:destination directionsMode:directionsMode companyName:GCMapsCompanyName appName:GCMapsAppName];
}

+ (void)baidumapDirectionFromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination directionsMode:(NSString *)directionsMode companyName:(NSString *)companyName appName:(NSString *)appName{
    //URI格式示例
    //@"baidumap://map/direction?origin=34.26,108.95&destination=40.00,116.36&mode=driving&src=yourCompanyName|yourAppName";
    NSString *requestString = [NSString stringWithFormat:@"baidumap://map/direction?origin=%.10f,%.10f&destination=%.10f,%.10f&mode=%@&src=%@|%@",origin.latitude,origin.longitude,destination.latitude,destination.longitude,directionsMode,companyName,appName];
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestString]];
}

+ (void)iosamapPathFromSource:(CLLocationCoordinate2D)source toDestination:(CLLocationCoordinate2D)destination tMode:(enum AMapTransitMOption)t mOption:(enum AMapDrivingMOption)m{
    [GCMaps iosamapPathFromSource:source toDestination:destination tMode:t mOption:m appName:GCMapsAppName];
}

+ (void)iosamapPathFromSource:(CLLocationCoordinate2D)source toDestination:(CLLocationCoordinate2D)destination tMode:(enum AMapTransitMOption)t mOption:(enum AMapDrivingMOption)m appName:(NSString *)appName{
    //URI格式示例
    //iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=39.92848272&slon=116.39560823&sname=A&did=BGVIS2&dlat=39.98848272&dlon=116.47560823&dname=B&dev=0&m=0&t=0
    NSString *requestString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&slat=%.10f&slon=%.10f&sname=&did=BGVIS2&dlat=%.10f&dlon=%.10f&dname=&dev=0&m=%ld&t=%ld",appName,source.latitude,source.longitude,destination.latitude,destination.longitude,(long)m,(long)t];
    requestString = [requestString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestString]];
}

+ (void)mkmapFromSource:(CLLocationCoordinate2D)source toDestination:(CLLocationCoordinate2D)destination directionsMode:(NSString *)directionsMode{
    MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:source addressDictionary:nil]];
    MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil]];
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:directionsMode,
                               MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard],
                               MKLaunchOptionsShowsTrafficKey:@YES };
    [MKMapItem openMapsWithItems:@[sourceItem,destinationItem] launchOptions:options];
}

@end
