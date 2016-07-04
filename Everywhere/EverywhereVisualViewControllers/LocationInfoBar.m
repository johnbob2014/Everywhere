//
//  LocationInfoBar.m
//  Everywhere
//
//  Created by 张保国 on 16/7/4.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "LocationInfoBar.h"
#import "UIView+AutoLayout.h"

@implementation LocationInfoBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setAddress:(NSString *)address{
    _address = address;
    self.addressLabel.text = address;
}

- (UILabel *)addressLabel{
    if (!_addressLabel) {
        UILabel *newlabel = [UILabel newAutoLayoutView];
        [self addSubview:newlabel];
        [newlabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [newlabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        _addressLabel = newlabel;
    }
    return _addressLabel;
}

@end
