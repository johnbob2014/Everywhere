
#import <UIKit/UIKit.h>

@class GCFileTableViewCell;

@protocol GCFileTableViewCellDelegate  <NSObject>

- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapIconAtIndexPath:(NSIndexPath *)indexPath;
//- (void)fileTableViewCell:(GCFileTableViewCell *)cell didTapActionAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GCFileTableViewCell : UITableViewCell

@property (nonatomic) BOOL isDirectory;
@property (nonatomic) BOOL isSelected;

@property (nonatomic,strong) NSString *contentName;

@property (nonatomic,strong) UILabel *createdLabel;
@property (nonatomic,strong) UILabel *sizeLabel;
@property (nonatomic,strong) UILabel *changedLabel;
@property (nonatomic,strong) UILabel *subitemCountLabel;

@property (nonatomic, assign) id <GCFileTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
 