//
//  EWFRInfo+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/8/25.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EWFRInfo+Assistant.h"
#import "EverywhereCoreDataHeader.h"

@implementation EWFRInfo (Assistant)

- (NSString *)filePath{
    return [EWFRStorageDirectoryPath stringByAppendingPathComponent:self.identifier];
}

+ (EWFRInfo *)fetchEWFRInfoWithIdentifier:(NSString *)ewfrID inManagedObjectContext:(NSManagedObjectContext *)context{
    EWFRInfo *info = nil;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_EWFRInfo];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@",ewfrID];
    
    NSError *fetchError;
    NSArray *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    if(matches.count == 1){
        info = matches.firstObject;
    }else if (!matches || fetchError || [matches count]>1) {
        if(!matches)  NSLog(@"Fetch Result : Not Found.");
        if(fetchError)  NSLog(@"Fetch Result : %@",fetchError.localizedDescription);
        if(matches.count > 1)  NSLog(@"Fetch Result : More than 1 result.");
    }
    
    return info;
}

+ (EWFRInfo *)newEWFRInfoWithEWFR:(EverywhereFootprintsRepository *)ewfr inManagedObjectContext:(NSManagedObjectContext *)context{
    EWFRInfo *info = [NSEntityDescription insertNewObjectForEntityForName:EntityName_EWFRInfo inManagedObjectContext:context];
    
    info.footprintsCount = @(ewfr.footprintAnnotations.count);
    info.creationDate = ewfr.creationDate;
    info.radius = @(ewfr.radius);
    info.footprintsRepositoryType = @(ewfr.footprintsRepositoryType);
    info.title = ewfr.title;
    info.placemarkStatisticalInfo = ewfr.placemarkStatisticalInfo;
    info.modificatonDate = ewfr.modificatonDate;
    
    info.distance = @(ewfr.distance);
    info.startDate = ewfr.startDate;
    info.endDate = ewfr.endDate;
    info.duration = @(ewfr.duration);
    info.averageSpeed = @(ewfr.averageSpeed);
    
    info.identifier = ewfr.identifier;
    
    [context save:NULL];
    return info;
}

+ (NSArray <EWFRInfo *> *)fetchAllEWFRInfosInManagedObjectContext:(NSManagedObjectContext *)context{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:EntityName_EWFRInfo];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    NSError *fetchError;
    NSArray <EWFRInfo *> *matches = [context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError) NSLog(@"Fetch All Error : %@",fetchError.localizedDescription);
    return matches;
}

@end
