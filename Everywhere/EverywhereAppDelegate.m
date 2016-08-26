//
//  EverywhereAppDelegate.m
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "EverywhereAppDelegate.h"

#import "EverywhereCoreDataManager.h"
#import "EverywhereSettingManager.h"
#import "EverywhereFootprintsRepository.h"

#import "AssetsMapProVC.h"

#import "WXApi.h"

@interface EverywhereAppDelegate () <WXApiDelegate>

@end

@implementation EverywhereAppDelegate{
    AssetsMapProVC *assetsMapProVC;
    EverywhereSettingManager *settingManager;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    
    settingManager = [EverywhereSettingManager defaultManager];
    
#warning Fix Before Submit
    settingManager.hasPurchasedRecordAndEdit = NO;
    settingManager.hasPurchasedShareAndBrowse = NO;
    settingManager.hasPurchasedImportAndExport = NO;

    settingManager.hasPurchasedRecordAndEdit = YES;
    settingManager.hasPurchasedShareAndBrowse = YES;
    settingManager.hasPurchasedImportAndExport = YES;
    
    // 首次启动
    if(!settingManager.everLaunched){
        settingManager.everLaunched = YES;
        
        settingManager.trialCountForMFR = 10;
        settingManager.trialCountForGPX = 10;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    assetsMapProVC = [AssetsMapProVC new];
    self.window.rootViewController = assetsMapProVC;
    self.window.tintColor = settingManager.baseTintColor;
    [self.window makeKeyAndVisible];
    
    // 需要访问网络，在后台进行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //向微信注册id
        BOOL wx=[WXApi registerApp:settingManager.wxAppID];
        if(DEBUGMODE) NSLog(@"WeChat Rigister：%@",wx? @"Succeeded" : @"Failed");
        
        //从网络更新应用数据
        //[EverywhereSettingManager updateAppInfoAndAppQRCodeImageData];
    });
    
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if (settingManager.praiseCount != 0) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [application registerUserNotificationSettings:
             [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }

    }
    
    // 设置 SVProgressHUD 样式
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    
    return YES;
}

// iOS9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    //if(DEBUGMODE) NSLog(@"%@",url);
    if(DEBUGMODE) NSLog(@"options : %@",options);
    [self didReceiveFootprintsRepositoryString:url.absoluteString];
    return YES;
}

// iOS8
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    if(DEBUGMODE) NSLog(@"openURL : %@",url);
    
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
    
    [EverywhereCoreDataManager asyncUpdatePlacemarkForPHAssetInfoWithCompletionBlock:^(NSInteger reverseGeocodeSucceedCountForThisTime, NSInteger reverseGeocodeSucceedCountForTotal, NSInteger totalPHAssetInfoCount) {
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self checkInbox];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if(DEBUGMODE) NSLog(@"%@",NSStringFromSelector(_cmd));
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    // 程序退出时保存记录的足迹
    [assetsMapProVC intelligentlySaveRecordedFootprintAnnotationsAndClearCatche];
    
    [self saveContext];
}

