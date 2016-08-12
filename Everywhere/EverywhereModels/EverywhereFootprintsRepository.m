//
//  EverywhereFootprintsRepository.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereFootprintsRepository.h"

@implementation EverywhereFootprintsRepository

- (NSDate *)modificatonDate{
    if(_modificatonDate) return _modificatonDate;
    else return self.creationDate;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    EverywhereFootprintsRepository *footprintsRepository = [EverywhereFootprintsRepository new];
    
    footprintsRepository.footprintAnnotations = [aDecoder decodeObjectForKey:@"footprintAnnotations"];
    
    footprintsRepository.radius = [aDecoder decodeDoubleForKey:@"radius"];
    
    footprintsRepository.title = [aDecoder decodeObjectForKey:@"title"];
    
    footprintsRepository.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
    
    footprintsRepository.modificatonDate = [aDecoder decodeObjectForKey:@"modificatonDate"];
    
    footprintsRepository.footprintsRepositoryType = [aDecoder decodeIntegerForKey:@"footprintsRepositoryType"];
    
    footprintsRepository.placemarkInfo = [aDecoder decodeObjectForKey:@"placemarkInfo"];
    
    return footprintsRepository;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.footprintAnnotations forKey:@"footprintAnnotations"];
    
    [aCoder encodeDouble:self.radius forKey:@"radius"];
    
    [aCoder encodeObject:self.title forKey:@"title"];
    
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
    
    [aCoder encodeObject:self.modificatonDate forKey:@"modificatonDate"];
    
    [aCoder encodeInteger:self.footprintsRepositoryType forKey:@"footprintsRepositoryType"];
    
    if (self.placemarkInfo) [aCoder encodeObject:self.placemarkInfo forKey:@"placemarkInfo"];
}

- (id)copyWithZone:(NSZone *)zone{
    EverywhereFootprintsRepository *copyFootprintsRepository = [EverywhereFootprintsRepository allocWithZone:zone];
    
    copyFootprintsRepository.footprintAnnotations = self.footprintAnnotations;
    copyFootprintsRepository.radius = self.radius;
    copyFootprintsRepository.title = self.title;
    copyFootprintsRepository.creationDate = self.creationDate;
    copyFootprintsRepository.modificatonDate = self.modificatonDate;
    copyFootprintsRepository.footprintsRepositoryType = self.footprintsRepositoryType;
    copyFootprintsRepository.placemarkInfo = self.placemarkInfo;
    
    return copyFootprintsRepository;
}

#pragma mark - Export To and Import From MFR File

