//
//  SimpleImageBrowser.h
//  Everywhere
//
//  Created by BobZhang on 16/8/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleImageBrowser : UIViewController

/**
 *  初始化方法
 *
 *  @param imageArray UIImage数组
 *
 *  @return 实例
 */
- (instancetype)initWithImageArray:(NSArray <UIImage *> *)imageArray;

@end
