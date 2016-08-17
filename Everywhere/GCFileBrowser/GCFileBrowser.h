//
//  GCFileBrowser.h
//  Everywhere
//
//  Created by BobZhang on 16/8/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  文件浏览器
 *  版本v1.0.0
 *  作者 : BobZhang
 */
@interface GCFileBrowser : UIViewController

/**
 *  目录路径
 */
@property (strong,nonatomic) NSString *directoryPath;

/**
 *  是否显示 文件交互控制器
 */
@property (assign,nonatomic) BOOL enableDocumentInteractionController;

/**
 *  是否显示 底部操作菜单
 */
@property (assign,nonatomic) BOOL enableActionMenu;


@end
