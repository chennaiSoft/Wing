
#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@protocol BOXBrowserDelegate
- (void)BoxfileDownloaded:(NSString*)filePath withExtension:(NSString*)fileExtension;
@end

@interface BOXSampleAccountsViewController : UITableViewController <BOXAPIAccessTokenDelegate>

@property (nonatomic,strong) id<BOXBrowserDelegate> delegate;

- (instancetype)initWithAppUsers:(BOOL)appUsers;

@end

