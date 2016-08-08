//
//  EverywhereShareRepository.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereShareRepository.h"

@implementation EverywhereShareRepository

- (NSDate *)modificatonDate{
    if(_modificatonDate) return _modificatonDate;
    else return self.creationDate;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    EverywhereShareRepository *shareRepository = [EverywhereShareRepository new];
    
    shareRepository.shareAnnos = [aDecoder decodeObjectForKey:@"shareAnnos"];
    
    shareRepository.radius = [aDecoder decodeDoubleForKey:@"radius"];
    
    shareRepository.title = [aDecoder decodeObjectForKey:@"title"];
    
    shareRepository.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
    
    shareRepository.modificatonDate = [aDecoder decodeObjectForKey:@"modificatonDate"];
    
    shareRepository.shareRepositoryType = [aDecoder decodeIntegerForKey:@"shareRepositoryType"];
    
    shareRepository.placemarkInfo = [aDecoder decodeObjectForKey:@"placemarkInfo"];
    
    return shareRepository;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.shareAnnos forKey:@"shareAnnos"];
    
    [aCoder encodeDouble:self.radius forKey:@"radius"];
    
    [aCoder encodeObject:self.title forKey:@"title"];
    
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
    
    [aCoder encodeObject:self.modificatonDate forKey:@"modificatonDate"];
    
    [aCoder encodeInteger:self.shareRepositoryType forKey:@"shareRepositoryType"];
    
    if (self.placemarkInfo) [aCoder encodeObject:self.placemarkInfo forKey:@"placemarkInfo"];
}

- (id)copyWithZone:(NSZone *)zone{
    EverywhereShareRepository *copyShareRepository = [EverywhereShareRepository allocWithZone:zone];
    
    copyShareRepository.shareAnnos = self.shareAnnos;
    copyShareRepository.radius = self.radius;
    copyShareRepository.title = self.title;
    copyShareRepository.creationDate = self.creationDate;
    copyShareRepository.modificatonDate = self.modificatonDate;
    copyShareRepository.shareRepositoryType = self.shareRepositoryType;
    copyShareRepository.placemarkInfo = self.placemarkInfo;
    
    return copyShareRepository;
}
@end
