
#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>

@interface CSFriendsViewController : UIViewController {
    
    UITableView * contactTable;
    NSInteger indexx;
}

@property (nonatomic, strong)ABPeoplePickerNavigationController* addressBookController;

@property (nonatomic) BOOL checkPage;

@end
