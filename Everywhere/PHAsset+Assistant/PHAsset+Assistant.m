//
//  PHAsset+Assistant.m
//  Everywhere
//
//  Created by BobZhang on 16/6/29.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "PHAsset+Assistant.h"

@implementation PHAsset (Assistant)

- (UIImage *)synchronousFetchUIImageAtTargetSize:(CGSize)targetSize{
    __block UIImage *requestImage = nil;
    PHImageRequestOptions *imageRequestOptions = [PHImageRequestOptions new];
    // 设置同步获取图片
    imageRequestOptions.synchronous = YES;
    imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    [[PHImageManager defaultManager] requestImageForAsset:self
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:imageRequestOptions
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                requestImage = result;
                                            }];
    return requestImage;
}

- (AVPlayerItem *)synchronousFetchAVPlayerItem{
    
    __block AVPlayerItem *returnItem = nil;
    
    if (self.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [PHVideoRequestOptions new];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
        
        [[PHImageManager defaultManager] requestPlayerItemForVideo:self options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            returnItem = playerItem;
        }];
        
        NSDate *startDate = [NSDate date];
        
        // 等待returnItem被赋值，如未赋值，等待0.1秒；如已赋值，或等待时间超过1秒，退出，返回空值
        while (!returnItem || [[NSDate date] timeIntervalSinceDate:startDate] < 1) {
            [NSThread sleepForTimeInterval:0.1];
        }
        
    }
    
    return returnItem;
}
@end
