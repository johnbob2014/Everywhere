//
//  EverywhereAppDelegate.m
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#define DEBUGMODE 1

#import "EverywhereAppDelegate.h"

#import "EverywhereCoreDataManager.h"
#import "EverywhereSettingManager.h"
#import "EverywhereFootprintsRepositoryManager.h"

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
    
#warning Fix Before Submit
    [EverywhereSettingManager defaultManager].hasPurchasedRecord = YES;//NO;//
    [EverywhereSettingManager defaultManager].hasPurchasedShare = YES;//NO;//
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    assetsMapProVC = [AssetsMapProVC new];
    self.window.rootViewController = assetsMapProVC;
    self.window.tintColor = [EverywhereSettingManager defaultManager].baseTintColor;
    [self.window makeKeyAndVisible];
    
    // 需要访问网络，在后台进行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //向微信注册id
        BOOL wx=[WXApi registerApp:@"wxa1b9c5632d24039a"];
        if(DEBUGMODE) NSLog(@"WeChat Rigister：%@",wx? @"Succeeded" : @"Failed");
        
        //从网络更新应用数据
        [EverywhereSettingManager updateAppInfoAndAppQRCodeImageData];
    });
    
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if ([EverywhereSettingManager defaultManager].praiseCount != 0) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [application registerUserNotificationSettings:
             [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }

    }
    
    return YES;
}

// iOS9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    //NSLog(@"%@",url);
    NSLog(@"options : %@",options);
    [self didReceiveFootprintsRepositoryString:url.absoluteString];
    return YES;
}

// iOS8
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"openURL : %@",url);
    
    [self didReceiveFootprintsRepositoryString:url.absoluteString];
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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path_Inbox]) return;
    
    NSError *readContentsError;
    NSArray <NSString *> *fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Path_Inbox error:&readContentsError];
    
    if (!fileNameArray){
        NSLog(@"readContentsError : %@",readContentsError.localizedDescription);
        return;
    }
    
    if (fileNameArray.count == 0){
        NSLog(@"No file in Inbox!");
        return;
    }else if (fileNameArray.count == 1){
        
    }else if (fileNameArray.count > 1){
        NSLog(@"Inbox file count > 1!");
    }
    
    NSString *filePath = [Path_Inbox stringByAppendingPathComponent:fileNameArray.firstObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return;
    
    EverywhereFootprintsRepository *footprintsRepository = nil;
    NSString *pathExtension = [[filePath pathExtension] lowercaseString];
    
    if ([pathExtension isEqualToString:@"abfr"]){
        footprintsRepository = [EverywhereFootprintsRepository importFromABFRFile:filePath];
    }else if ([pathExtension isEqualToString:@"gpx"]){
        footprintsRepository = [EverywhereFootprintsRepository importFromGPXFile:filePath];
    }else{
        
    }
    
    [assetsMapProVC didReceiveFootprintsRepository:footprintsRepository];
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    
    /*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray <EverywhereFootprintsRepository *> *importedArray = [EverywhereFootprintsRepositoryManager importFootprintsRepositoryFromABFRFilesAtPath:Path_Inbox];
        
        if (importedArray && importedArray.count > 0){
            NSLog(@"收到足迹包文件数 : %lu",(unsigned long)importedArray.count);
            dispatch_async(dispatch_get_main_queue(),^{
                [assetsMapProVC didReceiveFootprintsRepository:importedArray.firstObject];
            });
        }
        
        
    });
    
    NSError *removeError;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:Path_Inbox error:&removeError];
    if (!success){
        NSLog(@"Error removing inbox: %@", removeError.localizedFailureReason);
    }
     */
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    // 程序退出时保存记录的足迹
    [assetsMapProVC intelligentlySaveRecordedFootprintAnnotationsAndClearCatche];
    
    [self saveContext];
}

- (void)didReceiveFootprintsRepositoryString:(NSString *)receivedString{
    NSString *footprintsRepositoryString = nil;
    //CLLocationDistance sharedRadius = 0;
    
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",WXAppID];
    
    if (![receivedString containsString:headerString]){
        //NSLog(@"接收到的字符串无法解析！");
        return;
    }
    
    footprintsRepositoryString = [receivedString stringByReplacingOccurrencesOfString:headerString withString:@""];
    // For iOS9
    footprintsRepositoryString = [footprintsRepositoryString stringByReplacingOccurrencesOfString:@"%0D%0A" withString:@"\n"];
    // For iOS8
    footprintsRepositoryString = [footprintsRepositoryString stringByReplacingOccurrencesOfString:@"%20" withString:@"\n"];
    
    //if (DEBUGMODE) NSLog(@"\n%@",footprintsRepositoryString);
    
    NSData *footprintsRepositoryData = [[NSData alloc] initWithBase64EncodedString:footprintsRepositoryString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    // 获取接收到的分享对象
    EverywhereFootprintsRepository *footprintsRepository = nil;
    
    // 解析数据可能出错
    @try {
        footprintsRepository = [NSKeyedUnarchiver unarchiveObjectWithData:footprintsRepositoryData];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    [assetsMapProVC didReceiveFootprintsRepository:footprintsRepository];

}
/*
+ (void)checkAndProcessInbox{
    NSError *error;
    BOOL success;
    BOOL isDir;
    NSFileManager *defaultFM = [NSFileManager defaultManager];
    
    // Does the inbox folder exist? If not, we're done here.
    if (![defaultFM fileExistsAtPath:Path_Inbox isDirectory:&isDir]) return;
    
    // It exists. Is it a dir?
    if (!isDir){
        // 如果 Inbox 不是文件夹而是一个文件，那么删除这个文件
        if (![defaultFM removeItemAtPath:Path_Inbox error:&error]){
            // 如果删除失败，返回
            NSLog(@"Error deleting Inbox file (not directory): %@", error.localizedFailureReason);
            return;
        }
    }
    
    NSArray *fileNameArray = [defaultFM contentsOfDirectoryAtPath:Path_Inbox error:&error];
    if (!fileNameArray) {
        NSLog(@"Error reading contents of Inbox: %@", error.localizedFailureReason);
        return;
    }
    
    NSUInteger initialCount = fileNameArray.count;
    
    for (NSString *fileName in fileNameArray) {
        NSString *sourcePath = [Path_Inbox stringByAppendingPathComponent:fileName];
        NSString *destPath = [Path_Documents stringByAppendingPathComponent:fileName];
        
        if ([defaultFM fileExistsAtPath:destPath]) {
            destPath = nil;
        }
        
        if (!destPath) {
            NSLog(@"Error. File name conflict could not be resolved for %@. Bailing", fileName);
            continue;
        }
        
        if (![defaultFM moveItemAtPath:sourcePath toPath:destPath error:&error]) {
            NSLog(@"Error moving file %@ to Documents from Inbox: %@", fileName, error.localizedFailureReason);
            continue;
        }
    }
    
    // Inbox should now be empty
    fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Path_Inbox error:&error];
    if (!fileNameArray)
    {
        NSLog(@"Error reading contents of Inbox: %@", error.localizedFailureReason);
        return;
    }
    
    if (fileNameArray.count)
    {
        NSLog(@"Error clearing out inbox. %lu items still remain", (unsigned long)fileNameArray.count);
        return;
    }
    
    // Remove the inbox
    success = [[NSFileManager defaultManager] removeItemAtPath:Path_Inbox error:&error];
    if (!success)
    {
        NSLog(@"Error removing inbox: %@", error.localizedFailureReason);
        return;
    }
    
    NSLog(@"Moved %lu items from the Inbox to the Documents folder", (unsigned long)initialCount);
}
*/

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
