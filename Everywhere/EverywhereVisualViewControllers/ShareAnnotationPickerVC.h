//
//  ShareAnnotationPickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/20.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EverywhereShareAnnotation.h"

typedef void(^ShareAnnotationsDidChangeHandler)(NSArray <EverywhereShareAnnotation *> *changedShareAnnos);

@interface ShareAnnotationPickerVC : UIViewController
@property (strong,nonatomic) NSArray <EverywhereShareAnnotation *> *shareAnnos;
@property (copy,nonatomic) ShareAnnotationsDidChangeHandler shareAnnotationsDidChangeHandler;
@end
