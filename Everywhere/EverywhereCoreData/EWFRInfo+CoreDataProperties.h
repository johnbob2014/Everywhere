//
//  EWFRInfo+CoreDataProperties.h
//  Everywhere
//
//  Created by BobZhang on 16/8/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "EWFRInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface EWFRInfo (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *creationDate;
@property (nullable, nonatomic, retain) NSNumber *footprintsRepositoryType;
@property (nullable, nonatomic, retain) NSDate *modificatonDate;
@property (nullable, nonatomic, retain) NSString *placemarkStatisticalInfo;
@property (nullable, nonatomic, retain) NSNumber *radius;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *footprintsCount;
@property (nullable, nonatomic, retain) NSDate *startDate;
@property (nullable, nonatomic, retain) NSDate *endDate;
@property (nullable, nonatomic, retain) NSNumber *duration;
@property (nullable, nonatomic, retain) NSNumber *averageSpeed;
@property (nullable, nonatomic, retain) NSString *identifier;
@end

NS_ASSUME_NONNULL_END
