//
//  UIAlertController+Assistant.m
//  Everywhere
//
//  Created by 张保国 on 16/7/23.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "UIAlertController+Assistant.h"

@implementation UIAlertController (Assistant)

+ (UIAlertController *)informationAlertControllerWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *iKnowAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"I Know",@"我知道了") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:iKnowAction];
    return alertController;
}

+ (UIAlertController *)okCancelAlertControllerWithTitle:(NSString *)title message:(NSString *)message okActionHandler:(void (^)(UIAlertAction *action))okActionHandler{
    return [UIAlertController okCancelAlertControllerWithTitle:title message:message okActionHandler:okActionHandler cancelActionHandler:nil];
}

+ (UIAlertController *)okCancelAlertControllerWithTitle:(NSString *)title message:(NSString *)message okActionHandler:(void (^)(UIAlertAction *action))okActionHandler cancelActionHandler:(void (^)(UIAlertAction *action))cancelActionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定") style:UIAlertActionStyleDefault handler:okActionHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:cancelActionHandler];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = okAction;
    
    return alertController;
}


+ (UIAlertController *)renameAlertControllerWithOKActionHandler:(void (^)(UIAlertAction *action))handler
                                textFieldConfigurationHandler:(void (^)(UITextField *textField))configurationHandler{
    
    NSString *alertTitle = NSLocalizedString(@"Rename", @"重命名");
    NSString *alertMessage = NSLocalizedString(@"Enter a new name", @"输入新名称");
    
    return [UIAlertController singleTextFieldAlertControllerWithTitle:alertTitle
                                                              message:alertMessage
                                                      okActionHandler:handler
                                        textFieldConfigurationHandler:configurationHandler];
    /*
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定")
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = okAction;
    
    [alertController addTextFieldWithConfigurationHandler:configurationHandler];
    return alertController;
    */
}

+ (UIAlertController *)singleTextFieldAlertControllerWithTitle:(NSString *)alertTitle
                                                       message:(NSString *)alertMessage
                                               okActionHandler:(void (^)(UIAlertAction *action))handler
                                 textFieldConfigurationHandler:(void (^)(UITextField *textField))configurationHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定")
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    if (iOS9) alertController.preferredAction = okAction;
    
    [alertController addTextFieldWithConfigurationHandler:configurationHandler];
    return alertController;
}

@end
