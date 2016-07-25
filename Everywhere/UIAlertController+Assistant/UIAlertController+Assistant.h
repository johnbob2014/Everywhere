//
//  UIAlertController+Assistant.h
//  Everywhere
//
//  Created by 张保国 on 16/7/23.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Assistant)
+ (UIAlertController *)infomationAlertControllerWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertController *)okCancelAlertControllerWithTitle:(NSString *)title message:(NSString *)message okHandler:(void (^)(UIAlertAction *action))okHandler;
+ (UIAlertController *)renameAlertControllerWithActionHandler:(void (^)(UIAlertAction *action))handler
                                textFieldConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@end
