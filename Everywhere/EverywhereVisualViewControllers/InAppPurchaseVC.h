//
//  SettingVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

@import UIKit;

/**
 交易类型:购买 或 恢复
 */
enum TransactionType {
    TransactionTypePurchase  = 0,        /**< 购买    */
    TransactionTypeRestore = 1,        /**< 恢复      */
};

typedef void(^InAppPurchaseCompletionHandler)(enum TransactionType transactionType,NSInteger productIndex,BOOL succeeded);

@interface InAppPurchaseVC : UIViewController

/**
 *  交易类型
 */
@property (assign,nonatomic) enum TransactionType transactionType;

/**
 *  全部产品ID数组
 */
@property (strong,nonatomic) NSArray <NSString *> *productIDArray;

/**
 *  要购买或恢复的 产品序号数组
 */
@property (strong,nonatomic) NSArray <NSNumber *> *productIndexArray;

/**
 *  购买完成后调用的block，每个产品调用一次
 */
@property (copy,nonatomic) InAppPurchaseCompletionHandler inAppPurchaseCompletionHandler;

@end
