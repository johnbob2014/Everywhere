//
//  SettingVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "InAppPurchaseVC.h"
#import <StoreKit/StoreKit.h>


@interface InAppPurchaseVC () <SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (copy,nonatomic) NSString *infoString;
@end

@implementation InAppPurchaseVC{
    UITextView *textView;
    UIBarButtonItem *secondRightBarButtonItem,*rightBarButtonItem;//
    
    NSMutableArray <SKPayment*> *addedPaymentMA;
    //NSString *productTitle,*productDescription,*productPrice;
}

#pragma mark - Setter

-(void)setInfoString:(NSString *)infoString{
    _infoString=infoString;
    textView.text=[textView.text stringByAppendingString:infoString];
}

#pragma mark - Life Cycle

-(void)viewDidDisappear:(BOOL)animated{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //监听结果
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    NSString *title = self.transactionType == TransactionTypePurchase ? NSLocalizedString(@"Purchase",@"购买") : NSLocalizedString(@"Restore",@"恢复");
    self.title = title;
    
    secondRightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leftButtonPressed:)];
    rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPressed:)];
    //self.navigationItem.secondRightBarButtonItem = secondRightBarButtonItem;
    self.navigationItem.rightBarButtonItems = @[rightBarButtonItem,secondRightBarButtonItem];
    
    [self initPurchaseUI];
    
    [self startPurchaseOrRestore];
}

-(void)leftButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    if (self.navigationController) [self.navigationController popViewControllerAnimated:YES];
    else [self dismissViewControllerAnimated:YES completion:nil];
    */
}

-(void)rightButtonPressed:(id)sender{
    textView.text=@"";
    [self startProductRequest];
}

-(void)initPurchaseUI{
    textView=[[UITextView alloc]initForAutoLayout];
    textView.font = [UIFont bodyFontWithSizeMultiplier:1.0];
    [textView.layer setBorderColor:[UIColor grayColor].CGColor];
    textView.editable=NO;
    textView.selectable=NO;
    textView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:textView];
    [textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)startPurchaseOrRestore{
    secondRightBarButtonItem.enabled = NO;
    rightBarButtonItem.enabled = NO;
    
    //购买还是恢复
    if (self.transactionType == TransactionTypePurchase) {
        [rightBarButtonItem setTitle:NSLocalizedString(@"Purchasing...",@"正在购买...")];
        [self startProductRequest];
    }else{
        [rightBarButtonItem setTitle:NSLocalizedString(@"Restoring...",@"正在恢复...")];
        self.infoString=NSLocalizedString(@"-----Request to restore product-----\n-----Wait Please-----\n",@"-----向iTunes Store请求恢复产品-----\n-----请耐心等待-----\n");
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }

}

//自定义方法，发出产品查询请求
-(void)startProductRequest{
    if ([SKPaymentQueue canMakePayments]) {
        //允许程序内付费购买
        self.infoString=NSLocalizedString(@"-----Request product information-----\n-----Wait Please-----\n",@"-----向iTunes Store请求产品信息-----\n-----请耐心等待-----\n");
        
        NSMutableSet *productSet = [NSMutableSet new];
        for (NSNumber *indexNumber in self.productIndexArray) {
            [productSet addObject:self.productIDArray[indexNumber.integerValue]];
        }
        
        //NSSet *productSet=[NSSet setWithObject:self.productIDArray[self.productIndex]];
        //if(DEBUGMODE) NSLog(@"查询产品ID : %@",self.productIDArray[self.productIndex]);
        SKProductsRequest *productRequest=[[SKProductsRequest alloc]initWithProductIdentifiers:productSet];
        productRequest.delegate=self;
        [productRequest start];
    }
    else{
        //不允许程序内付费购买
        self.infoString=NSLocalizedString(@"-----InAppPurchase is denied,please turn on the function in iOS settings-----\n",@"-----不允许程序内付费购买，请到“设置”中打开-----\n");
    }

}

#pragma mark - SKProductsRequestDelegate

