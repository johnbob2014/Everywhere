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

/*
@property (assign,nonatomic,readonly) double speedkmPerhour;
@property (assign,nonatomic,readonly) double speedmPerSecond;
@property (assign,nonatomic,readonly) CLLocationDistance minDistance;
@property (assign,nonatomic,readonly) NSTimeInterval minTimeInterval;
*/

@property (assign,nonatomic,readwrite) double speedkmPerhour;
@property (assign,nonatomic,readwrite) double speedmPerSecond;

@property (assign,nonatomic,readwrite) CLLocationDistance minDistance;
@property (assign,nonatomic,readwrite) NSTimeInterval minTimeInterval;

@end

@implementation RecordModeSettingBar{
    UISegmentedControl *groupSeg;
    NSArray <NSString *> *groupNameArray;
    
    UILabel *speedLabel,*sDLabel,*sTILabel;
    NSString *speedLabelTitle,*sDLabelTitle,*sTILabelTitle;
    
    UISlider *speedSlider;
    float lastspeedBeforeSegValueChaned;
    
    EverywhereSettingManager *settingManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        settingManager = [EverywhereSettingManager defaultManager];
        
        sDLabelTitle = NSLocalizedString(@"Record Distance",@"记录距离");
        sTILabelTitle = NSLocalizedString(@"Record TimeInterval",@"记录间隔");
        speedLabelTitle = NSLocalizedString(@"speed",@"速度");
        
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
        
        
        speedLabel = [UILabel newAutoLayoutView];
        speedLabel.font = labelFont;
        speedLabel.text = speedLabelTitle;
        speedLabel.textColor = [UIColor whiteColor];
        speedLabel.textAlignment = NSTextAlignmentLeft;
        //speedLabel.layer.cornerRadius = 0.4;
        //speedLabel.layer.borderWidth = 1;
        //speedLabel.layer.borderColor = self.tintColor.CGColor;
        [self addSubview:speedLabel];
        [speedLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:sDLabel withOffset:10];
        [speedLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
        
        CGFloat speedSliderWidth = ScreenWidth > 375 ? 150 : 100;
        
        speedSlider = [UISlider newAutoLayoutView];
        speedSlider.tintColor = [UIColor whiteColor];
        speedSlider.minimumValue = - 0.6;
        speedSlider.maximumValue = 0.6;
        speedSlider.continuous = NO;
        speedSlider.value = 0;
        [speedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:speedSlider];
        [speedSlider autoAlignAxis:ALAxisHorizontal toSameAxisOfView:speedLabel];
        [speedSlider autoSetDimension:ALDimensionWidth toSize:speedSliderWidth];
        [speedSlider autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        
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
    speedSlider.value = 0;
    [self updateData:sender.selectedSegmentIndex];
}

- (void)updateData:(NSInteger)index{
    settingManager.defaultTransport = index;
    if (DEBUGMODE) NSLog(@"defaultTransport : %lu",settingManager.defaultTransport);
    
    switch (index) {
        case 0:
            // 注意这里的速度计算
            self.speedkmPerhour = self.customMinDistance / self.customMinTimeInterval * 3600.0 / 1000.0;
            self.minDistance = self.customMinDistance;
            self.minTimeInterval = self.customMinTimeInterval;
            break;
        case 1:
            self.minDistance = settingManager.minDistanceWalkForRecord;
            self.speedkmPerhour = 5.0;
            break;
        case 2:
            self.minDistance = settingManager.minDistanceRideForRecord;
            self.speedkmPerhour = 15.0;
            break;
        case 3:
            self.minDistance = settingManager.minDistanceDriveForRecord;
            self.speedkmPerhour = 70.0;
            break;
        case 4:
            self.minDistance = settingManager.minDistanceHighSpeedForRecord;
            self.speedkmPerhour = 200.0;
            break;
        default:
            break;
    }
    lastspeedBeforeSegValueChaned = self.speedkmPerhour;
}

- (void)sliderValueChanged:(UISlider *)sender{
    self.speedkmPerhour = lastspeedBeforeSegValueChaned * (1 + sender.value);
}

- (void)setSpeedkmPerhour:(double)speedkmPerhour{
    _speedkmPerhour = speedkmPerhour;
    self.speedmPerSecond = speedkmPerhour * 1000.0 / 3600.0;
    self.minTimeInterval = self.minDistance / self.speedmPerSecond;
    if (ScreenWidth > 375){
        speedLabel.text = [NSString stringWithFormat:@"%@ : %.1fkm/h %.1fm/s",speedLabelTitle,speedkmPerhour,self.speedmPerSecond];
    }else{
        speedLabel.text = [NSString stringWithFormat:@"%.1fkm/h %.1fm/s",speedkmPerhour,self.speedmPerSecond];
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
