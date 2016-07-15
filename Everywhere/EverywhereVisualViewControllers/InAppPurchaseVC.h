//
//  SettingVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

@import UIKit;

/*! @brief 交易类型:购买 或 恢复
 *
 */
enum TransactionType {
    TransactionTypePurchase  = 0,        /**< 购买    */
    TransactionTypeRestore = 1,        /**< 恢复      */
};

@interface InAppPurchaseVC : UIViewController
@property (assign,nonatomic) int productIndex;
@property (assign,nonatomic) enum TransactionType transactionType;
@end
