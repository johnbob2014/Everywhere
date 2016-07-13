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
@property (assign,nonatomic) BOOL pinInfoLabelToTop;
@end

@implementation CellView

- (instancetype)init{
    
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
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj autoRemoveConstraintsAffectingView];
    }];
    
    // cellTitleLabel
    [self.cellTitleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    // cellInfoLabel
    if (self.pinInfoLabelToTop) {
        [self.cellInfoLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    }else{
        [self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.cellInfoLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.cellTitleLabel.bounds.size.height];
    }

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
    CellView *totalCell;
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
        self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        
        // 村镇街道
        thoroughfareCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"St.", @"");
        [self addSubview:thoroughfareCell];
        
        // 县区
        subLocalityCell = [CellView newAutoLayoutView];
        subLocalityCell.cellTitle = NSLocalizedString(@"Dist.", @"");
        [self addSubview:subLocalityCell];
        
        // 市
        localityCell = [CellView newAutoLayoutView];
        localityCell.cellTitle = NSLocalizedString(@"City", @"");
        [self addSubview:localityCell];

        // 省、直瞎市
        administrativeAreaCell = [CellView newAutoLayoutView];
        administrativeAreaCell.cellTitle = NSLocalizedString(@"Prov.", @"");
        [self addSubview:administrativeAreaCell];
        
        // 国家
        countryCell = [CellView newAutoLayoutView];
        countryCell.cellTitle = NSLocalizedString(@"State", @"");
        [self addSubview:countryCell];
        
        // 里程/面积
        totalCell = [CellView newAutoLayoutView];
        totalCell.cellInfoLabel.numberOfLines = 0;
        totalCell.pinInfoLabelToTop = YES;
        [self addSubview:totalCell];

    }
    return self;
}

#define blankToSuper 5.0
#define cellWidthRate 0.14

- (void)layoutSubviews{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj autoRemoveConstraintsAffectingView];
    }];
    
    float blankBetweenCellView = (self.bounds.size.width * (1 - cellWidthRate*5 - 0.22) - blankToSuper * 2) / 5.0;
    
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
    
    [totalCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
    [totalCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
    [totalCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:countryCell withOffset:blankBetweenCellView];
    [totalCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.22];

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

- (void)setTotalTitle:(NSString *)totalTitle{
    _totalTitle = totalTitle;
    totalCell.cellTitle = totalTitle;
}

- (void)setTotalDistance:(double)totalDistance{
    _totalDistance = totalDistance;
    NSString *totalString;
    if (totalDistance >=1000) {
        totalString = [NSString stringWithFormat:@"%.2f km",totalDistance/1000.0];
    }else{
        totalString = [NSString stringWithFormat:@"%.0f m",totalDistance];
    }
    totalCell.cellInfo = totalString;
}

- (void)setTotalArea:(double)totalArea{
    _totalArea = totalArea;
    NSString *totalString;
    if (totalArea >=1000*1000) {
        totalString = [NSString stringWithFormat:@"%.2f k㎡",totalArea/(1000.0*1000.0)];
    }else{
        totalString = [NSString stringWithFormat:@"%.0f ㎡",totalArea];
    }
    totalCell.cellInfo = totalString;
}

@end
