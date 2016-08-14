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
    EverywhereFootprintsRepository *footprintsRepository = nil;
    @try {
        footprintsRepository = (EverywhereFootprintsRepository *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    @catch (NSException *exception) {
        if(DEBUGMODE) NSLog(@"从MFR文件生成足迹包出错！");
        return nil;
    }
    @finally {
        return footprintsRepository;
    }
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
    
    if (![[filePath pathExtension] isEqualToString:@"gpx"]) return nil;
    
    // 使用XMLDictionary解析gpx文件
    NSDictionary *gpxFileDic = [NSDictionary dictionaryWithXMLFile:filePath];
    // 如果格式不对
    if (!gpxFileDic || ![gpxFileDic isKindOfClass:[NSDictionary class]]) return nil;
    
    EverywhereFootprintsRepository *footprintsRepository = [EverywhereFootprintsRepository new];
    id valueObject;
    
    if ([gpxFileDic.allKeys containsObject:@"name"])
        valueObject = gpxFileDic[@"name"];
        if ([valueObject isKindOfClass:[NSString class]]) footprintsRepository.title = (NSString *)valueObject;
    
    if ([gpxFileDic.allKeys containsObject:@"time"]){
        valueObject = gpxFileDic[@"time"];
        if ([valueObject isKindOfClass:[NSString class]]) {
            footprintsRepository.creationDate = [NSDate dateFromGPXTimeString:(NSString *)valueObject];
        }
    }
    
    if ([gpxFileDic.allKeys containsObject:@"footprintsRepositoryType"]){
        valueObject = gpxFileDic[@"footprintsRepositoryType"];
        if ([valueObject isKindOfClass:[NSString class]]) footprintsRepository.footprintsRepositoryType = [(NSString *)valueObject integerValue];
    }else{
        footprintsRepository.footprintsRepositoryType = FootprintsRepositoryTypeReceived;
    }
    
    if ([gpxFileDic.allKeys containsObject:@"radius"]){
        valueObject = gpxFileDic[@"radius"];
        if ([valueObject isKindOfClass:[NSString class]]) footprintsRepository.radius = [(NSString *)valueObject floatValue];
    }
    
    // 添加wpt
    NSMutableArray <EverywhereFootprintAnnotation *> *userManuallyAddedFootprintArray = [NSMutableArray new];
    if ([gpxFileDic.allKeys containsObject:@"wpt"]){
        id wptObject = gpxFileDic[@"wpt"];
        
        if (wptObject){
            NSArray *wptDicArray;
            // 如果只有一个点，wptDicArray会被XMLDictionary解析成字典，这时候，需要将wptDicArray转化为数组
            if ([wptObject isKindOfClass:[NSArray class]]){
                wptDicArray = wptObject;
            }else if ([wptDicArray isKindOfClass:[NSDictionary class]]) {
                wptDicArray = @[wptObject];
            }
            
            for (NSDictionary *wptDic in wptDicArray) {
                EverywhereFootprintAnnotation *footprintAnnotation = [EverywhereFootprintAnnotation footprintAnnotationFromGPXPointDictionary:wptDic isUserManuallyAdded:YES];
                if(footprintAnnotation) [userManuallyAddedFootprintArray addObject:footprintAnnotation];
            }
        }
        
    }
    
    // 添加trkpt
    NSMutableArray <EverywhereFootprintAnnotation *> *footprintArray = [NSMutableArray new];
    if ([gpxFileDic.allKeys containsObject:@"trk"]){
        //trkDic
        NSDictionary *trkDic = gpxFileDic[@"trk"];
        
        if([trkDic.allKeys containsObject:@"name"]){
            // trk name
            // if(DEBUGMODE) NSLog(@"trk name : %@",trkDic[@"name"]);
        }
        
        if([trkDic.allKeys containsObject:@"trkseg"]){
            // trksegDic
            NSDictionary *trksegDic = trkDic[@"trkseg"];
            
            if ([trksegDic.allKeys containsObject:@"trkpt"]){
                // trkptDicArray
                
                id trkptObject = trksegDic[@"trkpt"];
                
                if (trkptObject) {
                    NSArray *trkptDicArray;
                    // 如果只有一个点，trkptDicArray会被XMLDictionary解析成字典，这时候，需要将trkptDicArray转化为数组
                    if ([trkptObject isKindOfClass:[NSArray class]]){
                        trkptDicArray = trkptObject;
                    }else if ([trkptDicArray isKindOfClass:[NSDictionary class]]) {
                        trkptDicArray = @[trkptObject];
                    }
                    
                    for (NSDictionary *trkptDic in trkptDicArray) {
                        EverywhereFootprintAnnotation *footprintAnnotation = [EverywhereFootprintAnnotation footprintAnnotationFromGPXPointDictionary:trkptDic isUserManuallyAdded:NO];
                        if(footprintAnnotation) [footprintArray addObject:footprintAnnotation];
                    }

                }
            }
        }
    }
    
    if (userManuallyAddedFootprintArray.count > 0){
        [footprintArray addObjectsFromArray:userManuallyAddedFootprintArray];
    }
    
    // 按时间排序
    [footprintArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult comparisonResult;
        
        NSTimeInterval ti = [((EverywhereFootprintAnnotation *)obj1).startDate timeIntervalSinceDate:((EverywhereFootprintAnnotation *)obj2).startDate];
        
        if (ti < 0) comparisonResult = NSOrderedAscending;
        else if (ti == 0) comparisonResult = NSOrderedSame;
        else comparisonResult = NSOrderedDescending;
        
        return comparisonResult;
    }];
    
    footprintsRepository.footprintAnnotations = footprintArray;

    return footprintsRepository;
}

@end
