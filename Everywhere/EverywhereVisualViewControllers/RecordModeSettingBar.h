//
//  RecordModeSettingBar.h
//  Everywhere
//
//  Created by 张保国 on 16/7/23.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MinDistanceOrTimeIntervalDidChangeHanlder)(CLLocationDistance selectedMinDistance , NSTimeInterval selectedMinTimeInterval);

@interface RecordModeSettingBar : UIView

/**
 *  最短距离
 */
@property (assign,nonatomic) CLLocationDistance customMinDistance;

/**
 *  最小时间间隔
 */
@property (assign,nonatomic) NSTimeInterval customMinTimeInterval;

/**
 * 传输用户设置的最短距离和最小时间间隔，如果某一项的值为0，则该项没有更新
 */
@property (copy,nonatomic) MinDistanceOrTimeIntervalDidChangeHanlder minDistanceOrTimeIntervalDidChangeHanlder;

@end
