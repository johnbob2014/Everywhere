//
//  GCStarAnnotationView.m
//  Everywhere
//
//  Created by BobZhang on 16/9/5.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "GCStarAnnotationView.h"

@implementation GCStarAnnotationView

- (UIColor *)starBackColor{
    if (!_starBackColor){
        _starBackColor = [[UIColor flatRedColor] colorWithAlphaComponent:0.6];
    }
    return _starBackColor;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self){
        self.backgroundColor = [UIColor clearColor];//[UIColor flatRedColor];
        NSString *startString = @"⭐️";
        CGSize stringSize = [startString sizeWithAttributes:self.attributes];
        CGFloat edgeLength = (stringSize.width + stringSize.height) / 2.0;
        self.frame = CGRectMake(0, 0, edgeLength, edgeLength);
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (self.selected){
        //CGRect circleRect = CGRectInset(rect, -rect.size.width, -rect.size.height);
        UIBezierPath *circleBezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        [circleBezierPath setLineWidth:1.0];
        [self.starBackColor setStroke];
        [self.starBackColor setFill];
        [circleBezierPath stroke];
        [circleBezierPath fill];
    }
    
    NSString *startString = @"⭐️";
    [startString drawInRect:rect withAttributes:self.attributes];
    
}

+ (NSDictionary<NSString *,id> *)attributesWithStarScale:(float)starScale{
    return @{NSFontAttributeName:[UIFont boldBodyFontWithSizeMultiplier:starScale],
             NSStrokeColorAttributeName:[UIColor flatRedColor],
             NSStrokeWidthAttributeName:@(2.0)};
}

- (NSDictionary<NSString *,id> *)attributes{
    if (!_attributes){
        _attributes = [GCStarAnnotationView attributesWithStarScale:self.starScale];
    }
    return _attributes;
}

- (float)starScale{
    if (_starScale > 0) return _starScale;
    else return 1.2;
}

@end
