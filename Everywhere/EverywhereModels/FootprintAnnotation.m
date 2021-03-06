//
//  FootprintAnnotation.m
//  Everywhere
//
//  Created by BobZhang on 16/7/15.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "FootprintAnnotation.h"

@implementation FootprintAnnotation

- (CLLocation *)location{
    return [[CLLocation alloc] initWithCoordinate:self.coordinateWGS84 altitude:self.altitude horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:self.speed timestamp:[NSDate date]];
}

- (CLLocationCoordinate2D)coordinate{
    return [GCCoordinateTransformer transformToMarsFromEarth:self.coordinateWGS84];
}

- (NSString *)title{
    return self.customTitle;
}

- (NSString *)subtitle{
    return [self dateString];
}

- (NSString *)customTitle{
    if (!_customTitle){
        _customTitle = [self dateString];
    }
    return _customTitle;
}

- (NSString *)dateString{
    if (self.endDate) return [NSString stringWithFormat:@"%@ ~ %@",[self.startDate stringWithFormat:@"yyyy-MM-dd"],[self.endDate stringWithFormat:@"yyyy-MM-dd"]];
    else return [self.startDate stringWithDefaultFormat];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    CGPoint coordinateWGS84Point = [aDecoder decodeCGPointForKey:@"coordinateWGS84Point"];
    
    FootprintAnnotation *footprintAnnotation = [FootprintAnnotation new];
    footprintAnnotation.coordinateWGS84 = CLLocationCoordinate2DMake(coordinateWGS84Point.x, coordinateWGS84Point.y);
    footprintAnnotation.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    footprintAnnotation.endDate = [aDecoder decodeObjectForKey:@"endDate"];
    footprintAnnotation.customTitle = [aDecoder decodeObjectForKey:@"customTitle"];
    footprintAnnotation.isUserManuallyAdded = [aDecoder decodeBoolForKey:@"isUserManuallyAdded"];
    footprintAnnotation.altitude = [aDecoder decodeDoubleForKey:@"altitude"];
    footprintAnnotation.speed = [aDecoder decodeDoubleForKey:@"speed"];
    footprintAnnotation.thumbnailArray = [aDecoder decodeObjectForKey:@"thumbnailArray"];
    return footprintAnnotation;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    CGPoint coordinateWGS84Point = CGPointMake(self.coordinateWGS84.latitude, self.coordinateWGS84.longitude);
    [aCoder encodeCGPoint:coordinateWGS84Point forKey:@"coordinateWGS84Point"];
    
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    
    if (self.endDate) {
        [aCoder encodeObject:self.endDate forKey:@"endDate"];
    }
    
    if (self.customTitle){
        [aCoder encodeObject:self.customTitle forKey:@"customTitle"];
    }
    
    if (self.isUserManuallyAdded){
        [aCoder encodeBool:self.isUserManuallyAdded forKey:@"isUserManuallyAdded"];
    }
    
    if (self.altitude != 0){
        [aCoder encodeDouble:self.altitude forKey:@"altitude"];
    }
    
    if (self.speed != 0){
        [aCoder encodeDouble:self.speed forKey:@"speed"];
    }
    
    if (self.thumbnailArray){
        [aCoder encodeObject:self.thumbnailArray forKey:@"thumbnailArray"];
    }
}

#pragma mark - Export To and Import From GPX File

- (NSString *)gpx_wpt_String{
    NSMutableString *gpx_wpt_String = [NSMutableString new];
    [gpx_wpt_String appendFormat:@"\n    "];
    [gpx_wpt_String appendFormat:@"<wpt lat=\"%.9f\" lon=\"%.9f\">",self.coordinateWGS84.latitude,self.coordinateWGS84.longitude];
    [gpx_wpt_String appendFormat:@"\n    "];
    [gpx_wpt_String appendFormat:@"<ele>%.2f</ele>",self.altitude];
    [gpx_wpt_String appendFormat:@"\n    "];
    [gpx_wpt_String appendFormat:@"<name>%@</name>",self.title];
    [gpx_wpt_String appendFormat:@"\n    "];
    [gpx_wpt_String appendFormat:@"<time>%@T%@Z</time>",[self.startDate stringWithFormat:@"yyyy-MM-dd"],[self.startDate stringWithFormat:@"hh:mm:ss"]];
    if (self.endDate){
        [gpx_wpt_String appendFormat:@"\n    "];
        [gpx_wpt_String appendFormat:@"<endtime>%@T%@Z</endtime>",[self.endDate stringWithFormat:@"yyyy-MM-dd"],[self.endDate stringWithFormat:@"hh:mm:ss"]];
    }
    [gpx_wpt_String appendFormat:@"\n    "];
    [gpx_wpt_String appendFormat:@"</wpt>"];
    return gpx_wpt_String;
}