//代理方法：收到查询的产品信息
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    //if(DEBUGMODE) NSLog(@"未识别的产品信息:%@",response.invalidProductIdentifiers);
    
    self.infoString=NSLocalizedString(@"-----Receive feedback from iTunes Store-----\n",@"-----收到iTunes Store的反馈信息-----\n");
    
    NSArray <SKProduct *> *products = response.products;
    
    if(DEBUGMODE) NSLog(@"请求查询的产品个数: %lu\n",(unsigned long)[products count]);
                 
    if ([products count]>0) {
        //SKProduct *product = products.firstObject;
        addedPaymentMA = [NSMutableArray new];
        for (SKProduct *product in products) {
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            
//            NSString *productTitle = product.localizedTitle;
//            NSString *productDescription = product.localizedDescription;
//            NSString *productPrice = [NSString stringWithFormat:@"%@",product.price];
            
            self.infoString=[[NSString alloc]initWithFormat:@"\n-----%@-----\n%@\n-----%@-----\n%@\n-----%@-----\n%@\n\n",NSLocalizedString(@"Product Name",@"产品名称"),product.localizedTitle,NSLocalizedString(@"Product Description",@"产品描述信息"),product.localizedDescription,NSLocalizedString(@"Product Price",@"产品价格"),product.price];
            
            //发起购买请求
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            self.infoString=NSLocalizedString(@"-----Sned payment to iTunes Store-----\n",@"-----向iTunes Store发送交易请求-----\n");
            
            [addedPaymentMA addObject:payment];
        }
        
    }
    else{
        self.infoString=NSLocalizedString(@"-----No such product in iTunes Store-----\n",@"-----iTunes Store没有相关产品信息-----\n");
        
        [request cancel];
    }
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSString *lst1=NSLocalizedString(@"-----Failed to request product information from iTunes Store-----\n",@"-----向iTunes Store请求产品信息失败-----\n");
    NSString *lst2=NSLocalizedString(@"Error : ",@"错误信息 : ");
    self.infoString=[[NSString alloc]initWithFormat:@"%@%@%@\n",lst1,lst2,error.localizedDescription];
    
}

-(void)requestDidFinish:(SKRequest *)request{
    //self.infoString=NSLocalizedString(@"-----iTunes Store反馈信息结束-----\n",@"-----iTunes Store反馈信息结束-----\n");
}

#pragma mark - SKPaymentTransactionObserver Protocol

//收到交易结果
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    //交易结果<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
    //监听购买结果
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    /*
    if (!productTitle) {
        //secondRightBarButtonItem.enabled = YES;
        //rightBarButtonItem.enabled = YES;
        return;
    }
*/
    
    self.infoString=NSLocalizedString(@"-----Receive payment result from iTunes Store-----\n",@"-----收到iTunes Store反馈的交易结果-----\n");
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        if(DEBUGMODE) NSLog(@"transaction.payment.productIdentifier :\n%@",transaction.payment.productIdentifier);
        
        if (![addedPaymentMA containsObject:transaction.payment]) return;
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                //交易完成,调用自定义方法，提供相应内容、记录交易记录等
                if(DEBUGMODE) NSLog(@"SKPaymentTransactionStatePurchased");
                [self completeTransaction:transaction succeeded:YES transactionType:TransactionTypePurchase];
                break;
            case SKPaymentTransactionStateRestored:
                if(DEBUGMODE) NSLog(@"SKPaymentTransactionStateRestored");
                [self completeTransaction:transaction succeeded:YES transactionType:TransactionTypeRestore];
                break;
            case SKPaymentTransactionStateFailed:
                [self completeTransaction:transaction succeeded:NO transactionType:self.transactionType];
                if(DEBUGMODE) NSLog(@"SKPaymentTransactionStateFailed");
                break;
            case SKPaymentTransactionStateDeferred:
                if(DEBUGMODE) NSLog(@"SKPaymentTransactionStateDeferred");
                continue;
                break;
            case SKPaymentTransactionStatePurchasing:
                if(DEBUGMODE) NSLog(@"SKPaymentTransactionStatePurchasing");
                continue;
                break;
            default:
                break;
        }
        
        [NSThread sleepForTimeInterval:1.0];
    }
    
    secondRightBarButtonItem.enabled = YES;
    rightBarButtonItem.enabled = YES;
}


