//
//  SettingVC.m
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "InAppPurchaseVC.h"
#import <StoreKit/StoreKit.h>

//#define ProductID_ShareFunctionAndBrowserMode @"com.ZhangBaoGuo.AlbumMaps.ShareFunctionAndBrowserMode"
//#define ProductID_RecordFuntionAndRecordMode @"com.ZhangBaoGuo.AlbumMaps.RecordFuntionAndRecordMode"

@interface InAppPurchaseVC () <SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property (strong,nonatomic) UITextView *textView;
@property (copy,nonatomic) NSString *infoString;
@property (strong,nonatomic) UIBarButtonItem *leftBarButtonItem;
@property (strong,nonatomic) UIBarButtonItem *rightBarButtonItem;
@end

@implementation InAppPurchaseVC

#pragma mark - User
-(void)leftButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)rightButtonPressed:(id)sender{
    self.textView.text=@"";
    [self startProductRequest];
}

-(void)setInfoString:(NSString *)infoString{
    _infoString=infoString;
    self.textView.text=[self.textView.text stringByAppendingString:infoString];
}

#pragma mark - init
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = self.transactionType == TransactionTypePurchase ? NSLocalizedString(@"Purchase",@"购买") : NSLocalizedString(@"Restore",@"恢复");
    self.title = title;
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(leftButtonPressed:)];
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
    [self initPurchaseUI];
    
    //监听结果
    [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    
    //购买还是恢复
    switch (_transactionType) {
        case TransactionTypePurchase:
            [self.rightBarButtonItem setTitle:NSLocalizedString(@"Purchasing...",@"正在购买...")];
            [self startProductRequest];
            break;
        case TransactionTypeRestore:
            [self.rightBarButtonItem setTitle:NSLocalizedString(@"Restoring...",@"正在恢复...")];
            //self.infoString=NSLocalizedString(@"-----向iTunes Store请求恢复产品-----\n-----请耐心等待-----\n",@"-----向iTunes Store请求恢复产品-----\n-----请耐心等待-----\n");
            
            [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
            break;
        default:
            break;
    }
}

-(void)initPurchaseUI{
    self.textView=[[UITextView alloc]initForAutoLayout];
    [self.textView.layer setBorderColor:[UIColor grayColor].CGColor];
    self.textView.editable=NO;
    self.textView.selectable=NO;
    self.textView.translatesAutoresizingMaskIntoConstraints=NO;
    [self.view addSubview:self.textView];
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

-(void)viewDidDisappear:(BOOL)animated{
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
}

#pragma - Custom Methods

//发出产品请求
-(void)startProductRequest{
    if ([SKPaymentQueue canMakePayments]) {
        //允许程序内付费购买
        self.infoString=NSLocalizedString(@"-----Request Product Infomation...-----\n",@"-----向iTunes Store请求产品信息-----\n-----请耐心等待-----\n");
        
        /*
        NSString *ProductID=nil;
        switch (self.productIndex) {
            case 0:
                ProductID = ProductID_ShareFunctionAndBrowserMode;
                break;
                
            case 1:
                ProductID = ProductID_RecordFuntionAndRecordMode;
                break;
                
            case 2:
                //ProductID=ProductID_1200;
                break;
                
            case 3:
                //ProductID=ProductID_1800;
                break;
                
            default:
                break;
        }
        */
        
        NSSet *productSet=[NSSet setWithObject:self.productIDs[self.productIndex]];
        SKProductsRequest *productRequest=[[SKProductsRequest alloc]initWithProductIdentifiers:productSet];
        productRequest.delegate=self;
        [productRequest start];
    }
    else{
        //NSLog(@"不允许程序内付费购买");
        self.infoString=NSLocalizedString(@"-----InAppPurchase is denied,please turn on the function in iOS settings-----\n",@"-----不允许程序内付费购买，请到“设置”中打开-----\n");
        
    }

}

#pragma - Delegate
//代理方法：收到产品信息
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    //NSLog(@"未识别的产品信息:%@",response.invalidProductIdentifiers);
    
    NSArray *products=response.products;
    self.infoString=NSLocalizedString(@"-----收到iTunes Store的反馈信息-----\n",@"-----收到iTunes Store的反馈信息-----\n");
    
    //NSLog(@"能识别的产品种类数: %lu\n",(unsigned long)[products count]);
                 
    if ([products count]>0) {
        SKProduct *product=products[0];
        SKPayment *payment=[SKPayment paymentWithProduct:product];
        
        //发起购买请求
        [[SKPaymentQueue defaultQueue]addPayment:payment];
        
        NSString *productName=NSLocalizedString(@"Product Name",@"产品名称");
        NSString *productDescription=NSLocalizedString(@"Product Description",@"产品描述信息");
        NSString *productPrice=NSLocalizedString(@"Product Price",@"产品价格");
        
        self.infoString=[[NSString alloc]initWithFormat:@"\n-----%@-----\n%@\n-----%@-----n%@\n-----%@-----\n%@\n\n",productName,product.localizedTitle,productDescription,product.localizedDescription,productPrice,product.price];
        
        self.infoString=NSLocalizedString(@"-----向iTunes Store发送交易请求-----\n",@"-----向iTunes Store发送交易请求-----\n");
    }
    else{
        self.infoString=NSLocalizedString(@"-----iTunes Store没有相关产品信息-----\n",@"-----iTunes Store没有相关产品信息-----\n");
        
        [request cancel];
    }
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSString *lst1=NSLocalizedString(@"-----向iTunes Store请求信息失败-----",@"-----向iTunes Store请求信息失败-----");
    NSString *lst2=NSLocalizedString(@"Error",@"错误信息");
    self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@：%@-----\n",lst1,lst2,error.localizedDescription];
    
}

-(void)requestDidFinish:(SKRequest *)request{
    self.infoString=NSLocalizedString(@"-----iTunes Store反馈信息结束-----\n",@"-----iTunes Store反馈信息结束-----\n");
}

//代理方法：收到交易结果
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    //交易结果<SKPaymentTransactionObserver> 千万不要忘记绑定，代码如下：
    //监听购买结果
    //[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    self.infoString=NSLocalizedString(@"-----收到iTunes Store反馈的交易结果-----\n",@"-----收到iTunes Store反馈的交易结果-----\n");
    
    //NSLog(@"交易数量:%lu",(unsigned long)[transactions count]);
    if (_transactionType==TransactionTypeRestore&&[transactions count]==0) {
        self.infoString=NSLocalizedString(@"-----No Product that can be restored!-----\n",@"-----您没有可供恢复的项目！-----\n");
        
    }
    
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                //交易完成,调用自定义方法，提供相应内容、记录交易记录等
                NSLog(@"SKPaymentTransactionStatePurchased");
                [self completeTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateRestored:{
                NSLog(@"SKPaymentTransactionStateRestored");
                [self completeTransaction:transaction];
            }
                break;
                
            case SKPaymentTransactionStateFailed:{
                NSLog(@"SKPaymentTransactionStateFailed");
                
                NSString *lst1=NSLocalizedString(@"-----Failed,please try again!-----",@"-----交易失败，请重新尝试-----");
                NSString *lst2=NSLocalizedString(@"Error",@"错误信息");
                self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@：%@-----\n\n",lst1,lst2,[self showTransactionErrorCode:transaction]];
                [self.rightBarButtonItem setTitle:NSLocalizedString(@"Try Again",@"重试")];
                self.rightBarButtonItem.enabled=YES;
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                if (self.inAppPurchaseCompletionHandler) self.inAppPurchaseCompletionHandler(NO,self.productIndex,self.transactionType);
            }
                break;
            default:{
                if (self.inAppPurchaseCompletionHandler) self.inAppPurchaseCompletionHandler(NO,self.productIndex,self.transactionType);
            }
                break;
        }
    }

}

