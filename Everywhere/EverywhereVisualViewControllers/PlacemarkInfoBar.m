//
//  PlacemarkInfoBar.m
//  Everywhere
//
//  Created by 张保国 on 16/7/7.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "PlacemarkInfoBar.h"

#pragma mark - CellView

@interface CellView : UIView
@property (strong,nonatomic) NSString *cellInfo;
@property (strong,nonatomic) NSString *cellTitle;
@property (strong,nonatomic) UILabel *cellInfoLabel;
@property (strong,nonatomic) UILabel *cellTitleLabel;
@end

@implementation CellView

- (instancetype)init{
    //NSLog(@"CellView : %@",NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.cellInfoLabel = [UILabel newAutoLayoutView];
        self.cellInfoLabel.font = [UIFont bodyFontWithSizeMultiplier:1.2];
        self.cellInfoLabel.textAlignment = NSTextAlignmentCenter;
        self.cellInfoLabel.text = @"0";
        [self addSubview:self.cellInfoLabel];
        
        self.cellTitleLabel = [UILabel newAutoLayoutView];
        self.cellTitleLabel.font = [UIFont bodyFontWithSizeMultiplier:0.8];
        self.cellTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.cellTitleLabel.text = @"/";
        [self addSubview:self.cellTitleLabel];
        
        //self.clipsToBounds = YES;

    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4.0];
    bezierPath.lineWidth = 2;
    [[UIColor whiteColor] setStroke];
    [bezierPath stroke];
}

- (void)layoutSubviews{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //[self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        //[self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        
    });
    /*
    [self.cellTitleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    */
    
    //[self.cellInfoLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.cellTitleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.cellInfoLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:self.cellTitleLabel.frame.size.height];
    
    /*
    [self.cellInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [self.cellInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    [self.cellInfoLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.cellTitleLabel withOffset:5 relation:NSLayoutRelationGreaterThanOrEqual];
    */
    
    /*
    CGRect infoRect = self.cellInfoLabel.frame;
    infoRect.origin.x = 0;
    infoRect.origin.y = 0;
    self.cellInfoLabel.frame = infoRect;
    
    CGRect titleRect = self.cellTitleLabel.frame;
    titleRect.origin.x = 0;
    titleRect.origin.y = self.frame.size.height - titleRect.size.height;
    self.cellTitleLabel.frame = titleRect;
    */
    
    /*
    self.cellInfoLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height * 0.3);
    self.cellTitleLabel.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height * 0.3, self.frame.size.width, self.frame.size.height * 0.1);
    */
    
    //self.cellInfoLabel.frame = CGPointMake(0, 0);
    //NSLog(@"\ncell          : %@\ncellInfoLabel : %@",NSStringFromCGPoint(self.frame.origin),NSStringFromCGRect(self.cellInfoLabel.frame));
    //NSLog(@"\ncellInfoLabel : %@\ncellTitleLabel : %@",NSStringFromCGPoint(self.cellInfoLabel.frame.origin),NSStringFromCGPoint(self.cellTitleLabel.frame.origin));
}

- (void)setCellInfo:(NSString *)cellInfo{
    _cellInfo = cellInfo;
    self.cellInfoLabel.text = cellInfo;
}

- (void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    self.cellTitleLabel.text = cellTitle;
}

@end

#pragma mark - PlacemarkInfoBar

@implementation PlacemarkInfoBar{
    CellView *countryCell;
    CellView *administrativeAreaCell;
    //CellView *subAdministrativeAreaCell;
    CellView *localityCell;
    CellView *subLocalityCell;
    CellView *thoroughfareCell;
    //CellView *subThoroughfareCell;
    CellView *totalDistanceCell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    //NSLog(@"PlacemarkInfoBar : %@",NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        // 村镇街道
        thoroughfareCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"街道", @"");
        [self addSubview:thoroughfareCell];
        
        // 县区
        subLocalityCell = [CellView newAutoLayoutView];
        subLocalityCell.cellTitle = NSLocalizedString(@"县区", @"");
        [self addSubview:subLocalityCell];
        
        // 市
        localityCell = [CellView newAutoLayoutView];
        localityCell.cellTitle = NSLocalizedString(@"市", @"");
        [self addSubview:localityCell];

        // 省、直瞎市
        administrativeAreaCell = [CellView newAutoLayoutView];
        administrativeAreaCell.cellTitle = NSLocalizedString(@"省", @"");
        [self addSubview:administrativeAreaCell];
        
        // 国家
        countryCell = [CellView newAutoLayoutView];
        countryCell.cellTitle = NSLocalizedString(@"国家", @"");
        [self addSubview:countryCell];
        
        // 里程
        totalDistanceCell = [CellView newAutoLayoutView];
        totalDistanceCell.cellInfoLabel.numberOfLines = 0;
        totalDistanceCell.cellTitle = NSLocalizedString(@"里程", @"");
        [self addSubview:totalDistanceCell];

    }
    return self;
}

#define blankToSuper 5.0
#define blankBetweenCellView 5.0
#define cellWidthRate 0.14

- (void)layoutSubviews{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
    });
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeConstraints:obj.constraints];
    }];
    
    [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:blankToSuper];
    [thoroughfareCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * cellWidthRate];
    
    [subLocalityCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [subLocalityCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [subLocalityCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:thoroughfareCell withOffset:blankBetweenCellView];
    [subLocalityCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * cellWidthRate];
    
    [localityCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [localityCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [localityCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:subLocalityCell withOffset:blankBetweenCellView];
    [localityCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * cellWidthRate];
    
    [administrativeAreaCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [administrativeAreaCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [administrativeAreaCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:localityCell withOffset:blankBetweenCellView];
    [administrativeAreaCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * cellWidthRate];
    
    [countryCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [countryCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [countryCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:administrativeAreaCell withOffset:blankBetweenCellView];
    [countryCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * cellWidthRate];
    
    [totalDistanceCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [totalDistanceCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [totalDistanceCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:countryCell withOffset:blankBetweenCellView];
    [totalDistanceCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.22];

}

- (void)setThoroughfareCount:(NSUInteger)thoroughfareCount{
    _thoroughfareCount = thoroughfareCount;
    thoroughfareCell.cellInfo = [NSString stringWithFormat:@"%ld",(unsigned long)thoroughfareCount];
}

- (void)setSubLocalityCount:(NSUInteger)subLocalityCount{
    _subLocalityCount = subLocalityCount;
    subLocalityCell.cellInfo = [NSString stringWithFormat:@"%ld",(unsigned long)subLocalityCount];
}

- (void)setLocalityCount:(NSUInteger)localityCount{
    _localityCount = localityCount;
    localityCell.cellInfo = [NSString stringWithFormat:@"%ld",(unsigned long)localityCount];
}

- (void)setAdministrativeAreaCount:(NSUInteger)administrativeAreaCount{
    _administrativeAreaCount = administrativeAreaCount;
    administrativeAreaCell.cellInfo = [NSString stringWithFormat:@"%ld",(unsigned long)administrativeAreaCount];
}

- (void)setCountryCount:(NSUInteger)countryCount{
    _countryCount = countryCount;
    countryCell.cellInfo = [NSString stringWithFormat:@"%ld",(unsigned long)countryCount];
}

- (void)setTotalDistance:(double)totalDistance{
    _totalDistance = totalDistance;
    NSString *totalString;
    if (totalDistance >=1000) {
        totalString = [NSString stringWithFormat:@"%.2f km",totalDistance/1000.0];
    }else{
        totalString = [NSString stringWithFormat:@"%.0f m",totalDistance];
    }
    totalDistanceCell.cellInfo = totalString;
}
@end
