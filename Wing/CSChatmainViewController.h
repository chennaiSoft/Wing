
#import <UIKit/UIKit.h>

@interface CSChatmainViewController : UIViewController

@property(nonatomic, strong) UITableView * chatTableView;
@property (nonatomic, strong) NSMutableArray * arraymessages;
@property (nonatomic, strong) UIBarButtonItem *deleteAllBtn;
@property (nonatomic,retain)  NSString *searchString;
//@property (strong, nonatomic) UISearchController *searchController;
- (void)reloadTable;

@end
