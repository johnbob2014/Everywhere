
#import "GCFileTableViewCell.h"
#import "GCFileBrowserConfiguration.h"

@interface GCFileTableViewCell () <UIScrollViewDelegate>

@end

@implementation GCFileTableViewCell{
    UIImageView *backgroundImageView;
    UIButton *iconButton;
    UILabel *detailDisclosureLabel;
    UIScrollView *scrollViewForTitle;
    UITextField *titleTextField;
}

@synthesize createdLabel,sizeLabel,changedLabel,subitemCountLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[self.layer setMasksToBounds:YES];
        
		iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[iconButton setAdjustsImageWhenHighlighted:NO];
        [iconButton addTarget:self action:@selector(iconButtonTD) forControlEvents:UIControlEventTouchDown];
        
        iconButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:iconButton];
        [iconButton autoSetDimensionsToSize:CGSizeMake(55, 55)];
        [iconButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [iconButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        scrollViewForTitle = [UIScrollView newAutoLayoutView];
        scrollViewForTitle.delegate = self;
        scrollViewForTitle.userInteractionEnabled = NO;
        scrollViewForTitle.showsHorizontalScrollIndicator = YES;
        scrollViewForTitle.backgroundColor = DEBUGMODE ? [RandomFlatColor colorWithAlphaComponent:0.6] : [UIColor clearColor];
        [self.contentView addSubview:scrollViewForTitle];
        [scrollViewForTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [scrollViewForTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30];
        [scrollViewForTitle autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:5];
        [scrollViewForTitle autoSetDimension:ALDimensionHeight toSize:30];
        //[scrollViewForTitle sizeToFit];
        
        titleTextField = [UITextField newAutoLayoutView];
        [titleTextField setStyle:UITextFieldStyleWhiteBold];
        [titleTextField setUserInteractionEnabled:NO];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
        
        [scrollViewForTitle addSubview:titleTextField];
        [titleTextField sizeToFit];
        [titleTextField autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [titleTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        
		createdLabel = [UILabel newAutoLayoutView];
        [createdLabel setStyle:UILabelStyleBrownBold];
        [createdLabel setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:createdLabel];
        [createdLabel sizeToFit];
        [createdLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scrollViewForTitle withOffset:5];
        [createdLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:5];
        
		sizeLabel = [UILabel newAutoLayoutView];
        [sizeLabel setStyle:UILabelStyleBrownBold];
        [sizeLabel setBackgroundColor:[UIColor clearColor]];
        [sizeLabel setTextAlignment:NSTextAlignmentRight];
		[self.contentView addSubview:sizeLabel];
        [sizeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:createdLabel];
        [sizeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdLabel withOffset:10];
		
		subitemCountLabel = [UILabel newAutoLayoutView];
        [subitemCountLabel setTextAlignment:NSTextAlignmentCenter];
		[subitemCountLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
        [subitemCountLabel setStyle:UILabelStyleBrownBold];
		[subitemCountLabel setHidden:YES];
        [self.contentView addSubview:subitemCountLabel];
        [subitemCountLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:createdLabel];
        [subitemCountLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdLabel withOffset:10];
        
        
        detailDisclosureLabel = [UILabel newAutoLayoutView];
        [detailDisclosureLabel setStyle:UILabelStyleBrownBold];
        [self.contentView addSubview:detailDisclosureLabel];
        [detailDisclosureLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [detailDisclosureLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    }
    return self;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

#pragma mark - Getter & Setter

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat contentWidth = scrollViewForTitle.contentSize.width;
    CGFloat frameWidth = scrollViewForTitle.frame.size.width;
    
    if (frameWidth == 0) frameWidth = self.frame.size.width - 85;
    
    //NSLog(@"%@",NSStringFromCGSize(scrollViewForTitle.contentSize));
    //NSLog(@"%@",NSStringFromCGSize(scrollViewForTitle.frame.size));
    
    if (contentWidth > frameWidth){
        CGFloat maxOffset = contentWidth - frameWidth;
        
        NSTimeInterval durationTI = 1.0f;
        if (frameWidth != 0)
            durationTI = contentWidth / frameWidth;
        
        [UIView animateWithDuration:durationTI
                              delay:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             scrollViewForTitle.contentOffset = CGPointMake(maxOffset,0);
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:durationTI
                                                   delay:1.0
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  scrollViewForTitle.contentOffset = CGPointZero;
                                                  //scrollViewForTitle.contentOffset = CGPointMake(maxOffset,0);
                                              }
                                              completion:^(BOOL finished) {
                                                  
                                              }];
                             
                         }];
    }
}

- (void)setContentName:(NSString *)contentName{
    _contentName = contentName;
    
    titleTextField.text = contentName;
    [titleTextField sizeToFit];
    
    scrollViewForTitle.contentSize = titleTextField.frame.size;
    scrollViewForTitle.contentOffset = CGPointZero;
}

- (void)setIsSelected:(BOOL)isSelected{
    iconButton.selected = isSelected;
}

- (void)setIsDirectory:(BOOL)isDirectory{
	if (isDirectory) {
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder@2x"] forState:UIControlStateNormal];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder-selected@2x"] forState:UIControlStateSelected];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder-selected@2x"] forState:UIControlStateHighlighted];
        detailDisclosureLabel.text = @"➤";
        [subitemCountLabel setHidden:NO];
        [changedLabel setHidden:YES];
        [sizeLabel setHidden:YES];
				
	}else {
        [iconButton setImage:[UIImage imageNamed:@"item-icon-file@2x"] forState:UIControlStateNormal];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-file-selected@2x"] forState:UIControlStateSelected];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-file-selected@2x"] forState:UIControlStateHighlighted];
        detailDisclosureLabel.text = @"✦";
        [subitemCountLabel setHidden:YES];
        [changedLabel setHidden:NO];
        [sizeLabel setHidden:NO];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)iconButtonTD{
	if ([self.delegate respondsToSelector:@selector(fileTableViewCell:didTapIconAtIndexPath:)]) {
		[self.delegate fileTableViewCell:(GCFileTableViewCell *)self didTapIconAtIndexPath:(NSIndexPath *)self.indexPath];
	}
}

/*
- (void)actionButtonTD{
    if ([self.delegate respondsToSelector:@selector(fileTableViewCell:didTapActionAtIndexPath:)]) {
        [self.delegate fileTableViewCell:(GCFileTableViewCell *)self didTapActionAtIndexPath:(NSIndexPath *)self.indexPath];
    }
}
 */
@end