- (void)checkInbox{
    NSString *Path_Inbox = [NSURL inboxURL].path;
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path_Inbox]) return;
    
    NSError *readContentsError;
    NSArray <NSString *> *fileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:Path_Inbox error:&readContentsError];
    
    if (!fileNameArray){
        if(DEBUGMODE) NSLog(@"readContentsError : %@",readContentsError.localizedDescription);
        return;
    }
    
    if (fileNameArray.count == 0){
        return;
    }else if (fileNameArray.count == 1){
        if(DEBUGMODE) NSLog(@"接收到1个文件");
    }else if (fileNameArray.count > 1){
        if(DEBUGMODE) NSLog(@"接收到多个文件，本次只处理1个！");
    }
    
    NSString *fileName = fileNameArray.firstObject;
    NSString *filePath = [Path_Inbox stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) return;
    
    /*
     // 移动到接收文件夹的代码，勿删！！！
    NSString *receivedDirectoryPath = [Path_Documents stringByAppendingPathComponent:@"Received Files"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:receivedDirectoryPath isDirectory:NULL]){
        if (![[NSFileManager defaultManager] createDirectoryAtPath:receivedDirectoryPath withIntermediateDirectories:NO attributes:nil error:NULL]){
            if(DEBUGMODE) NSLog(@"创建接收文件夹失败！");
            return;
        }
    }
    
    NSString *newFilePath = [receivedDirectoryPath stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath isDirectory:NULL]){
        if(DEBUGMODE) NSLog(@"接收文件夹中有同名文件，自动重新命名！");
        NSString *fileBase = [fileName stringByReplacingOccurrencesOfString:[@"." stringByAppendingString:[fileName pathExtension]] withString:@""];
        NSString *newFileName = [NSString stringWithFormat:@"%@-%.0f.%@",fileBase,[[NSDate date] timeIntervalSinceReferenceDate]*1000,[fileName pathExtension]];
        newFilePath = [receivedDirectoryPath stringByAppendingPathComponent:newFileName];
    }
    
    NSError *moveError;
    if (![[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newFilePath error:&moveError]){
        if(DEBUGMODE) NSLog(@"移动接收的文件到接收文件夹失败！");
        return;
    }
    */
    
    EverywhereFootprintsRepository *footprintsRepository = nil;
    NSString *pathExtension = [[filePath pathExtension] lowercaseString];
    
    if ([pathExtension isEqualToString:@"mfr"]){
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Receiving data...", @"接收数据中...")];
        footprintsRepository = [EverywhereFootprintsRepository importFromMFRFile:filePath];
        [SVProgressHUD dismiss];
    }else if ([pathExtension isEqualToString:@"gpx"]){
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Receiving data...", @"接收数据中...")];
        footprintsRepository = [EverywhereFootprintsRepository importFromGPXFile:filePath];
        [SVProgressHUD dismiss];
    }else{
        [assetsMapProVC dismissViewControllerAnimated:YES completion:nil];
        [assetsMapProVC presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Unsupported file types.\nPlease import MFR or GPX files.", @"文件格式不支持。\n请导入MFR或GPX文件。")]
                                     animated:YES
                                   completion:nil];
        return;
    }
    
    if (!footprintsRepository){
        [assetsMapProVC dismissViewControllerAnimated:YES completion:nil];
        [assetsMapProVC presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:NSLocalizedString(@"Parse file failed!", @"解析文件失败！")]
                                     animated:YES
                                   completion:nil];
        return;
    }
    
    [assetsMapProVC didReceiveFootprintsRepository:footprintsRepository];
    
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
}

- (void)didReceiveFootprintsRepositoryString:(NSString *)receivedString{
    NSString *footprintsRepositoryString = nil;
    //CLLocationDistance sharedRadius = 0;
    
    NSString *headerString = [NSString stringWithFormat:@"%@://AlbumMaps/",settingManager.wxAppID];
    
    if (![receivedString containsString:headerString]){
        //if(DEBUGMODE) NSLog(@"接收到的字符串无法解析！");
        return;
    }
    
    footprintsRepositoryString = [receivedString stringByReplacingOccurrencesOfString:headerString withString:@""];
    // For iOS9
    footprintsRepositoryString = [footprintsRepositoryString stringByReplacingOccurrencesOfString:@"%0D%0A" withString:@"\n"];
    // For iOS8
    footprintsRepositoryString = [footprintsRepositoryString stringByReplacingOccurrencesOfString:@"%20" withString:@"\n"];
    
    //if (DEBUGMODE) if(DEBUGMODE) NSLog(@"\n%@",footprintsRepositoryString);
    
    // 获取接收到的分享对象
    EverywhereFootprintsRepository *footprintsRepository = nil;
    
    //footprintsRepository = [NSKeyedUnarchiver unarchiveObjectWithData:footprintsRepositoryData];
    
    //#warning why?
    
    // 解析数据可能出错
    @try {
        NSData *footprintsRepositoryData = [[NSData alloc] initWithBase64EncodedString:footprintsRepositoryString
                                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
        footprintsRepository = [NSKeyedUnarchiver unarchiveObjectWithData:footprintsRepositoryData];
    } @catch (NSException *exception) {
        if(DEBUGMODE) NSLog(@"解析微信分享数据出错!");
        if(DEBUGMODE) NSLog(@"exception :\n%@",exception);
        return;
    } @finally {
        if (footprintsRepository) [assetsMapProVC didReceiveFootprintsRepository:footprintsRepository];
    }
    
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
    NSURL *storeURL = [[NSURL libraryURL] URLByAppendingPathComponent:@"Everywhere.sqlite"];
    if(DEBUGMODE) NSLog(@"storeURL : %@",storeURL.absoluteString);
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // 数据轻量迁移
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                              NSInferMappingModelAutomaticallyOption:@(YES)};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        if(DEBUGMODE) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
            if(DEBUGMODE) NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
