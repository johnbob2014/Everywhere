//
//  CoordinateInfo+CoreDataProperties.h
//  Everywhere
//
//  Created by BobZhang on 16/8/30.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CoordinateInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoordinateInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *administrativeArea_Placemark;
@property (nullable, nonatomic, retain) NSNumber *altitude;
@property (nullable, nonatomic, retain) NSString *ccISOcountryCode_Placemark;
@property (nullable, nonatomic, retain) NSString *country_Placemark;
@property (nullable, nonatomic, retain) NSString *inlandWater_Placemark;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *level;
@property (nullable, nonatomic, retain) NSString *locality_Placemark;
@property (nullable, nonatomic, retain) NSString *localizedPlaceString_Placemark;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *name_Placemark;
@property (nullable, nonatomic, retain) NSString *ocean_Placemark;
@property (nullable, nonatomic, retain) NSString *postalCode_Placemark;
@property (nullable, nonatomic, retain) NSNumber *reverseGeocodeSucceed;
@property (nullable, nonatomic, retain) NSString *subAdministrativeArea_Placemark;
@property (nullable, nonatomic, retain) NSString *subLocality_Placemark;
@property (nullable, nonatomic, retain) NSString *subThoroughfare_Placemark;
@property (nullable, nonatomic, retain) NSString *thoroughfare_Placemark;
@property (nullable, nonatomic, retain) NSNumber *speed;
@property (nullable, nonatomic, retain) NSNumber *verticalAccuracy;
@property (nullable, nonatomic, retain) NSNumber *horizontalAccuracy;
@property (nullable, nonatomic, retain) NSNumber *course;

@end

NS_ASSUME_NONNULL_END