- (BOOL)exportToMFRFile:(NSString *)filePath{
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+ (EverywhereFootprintsRepository *)importFromMFRFile:(NSString *)filePath{
    return (EverywhereFootprintsRepository *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

#pragma mark - Export To and Import From GPX File

- (BOOL)exportToGPXFile:(NSString *)filePath{
    NSMutableString *gpx_String = [NSMutableString new];
    
    // xml版本及编码
    [gpx_String appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    
    // gpx头
    [gpx_String appendFormat:@"<gpx"];
    [gpx_String appendFormat:@"    version=\"1.0\""];
    [gpx_String appendFormat:@"    creator=\"GPSBabel - http://www.gpsbabel.org\""];
    [gpx_String appendFormat:@"    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""];
    [gpx_String appendFormat:@"    xmlns=\"http://www.topografix.com/GPX/1/0\""];
    [gpx_String appendFormat:@"    xsi:schemaLocation=\"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd\">"];
    
    // 缩进1层
    // 日期
    [gpx_String appendFormat:@"    <time>%@T%@Z</time>",[self.creationDate stringWithFormat:@"yyyy-MM-dd"],[self.creationDate stringWithFormat:@"hh:mm:ss"]];
    
    // 名称
    [gpx_String appendFormat:@"    <name>%@</name>",self.title];
    
    // 座标范围
    EverywhereFootprintAnnotation *firstFP = self.footprintAnnotations.firstObject;
    CLLocationDegrees minlat = firstFP.coordinateWGS84.latitude;
    CLLocationDegrees minlon = firstFP.coordinateWGS84.longitude;
    CLLocationDegrees maxlat = minlat;
    CLLocationDegrees maxlon = minlon;
    
    for (EverywhereFootprintAnnotation *fp in self.footprintAnnotations) {
        
        CLLocationDegrees currentLatitude = fp.coordinateWGS84.latitude;
        if (currentLatitude < minlat) minlat = currentLatitude;
        if (currentLatitude > maxlat) maxlat = currentLatitude;
        
        CLLocationDegrees currentLongitude = fp.coordinateWGS84.longitude;
        if (currentLongitude < minlon) minlon = currentLongitude;
        if (currentLongitude > maxlon) maxlon = currentLongitude;
    }
    
    [gpx_String appendFormat:@"    <bounds minlat=\"%.9f\" minlon=\"%.9f\" maxlat=\"%.9f\" maxlon=\"%.9f\"/>",minlat,minlon,maxlat,maxlon];
    
    // AlbumMaps特有属性 足迹包类型
    [gpx_String appendFormat:@"    <footprintsRepositoryType>%lu</footprintsRepositoryType>",(unsigned long)self.footprintsRepositoryType];
    
    // AlbumMaps特有属性 足迹包半径
    [gpx_String appendFormat:@"    <radius>%.2f</radius>",self.radius];
    
    // 添加wpt
    for (EverywhereFootprintAnnotation *fp in self.footprintAnnotations) {
        if (fp.isUserManuallyAdded) [gpx_String appendString:[fp gpx_wpt_String]];
    }
    
    // 添加trk
    [gpx_String appendFormat:@"    <trk>"];
    
    // 缩进2层
    [gpx_String appendFormat:@"        <name>AlbumMaps Line Track</name>"];
    [gpx_String appendFormat:@"        <trkseg>"];
    
    // 添加trkpt
    for (EverywhereFootprintAnnotation *fp in self.footprintAnnotations) {
        [gpx_String appendString:[fp gpx_trk_trkseg_trkpt_String]];
    }
    
    // 回缩，结束trkseg
    [gpx_String appendFormat:@"        </trkseg>"];
    
    // 回缩，结束trk
    [gpx_String appendFormat:@"    </trk>"];
    
    // 回缩，结束gpx
    [gpx_String appendFormat:@"</gpx>"];
    
    // 写入文件
    NSData *gpx_Data = [gpx_String dataUsingEncoding:NSUTF8StringEncoding];
    return [gpx_Data writeToFile:filePath atomically:YES];
}

+ (EverywhereFootprintsRepository *)importFromGPXFile:(NSString *)filePath{
    EverywhereFootprintsRepository *footprintsRepository = [EverywhereFootprintsRepository new];
    
    if ([[filePath pathExtension] isEqualToString:@"gpx"]){
        NSDictionary *gpxFileDic = [NSDictionary dictionaryWithXMLFile:filePath];
        //NSLog(@"gpxFileDic :\n%@",gpxFileDic);
        
        
        if (gpxFileDic){
            
            if ([gpxFileDic.allKeys containsObject:@"name"])
                footprintsRepository.title = gpxFileDic[@"name"];
            
            if ([gpxFileDic.allKeys containsObject:@"time"]){
                NSString *timeString = gpxFileDic[@"time"];
                footprintsRepository.creationDate = [NSDate dateFromGPXTimeString:timeString];
            }
            
            if ([gpxFileDic.allKeys containsObject:@"footprintsRepositoryType"]){
                footprintsRepository.footprintsRepositoryType = [gpxFileDic[@"footprintsRepositoryType"] unsignedIntegerValue];
            }else{
                footprintsRepository.footprintsRepositoryType = FootprintsRepositoryTypeReceived;
            }
            
            if ([gpxFileDic.allKeys containsObject:@"radius"]){
                footprintsRepository.radius = [gpxFileDic[@"radius"] floatValue];
            }
            
            // 添加wpt
            NSMutableArray <EverywhereFootprintAnnotation *> *userManuallyAddedFootprintArray = [NSMutableArray new];
            if ([gpxFileDic.allKeys containsObject:@"wpt"]){
                NSArray *wptDicArray = gpxFileDic[@"wpt"];
                for (NSDictionary *wptDic in wptDicArray) {
                    EverywhereFootprintAnnotation *footprintAnnotation = [EverywhereFootprintAnnotation footprintAnnotationFromGPXPointDictionary:wptDic isUserManuallyAdded:YES];
                   if(footprintAnnotation) [userManuallyAddedFootprintArray addObject:footprintAnnotation];
                }
            }
            
            // 添加trkpt
            NSMutableArray <EverywhereFootprintAnnotation *> *footprintArray = [NSMutableArray new];
            if ([gpxFileDic.allKeys containsObject:@"trk"]){
                //trkDic
                NSDictionary *trkDic = gpxFileDic[@"trk"];
                
                if([trkDic.allKeys containsObject:@"name"]){
                    // trk name
                    NSLog(@"trk name : %@",trkDic[@"name"]);
                }
                
                if([trkDic.allKeys containsObject:@"trkseg"]){
                    // trksegDic
                    NSDictionary *trksegDic = trkDic[@"trkseg"];
                    
                    if ([trksegDic.allKeys containsObject:@"trkpt"]){
                        // trkptArray
                        NSArray *trkptArray = trksegDic[@"trkpt"];
                        
                        for (NSDictionary *trkptDic in trkptArray) {
                            EverywhereFootprintAnnotation *footprintAnnotation = [EverywhereFootprintAnnotation footprintAnnotationFromGPXPointDictionary:trkptDic isUserManuallyAdded:NO];
                            if(footprintAnnotation) [footprintArray addObject:footprintAnnotation];
                        }

                    }
                }
            }
            
            if (userManuallyAddedFootprintArray.count > 0){
                [footprintArray addObjectsFromArray:userManuallyAddedFootprintArray];
            }
            
            footprintsRepository.footprintAnnotations = footprintArray;
            
        }else{
            return nil;
        }
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:gpxFileDic options:NSJSONWritingPrettyPrinted error:NULL];
        [jsonData writeToFile:[Path_Documents stringByAppendingPathComponent:@"b.json"] atomically:YES];
        //[gpxFileDic writeToFile:[Path_Documents stringByAppendingPathComponent:@"a.json"] atomically:YES];
    }else{
        return nil;
    }
    
    return footprintsRepository;
}

@end
