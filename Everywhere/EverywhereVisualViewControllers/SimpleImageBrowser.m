//
//  SimpleImageBrowser.m
//  Everywhere
//
//  Created by BobZhang on 16/8/22.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "SimpleImageBrowser.h"

@interface SimpleImageBrowser() <UIScrollViewDelegate>
@property (strong,nonatomic) NSArray <UIImage *> *imageArray;
@property (assign,nonatomic) NSInteger currentIndex;
@property (assign,nonatomic) BOOL showBorder;
@end

@implementation SimpleImageBrowser{
    UILabel *indexLabel;
    UIScrollView *myScrollView;
    
    CGFloat imageViewWidth;
    CGFloat imageViewOffset;
}

#pragma mark - Getter & Setter
- (void)setCurrentIndex:(NSInteger)currentIndex{
    if (currentIndex < 0 || currentIndex > self.imageArray.count -1) return;
    
    _currentIndex = currentIndex;
    indexLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(currentIndex + 1),(unsigned long)self.imageArray.count];
}

#pragma mark - Life Cycle
- (instancetype)initWithImageArray:(NSArray *)imageArray{
    self = [super init];
    if (self) {
        if ([imageArray.firstObject isKindOfClass:[UIImage class]]) {
            self.imageArray = imageArray;
        }else if([imageArray.firstObject isKindOfClass:[NSData class]]) {
            NSMutableArray *ma = [NSMutableArray new];
            for (NSData *imageData in imageArray) {
                [ma addObject:[UIImage imageWithData:imageData]];
            }
            self.imageArray = ma;
        }
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    /*
    CGFloat showWidth = self.image.size.width < ScreenWidth ? self.image.size.width : ScreenWidth - 20;
    CGFloat showHeight = self.image.size.height < ScreenHeight ? self.image.size.height : ScreenHeight - 80;
    self.contentSizeInPopup = CGSizeMake(showWidth, showHeight);
    self.landscapeContentSizeInPopup = CGSizeMake(showHeight, showWidth);
    */
    
    self.title = [NSString stringWithFormat:@"%@ - %lu%@",self.title,(unsigned long)self.imageArray.count,NSLocalizedString(@"Photos", @"张照片")];
    
    UIView *topView = [UIView newAutoLayoutView];
    topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview: topView];
    [topView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [topView autoSetDimension:ALDimensionHeight toSize:30];
    
    indexLabel = [UILabel newAutoLayoutView];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.font = [UIFont boldBodyFontWithSizeMultiplier:1.2];
    indexLabel.textColor = [UIColor whiteColor];
    if (self.showBorder){
        indexLabel.layer.borderWidth = 1;
        indexLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        indexLabel.layer.cornerRadius = 4.0;
    }
    [topView addSubview:indexLabel];
    [indexLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
    [indexLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    UIButton *saveButton = [UIButton newAutoLayoutView];
    saveButton.titleLabel.textColor = [UIColor whiteColor];
    saveButton.titleLabel.font = [UIFont boldBodyFontWithSizeMultiplier:1.2];
    if (self.showBorder){
        saveButton.layer.borderWidth = 1;
        saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        saveButton.layer.cornerRadius = 4.0;
    }
    [saveButton setTitle:NSLocalizedString(@"Save", @"保存") forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveCurrentImage) forControlEvents:UIControlEventTouchDown];
    [topView addSubview:saveButton];
    [saveButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [saveButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    imageViewWidth = self.view.frame.size.width;
    imageViewOffset = 20;
    
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGR:)];
    
    myScrollView = [UIScrollView newAutoLayoutView];
    myScrollView.backgroundColor = [UIColor blackColor];
    [myScrollView addGestureRecognizer:pinchGR];
    myScrollView.delegate = self;
    [self.view addSubview:myScrollView];
    [myScrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [myScrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:topView withOffset:0];
    
    myScrollView.contentSize = CGSizeMake((imageViewWidth + imageViewOffset) * self.imageArray.count - imageViewOffset, self.view.frame.size.height - 30);
    
    [self.imageArray enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView;
        imageView = [[UIImageView alloc] initWithImage:obj];
        imageView.backgroundColor = ClearColor;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake((imageViewWidth + imageViewOffset) * idx, 0, imageViewWidth, self.view.frame.size.height - 30);
        [myScrollView addSubview:imageView];
    }];
    
    self.currentIndex = 0;
}

- (void)saveCurrentImage{
    [SVProgressHUD show];
    UIImageWriteToSavedPhotosAlbum(self.imageArray[self.currentIndex], self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
         [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@">_< Save Failed",@">_< 保存失败")];
    }else{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"^_^ Save Succeeded",@"^_^ 保存成功")];
    }
    
    [SVProgressHUD dismissWithDelay:2.0];
}


- (void)pinchGR:(UIPinchGestureRecognizer *)sender{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    CGFloat xOffset = scrollView.contentOffset.x;
    self.currentIndex = floorf(xOffset / (imageViewWidth + imageViewOffset));
    //NSLog(@"%ld",(long)self.currentIndex);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    CGFloat xOffset = targetContentOffset->x;
    CGFloat xCurrentImageView = self.currentIndex * (imageViewWidth + imageViewOffset);
    CGFloat xOffsetDelta = xOffset - xCurrentImageView;
    
    CGFloat expectedXOffset;
    if (xOffsetDelta > (imageViewOffset + imageViewWidth)/3.0){
        expectedXOffset = xCurrentImageView + (imageViewWidth + imageViewOffset);
    }else{
        expectedXOffset = xCurrentImageView;
    }
    
    *targetContentOffset = CGPointMake(expectedXOffset, targetContentOffset->y);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return scrollView.subviews[self.currentIndex];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

@end
