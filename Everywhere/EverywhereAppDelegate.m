//
//  EverywhereAppDelegate.m
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define DEBUGMODE 1

#import "EverywhereAppDelegate.h"

//#import "GCPhotoManager.h"
//#import "NSDate+Assistant.h"

#import "EverywhereCoreDataManager.h"
//#import "PHAssetInfo.h"

#import "EverywhereSettingManager.h"

#import "AssetsMapProVC.h"

#import "WXApi.h"

@interface EverywhereAppDelegate () <WXApiDelegate>

@end

@implementation EverywhereAppDelegate{
    AssetsMapProVC *assetsMapProVC;
//    
//    GCPhotoManager *photoManager;
//    EverywhereCoreDataManager *cdManager;
//    EverywhereSettingManager *settingManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    //向微信注册id
    BOOL wx=[WXApi registerApp:@"wxa1b9c5632d24039a"];
    if(DEBUGMODE) NSLog(@"WeChat Rigister：%@",wx? @"Succeeded" : @"Failed");
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    assetsMapProVC = [AssetsMapProVC new];
    self.window.rootViewController = assetsMapProVC;
    self.window.tintColor = [EverywhereSettingManager defaultManager].baseTintColor;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if ([EverywhereSettingManager defaultManager].praiseCount != 0) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }

    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    //NSLog(@"%@",url);
    
    [assetsMapProVC didReceiveShareRepositoryString:url.absoluteString];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    //NSLog(@"%@",url);
    
    [assetsMapProVC didReceiveShareRepositoryString:url.absoluteString];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if (assetsMapProVC.isRecording){
        [assetsMapProVC.locationManagerForRecording startUpdatingLocation];
    }
    
    [[EverywhereCoreDataManager defaultManager] asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:^(NSInteger reverseGeocodeSucceedCountForThisTime, NSInteger reverseGeocodeSucceedCountForTotal, NSInteger totalPHAssetInfoCount) {
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ZhangBaoGuo.Everywhere" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Everywhere" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Everywhere.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
