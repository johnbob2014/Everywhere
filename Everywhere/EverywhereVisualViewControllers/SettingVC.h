//
//  SettingVC.h
//  Everywhere
//
//  Created by BobZhang on 16/7/13.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoordinateInfoPickerVC.h"

@interface SettingVC : UIViewController

//@property (strong,nonatomic) UIViewController *presentVC;
@property (copy,nonatomic) DidSelectCoordinateInfo didSelectCoordinateInfo;

@end
