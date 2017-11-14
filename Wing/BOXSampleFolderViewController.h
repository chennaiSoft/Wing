
#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@protocol BOXFolderDelegate
- (void)BoxfileDownloaded:(NSString*)filePath withExtension:(NSString*)fileExtension;
@end

@interface BOXSampleFolderViewController : UITableViewController

- (instancetype)initWithClient:(BOXContentClient *)client folderID:(NSString *)folderID;
@property (nonatomic,strong)id<BOXFolderDelegate> delegate;

@end
