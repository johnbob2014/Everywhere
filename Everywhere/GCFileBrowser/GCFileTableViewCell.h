
#import <UIKit/UIKit.h>

@class GCFileTableViewCell;

@protocol GCFileTableViewCellDelegate  <NSObject>

- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapIconAtIndexPath:(NSIndexPath *)indexPath;
- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapActionAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GCFileTableViewCell : UITableViewCell

@property (nonatomic) BOOL isDirectory;
@property (nonatomic) BOOL isSelected;

@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) UILabel *createdValueLabel;
@property (nonatomic,strong) UILabel *sizeValueLabel;
@property (nonatomic,strong) UILabel *changedValueLabel;
@property (nonatomic,strong) UILabel *countLabel;

@property (nonatomic, assign) id <GCFileTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
 