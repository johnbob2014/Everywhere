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

/**
 *  《相册地图》专用Block，用于传送要显示的CoordinateInfo
 */
@property (copy,nonatomic) DidSelectCoordinateInfo didSelectCoordinateInfo;

@end
