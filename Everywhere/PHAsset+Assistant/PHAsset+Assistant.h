//
//  PHAsset+Assistant.h
//  Everywhere
//
//  Created by BobZhang on 16/6/29.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

@import Photos;
@import AVKit;

@interface PHAsset (Assistant)

/**
 同步获取相册照片或视频的 UIImage ，可指定获取大小 targetSize - PHAsset+Assistant
 */

- (UIImage *)synchronousFetchUIImageAtTargetSize:(CGSize)targetSize;

/**
 同步获取相册视频的 AVPlayerItem ，会阻碍进程0.1秒~1秒，如获取失败，则返回空值 - PHAsset+Assistant
 */
- (AVPlayerItem *)synchronousFetchAVPlayerItem;

@end
