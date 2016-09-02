//
//  AssetDetailVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/6.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereAnnotation.h"

@interface AssetDetailVC : UIViewController

/**
 *  要显示的 PHAsset localIndentifier 数组
 */
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;

/**
 *  是否显示序号标签
 */
@property (assign,nonatomic) BOOL showIndexLabel;

/**
 *  是否上滑退出
 */
@property (assign,nonatomic) BOOL swipeUpToQuit;

@end