//交易成功，未用户提供相关功能
-(void)completeTransaction:(SKPaymentTransaction *)transaction{
    //禁用重新尝试按钮
    //self.rightButton.enabled=NO;
    
    //显示提示信息
    NSString *typeString=[NSString new];
    
    switch (self.transactionType) {
        case TransactionTypePurchase:{
            typeString=NSLocalizedString(@"Purchase",@"购买");
            [self.rightBarButtonItem setTitle:NSLocalizedString(@"",@"成功")];
        }
            break;
        case TransactionTypeRestore:{
            typeString=NSLocalizedString(@"Restore",@"恢复");
            [self.rightBarButtonItem setTitle:NSLocalizedString(@"Succeeded",@"成功")];
        }
            break;
            
        default:
            break;
    }
    
    //NSLog(@"处理成功:%@",transaction.payment.productIdentifier);
    self.infoString=[[NSString alloc]initWithFormat:NSLocalizedString(@"-----Succeeded-----",@"-----%@成功，请返回使用!-----\n"),typeString];
    
    //关闭成功的交易
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    
    if (self.inAppPurchaseCompletionHandler) self.inAppPurchaseCompletionHandler(YES,self.productIndex,self.transactionType);
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
    
    self.infoString=NSLocalizedString(@"-----iTunes Store恢复结束-----",@"-----iTunes Store恢复结束-----");
    
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error");
    
    NSString *lst1=NSLocalizedString(@"-----iTunes Store恢复失败，请重新尝试-----",@"-----iTunes Store恢复失败，请重新尝试-----");
    NSString *lst2=NSLocalizedString(@"错误信息",@"错误信息");
    self.infoString=[[NSString alloc]initWithFormat:@"%@\n-----%@：%@-----\n",lst1,lst2,error.localizedDescription];
    
}

@end