- (NSString *)gpx_trk_trkseg_trkpt_String:(BOOL)enhancedGPX{
    NSMutableString *gpx_trk_trkseg_trkpt_String = [NSMutableString new];
    [gpx_trk_trkseg_trkpt_String appendFormat:@"\n            "];
    [gpx_trk_trkseg_trkpt_String appendFormat:@"<trkpt lat=\"%.9f\" lon=\"%.9f\">",self.coordinateWGS84.latitude,self.coordinateWGS84.longitude];
    [gpx_trk_trkseg_trkpt_String appendFormat:@"<ele>%.2f</ele>",self.altitude];
    [gpx_trk_trkseg_trkpt_String appendFormat:@"\n            "];
    [gpx_trk_trkseg_trkpt_String appendFormat:@"<time>%@T%@Z</time>",[self.startDate stringWithFormat:@"yyyy-MM-dd"],[self.startDate stringWithFormat:@"hh:mm:ss"]];
    // AlbumMaps特有属性 trkpt结束日期
    if (self.endDate){
        [gpx_trk_trkseg_trkpt_String appendFormat:@"\n            "];
        [gpx_trk_trkseg_trkpt_String appendFormat:@"<endtime>%@T%@Z</endtime>",[self.endDate stringWithFormat:@"yyyy-MM-dd"],[self.endDate stringWithFormat:@"hh:mm:ss"]];
    }
    
    // AlbumMaps特有属性 trkpt缩略图
    if (enhancedGPX){
        [gpx_trk_trkseg_trkpt_String appendFormat:@"\n            <thumbnails>"];
        int index = 0;
        for (id thumbnail in self.thumbnailArray) {
            NSData *thumbnailData;
            if ([thumbnail isKindOfClass:[NSData class]]){
                thumbnailData = (NSData *)thumbnail;
            }
            else if ([thumbnail isKindOfClass:[UIImage class]]){
                UIImage *thumbnailUIImage = (UIImage *)thumbnail;
                thumbnailData = UIImageJPEGRepresentation(thumbnailUIImage, 1.0);
            }
            
            [gpx_trk_trkseg_trkpt_String appendFormat:@"\n                <thumbnail index=\"%d\">",index];
            [gpx_trk_trkseg_trkpt_String appendFormat:@"\n                    <data>%@</data>",[thumbnailData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
            [gpx_trk_trkseg_trkpt_String appendFormat:@"\n                </thumbnail>"];
            
            index++;
        }
        [gpx_trk_trkseg_trkpt_String appendFormat:@"\n            </thumbnails>"];
    }
    
    [gpx_trk_trkseg_trkpt_String appendFormat:@"\n            "];
    [gpx_trk_trkseg_trkpt_String appendFormat:@"</trkpt>"];
    return gpx_trk_trkseg_trkpt_String;
}

+ (FootprintAnnotation *)footprintAnnotationFromGPXPointDictionary:(NSDictionary *)pointDictionary isUserManuallyAdded:(BOOL)isUserManuallyAdded{
    
    // 如果不是字典，返回空值
    if (!pointDictionary || ![pointDictionary isKindOfClass:[NSDictionary class]]) return nil;
    
//    // point字典中的所有值都应该是字符串，如果不是，返回空值
//    for (id valueObject in pointDictionary.allValues) {
//        if (![valueObject isKindOfClass:[NSString class]]) return nil;
//    }
    
    FootprintAnnotation *footprintAnnotation = [FootprintAnnotation new];
    
    footprintAnnotation.isUserManuallyAdded = isUserManuallyAdded;
    
    if ([pointDictionary.allKeys containsObject:@"name"])
        footprintAnnotation.customTitle = pointDictionary[@"name"];
    
    if ([pointDictionary.allKeys containsObject:@"_lat"] && [pointDictionary.allKeys containsObject:@"_lon"]){
        footprintAnnotation.coordinateWGS84 = CLLocationCoordinate2DMake([pointDictionary[@"_lat"] doubleValue], [pointDictionary[@"_lon"] doubleValue]);
    }
    
    if ([pointDictionary.allKeys containsObject:@"ele"])
        footprintAnnotation.altitude = [pointDictionary[@"ele"] doubleValue];
    
    if ([pointDictionary.allKeys containsObject:@"time"]){
        NSString *timeString = pointDictionary[@"time"];
        footprintAnnotation.startDate = [NSDate dateFromGPXTimeString:timeString];
    }else{
        footprintAnnotation.startDate = NOW;
    }
    
    // AlbumMaps特有属性 endtime endDate
    if ([pointDictionary.allKeys containsObject:@"endtime"]){
        NSString *timeString = pointDictionary[@"endtime"];
        footprintAnnotation.endDate = [NSDate dateFromGPXTimeString:timeString];
    }
    
    // AlbumMaps特有属性
    if ([pointDictionary.allKeys containsObject:@"thumbnails"]){
        NSDictionary *thumbnailsDic = pointDictionary[@"thumbnails"];
        if ([thumbnailsDic.allKeys containsObject:@"thumbnail"]) {
            id thumbnailObject = thumbnailsDic[@"thumbnail"];
            
            NSArray *thumbnailNSDicNSArray = [NSArray new];
            if ([thumbnailObject isKindOfClass:[NSArray class]]) {
                thumbnailNSDicNSArray = (NSArray *)thumbnailObject;
            }else if ([thumbnailObject isKindOfClass:[NSDictionary class]]){
                thumbnailNSDicNSArray = @[thumbnailObject];
            }
            
            footprintAnnotation.thumbnailArray = [NSMutableArray new];
            for (NSDictionary *thumbnailNSDic in thumbnailNSDicNSArray) {
                if ([thumbnailNSDic.allKeys containsObject:@"data"] ) {
                    NSString *thumbnailDataString = thumbnailNSDic[@"data"];
                    NSData *thumbnailData = [[NSData alloc] initWithBase64EncodedString:thumbnailDataString options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    [footprintAnnotation.thumbnailArray addObject:thumbnailData];
                }
            }
        }
    }
    
    return footprintAnnotation;
}

@end
