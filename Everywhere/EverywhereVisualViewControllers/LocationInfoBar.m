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
/*
UIEdgeInsets UIEdgeInsetsMake (
                               CGFloat top,
                               CGFloat left,
                               CGFloat bottom,
                               CGFloat right
                               );
 */

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *coordlabel = [UILabel newAutoLayoutView];
        coordlabel.numberOfLines = 0;
        [self addSubview:coordlabel];
        [coordlabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
        [coordlabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        self.coordinateLabel = coordlabel;
        
        UILabel *altLabel = [UILabel newAutoLayoutView];
        altLabel.numberOfLines = 0;
        [self addSubview:altLabel];
        [altLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.coordinateLabel withOffset:5];
        [altLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        self.altitudeLabel = altLabel;
        
        UILabel *addlabel = [UILabel newAutoLayoutView];
        addlabel.numberOfLines = 0;
        addlabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:addlabel];
        [addlabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.altitudeLabel withOffset:5];
        [addlabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [addlabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        self.addressLabel = addlabel;
        
        /*
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageViewTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapGR:)];
        [imageView addGestureRecognizer:imageViewTapGR];
        
        UIButton *badgeButton = [UIButton newAutoLayoutView];
        badgeButton.userInteractionEnabled = NO;
        [badgeButton setBackgroundImage:[UIImage imageNamed:@"badge"] forState:UIControlStateNormal];
        [badgeButton setTitle:@"0" forState:UIControlStateNormal];
        badgeButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        [imageView addSubview:badgeButton];
        [badgeButton autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
        [badgeButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
         */

    }
    return self;
}

- (void)setLatitude:(CLLocationDegrees)latitude{
    _latitude = latitude;
    [self updateCoordinateLabel];
}

- (void)setLongitude:(CLLocationDegrees)longitude{
    _longitude = longitude;
    [self updateCoordinateLabel];
}

- (void)setHorizontalAccuracy:(CLLocationDistance)horizontalAccuracy{
    _horizontalAccuracy = horizontalAccuracy;
    [self updateCoordinateLabel];
}

+ (NSString *)dmsStringWithDegrees:(CLLocationDegrees)degrees{
    double degreeFloor = floor(degrees);
    double minutes = (degrees - degreeFloor) * 60.0;
    double minuteFloor = floor(minutes);
    double seconds = (minutes - minuteFloor) * 60.0;
    double secondFloor = floor(seconds);
    NSString *dmsString = [NSString stringWithFormat:@"%.0f°%0.f'%.0f''",degreeFloor,minuteFloor,secondFloor];
    return dmsString;
}

-(void)updateCoordinateLabel{
    NSMutableString *ma = [NSMutableString new];
    [ma appendString:self.latitude > 0 ? NSLocalizedString(@"N. ", @""):NSLocalizedString(@"S. ", @"")];
    [ma appendString:[LocationInfoBar dmsStringWithDegrees:self.latitude]];
    [ma appendFormat:@" (%.4f°)",fabs(self.latitude)];
    [ma appendFormat:@"\n"];
    [ma appendString:self.longitude > 0 ? NSLocalizedString(@"E. ", @""):NSLocalizedString(@"W. ", @"")];
    [ma appendString:[LocationInfoBar dmsStringWithDegrees:self.longitude]];
    [ma appendFormat:@" (%.4f°)",fabs(self.longitude)];
    self.coordinateLabel.text = ma;
}

- (void)setAltitude:(CLLocationDistance)altitude{
    _altitude = altitude;
    [self updateAltitudeLabel];
}

- (void)setVerticalAccuracy:(CLLocationDistance)verticalAccuracy{
    _verticalAccuracy = verticalAccuracy;
    [self updateAltitudeLabel];
}

- (void)setLevel:(NSInteger)level{
    _level = level;
    [self updateAltitudeLabel];
}

- (void)updateAltitudeLabel{
    NSMutableString *ma = [NSMutableString new];
    if (self.altitude != 0) {
        [ma appendString:NSLocalizedString(@"Altitude : ", @"")];
        [ma appendFormat:@"%.2f",self.altitude];
    }
    if (self.level != 0) {
        [ma appendFormat:@"\n"];
        [ma appendString:NSLocalizedString(@"Floor : ", @"")];
        [ma appendFormat:@"%ld",(long)self.level];
    }
    self.altitudeLabel.text = ma;
}

- (void)setAddress:(NSString *)address{
    _address = address;
    self.addressLabel.text = address;
}

@end
