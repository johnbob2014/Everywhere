//
//  EverywhereAnnotation.h
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface EverywhereAnnotation : NSObject <MKAnnotation>

/**
 必需，location，座标为WGS84编码格式
 */
@property (strong,nonatomic) CLLocation *location;

/**
 包含的照片的localIdentifier数组
 */
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;

/**
 标题
 */
@property (strong,nonatomic) NSString *annotationTitle;

/**
 子标题
 */
@property (strong,nonatomic) NSString *annotationSubtitle;

/**
 只读，包含的照片数量
 */
@property (assign,nonatomic,readonly) NSInteger assetCount;

@end
