
#import "GCFileTableViewCell.h"

#define GCCOLOR_FILES_TITLE [UIColor colorWithRed:0.4 green:0.357 blue:0.325 alpha:1] /*#665b53*/
#define GCCOLOR_FILES_TITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
#define GCCOLOR_FILES_COUNTER [UIColor colorWithRed:0.608 green:0.376 blue:0.251 alpha:1] /*#9b6040*/
#define GCCOLOR_FILES_COUNTER_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:0.35] /*#ffffff*/
#define GCCOLOR_FILES_SUBTITLE [UIColor colorWithRed:0.694 green:0.639 blue:0.6 alpha:1] /*#b1a399*/
#define GCCOLOR_FILES_SUBTITLE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/
#define GCCOLOR_FILES_SUBTITLE_VALUE [UIColor colorWithRed:0.694 green:0.639 blue:0.6 alpha:1] /*#b1a399*/
#define GCCOLOR_FILES_SUBTITLE_VALUE_SHADOW [UIColor colorWithRed:1 green:1 blue:1 alpha:1] /*#ffffff*/

#define GCFONT_FILES_TITLE [UIFont fontWithName:@"HelveticaNeue" size:(ScreenWidth > 375 ? 22.0f : 16.0f)]
#define GCFONT_FILES_COUNTER [UIFont fontWithName:@"HelveticaNeue-Bold" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]
#define GCFONT_FILES_SUBTITLE [UIFont fontWithName:@"HelveticaNeue-Bold" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]
#define GCFONT_FILES_SUBTITLE_VALUE [UIFont fontWithName:@"HelveticaNeue" size:(ScreenWidth > 375 ? 14.0f : 10.0f)]

@implementation GCFileTableViewCell

