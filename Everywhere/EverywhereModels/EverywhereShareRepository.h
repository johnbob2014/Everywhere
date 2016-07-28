//
//  EverywhereShareRepository.h
//  Everywhere
//
//  Created by 张保国 on 16/7/17.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EverywhereShareAnnotation.h"

@interface EverywhereShareRepository : NSObject <NSCoding,NSCopying>

@property (strong,nonatomic) NSArray <EverywhereShareAnnotation *> *shareAnnos;
@property (assign,nonatomic) double radius;

@property (strong,nonatomic) NSString *title;

@property (strong,nonatomic) NSString *placemarkInfo;

@property (strong,nonatomic) NSDate *creationDate;

@property (assign,nonatomic) ShareRepositoryType shareRepositoryType;

@end
