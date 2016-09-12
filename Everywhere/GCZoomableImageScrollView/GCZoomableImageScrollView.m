//
//  GCZoomableImageScrollView.m
//  Everywhere
//
//  Created by 张保国 on 16/9/9.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCZoomableImageScrollView.h"

@interface GCZoomableImageScrollView () <UIScrollViewDelegate>

@property (strong,nonatomic) UIImageView *imageView;

@end

@implementation GCZoomableImageScrollView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        self.delegate = self;
        
        self.scrollEnabled = YES;
        
        self.zoomScale = 1.0;
        self.maximumZoomScale = 1.0;
        self.minimumZoomScale = 1.0;
        self.bouncesZoom = YES;
        
        self.backgroundColor = [UIColor blackColor];
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews{
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    self.imageView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    //self.imageView = [UIImageView newAutoLayoutView];

    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imageView];
    //[self.imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    //[self.imageView autoCenterInSuperview];
    
    self.imageView.userInteractionEnabled = YES;
    
    /*
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewSingleTapGR:)];
    singleTapGR.numberOfTapsRequired = 1;
    singleTapGR.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:singleTapGR];
    */
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTapGR:)];
    doubleTapGR.numberOfTapsRequired = 2;
    doubleTapGR.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:doubleTapGR];
    
    
}

- (void)imageViewSingleTapGR:(UITapGestureRecognizer *)sender{
    
}

- (void)imageViewDoubleTapGR:(UITapGestureRecognizer *)sender{
    [self zoomToMinMax:[sender locationInView:sender.view]];
}

#pragma mark - Orientation

- (void)orientationDidChange:(NSNotification *)noti{
    [self updateImageView];
}

#pragma mark - Setter

- (float)imageMaximumZoomScale{
    if (_imageMaximumZoomScale == 0) _imageMaximumZoomScale = 1.0;
    return _imageMaximumZoomScale;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
    [self updateImageView];
}


- (void)updateImageView{
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));
   
    
    //NSLog(@"self.bounds: %@",NSStringFromCGRect(self.bounds));

    //CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    if (self.zoomScale != 1.0) [self zoomBackWithCenterPoint:centerPoint animated:NO];
    
    CGFloat imageWidth = self.image.size.width;
    CGFloat imageHeight = self.image.size.height;
    BOOL overWidth = imageWidth > self.bounds.size.width;
    BOOL overHeight = imageHeight > self.bounds.size.height;
    
    CGSize fitSize = CGSizeMake(imageWidth, imageHeight);
    if (overWidth && overHeight){
        // 图片的宽、高均大于SV的宽、高
        // fit by image width first if (height / times) still
        // bigger than self.bound.size.width
        // Then fit by height instead
        CGFloat timesThanScreenWidth = (imageWidth / self.bounds.size.width);
        if ((imageHeight / timesThanScreenWidth) < self.bounds.size.height){
            self.maximumZoomScale = timesThanScreenWidth * self.imageMaximumZoomScale;
            fitSize.width = self.bounds.size.width;
            fitSize.height = imageHeight / timesThanScreenWidth;
        }else{
            CGFloat timesThanScreenHeight = (imageHeight / self.bounds.size.height);
            self.maximumZoomScale = timesThanScreenHeight * self.imageMaximumZoomScale;
            fitSize.width = imageWidth / timesThanScreenHeight;
            fitSize.height = self.bounds.size.height;
        }
    }else if (overWidth && !overHeight){
        CGFloat timesThanScreenWidth = (imageWidth / self.bounds.size.width);
        self.maximumZoomScale = timesThanScreenWidth * self.imageMaximumZoomScale;
        fitSize.width = self.bounds.size.width;
        fitSize.height = imageHeight / timesThanScreenWidth;
    }else if (!overWidth && overHeight){
        fitSize.height = self.bounds.size.height;
    }
    
    //NSLog(@"self.maximumZoomScale: %.2f",self.maximumZoomScale);
    self.contentSize = fitSize;
    //[self.imageView autoSetDimensionsToSize:fitSize];
    

    self.imageView.frame = CGRectMake((centerPoint.x - fitSize.width / 2),
                                      (centerPoint.y - fitSize.height / 2),
                                      fitSize.width,
                                      fitSize.height);
    //NSLog(@"self.imageView.frame: %@",NSStringFromCGRect(self.imageView.frame));
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //NSLog(@"self.zoomScale: %.2f",self.zoomScale);
    
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    CGFloat offsetX =
    (self.bounds.size.width > self.contentSize.width) ?
    (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY =
    (self.bounds.size.height > self.contentSize.height)?
    (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
    
    self.imageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                        self.contentSize.height * 0.5 + offsetY);
    
    //NSLog(@"self.imageView.center: %@",NSStringFromCGPoint(self.imageView.center));
    
}


#pragma mark - Zoom Action

- (void)zoomToMinMax:(CGPoint)locationPoint{
    BOOL rangeLeft = self.zoomScale > (self.maximumZoomScale * 0.9);
    BOOL rangeRight = self.zoomScale <= self.maximumZoomScale;
    
    float destinationScale = rangeLeft && rangeRight ? self.minimumZoomScale : self.maximumZoomScale;
    CGRect destinationRect = [self zoomRectForScale:destinationScale withCenter:locationPoint];
    
    [self zoomToRect:destinationRect animated:YES];
}

- (void)zoomBackWithCenterPoint:(CGPoint)center animated:(BOOL)animated {
    CGRect rect = [self zoomRectForScale:1.0 withCenter:center];
    [self zoomToRect:rect animated:animated];
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2);
    
    return zoomRect;
}

@end
