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
 必需，location，座标为WGS84编码格式 - EverywhereAnnotation
 */
@property (strong,nonatomic) CLLocation *location;

/**
 该Annotation包含的照片的localIdentifier数组 - EverywhereAnnotation
 */
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;

/**
 该Annotation的标题 - EverywhereAnnotation
 */
@property (strong,nonatomic) NSString *annotationTitle;

/**
 只读，该Annotation包含的照片数量 - EverywhereAnnotation
 */
@property (assign,nonatomic,readonly) NSInteger assetCount;

@end
