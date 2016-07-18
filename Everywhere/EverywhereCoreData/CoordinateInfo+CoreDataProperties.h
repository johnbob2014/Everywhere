//
//  CoordinateInfo+CoreDataProperties.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CoordinateInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoordinateInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *administrativeArea_Placemark;
@property (nullable, nonatomic, retain) NSString *ccISOcountryCode_Placemark;
@property (nullable, nonatomic, retain) NSString *country_Placemark;
@property (nullable, nonatomic, retain) NSString *inlandWater_Placemark;
@property (nullable, nonatomic, retain) NSNumber *latitude;
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

@end

NS_ASSUME_NONNULL_END