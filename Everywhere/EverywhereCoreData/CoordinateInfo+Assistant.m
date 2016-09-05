//
//  CoordinateInfo+Assistant.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "CoordinateInfo+Assistant.h"
#import "EverywhereCoreDataHeader.h"
#import "CLPlacemark+Assistant.h"
#import "GCCoordinateTransformer.h"

@implementation CoordinateInfo (Assistant)

#pragma mark - MKAnnotation Protocol

- (CLLocationCoordinate2D)coordinate{
    return [GCCoordinateTransformer transformToMarsFromEarth:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue])];
}

- (NSString *)title{
    if (self.customTitle && ![self.customTitle isEqualToString:@""]) return self.customTitle;
    else return [self.localizedPlaceString_Placemark placemarkBriefName];
}

- (NSString *)subtitle{
    if (self.modificationDate) return [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Collected", @"收藏于"),[self.modificationDate stringWithDefaultFormat]];
    else return nil;
}

#pragma mark - Core Data

+ (CoordinateInfo *)fetchCoordinateInfoWithLatitude:(double)latitude longitude:(double)longitude inManagedObjectContext:(NSManagedObjectContext *)context{
    CoordinateInfo *info = nil;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_CoordinateInfo];
    // 查找时，对参数值进行截取
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(latitude = %@) && (longitude = %@)",@([CoordinateInfo truncatedValue:latitude]),@([CoordinateInfo truncatedValue:longitude])];
    NSError *fetchError;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    if(matches.count == 1){
        info = matches.firstObject;
    }else if (!matches || fetchError || [matches count]>1) {
        if(!matches) NSLog(@"Fetch Result : Not Found.");
        if(fetchError) NSLog(@"Fetch Result : %@",fetchError.localizedDescription);
        if(matches.count > 1) NSLog(@"Fetch Result : More than 1 result.");
    }
    
    return info;
}

+ (CoordinateInfo *)coordinateInfoWithCLLocation:(CLLocation *)location inManagedObjectContext:(NSManagedObjectContext *)context{
    // The instance has its entity description set and is inserted it into context.
    // 查找方法会进行截取，这里无需截取
    CoordinateInfo *info = [CoordinateInfo fetchCoordinateInfoWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude inManagedObjectContext:context];
    
    if (!info){
        info = [NSEntityDescription insertNewObjectForEntityForName:EntityName_CoordinateInfo inManagedObjectContext:context];
        // 赋值时，对参数值进行截取
        info.latitude = @([CoordinateInfo truncatedValue:location.coordinate.latitude]);
        info.longitude = @([CoordinateInfo truncatedValue:location.coordinate.longitude]);
        info.altitude = @(location.altitude);
        
        info.speed = @(location.speed);
        info.course = @(location.course);
        info.horizontalAccuracy = @(location.horizontalAccuracy);
        info.verticalAccuracy = @(location.verticalAccuracy);
        info.level = @(location.floor.level);
        
        // 保存修改后的信息
        [context save:NULL];
    }
    
    return info;
}

+ (CoordinateInfo *)coordinateInfoWithPHAssetInfo:(PHAssetInfo *)assetInfo inManagedObjectContext:(NSManagedObjectContext *)context{
    // The instance has its entity description set and is inserted it into context.
    // 查找方法会进行截取，这里无需截取
    CoordinateInfo *info = [CoordinateInfo fetchCoordinateInfoWithLatitude:[assetInfo.latitude_Coordinate_Location doubleValue] longitude:[assetInfo.longitude_Coordinate_Location doubleValue] inManagedObjectContext:context];
    
    if (!info) {
        info = [NSEntityDescription insertNewObjectForEntityForName:EntityName_CoordinateInfo inManagedObjectContext:context];
        // 赋值时，对参数值进行截取
        info.latitude = @([CoordinateInfo truncatedValue:[assetInfo.latitude_Coordinate_Location doubleValue]]);
        info.longitude = @([CoordinateInfo truncatedValue:[assetInfo.longitude_Coordinate_Location doubleValue]]);
        info.altitude = assetInfo.altitude_Location;
        
        info.speed = assetInfo.speed_Location;
        info.course = assetInfo.course_Location;
        info.horizontalAccuracy = assetInfo.horizontalAccuracy_Location;
        info.verticalAccuracy = assetInfo.verticalAccuracy_Location;
        info.level = assetInfo.level_floor_Location;
        
        if (assetInfo.reverseGeocodeSucceed) {
            
            info.name_Placemark = assetInfo.name_Placemark;
            info.ccISOcountryCode_Placemark = assetInfo.ccISOcountryCode_Placemark;
            info.country_Placemark = assetInfo.country_Placemark;
            info.postalCode_Placemark = assetInfo.postalCode_Placemark;
            info.administrativeArea_Placemark = assetInfo.administrativeArea_Placemark;
            info.subAdministrativeArea_Placemark = assetInfo.subAdministrativeArea_Placemark;
            info.locality_Placemark = assetInfo.locality_Placemark;
            info.subLocality_Placemark = assetInfo.subLocality_Placemark;
            info.thoroughfare_Placemark = assetInfo.thoroughfare_Placemark;
            info.subThoroughfare_Placemark = assetInfo.subThoroughfare_Placemark;
            info.inlandWater_Placemark = assetInfo.inlandWater_Placemark;
            info.ocean_Placemark = assetInfo.ocean_Placemark;
            
            info.localizedPlaceString_Placemark = assetInfo.localizedPlaceString_Placemark;
            
            info.reverseGeocodeSucceed = @(YES);
        }
        
        // 保存修改后的信息
        [context save:NULL];
    }

    return info;
}

