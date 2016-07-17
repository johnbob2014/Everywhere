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
    
    
    //NSData *shareAnnosData = [aDecoder decodeObjectForKey:@"shareAnnosData"];
    //NSArray <EverywhereShareMKAnnotation *> *shareAnnos = [NSKeyedUnarchiver unarchiveObjectWithData:shareAnnosData];
    
    double radius = [aDecoder decodeDoubleForKey:@"radius"];
    NSString *title = [aDecoder decodeObjectForKey:@"title"];
    NSTimeInterval creationDateTimeInterval = [aDecoder decodeDoubleForKey:@"creationDateTimeInterval"];
    NSDate *creationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:creationDateTimeInterval];
        
    shareRepository.shareAnnos = [aDecoder decodeObjectForKey:@"shareAnnos"];
    shareRepository.radius = radius;
    shareRepository.title = title;
    shareRepository.creationDate = creationDate;
    
    return shareRepository;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.shareAnnos forKey:@"shareAnnos"];
    //NSData *shareAnnosData = [NSKeyedArchiver archivedDataWithRootObject:self.shareAnnos];
    //[aCoder encodeObject:shareAnnosData forKey:@"shareAnnosData"];

    [aCoder encodeDouble:self.radius forKey:@"radius"];
    
    [aCoder encodeObject:self.title forKey:@"title"];
    
    NSTimeInterval creationDateTimeInterval = [self.creationDate timeIntervalSinceReferenceDate];
    [aCoder encodeDouble:creationDateTimeInterval forKey:@"creationDateTimeInterval"];

}

@end
