//
//  EverywhereVisualViewControllers.h
//  Everywhere
//
//  Created by 张保国 on 16/6/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController

@end

@interface MapVC : UIViewController

@end

@import Photos;

@interface CollectionListTVC : UITableViewController
//@property (nonatomic,strong) PHCollectionList * a;
@end

@interface AssetCollectionTVC : UITableViewController
@property (nonatomic,strong) PHCollectionList *collectionList;
@end

@interface AssetTVC : UITableViewController
@property (nonatomic,strong) PHAssetCollection *assetCollection;
@end