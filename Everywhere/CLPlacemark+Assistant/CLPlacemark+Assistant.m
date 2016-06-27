//
//  CLPlacemark+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/6/27.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CLPlacemark+Assistant.h"

@implementation CLPlacemark (Assistant)

- (NSString *)localizedPlaceString{
    NSMutableString *resultString = [NSMutableString new];
    
    if (self.name)
        [resultString appendFormat:@"%@,",self.name];
    if (self.subThoroughfare)
        [resultString appendFormat:@"%@,",self.subThoroughfare];
    if (self.thoroughfare)
        [resultString appendFormat:@"%@,",self.thoroughfare];
    if (self.subLocality)
        [resultString appendFormat:@"%@,",self.subLocality];
    if (self.locality)
        [resultString appendFormat:@"%@,",self.locality];
    if (self.subAdministrativeArea)
        [resultString appendFormat:@"%@,",self.subAdministrativeArea];
    if (self.administrativeArea)
        [resultString appendFormat:@"%@,",self.administrativeArea];
    if (self.country)
        [resultString appendFormat:@"%@",self.country];
    
    if (self.inlandWater)
        [resultString appendFormat:@" %@",self.inlandWater];
    if (self.ocean)
        [resultString appendFormat:@" %@",self.ocean];
    
    return [NSString stringWithString:resultString];
}

- (NSString *)areasOfInterestStringWithIndex:(BOOL)withIndex{
    
    if (self.areasOfInterest){
        NSMutableString *resultString = [NSMutableString new];
        NSInteger i = 1;
        for (NSString *interest in self.areasOfInterest) {
            if (withIndex)
                [resultString appendFormat:@"%ld : %@,",(long)i++,interest];
            else
                [resultString appendFormat:@"%@,",interest];
        }
        return [NSString stringWithString:[resultString substringToIndex:resultString.length - 1]];
    }else{
        return nil;
    }
}

@end
