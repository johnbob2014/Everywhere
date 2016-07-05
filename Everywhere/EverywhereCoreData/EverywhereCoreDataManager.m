//
//  EverywhereCoreDataManager.m
//  Everywhere
//
//  Created by BobZhang on 16/7/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereCoreDataManager.h"
#import "EverywhereAppDelegate.h"

@implementation EverywhereCoreDataManager

+ (instancetype)defaultManager{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (NSManagedObjectContext *)appMOC{
    EverywhereAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

@synthesize lastUpdateDate;

- (NSDate *)lastUpdateDate{
    NSDate *aDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateDate"];
    return aDate;
}

- (void)setLastUpdateDate:(NSDate *)aDate{
    lastUpdateDate = aDate;
    [[NSUserDefaults standardUserDefaults] setValue:aDate forKey:@"lastUpdateDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
