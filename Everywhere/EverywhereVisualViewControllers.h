//
//  EverywhereVisualViewControllers.h
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface MainVC : UIViewController

@end


@interface MapVC : UIViewController

@end


@interface CollectionListsTVC : UITableViewController
@end


@interface AssetCollectionsTVC : UITableViewController
@property (nonatomic,strong) PHCollectionList *collectionList;
@end

@interface PeriodAssetCollectionsTVC : UITableViewController
@end

@interface AssetsTVC : UITableViewController
@property (nonatomic,strong) PHAssetCollection *assetCollection;
@end


@interface AssetDetailVC : UIViewController
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;
@end

