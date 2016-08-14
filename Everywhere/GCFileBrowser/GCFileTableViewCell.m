
#import "GCFileTableViewCell.h"
#import "GCFileBrowserConfiguration.h"

@implementation GCFileTableViewCell{
    UIImageView *backgroundImageView;
    UIButton *iconButton;
    UILabel *detailDisclosureLabel;//,*transparentActionButton,*fileActionButton;
    
    UIScrollView *scrollViewForTitle;
    
    UITextField *titleTextField;
    //UILabel *createdLabel,*sizeLabel, *changedLabel;
    
}
@synthesize createdValueLabel,sizeValueLabel,changedValueLabel,countLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-short"]];
		[backgroundImageView setContentMode:UIViewContentModeTopRight];
        //[self setBackgroundView:backgroundImageView];
        
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		
		iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[iconButton setAdjustsImageWhenHighlighted:NO];
        [iconButton addTarget:self action:@selector(iconButtonTD) forControlEvents:UIControlEventTouchDown];
        
        iconButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:iconButton];
        [iconButton autoSetDimensionsToSize:CGSizeMake(40, 40)];
        [iconButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [iconButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        scrollViewForTitle = [UIScrollView newAutoLayoutView];
        scrollViewForTitle.showsHorizontalScrollIndicator = YES;
        scrollViewForTitle.backgroundColor = DEBUGMODE ? [[UIColor cyanColor] colorWithAlphaComponent:0.6] : [UIColor clearColor];
        [self.contentView addSubview:scrollViewForTitle];
        [scrollViewForTitle autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [scrollViewForTitle autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:30];
        [scrollViewForTitle autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:5];
        [scrollViewForTitle autoSetDimension:ALDimensionHeight toSize:30];
        //[scrollViewForTitle sizeToFit];
        
        titleTextField = [UITextField newAutoLayoutView];
		[titleTextField setFont:GCFONT_FILES_TITLE];
        [titleTextField setTextColor:GCCOLOR_FILES_TITLE];
        [titleTextField.layer setShadowColor:GCCOLOR_FILES_TITLE_SHADOW.CGColor];
		[titleTextField.layer setShadowOffset:CGSizeMake(0, 1)];
		[titleTextField.layer setShadowOpacity:1.0f];
		[titleTextField.layer setShadowRadius:0.0f];
        [titleTextField setUserInteractionEnabled:NO];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
        
        [scrollViewForTitle addSubview:titleTextField];
        [titleTextField sizeToFit];
        [titleTextField autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [titleTextField autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        
        /*
        createdLabel = [UILabel newAutoLayoutView];
		[createdLabel setText:@"Created:"];
		[createdLabel setFont:GCFONT_FILES_SUBTITLE];
		[createdLabel setTextColor:GCCOLOR_FILES_SUBTITLE];
		[createdLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_SHADOW];
		[createdLabel setShadowOffset:CGSizeMake(0, 1)];
		[createdLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:createdLabel];
        [createdLabel sizeToFit];
        [createdLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scrollViewForTitle withOffset:5];
        [createdLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:5];
		*/
        
		createdValueLabel = [UILabel newAutoLayoutView];
		[createdValueLabel setFont:GCFONT_FILES_COUNTER];
		[createdValueLabel setTextColor:GCCOLOR_FILES_COUNTER];
		[createdValueLabel setShadowColor:GCCOLOR_FILES_COUNTER_SHADOW];
		[createdValueLabel setShadowOffset:CGSizeMake(0, 1)];
		[createdValueLabel setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:createdValueLabel];
        [createdValueLabel sizeToFit];
        //[createdValueLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:createdLabel];
        //[createdValueLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdLabel withOffset:10];
        [createdValueLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scrollViewForTitle withOffset:5];
        [createdValueLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:5];
        /*
		sizeLabel = [UILabel newAutoLayoutView];
		[sizeLabel setText:@"Size:"];
		[sizeLabel setFont:GCFONT_FILES_SUBTITLE];
		[sizeLabel setTextColor:GCCOLOR_FILES_SUBTITLE];
		[sizeLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_SHADOW];
		[sizeLabel setShadowOffset:CGSizeMake(0, 1)];
		[sizeLabel setBackgroundColor:[UIColor clearColor]];
        
		[self.contentView addSubview:sizeLabel];
        [sizeLabel sizeToFit];
        [sizeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:scrollViewForTitle withOffset:5];
        [sizeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdValueLabel withOffset:10];
		*/
        
		sizeValueLabel = [UILabel newAutoLayoutView];
		[sizeValueLabel setFont:GCFONT_FILES_COUNTER];
		[sizeValueLabel setTextColor:GCCOLOR_FILES_COUNTER];
		[sizeValueLabel setShadowColor:GCCOLOR_FILES_COUNTER_SHADOW];
		[sizeValueLabel setShadowOffset:CGSizeMake(0, 1)];
		[sizeValueLabel setBackgroundColor:[UIColor clearColor]];
        [sizeValueLabel setTextAlignment:NSTextAlignmentRight];
		[self.contentView addSubview:sizeValueLabel];
        [sizeValueLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:createdValueLabel];
        [sizeValueLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdValueLabel withOffset:10];
		
        /*
		changedLabel = [UILabel newAutoLayoutView];
		[changedLabel setText:@"Changed:"];
		[changedLabel setFont:GCFONT_FILES_SUBTITLE];
		[changedLabel setTextColor:GCCOLOR_FILES_SUBTITLE];
		[changedLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_SHADOW];
		[changedLabel setShadowOffset:CGSizeMake(0, 1)];
		[changedLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:changedLabel];
        [changedLabel sizeToFit];
        [changedLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:createdLabel withOffset:5];
        [changedLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:10];
		
		changedValueLabel = [UILabel newAutoLayoutView];
		[changedValueLabel setFont:GCFONT_FILES_SUBTITLE_VALUE];
		[changedValueLabel setTextColor:GCCOLOR_FILES_SUBTITLE_VALUE];
		[changedValueLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_VALUE_SHADOW];
		[changedValueLabel setShadowOffset:CGSizeMake(0, 1)];
		[changedValueLabel setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:changedValueLabel];
        [changedValueLabel sizeToFit];
        [changedValueLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:changedLabel];
        [changedValueLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:changedLabel withOffset:10];
        */
        
		[self.layer setMasksToBounds:YES];
		
		countLabel = [UILabel newAutoLayoutView];
        //[countLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		//[countLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"item-counter"]]];
		[countLabel setTextAlignment:NSTextAlignmentCenter];
		[countLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
		[countLabel setFont:GCFONT_FILES_COUNTER];
		[countLabel setTextColor:GCCOLOR_FILES_COUNTER];
		[countLabel setShadowColor:GCCOLOR_FILES_COUNTER_SHADOW];
		[countLabel setShadowOffset:CGSizeMake(0, 1)];

		[countLabel setHidden:YES];
        [self.contentView addSubview:countLabel];
        [countLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:createdValueLabel];
        [countLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdValueLabel withOffset:10];
        
        
        detailDisclosureLabel = [UILabel newAutoLayoutView];
        //detailDisclosureLabel.userInteractionEnabled = NO;
        detailDisclosureLabel.font = GCFONT_FILES_COUNTER;
        detailDisclosureLabel.textColor = GCCOLOR_FILES_COUNTER;
        detailDisclosureLabel.shadowColor = GCCOLOR_FILES_COUNTER;
        detailDisclosureLabel.shadowOffset = CGSizeMake(0, 1);
        detailDisclosureLabel.text = @"➤";
        [self.contentView addSubview:detailDisclosureLabel];
        [detailDisclosureLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [detailDisclosureLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        //[detailDisclosureLabel autoSetDimensionsToSize:CGSizeMake(50, 20)];
        
        //[countLabel sizeToFit];
        //[countLabel autoSetDimensionsToSize:CGSizeMake(47, 28)];
        //[countLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        //[countLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        /*
        fileActionButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        //fileActionButton.backgroundColor = [UIColor clearColor];
        //[fileActionButton addTarget:self action:@selector(actionButtonTD) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:fileActionButton];
        [fileActionButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:countLabel];
        [fileActionButton autoAlignAxis:ALAxisVertical toSameAxisOfView:countLabel];
        [fileActionButton autoSetDimensionsToSize:CGSizeMake(47 , 47)];
        
        transparentActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        transparentActionButton.backgroundColor = [UIColor clearColor];
        [transparentActionButton addTarget:self action:@selector(actionButtonTD) forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:transparentActionButton];
        [transparentActionButton autoAlignAxis:ALAxisHorizontal toSameAxisOfView:countLabel];
        [transparentActionButton autoAlignAxis:ALAxisVertical toSameAxisOfView:countLabel];
        [transparentActionButton autoSetDimensionsToSize:CGSizeMake(47 , 47)];
         */
//		[self setAccessoryView:countLabel];
        
        //swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        //swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        //[self addGestureRecognizer:swipeRecognizer];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    titleTextField.text = title;
    [titleTextField sizeToFit];
    scrollViewForTitle.contentSize = titleTextField.frame.size;
}

- (void)setIsSelected:(BOOL)isSelected{
    iconButton.selected = isSelected;
}

- (void)setIsDirectory:(BOOL)isDirectory{
	if (isDirectory) {
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder"] forState:UIControlStateNormal];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder-selected"] forState:UIControlStateSelected];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-folder-selected"] forState:UIControlStateHighlighted];
        //			[iconButton setFrame:CGRectMake(50, 28, 32, 26)];
        
        [detailDisclosureLabel setHidden:NO];
        [countLabel setHidden:NO];
        //[transparentactionButton setHidden:YES];
        
        //[changedLabel setHidden:YES];
        [changedValueLabel setHidden:YES];
        //[sizeLabel setHidden:YES];
        [sizeValueLabel setHidden:YES];
				
	}else {
        [iconButton setImage:[UIImage imageNamed:@"item-icon-file"] forState:UIControlStateNormal];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-file-selected"] forState:UIControlStateSelected];
        [iconButton setImage:[UIImage imageNamed:@"item-icon-file-selected"] forState:UIControlStateHighlighted];
        //			[iconButton setFrame:CGRectMake(50, 28, 28, 33)];
        
        [detailDisclosureLabel setHidden:YES];
        [countLabel setHidden:YES];
        //[transparentactionButton setHidden:NO];
        
        //[changedLabel setHidden:NO];
        [changedValueLabel setHidden:NO];
        //[sizeLabel setHidden:NO];
        [sizeValueLabel setHidden:NO];
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

- (void)actionButtonTD{
    if ([self.delegate respondsToSelector:@selector(fileTableViewCell:didTapActionAtIndexPath:)]) {
        [self.delegate fileTableViewCell:(GCFileTableViewCell *)self didTapActionAtIndexPath:(NSIndexPath *)self.indexPath];
    }
}
@end
