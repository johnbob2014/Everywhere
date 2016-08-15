//
//  RecordModeSettingBar.m
//  Everywhere
//
//  Created by 张保国 on 16/7/23.
//  Copyright © 2016年 ZhangBaoGuo. All rights reserved.
//

#import "RecordModeSettingBar.h"
#import "EverywhereSettingManager.h"

@interface RecordModeSettingBar ()

@property (assign,nonatomic,readwrite) double velocitykmPerhour;
@property (assign,nonatomic,readwrite) double velocitymPerSecond;

@property (assign,nonatomic,readwrite) CLLocationDistance minDistance;
@property (assign,nonatomic,readwrite) NSTimeInterval minTimeInterval;

@end

@implementation RecordModeSettingBar{
    UISegmentedControl *groupSeg;
    NSArray <NSString *> *groupNameArray;
    
    UILabel *velocityLabel,*sDLabel,*sTILabel;
    NSString *velocityLabelTitle,*sDLabelTitle,*sTILabelTitle;
    
    UISlider *velocitySlider;
    float lastVelocityBeforeSegValueChaned;
    
    EverywhereSettingManager *settingManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        settingManager = [EverywhereSettingManager defaultManager];
        
        sDLabelTitle = NSLocalizedString(@"MinDistance",@"最短距离");
        sTILabelTitle = NSLocalizedString(@"MinTimeInterval",@"最小间隔");
        velocityLabelTitle = NSLocalizedString(@"Velocity",@"速度");
        
        // Do any additional setup after loading the view.
        groupNameArray = @[NSLocalizedString(@"Custom", @"自定义"),
                           NSLocalizedString(@"Walk", @"步行"),
                           NSLocalizedString(@"Ride", @"骑行"),
                           NSLocalizedString(@"Drive", @"驾车"),
                           NSLocalizedString(@"HighSpeed", @"高速")];
        
        groupSeg = [[UISegmentedControl alloc] initWithItems:groupNameArray];
        groupSeg.tintColor = [UIColor whiteColor];
        groupSeg.selectedSegmentIndex = settingManager.defaultTransport;
        [groupSeg addTarget:self action:@selector(segValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:groupSeg];
        groupSeg.translatesAutoresizingMaskIntoConstraints = NO;
        [groupSeg autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 0,5) excludingEdge:ALEdgeBottom];
        
        UIFont *labelFont = ScreenWidth > 375 ? [UIFont bodyFontWithSizeMultiplier:1.0] : [UIFont bodyFontWithSizeMultiplier:0.8];
        
        sDLabel = [UILabel newAutoLayoutView];
        sDLabel.font = labelFont;
        sDLabel.text = sDLabelTitle;
        sDLabel.textColor = [UIColor whiteColor];
        sDLabel.textAlignment = NSTextAlignmentLeft;
        sDLabel.layer.cornerRadius = 0.4;
        sDLabel.layer.borderWidth = 0;
        sDLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:sDLabel];
        [sDLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
        [sDLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        
        sTILabel = [UILabel newAutoLayoutView];
        sTILabel.font = labelFont;
        sTILabel.text = sTILabelTitle;
        sTILabel.textColor = [UIColor whiteColor];
        sTILabel.textAlignment = NSTextAlignmentLeft;
        sTILabel.layer.cornerRadius = 0.4;
        sTILabel.layer.borderWidth = 0;
        sTILabel.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:sTILabel];
        [sTILabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:groupSeg withOffset:10];
        
        
        velocityLabel = [UILabel newAutoLayoutView];
        velocityLabel.font = labelFont;
        velocityLabel.text = velocityLabelTitle;
        velocityLabel.textColor = [UIColor whiteColor];
        velocityLabel.textAlignment = NSTextAlignmentLeft;
        //velocityLabel.layer.cornerRadius = 0.4;
        //velocityLabel.layer.borderWidth = 1;
        //velocityLabel.layer.borderColor = self.tintColor.CGColor;
        [self addSubview:velocityLabel];
        [velocityLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:sDLabel withOffset:10];
        [velocityLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        CGFloat velocitySliderWidth = ScreenWidth > 375 ? 150 : 100;
        
        velocitySlider = [UISlider newAutoLayoutView];
        velocitySlider.tintColor = [UIColor whiteColor];
        velocitySlider.minimumValue = - 0.6;
        velocitySlider.maximumValue = 0.6;
        velocitySlider.continuous = NO;
        velocitySlider.value = 0;
        [velocitySlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:velocitySlider];
        [velocitySlider autoAlignAxis:ALAxisHorizontal toSameAxisOfView:velocityLabel];
        [velocitySlider autoSetDimension:ALDimensionWidth toSize:velocitySliderWidth];
        [velocitySlider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        
        self.customMinDistance = settingManager.minDistanceForRecord;
        self.customMinTimeInterval = settingManager.minTimeIntervalForRecord;
        
        [self updateData:groupSeg.selectedSegmentIndex];

    }
    return self;
}

- (void)layoutSubviews{
    //[sDLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withMultiplier:0.5];
    [sTILabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:self.bounds.size.width / 2.0];
}

- (void)segValueChanged:(UISegmentedControl *)sender{
    velocitySlider.value = 0;
    [self updateData:sender.selectedSegmentIndex];
}

- (void)updateData:(NSInteger)index{
    settingManager.defaultTransport = index;
    
    switch (index) {
        case 0:
            // 注意这里的速度计算
            self.velocitykmPerhour = self.customMinDistance / self.customMinTimeInterval * 3600.0 / 1000.0;
            self.minDistance = self.customMinDistance;
            self.minTimeInterval = self.customMinTimeInterval;
            break;
        case 1:
            self.minDistance = settingManager.minDistanceWalkForRecord;
            self.velocitykmPerhour = 5.0;
            break;
        case 2:
            self.minDistance = settingManager.minDistanceRideForRecord;
            self.velocitykmPerhour = 15.0;
            break;
        case 3:
            self.minDistance = settingManager.minDistanceDriveForRecord;
            self.velocitykmPerhour = 70.0;
            break;
        case 4:
            self.minDistance = settingManager.minDistanceHighSpeedForRecord;
            self.velocitykmPerhour = 200.0;
            break;
        default:
            break;
    }
    lastVelocityBeforeSegValueChaned = self.velocitykmPerhour;
}

- (void)sliderValueChanged:(UISlider *)sender{
    self.velocitykmPerhour = lastVelocityBeforeSegValueChaned * (1 + sender.value);
}

- (void)setVelocitykmPerhour:(double)velocitykmPerhour{
    _velocitykmPerhour = velocitykmPerhour;
    self.velocitymPerSecond = velocitykmPerhour * 1000.0 / 3600.0;
    self.minTimeInterval = self.minDistance / self.velocitymPerSecond;
    if (ScreenWidth > 375){
        velocityLabel.text = [NSString stringWithFormat:@"%@ : %.1fkm/h %.1fm/s",velocityLabelTitle,velocitykmPerhour,self.velocitymPerSecond];
    }else{
        velocityLabel.text = [NSString stringWithFormat:@"%.1fkm/h %.1fm/s",velocitykmPerhour,self.velocitymPerSecond];
    }
    
}

- (void)setMinDistance:(CLLocationDistance)minDistance{
    _minDistance = minDistance;
    sDLabel.text = [NSString stringWithFormat:@"%@ : %.0fm",sDLabelTitle,minDistance];
    if (self.minDistanceOrTimeIntervalDidChangeHanlder) self.minDistanceOrTimeIntervalDidChangeHanlder(minDistance,0);
}

- (void)setMinTimeInterval:(NSTimeInterval)minTimeInterval{
    _minTimeInterval = minTimeInterval;
    sTILabel.text = [NSString stringWithFormat:@"%@ : %.1fs",sTILabelTitle,minTimeInterval];
    if (self.minDistanceOrTimeIntervalDidChangeHanlder) self.minDistanceOrTimeIntervalDidChangeHanlder(0,minTimeInterval);
}

- (void)setCustomMinDistance:(CLLocationDistance)customMinDistance{
    _customMinDistance = customMinDistance;
    groupSeg.selectedSegmentIndex = 0;
    [self updateData:0];
}

- (void)setCustomMinTimeInterval:(NSTimeInterval)customMinTimeInterval{
    _customMinTimeInterval = customMinTimeInterval;
    groupSeg.selectedSegmentIndex = 0;
    [self updateData:0];
}

@end
