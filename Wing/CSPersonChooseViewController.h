
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CSBaseViewController.h"

@protocol GoToChatViewDeletagte <NSObject>

- (void)selectPerson:(NSManagedObject *)user;

@end

@interface CSPersonChooseViewController : CSBaseViewController

@property (nonatomic, strong) id <GoToChatViewDeletagte> deletgate;

@end
