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
 *  @param imageArray 可以是NSData数组 或 UIImage数组
 *
 *  @return 实例
 */
- (instancetype)initWithImageArray:(NSArray *)imageArray;

@end
