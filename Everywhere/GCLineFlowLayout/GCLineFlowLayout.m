//
//  GCLineFlowLayout.m
//  Everywhere
//
//  Created by 张保国 on 16/9/11.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCLineFlowLayout.h"

//#define kItemSize 200.0
//#define kZoomDistance 150
//#define kZoomAmount 0.6

@implementation GCLineFlowLayout


-(instancetype)init{
    self=[super init];
    if (self) {
        //self.itemSize = self.collectionView.bounds.size;
        //self.itemSize = CGSizeMake(kItemSize, kItemSize);
        self.scrollDirection=UICollectionViewScrollDirectionHorizontal;
        //CGFloat top_bottom_Inset=(self.collectionView.bounds.size.height - kItemSize) / 2;
        //CGFloat top_bottom_Inset=kItemSize;
        //self.sectionInset=UIEdgeInsetsMake(top_bottom_Inset, 0.0, top_bottom_Inset, 0.0);
        
        self.minimumInteritemSpacing = 0.0f;
        self.minimumLineSpacing = 40.0;
        
        self.sectionInset = UIEdgeInsetsZero;
        self.footerReferenceSize = CGSizeZero;
        self.headerReferenceSize = CGSizeZero;
    }
    return self;
}


//自动对齐到网格
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    //proposedContentOffset是没有对齐到网格时本来应该停下的位置
    CGFloat offsetAdjustment=MAXFLOAT;
    CGFloat horizontalCenter=proposedContentOffset.x + self.collectionView.bounds.size.width / 2.0;
    CGRect targetRect=CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *arry=[super layoutAttributesForElementsInRect:targetRect];
    //对当前屏幕中的UICollectionViewLayoutAttributes逐个与屏幕中心进行比较，找出最接近中心的一个
    for (UICollectionViewLayoutAttributes * attributes in arry) {
        CGFloat itemHorizontalCenter= attributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment=itemHorizontalCenter - horizontalCenter;
        }
    }
    //NSLog(@"proposedContentOffset.x: %0.2f,offsetAdjustment: %0.2f",proposedContentOffset.x,offsetAdjustment);
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

/*
//居中的Item按距离自动放大
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSArray *array=[super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin=self.collectionView.contentOffset;
    visibleRect.size=self.collectionView.bounds.size;
    for(UICollectionViewLayoutAttributes *attributes in array){
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distanceFromCenter =CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat distancePercentFromCenter =distanceFromCenter / kZoomDistance;
            if (ABS(distanceFromCenter) < kZoomDistance) {
                CGFloat zoom = 1 + kZoomAmount * (1 - ABS(distancePercentFromCenter));
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex=1;
            }
        }
    }
    return array;
}
*/

//当边界改变的时候，-invalidateLayout会自动被发送，才能让layout得到刷新
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

@end
