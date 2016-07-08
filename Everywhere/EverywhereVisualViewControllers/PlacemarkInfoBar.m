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
@end

@interface CellView ()
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
        self.cellInfoLabel.font = [UIFont bodyFontWithSizeMultiplier:1.5];
        self.cellInfoLabel.textAlignment = NSTextAlignmentCenter;
        self.cellInfoLabel.text = @"0";
        [self addSubview:self.cellInfoLabel];
        
        self.cellTitleLabel = [UILabel newAutoLayoutView];
        self.cellTitleLabel.font = [UIFont bodyFontWithSizeMultiplier:1.0];
        self.cellTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.cellTitleLabel.text = @"/";
        [self addSubview:self.cellTitleLabel];

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
        
        [self.cellInfoLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0) excludingEdge:ALEdgeBottom];
        [self.cellTitleLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    });
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
    }
    return self;
}

- (void)layoutSubviews{
    //NSLog(@"%@",NSStringFromSelector(_cmd));
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [thoroughfareCell autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:blankToSuper];
        [thoroughfareCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.18];
        
        [subLocalityCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [subLocalityCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [subLocalityCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:thoroughfareCell withOffset:blankBetweenCellView];
        [subLocalityCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.18];
        
        [localityCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [localityCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [localityCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:subLocalityCell withOffset:blankBetweenCellView];
        [localityCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.18];
        
        [administrativeAreaCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [administrativeAreaCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [administrativeAreaCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:localityCell withOffset:blankBetweenCellView];
        [administrativeAreaCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.18];
        
        [countryCell autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:blankToSuper];
        [countryCell autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:blankToSuper];
        [countryCell autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:administrativeAreaCell withOffset:blankBetweenCellView];
        [countryCell autoSetDimension:ALDimensionWidth toSize:self.bounds.size.width * 0.18];

    });
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

@end
