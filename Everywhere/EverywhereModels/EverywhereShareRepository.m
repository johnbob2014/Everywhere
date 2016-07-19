//
//  EverywhereShareRepository.m
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereShareRepository.h"

@implementation EverywhereShareRepository

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    EverywhereShareRepository *shareRepository = [EverywhereShareRepository new];
    
    shareRepository.shareAnnos = [aDecoder decodeObjectForKey:@"shareAnnos"];
    
    shareRepository.radius = [aDecoder decodeDoubleForKey:@"radius"];
    
    shareRepository.title = [aDecoder decodeObjectForKey:@"title"];
    
    shareRepository.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
    
    shareRepository.shareRepositoryType = [aDecoder decodeIntegerForKey:@"shareRepositoryType"];
    
    return shareRepository;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.shareAnnos forKey:@"shareAnnos"];
    
    [aCoder encodeDouble:self.radius forKey:@"radius"];
    
    [aCoder encodeObject:self.title forKey:@"title"];
    
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
    
    [aCoder encodeInteger:self.shareRepositoryType forKey:@"shareRepositoryType"];
}

@end
