//
//  AssetsMapProVC.h
//  Everywhere
//
//  Created by 张保国 on 16/7/3.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;
@class EverywhereFootprintsRepository;

@interface AssetsMapProVC : UIViewController

@property (strong,nonatomic) CLLocationManager *locationManagerForRecording;

@property (assign,nonatomic) BOOL isRecording;

- (void)didReceiveFootprintsRepository:(EverywhereFootprintsRepository *)footprintsRepository;

- (void)intelligentlySaveRecordedFootprintAnnotationsAndClearCatche;

@end
