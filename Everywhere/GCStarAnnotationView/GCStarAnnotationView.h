//
//  GCStarAnnotationView.h
//  Everywhere
//
//  Created by BobZhang on 16/9/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface GCStarAnnotationView : MKAnnotationView

/**
 *  星标大小，默认为1.2
 */
@property (assign,nonatomic) float starScale;

/**
 *  星标字符属性
 */
@property (copy,nonatomic) NSDictionary<NSString *,id> *attributes;

/**
 *  星标背景颜色，默认为红色
 */
@property (strong,nonatomic) UIColor *starBackColor;

@end
