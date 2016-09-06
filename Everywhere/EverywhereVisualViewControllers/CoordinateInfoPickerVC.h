//
//  CoordinateInfoPickerVC.h
//  Everywhere
//
//  Created by BobZhang on 16/9/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoordinateInfo.h"

typedef void(^DidSelectCoordinateInfo)(CoordinateInfo *selectedCoordinateInfo);

@interface CoordinateInfoPickerVC : UIViewController

/**
 *  传输用户选择的CoordinateInfo
 */
@property (copy,nonatomic) DidSelectCoordinateInfo didSelectCoordinateInfo;

@end
