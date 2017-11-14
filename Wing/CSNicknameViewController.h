
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "CSChatmainViewController.h"
#import "CSBaseViewController.h"

@interface CSNicknameViewController : CSBaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
    UIScrollView * scrollview;
    UITabBarController * tabBar;
    CSChatmainViewController * chatView;
}

@property(nonatomic, strong)NSString * nameStrnum;

@end
