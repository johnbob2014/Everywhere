//
//  PHAssetInfo+CoreDataProperties.h
//  Everywhere
//
//  Created by BobZhang on 16/8/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PHAssetInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface PHAssetInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *administrativeArea_Placemark;
@property (nullable, nonatomic, retain) NSNumber *altitude_Location;
@property (nullable, nonatomic, retain) NSString *burstIdentifier;
@property (nullable, nonatomic, retain) NSNumber *burstSelectionTypes;
@property (nullable, nonatomic, retain) NSString *ccISOcountryCode_Placemark;
@property (nullable, nonatomic, retain) NSString *country_Placemark;
@property (nullable, nonatomic, retain) NSNumber *course_Location;
@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSNumber *favorite;
@property (nullable, nonatomic, retain) NSNumber *hidden;
@property (nullable, nonatomic, retain) NSNumber *horizontalAccuracy_Location;
@property (nullable, nonatomic, retain) NSString *inlandWater_Placemark;
@property (nullable, nonatomic, retain) NSNumber *latitude_Coordinate_Location;
@property (nullable, nonatomic, retain) NSNumber *level_floor_Location;
@property (nullable, nonatomic, retain) NSString *localIdentifier;
@property (nullable, nonatomic, retain) NSString *locality_Placemark;
@property (nullable, nonatomic, retain) NSString *localizedPlaceString_Placemark;
@property (nullable, nonatomic, retain) NSNumber *longitude_Coordinate_Location;
@property (nullable, nonatomic, retain) NSNumber *mediaSubtypes;
@property (nullable, nonatomic, retain) NSNumber *mediaType;
@property (nullable, nonatomic, retain) NSDate *modificationDate;
@property (nullable, nonatomic, retain) NSString *name_Placemark;
@property (nullable, nonatomic, retain) NSString *ocean_Placemark;
@property (nullable, nonatomic, retain) NSNumber *pixelHeight;
@property (nullable, nonatomic, retain) NSNumber *pixelWidth;
@property (nullable, nonatomic, retain) NSString *postalCode_Placemark;
@property (nullable, nonatomic, retain) NSNumber *representsBurst;
@property (nullable, nonatomic, retain) NSNumber *reverseGeocodeSucceed;
@property (nullable, nonatomic, retain) NSNumber *speed_Location;
@property (nullable, nonatomic, retain) NSString *subAdministrativeArea_Placemark;
@property (nullable, nonatomic, retain) NSString *subLocality_Placemark;
@property (nullable, nonatomic, retain) NSString *subThoroughfare_Placemark;
@property (nullable, nonatomic, retain) NSString *thoroughfare_Placemark;
@property (nullable, nonatomic, retain) NSNumber *verticalAccuracy_Location;
@property (nullable, nonatomic, retain) NSNumber *eliminateThisAsset;
@property (nullable, nonatomic, retain) NSNumber *actAsThumbnail;
@property (nullable, nonatomic, retain) NSNumber *invalid;
@end

NS_ASSUME_NONNULL_END
