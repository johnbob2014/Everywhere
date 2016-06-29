//
//  PHAsset+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/6/29.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "PHAsset+Assistant.h"

@implementation PHAsset (Assistant)

+ (UIImage *)synchronousFetchUIImageFromPHAsset:(PHAsset *)asset targetSize:(CGSize)targetSize{
    __block UIImage *requestImage = nil;
    PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
    // 设置同步获取图片
    imageRequestOptions.synchronous = YES;
    imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:imageRequestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                requestImage = result;
                                            }];
    return requestImage;
}

@end
