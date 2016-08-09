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

- (BOOL)exportToFile:(NSString *)filePath{
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+ (EverywhereFootprintsRepository *)importFromFile:(NSString *)filePath{
    return (EverywhereFootprintsRepository *)[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
