
#import <UIKit/UIKit.h>

@class GCFileTableViewCell;

@protocol GCFileTableViewCellDelegate  <NSObject>

- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapIconAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GCFileTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic) BOOL isFile;
@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UILabel *createdLabel, *createdValueLabel, *sizeLabel, *sizeValueLabel, *changedLabel, *changedValueLabel, *countLabel;

@property (nonatomic, assign) id <GCFileTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)iconButtonTap;

@property (strong) UISwipeGestureRecognizer *swipeRecognizer;

@end
 