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
@property (strong,nonatomic) CLLocation *locaton;
@property (strong,nonatomic) UIImage *thumbnailImage;
@property (strong,nonatomic) NSURL *assetURL;

@property (assign,nonatomic) NSInteger assetCount;
@property (strong,nonatomic) NSArray <NSString *> *assetLocalIdentifiers;
@property (strong,nonatomic) NSString *annotationTitle;

@end
