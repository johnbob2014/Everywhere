//
//  UIAlertController+Assistant.h
//  Everywhere
//
//  Created by 张保国 on 16/7/23.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIAlertActionHandler)(UIAlertAction *action);

@interface UIAlertController (Assistant)
+ (UIAlertController *)informationAlertControllerWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertController *)okCancelAlertControllerWithTitle:(NSString *)title message:(NSString *)message okActionHandler:(void (^)(UIAlertAction *action))okActionHandler;
+ (UIAlertController *)okCancelAlertControllerWithTitle:(NSString *)title message:(NSString *)message okActionHandler:(void (^)(UIAlertAction *action))okActionHandler cancelActionHandler:(void (^)(UIAlertAction *action))cancelActionHandler;
+ (UIAlertController *)renameAlertControllerWithOKActionHandler:(void (^)(UIAlertAction *action))handler
                                textFieldConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
+ (UIAlertController *)singleTextFieldAlertControllerWithTitle:(NSString *)alertTitle
                                                       message:(NSString *)alertMessage
                                               okActionHandler:(void (^)(UIAlertAction *action))handler
                                 textFieldConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
@end
