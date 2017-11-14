
#import "JSQMessages.h"

#import "DemoModelData.h"
#import "NSUserDefaults+DemoSettings.h"


#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#import "MHGallery.h"
//#import "SAVideoRangeSlider.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import <CoreLocation/CoreLocation.h>

//#import "LCVoice.h"
//#import "RecordViewController.h"
//#import "TGDateUtils.h"
#import "ErrorConstant.h"

#import <MapKit/MapKit.h>

typedef enum : NSUInteger {
    FileTypeImage = 1,
    FileTypeVideo = 2,
    FileTypeUnknown = 3,
} FileType;

@class DemoMessagesViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(DemoMessagesViewController *)vc;

@end


@interface DemoMessagesViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,UIDocumentInteractionControllerDelegate>

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;
@property (nonatomic, strong) CLLocationManager * locationManager;

@property (strong, nonatomic) DemoModelData * demoData;
@property (strong, nonatomic) NSMutableArray * messageArr;
@property (strong) AVAudioPlayer *audioPlayer;


- (void)closePressed:(UIBarButtonItem *)sender;
- (void)reinitliazeNotification;

@end
