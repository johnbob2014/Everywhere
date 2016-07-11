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

+ (UIImage *)synchronousFetchUIImageFromPHAsset:(PHAsset *)asset targetSize:(CGSize)targetSize;

+ (AVPlayerItem *)playItemForVideoAsset:(PHAsset *)videoAsset;

@end