+ (NSArray <CoordinateInfo *> *)fetchFavoriteCoordinateInfosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_CoordinateInfo];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"favorite = %@",@(YES)];
    NSError *fetchError;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    return matches;
}

+ (double)truncatedValue:(double)aValue{
    double truncateBase = pow(10, 10);
    return floor(aValue * truncateBase) / truncateBase;
}

+ (CLGeocoder *)defaultGeocoder{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CLGeocoder new];
    });
    return instance;
}

+ (void)updatePlacemarkForCoordinateInfo:(CoordinateInfo *)coordinateInfo completionBlock:(void(^)(NSString *localizedPlaceString))completionBlock{
    
    [[CoordinateInfo defaultGeocoder] reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:[coordinateInfo.latitude doubleValue] longitude:[coordinateInfo.longitude doubleValue]]
                                        completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                            
                                            if (!error) {
                                                // 解析成功
                                                CLPlacemark *placemark = placemarks.lastObject;
                                                coordinateInfo.name_Placemark = placemark.name;
                                                coordinateInfo.ccISOcountryCode_Placemark = placemark.ISOcountryCode;
                                                coordinateInfo.country_Placemark = placemark.country;
                                                coordinateInfo.postalCode_Placemark = placemark.postalCode;
                                                coordinateInfo.administrativeArea_Placemark = placemark.administrativeArea;
                                                coordinateInfo.subAdministrativeArea_Placemark = placemark.subAdministrativeArea;
                                                coordinateInfo.locality_Placemark = placemark.locality;
                                                coordinateInfo.subLocality_Placemark = placemark.subLocality;
                                                coordinateInfo.thoroughfare_Placemark = placemark.thoroughfare;
                                                coordinateInfo.subThoroughfare_Placemark = placemark.subThoroughfare;
                                                coordinateInfo.inlandWater_Placemark = placemark.inlandWater;
                                                coordinateInfo.ocean_Placemark = placemark.ocean;
                                                
                                                coordinateInfo.localizedPlaceString_Placemark = [placemark localizedPlaceStringInReverseOrder:NO withInlandWaterAndOcean:NO];
                                                
                                                coordinateInfo.reverseGeocodeSucceed = @(YES);
                                                
                                            }else{
                                                // 解析失败
                                                coordinateInfo.reverseGeocodeSucceed = @(NO);
                                            }
                                            
                                            NSLog(@"CoordinateInfo : %@",coordinateInfo.localizedPlaceString_Placemark);
                                            
                                            // 保存修改后的信息
                                            [coordinateInfo.managedObjectContext save:NULL];
                                            
                                            if (completionBlock) completionBlock(coordinateInfo.localizedPlaceString_Placemark);
                                        }];
    
    
}

+ (NSDictionary <NSString *,NSArray<NSString *> *> *)placemarkInfoFromCoordinateInfos:(NSArray <CoordinateInfo *> *)coordinateInfoArray{
    NSMutableArray <NSString *> *country_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *administrativeArea_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *subAdministrativeArea_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *locality_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *subLocality_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *thoroughfare_Placemark = [NSMutableArray new];
    NSMutableArray <NSString *> *subThoroughfare_Placemark = [NSMutableArray new];
    
    [coordinateInfoArray enumerateObjectsUsingBlock:^(CoordinateInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.country_Placemark) {
            if (![country_Placemark containsObject:obj.country_Placemark]) [country_Placemark addObject:obj.country_Placemark];
        }
        if (obj.administrativeArea_Placemark){
            if (![administrativeArea_Placemark containsObject:obj.administrativeArea_Placemark]) [administrativeArea_Placemark addObject:obj.administrativeArea_Placemark];
        }
        if (obj.subAdministrativeArea_Placemark){
            if (![subAdministrativeArea_Placemark containsObject:obj.subAdministrativeArea_Placemark]) [subAdministrativeArea_Placemark addObject:obj.subAdministrativeArea_Placemark];
        }
        if (obj.locality_Placemark){
            if (![locality_Placemark containsObject:obj.locality_Placemark]) [locality_Placemark addObject:obj.locality_Placemark];
        }
        if (obj.subLocality_Placemark){
            if (![subLocality_Placemark containsObject:obj.subLocality_Placemark]) [subLocality_Placemark addObject:obj.subLocality_Placemark];
        }
        if (obj.thoroughfare_Placemark){
            if (![thoroughfare_Placemark containsObject:obj.thoroughfare_Placemark]) [thoroughfare_Placemark addObject:obj.thoroughfare_Placemark];
        }
        if (obj.subThoroughfare_Placemark){
            if (![subThoroughfare_Placemark containsObject:obj.subThoroughfare_Placemark]) [subThoroughfare_Placemark addObject:obj.subThoroughfare_Placemark];
        }
    }];
    
    return @{kCountryArray:country_Placemark,
             kAdministrativeAreaArray:administrativeArea_Placemark,
             kSubAdministrativeAreaArray:subAdministrativeArea_Placemark,
             kLocalityArray:locality_Placemark,
             kSubLocalityArray:subLocality_Placemark,
             kThoroughfareArray:thoroughfare_Placemark,
             kSubThoroughfareArray:subThoroughfare_Placemark};
}

@end
