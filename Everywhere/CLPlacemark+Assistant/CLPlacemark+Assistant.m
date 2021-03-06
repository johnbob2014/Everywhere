//
//  CLPlacemark+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/6/27.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CLPlacemark+Assistant.h"

@implementation CLPlacemark (Assistant)

- (NSString *)localizedPlaceStringInReverseOrder:(BOOL)reverseOrder withInlandWaterAndOcean:(BOOL)inlandWaterAndOcean{
    //if(DEBUGMODE) NSLog(@"%@",[self class]);
    
    // subLocality及其之前的地址信息，以逗号分隔
    NSMutableString *detailLocationStringTillSubLocality = [NSMutableString new];
    
    // 地址名称 或 街道信息
    // 如果能解析到具体地址名称，则self.name为具体地址名称，否则，为地址信息（包含街道信息）
    NSString *trimmedNameString = self.name;
    
    if (self.country){
        //if(DEBUGMODE) NSLog(@"country : %@",self.country);
        [detailLocationStringTillSubLocality appendFormat:@"%@",self.country];
        //detailLocationStringTillSubLocality = [self.country stringByAppendingFormat:@",%@",detailLocationStringTillSubLocality];
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.country withString:@""];
    }
    if (self.administrativeArea){
        //if(DEBUGMODE) NSLog(@"administrativeArea : %@",self.administrativeArea);
        [detailLocationStringTillSubLocality appendFormat:@",%@",self.administrativeArea];
        //detailLocationStringTillSubLocality = [self.administrativeArea stringByAppendingFormat:@",%@",detailLocationStringTillSubLocality];
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.administrativeArea withString:@""];
    }
    if (self.subAdministrativeArea){
        //if(DEBUGMODE) NSLog(@"subAdministrativeArea : %@",self.subAdministrativeArea);
        [detailLocationStringTillSubLocality appendFormat:@",%@",self.subAdministrativeArea];
        //detailLocationStringTillSubLocality = [self.subAdministrativeArea stringByAppendingFormat:@",%@",detailLocationStringTillSubLocality];
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.subAdministrativeArea withString:@""];
    }
    if (self.locality){
        //if(DEBUGMODE) NSLog(@"locality : %@",self.locality);
        [detailLocationStringTillSubLocality appendFormat:@",%@",self.locality];
        //detailLocationStringTillSubLocality = [self.locality stringByAppendingFormat:@",%@",detailLocationStringTillSubLocality];
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.locality withString:@""];
    }
    if (self.subLocality){
        //if(DEBUGMODE) NSLog(@"subLocality : %@",self.subLocality);
        [detailLocationStringTillSubLocality appendFormat:@",%@",self.subLocality];
        //detailLocationStringTillSubLocality = self.subLocality;
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.subLocality withString:@""];
    }
    if (self.thoroughfare){
        //if(DEBUGMODE) NSLog(@"thoroughfare : %@",self.thoroughfare);
        //[detailLocationStringTillSubLocality appendFormat:@"%@,",self.thoroughfare];
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.thoroughfare withString:@""];
    }
    if (self.subThoroughfare){
        //if(DEBUGMODE) NSLog(@"subThoroughfare : %@",self.subThoroughfare);
        //[detailLocationStringTillSubLocality appendFormat:@"%@,",self.subThoroughfare];
        trimmedNameString = [trimmedNameString stringByReplacingOccurrencesOfString:self.subThoroughfare withString:@""];
    }
    
    //if(DEBUGMODE) NSLog(@"name : %@",self.name);
    //if(DEBUGMODE) NSLog(@"trimmedNameString : %@",trimmedNameString);
    
    // 全部地址信息，以逗号分隔
    NSString *combinedDetailLocationString = nil;
    
    if ([self.name isEqualToString:trimmedNameString]) {
        // self.name 是地点名称
        // 这时 trimmedNameString 也是 地点名称 ，稍后添加
        // 这时combinedDetailLocationString 是 地址信息，不含街道信息
        combinedDetailLocationString = detailLocationStringTillSubLocality;
    }else{
        // self.name 是地址列表
        // 这时 trimmedNameString 是 街道信息 ，将其添加到地址信息中
        // 这时combinedDetailLocationString 是 地址信息，包含街道信息
        if (trimmedNameString)
            combinedDetailLocationString = [detailLocationStringTillSubLocality stringByAppendingFormat:@",%@",trimmedNameString];
        else
            combinedDetailLocationString = detailLocationStringTillSubLocality;
    }
    
    if (self.thoroughfare) combinedDetailLocationString = [combinedDetailLocationString stringByAppendingFormat:@",%@",self.thoroughfare];
    if (self.subThoroughfare) combinedDetailLocationString = [combinedDetailLocationString stringByAppendingFormat:@",%@",self.subThoroughfare];
    
    if ([self.name isEqualToString:trimmedNameString]) {
        // self.name 是地点名称
        // 在地下信息中添加地点名称
        combinedDetailLocationString = [combinedDetailLocationString stringByAppendingFormat:@",%@",self.name];
    }
    
    //if(DEBUGMODE) NSLog(@"combinedDetailLocationString : %@",combinedDetailLocationString);
    
    NSString *resultString = combinedDetailLocationString;
    
    if (reverseOrder) {
        // 生成逆序地址
        NSMutableString *tempMS = [NSMutableString new];
        NSArray *array = [combinedDetailLocationString componentsSeparatedByString:@","];
        for (NSInteger i = array.count - 1; i >= 0; i--) {
            [tempMS appendFormat:@"%@,",array[i]];
        }
        resultString = [tempMS substringToIndex:tempMS.length - 1];
    }
    
    if (inlandWaterAndOcean) {
        //添加水系情况
        if (self.inlandWater)
            resultString = [resultString stringByAppendingFormat:@" inlandWater : %@",self.inlandWater];
        if (self.ocean)
            resultString = [resultString stringByAppendingFormat:@" ocean : %@",self.ocean];
    }
    
    // 排除,,
    resultString = [resultString stringByReplacingOccurrencesOfString:@",," withString:@","];
    
    return resultString;
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

@implementation NSString (CLPlacemark_Assistant)

- (NSString *)placemarkBriefName{
    NSString *briefName;
    
    NSArray <NSString *> *stringArray = [self componentsSeparatedByString:@","];
    
    if (stringArray.count == 0){
        briefName = @"";
    }else if (stringArray.count == 1){
        briefName = stringArray.lastObject;
    }else if (stringArray.count > 1){
        if ([stringArray.lastObject length] >= 5){
            briefName = stringArray.lastObject;
        }else{
            briefName = [stringArray[stringArray.count - 2] stringByAppendingString:stringArray.lastObject];
        }
    }
    
    return briefName;
}

@end