-(void)completeTransaction:(SKPaymentTransaction *)transaction succeeded:(BOOL)succeeded transactionType:(enum TransactionType)transactionType{
    
    NSString *productIdentifier = transaction.payment.productIdentifier;
    NSInteger productIndex = [self.productIDArray indexOfObject:productIdentifier];
    
    NSString *typeString = transactionType == TransactionTypePurchase ? NSLocalizedString(@"Purchase", @"购买") : NSLocalizedString(@"Restore", @"恢复");
    NSString *resultString = succeeded ? NSLocalizedString(@"Succeeded", @"成功") : NSLocalizedString(@"Failed", @"失败");
    [rightBarButtonItem setTitle:resultString];
    
    //NSString *alertMessage = [NSString stringWithFormat:@"%@ %@ %@",typeString,productIdentifier,resultString];
    NSString *alertMessage = [NSString stringWithFormat:@"%@%@",typeString,resultString];
    //if (productIdentifier)
        [self presentViewController:[UIAlertController informationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:alertMessage]
                       animated:YES completion:nil];
    
    if (succeeded) {
        self.infoString=[[NSString alloc]initWithFormat:NSLocalizedString(@"-----%@ Succeeded-----",@"-----%@成功，请返回使用!-----\n"),typeString];
    }else{
        NSString *lst1=NSLocalizedString(@"-----Failed,please try again!-----",@"-----交易失败，请重新尝试-----");
        NSString *lst2=NSLocalizedString(@"Error",@"错误信息");
        self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@：%@-----\n\n",lst1,lst2,[self showTransactionErrorCode:transaction]];
        [rightBarButtonItem setTitle:NSLocalizedString(@"Try Again",@"重试")];
        rightBarButtonItem.enabled = YES;
    }
    
    secondRightBarButtonItem.enabled = YES;
    
    //关闭交易
    //[[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    
    if (self.inAppPurchaseCompletionHandler)
        self.inAppPurchaseCompletionHandler(transactionType,productIndex,succeeded);
}

-(NSString *)showTransactionErrorCode:(SKPaymentTransaction *)transaction{
    NSString *code=[NSString new];
    switch (transaction.error.code) {
        case SKErrorPaymentCancelled:
            code=NSLocalizedString(@"Cancelled",@"用户取消");
            break;
        case SKErrorPaymentNotAllowed:
            code=NSLocalizedString(@"NotAllowed",@"用户不允许购买");
            break;
        case SKErrorPaymentInvalid:
            code=NSLocalizedString(@"PaymentInvalid",@"参数未识别");
            break;
        case SKErrorStoreProductNotAvailable:
            code=NSLocalizedString(@"ProductNotAvailable",@"没有相关产品信息");
            break;
        case SKErrorClientInvalid:
            code=NSLocalizedString(@"ClientInvalid",@"客户端禁止购买");
            break;
        case SKErrorUnknown:
            code=NSLocalizedString(@"Unknown",@"未知错误");
            break;
        default:
            break;
    }
    return code;
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads{
    //if(DEBUGMODE) NSLog(@"paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads");
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
    //if(DEBUGMODE) NSLog(@"paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions");
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    //if(DEBUGMODE) NSLog(@"paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue");
    //self.infoString=NSLocalizedString(@"-----iTunes Store恢复结束-----",@"-----iTunes Store恢复结束-----");
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSString *lst1=NSLocalizedString(@"-----Restore failed,try again please-----",@"-----iTunes Store恢复失败，请重新尝试-----");
    NSString *lst2=NSLocalizedString(@"Error",@"错误信息");
    self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@ ：%@-----\n",lst1,lst2,error.localizedDescription];
    
    secondRightBarButtonItem.enabled = YES;
    rightBarButtonItem.enabled = YES;
    
    [rightBarButtonItem setTitle:NSLocalizedString(@"Try Again",@"重试")];
}

@end
