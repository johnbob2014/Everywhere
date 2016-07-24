//
//  UIAlertController+Assistant.m
//  Everywhere
//
//  Created by 张保国 on 16/7/23.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "UIAlertController+Assistant.h"

@implementation UIAlertController (Assistant)

+ (UIAlertController *)infomationAlertControllerWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *iKnowAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"I Konw",@"我知道了") style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:iKnowAction];
    return alertController;
}

+ (UIAlertController *)okCancelAlertControllerWithTitle:(NSString *)title message:(NSString *)message okHandler:(void (^)(UIAlertAction *action))okHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定") style:UIAlertActionStyleDefault handler:okHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    return alertController;
}

+ (UIAlertController *)renameAlertControllerWithHandler:(void (^)(UIAlertAction *action))handler{
    
    NSString *alertTitle = NSLocalizedString(@"Rename", @"更名");
    NSString *alertMessage = NSLocalizedString(@"Enter a new name", @"输入新名称");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",@"确定")
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",@"取消") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    return alertController;
}

@end
