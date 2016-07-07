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
@property (strong,nonatomic) NSString *cellTitle;
@property (strong,nonatomic) NSString *cellInfo;
@end

@interface CellView ()
@property (strong,nonatomic) UILabel *cellTitleLabel;
@property (strong,nonatomic) UILabel *cellInfoLabel;
@end

@implementation CellView

- (instancetype)init{
    NSLog(@"CellView : %@",NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        self.cellInfoLabel = [UILabel newAutoLayoutView];
        self.cellTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.cellInfoLabel];
        [self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.cellInfoLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        self.cellTitleLabel = [UILabel newAutoLayoutView];
        self.cellTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.cellTitleLabel];
        [self.cellTitleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        
        self.backgroundColor = [UIColor cyanColor];
    }
    return self;
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
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#define blankToSuper 5.0
#define blankBetweenCellView 5.0

- (instancetype)init{
    NSLog(@"PlacemarkInfoBar : %@",NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        // 村镇街道
        thoroughfareCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"村镇街道", @"");
        [self addSubview:thoroughfareCell];
        [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:blankToSuper];
        [thoroughfareCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.15];
        
        // 县区
        subLocalityCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"县区", @"");
        [self addSubview:subLocalityCell];
        [subLocalityCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [subLocalityCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [subLocalityCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:thoroughfareCell withOffset:blankBetweenCellView];
        [subLocalityCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.15];
        
        // 市
        localityCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"市", @"");
        [self addSubview:localityCell];
        [localityCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [localityCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [localityCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:subLocalityCell withOffset:blankBetweenCellView];
        [localityCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.15];
        
        // 省、直瞎市
        administrativeAreaCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"省", @"");
        [self addSubview:administrativeAreaCell];
        [administrativeAreaCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [administrativeAreaCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [administrativeAreaCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:localityCell withOffset:blankBetweenCellView];
        [administrativeAreaCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.15];
        
        // 国家
        countryCell = [CellView newAutoLayoutView];
        thoroughfareCell.cellTitle = NSLocalizedString(@"国家", @"");
        [self addSubview:countryCell];
        [countryCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [countryCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [countryCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:administrativeAreaCell withOffset:blankBetweenCellView];
        [countryCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.15];

    }
    return self;
}

- (void)setThoroughfareCount:(NSUInteger)thoroughfareCount{
    _thoroughfareCount = thoroughfareCount;
    thoroughfareCell.cellInfo = [NSString stringWithFormat:@"%ld",thoroughfareCount];
}

- (void)setSubLocalityCount:(NSUInteger)subLocalityCount{
    _subLocalityCount = subLocalityCount;
    subLocalityCell.cellInfo = [NSString stringWithFormat:@"%ld",subLocalityCount];
}

- (void)setLocalityCount:(NSUInteger)localityCount{
    _localityCount = localityCount;
    localityCell.cellInfo = [NSString stringWithFormat:@"%ld",localityCount];
}

- (void)setAdministrativeAreaCount:(NSUInteger)administrativeAreaCount{
    _administrativeAreaCount = administrativeAreaCount;
    administrativeAreaCell.cellInfo = [NSString stringWithFormat:@"%ld",administrativeAreaCount];
}

- (void)setCountryCount:(NSUInteger)countryCount{
    _countryCount = countryCount;
    countryCell.cellInfo = [NSString stringWithFormat:@"%ld",countryCount];
}

@end
