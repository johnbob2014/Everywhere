//
//  EverywhereMKAnnotation.h
//  Everywhere
//
//  Created by 张保国 on 16/7/2.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface EverywhereMKAnnotation : NSObject <MKAnnotation>

/**
 必需，该Annotation的location - EverywhereMKAnnotation
 */
@property (strong,nonatomic) CLLocation *location;

/**
 该Annotation包含的照片的localIdentifier数组 - EverywhereMKAnnotation
 */
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;

/**
 该Annotation的标题 - EverywhereMKAnnotation
 */
@property (strong,nonatomic) NSString *annotationTitle;

/**
 只读，该Annotation包含的照片数量 - EverywhereMKAnnotation
 */
@property (assign,nonatomic,readonly) NSInteger assetCount;

@end