@synthesize backgroundImageView, swipeRecognizer;
@synthesize iconButton;
@synthesize isFile;
@synthesize titleTextField;
@synthesize createdLabel, createdValueLabel, sizeLabel, sizeValueLabel, changedLabel, changedValueLabel, countLabel;
@synthesize delegate;
@synthesize indexPath;
//@synthesize fileObject;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file-cell-short"]];
		[backgroundImageView setContentMode:UIViewContentModeTopRight];
        [self setBackgroundView:backgroundImageView];
        
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		
		iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[iconButton setAdjustsImageWhenHighlighted:NO];
		[iconButton addTarget:self action:@selector(iconButtonAction:forEvent:) forControlEvents:UIControlEventTouchDown];
        
        iconButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:iconButton];
        [iconButton autoSetDimensionsToSize:CGSizeMake(60, 60)];
        [iconButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [iconButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        titleTextField = [UITextField newAutoLayoutView];
		[titleTextField setFont:GCFONT_FILES_TITLE];
        [titleTextField setTextColor:GCCOLOR_FILES_TITLE];
        [titleTextField.layer setShadowColor:GCCOLOR_FILES_TITLE_SHADOW.CGColor];
		[titleTextField.layer setShadowOffset:CGSizeMake(0, 1)];
		[titleTextField.layer setShadowOpacity:1.0f];
		[titleTextField.layer setShadowRadius:0.0f];
        [titleTextField setUserInteractionEnabled:NO];
		[titleTextField setBackgroundColor:[UIColor clearColor]];
        
        [self.contentView addSubview:titleTextField];
        [titleTextField sizeToFit];
        [titleTextField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [titleTextField autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:10];
		
        createdLabel = [UILabel newAutoLayoutView];
		[createdLabel setText:@"Created:"];
		[createdLabel setFont:GCFONT_FILES_SUBTITLE];
		[createdLabel setTextColor:GCCOLOR_FILES_SUBTITLE];
		[createdLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_SHADOW];
		[createdLabel setShadowOffset:CGSizeMake(0, 1)];
		[createdLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:createdLabel];
        [createdLabel sizeToFit];
        [createdLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleTextField withOffset:5];
        [createdLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:iconButton withOffset:10];
		
		createdValueLabel = [UILabel newAutoLayoutView];
		[createdValueLabel setFont:GCFONT_FILES_SUBTITLE_VALUE];
		[createdValueLabel setTextColor:GCCOLOR_FILES_SUBTITLE_VALUE];
		[createdValueLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_VALUE_SHADOW];
		[createdValueLabel setShadowOffset:CGSizeMake(0, 1)];
		[createdValueLabel setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:createdValueLabel];
        [createdValueLabel sizeToFit];
        [createdValueLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:createdLabel];
        [createdValueLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdLabel withOffset:10];
		
		sizeLabel = [UILabel newAutoLayoutView];
		[sizeLabel setText:@"Size:"];
		[sizeLabel setFont:GCFONT_FILES_SUBTITLE];
		[sizeLabel setTextColor:GCCOLOR_FILES_SUBTITLE];
		[sizeLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_SHADOW];
		[sizeLabel setShadowOffset:CGSizeMake(0, 1)];
		[sizeLabel setBackgroundColor:[UIColor clearColor]];
        
		[self.contentView addSubview:sizeLabel];
        [sizeLabel sizeToFit];
        [sizeLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:titleTextField withOffset:5];
        [sizeLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:createdValueLabel withOffset:10];
		
		sizeValueLabel = [UILabel newAutoLayoutView];
		[sizeValueLabel setFont:GCFONT_FILES_SUBTITLE_VALUE];
		[sizeValueLabel setTextColor:GCCOLOR_FILES_SUBTITLE_VALUE];
		[sizeValueLabel setShadowColor:GCCOLOR_FILES_SUBTITLE_VALUE_SHADOW];
		[sizeValueLabel setShadowOffset:CGSizeMake(0, 1)];
		[sizeValueLabel setBackgroundColor:[UIColor clearColor]];
        [sizeValueLabel setTextAlignment:NSTextAlignmentRight];
		[self.contentView addSubview:sizeValueLabel];
        [sizeValueLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:sizeLabel];
        [sizeValueLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:sizeLabel withOffset:10];
		
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
		[countLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"item-counter"]]];
		[countLabel setTextAlignment:NSTextAlignmentCenter];
		[countLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
		[countLabel setFont:GCFONT_FILES_COUNTER];
		[countLabel setTextColor:GCCOLOR_FILES_COUNTER];
		[countLabel setShadowColor:GCCOLOR_FILES_COUNTER_SHADOW];
		[countLabel setShadowOffset:CGSizeMake(0, 1)];

		[countLabel setHidden:YES];
        [self.contentView addSubview:countLabel];
        //[countLabel sizeToFit];
        [countLabel autoSetDimensionsToSize:CGSizeMake(47, 28)];
        [countLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
        [countLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];

//		[self setAccessoryView:countLabel];
        
        swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        //[self addGestureRecognizer:swipeRecognizer];
    }
    return self;
}

- (void)swipe:(id)sender
{
    [self iconButtonTap];
}

- (void)setIsFile:(BOOL)is {
	if (is) {
		[iconButton setImage:[UIImage imageNamed:@"item-icon-file"] forState:UIControlStateNormal];
		[iconButton setImage:[UIImage imageNamed:@"item-icon-file-selected"] forState:UIControlStateSelected];
		[iconButton setImage:[UIImage imageNamed:@"item-icon-file-selected"] forState:UIControlStateHighlighted];
		//			[iconButton setFrame:CGRectMake(50, 28, 28, 33)];
		
		
	} else {
		[iconButton setImage:[UIImage imageNamed:@"item-icon-folder"] forState:UIControlStateNormal];
		[iconButton setImage:[UIImage imageNamed:@"item-icon-folder-selected"] forState:UIControlStateSelected];
		[iconButton setImage:[UIImage imageNamed:@"item-icon-folder-selected"] forState:UIControlStateHighlighted];
		//			[iconButton setFrame:CGRectMake(50, 28, 32, 26)];
		
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)iconButtonAction:(id)sender forEvent:(UIEvent *)event {
	if (delegate && [delegate respondsToSelector:@selector(fileTableViewCell:didTapIconAtIndexPath:)]) {
		[delegate fileTableViewCell:(GCFileTableViewCell *)self didTapIconAtIndexPath:(NSIndexPath *)indexPath];	
	}
}

- (void)iconButtonTap {
	if (delegate && [delegate respondsToSelector:@selector(fileTableViewCell:didTapIconAtIndexPath:)]) {
		[delegate fileTableViewCell:(GCFileTableViewCell *)self didTapIconAtIndexPath:(NSIndexPath *)indexPath];	
	}
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

@end
