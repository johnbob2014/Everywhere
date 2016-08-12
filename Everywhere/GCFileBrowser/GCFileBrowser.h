//
//  GCFileBrowser.h
//  Everywhere
//
//  Created by BobZhang on 16/8/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCFileBrowser : UIViewController

@property (strong,nonatomic) NSString *directoryPath;

/**
 是否显示 文件交互控制器
 */
@property (assign,nonatomic) BOOL enableDocumentInteractionController;

/**
 是否显示 底部操作菜单
 */
@property (assign,nonatomic) BOOL enableActionMenu;

/**
 底部操作菜单 操作项 图片数组（普通状态）
 */
@property (strong,nonatomic) NSArray <UIImage *> *normalImageArray;

/**
 底部操作菜单 操作项 图片数组（高亮状态）
 */
@property (strong,nonatomic) NSArray <UIImage *> *highlightedImageArray;

@end
