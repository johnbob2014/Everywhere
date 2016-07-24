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
    UIBarButtonItem *leftBarButtonItem,*rightBarButtonItem;
    NSString *productTitle,*productDescription,*productPrice;
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
    
    leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leftButtonPressed:)];
    rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPressed:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self initPurchaseUI];
    
    [self startPurchaseOrRestore];
}

-(void)leftButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)rightButtonPressed:(id)sender{
    textView.text=@"";
    [self startProductRequest];
}

-(void)initPurchaseUI{
    textView=[[UITextView alloc]initForAutoLayout];
    [textView.layer setBorderColor:[UIColor grayColor].CGColor];
    textView.editable=NO;
    textView.selectable=NO;
    textView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:textView];
    [textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)startPurchaseOrRestore{
    leftBarButtonItem.enabled = NO;
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
        self.infoString=NSLocalizedString(@"-----Request product infomation-----\n-----Wait Please-----\n",@"-----向iTunes Store请求产品信息-----\n-----请耐心等待-----\n");
        
        NSSet *productSet=[NSSet setWithObject:self.productIDs[self.productIndex]];
        NSLog(@"查询产品ID : %@",self.productIDs[self.productIndex]);
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
    //NSLog(@"未识别的产品信息:%@",response.invalidProductIdentifiers);
    
    self.infoString=NSLocalizedString(@"-----Receive feedback from iTunes Store-----\n",@"-----收到iTunes Store的反馈信息-----\n");
    
    NSArray <SKProduct *> *products = response.products;
    
    NSLog(@"请求查询的产品个数: %lu\n",(unsigned long)[products count]);
                 
    if ([products count]>0) {
        SKProduct *product = products.firstObject;
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        productTitle = product.localizedTitle;
        productDescription = product.localizedDescription;
        productPrice = [NSString stringWithFormat:@"%@",product.price];
        
        self.infoString=[[NSString alloc]initWithFormat:@"\n-----%@-----\n%@\n-----%@-----\n%@\n-----%@-----\n%@\n\n",NSLocalizedString(@"Product Name",@"产品名称"),product.localizedTitle,NSLocalizedString(@"Product Description",@"产品描述信息"),product.localizedDescription,NSLocalizedString(@"Product Price",@"产品价格"),product.price];

        //发起购买请求
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        self.infoString=NSLocalizedString(@"-----Sned payment to iTunes Store-----\n",@"-----向iTunes Store发送交易请求-----\n");
        
    }
    else{
        self.infoString=NSLocalizedString(@"-----No such product in iTunes Store-----\n",@"-----iTunes Store没有相关产品信息-----\n");
        
        [request cancel];
    }
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSString *lst1=NSLocalizedString(@"-----Failed to request product infomation from iTunes Store-----\n",@"-----向iTunes Store请求产品信息失败-----\n");
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
    
    self.infoString=NSLocalizedString(@"-----Receive payment result from iTunes Store-----\n",@"-----收到iTunes Store反馈的交易结果-----\n");
    
    //NSLog(@"交易数量:%lu",(unsigned long)[transactions count]);
    if (self.transactionType == TransactionTypeRestore && transactions.count == 0) {
        self.infoString=NSLocalizedString(@"-----No Product that can be restored!-----\n",@"-----您没有可供恢复的项目！-----\n");
    }
    
    
    
    SKPaymentTransaction *transaction = transactions.firstObject;
    
    if (!transaction) {
        [self completeTransaction:nil succeeded:NO];
        return;
    }
    
    BOOL succeeded = NO;
    
    switch (transaction.transactionState) {
        case SKPaymentTransactionStatePurchased:
            //交易完成,调用自定义方法，提供相应内容、记录交易记录等
            NSLog(@"SKPaymentTransactionStatePurchased");
            succeeded = YES;
            break;
        case SKPaymentTransactionStateRestored:
            NSLog(@"SKPaymentTransactionStateRestored");
            succeeded = YES;
            break;
        case SKPaymentTransactionStateFailed:
            succeeded = NO;
            NSLog(@"SKPaymentTransactionStateFailed");
            break;
        case SKPaymentTransactionStateDeferred:
            NSLog(@"SKPaymentTransactionStateDeferred");
            return;
            break;
        case SKPaymentTransactionStatePurchasing:
            NSLog(@"SKPaymentTransactionStatePurchasing");
            return;
            break;
        default:
            break;
    }
    
    [self completeTransaction:transaction succeeded:succeeded];
    
}


-(void)completeTransaction:(SKPaymentTransaction *)transaction succeeded:(BOOL)succeeded{
    
    NSString *typeString = self.transactionType == TransactionTypePurchase ? NSLocalizedString(@"Purchase", @"购买") : NSLocalizedString(@"Restore", @"恢复");
    NSString *resultString = succeeded ? NSLocalizedString(@"Succeeded", @"成功") : NSLocalizedString(@"Failed", @"失败");
    [rightBarButtonItem setTitle:resultString];
    
    NSString *alertMessage = [NSString stringWithFormat:@"%@ %@ %@",typeString,productTitle,resultString];
    
    [self presentViewController:[UIAlertController infomationAlertControllerWithTitle:NSLocalizedString(@"Note", @"提示") message:alertMessage]
                       animated:YES completion:nil];
    
    if (succeeded) {
        self.infoString=[[NSString alloc]initWithFormat:NSLocalizedString(@"-----Succeeded-----",@"-----%@成功，请返回使用!-----\n"),typeString];
    }else{
        NSString *lst1=NSLocalizedString(@"-----Failed,please try again!-----",@"-----交易失败，请重新尝试-----");
        NSString *lst2=NSLocalizedString(@"Error",@"错误信息");
        self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@：%@-----\n\n",lst1,lst2,[self showTransactionErrorCode:transaction]];
        [rightBarButtonItem setTitle:NSLocalizedString(@"Try Again",@"重试")];
        rightBarButtonItem.enabled = YES;
    }
    
    leftBarButtonItem.enabled = YES;
    
    //关闭交易
    //[[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    
    if (self.inAppPurchaseCompletionHandler) self.inAppPurchaseCompletionHandler(succeeded,self.productIndex,self.transactionType);
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
    //NSLog(@"paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads");
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions{
    //NSLog(@"paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions");
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    //NSLog(@"paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue");
    //self.infoString=NSLocalizedString(@"-----iTunes Store恢复结束-----",@"-----iTunes Store恢复结束-----");
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSString *lst1=NSLocalizedString(@"-----Restore failed,try again please-----",@"-----iTunes Store恢复失败，请重新尝试-----");
    NSString *lst2=NSLocalizedString(@"Error",@"错误信息");
    self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@：%@-----\n",lst1,lst2,error.localizedDescription];
}

@end
