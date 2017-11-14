#import "DemoMessagesViewController.h"
#import "GUIDesign.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "XMPPConnect.h"
#import "ContactsObj.h"
#import "MessgaeTypeConstant.h"
#import "UploadClass.h"
#import "ChatStorageDB.h"
#import "UIImageView+AFNetworking.h"
#import "ScheduledMessageVC.h"
#import "RecordViewController.h"
#import "MapDetailViewController.h"
#import "AddToContactsViewController.h"
#import "MessageInfoViewController.h"
#import "CurrentChatsViewController.h"
#import <Intents/Intents.h>
/////
#import <CoreData/CoreData.h>

//#import "ImageEditViewController.h"

#import "NSData+XMPP.h"

//NSmanagedObj Model
#import "Message.h"
#import "MessageDic.h"
#import "ContactDb.h"
#import "TGDateUtils.h"

#import "CSGetFilesViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>

#import <DropboxSDK/DropboxSDK.h>
#import "DropboxBrowserViewController.h"

#import <BoxContentSDK/BOXContentSDK.h>
#import "BOXSampleAccountsViewController.h"
#import "BOXSampleFileDetailsController.h"
#import "CustomQLPreviewController.h"
#import "ProfileViewController.h"
#import "GroupProfileViewController.h"

@interface DemoMessagesViewController ()<NSFetchedResultsControllerDelegate, getFiles, CTAssetsPickerControllerDelegate,DropboxBrowserDelegate,BOXBrowserDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource,UISearchBarDelegate,UIScrollViewDelegate>
{
    BOOL editOpen;
    
    NSString *trimTempPath;
    NSInteger videoSize;
    NSInteger trimSize;
    NSInteger compressedVideoSize;
    
    CGFloat videoDuration;
    CGFloat trimDuration;
    NSInteger maxFileSize;
    
    NSTimer * timerTypingNotification;
    NSTimer * timerCanceltyping;
    UILabel * labelStatus;
    UILabel * labeltitle;
    
    CSGetFilesViewController * showFileFolder;
    XMPPStream * xmppStream;
    BOOL checkTimer;
    BOOL typingTimer;
    
    UIButton * recordCancelButton;
    NSString * audioEnabled;
    NSString * previewFilePath;
    
    NSDate * _timeStamp;
    
    UIActionSheet * actionSheetOptionOpenResendMessages;
    UIActionSheet * actionSheetOptionOpenSent;
    
    UIButton * downBtn;
    CGFloat yOffset;
    
    // Ameen Search tried.
    NSArray * searchResults;
    UIButton * searcheButton;
    NSMutableArray * searchArr;
    UIView * searchbgView;
}

@property (nonatomic, strong) NSString * receiverId;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSIndexPath * commonPath;
@property (strong, nonatomic) NSString * localidforfile;
@property (nonatomic, strong) NSString * stringTempPath;
@property (nonatomic, strong) NSString * stringOriginalPath;
@property (nonatomic, strong) NSString * currentLocLat;
@property (nonatomic, strong) NSString * currentLocLon;

@property (strong, nonatomic) AVAssetExportSession * exportSession;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;

@property (nonatomic, strong) NSArray * assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIPopoverController *popover;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSIndexPath *selection;
@property (weak, nonatomic) NSString * searchString;

@property (strong, nonatomic) NSDate *scheduledDate;
@property (retain, nonatomic) NSIndexPath *selectedIndexPath;
@property (retain, nonatomic) UITableViewCell * selectedIndexCell;

@property (strong, nonatomic) RecordViewController *recordView;
@property(nonatomic,retain) LCVoice * voice;

// By Ameen

@property(nonatomic) UISearchBar * searchBar;
@property(nonatomic, strong)UISearchController * searchController;
@property (nonatomic) BOOL isSearchEnabled;
@property (nonatomic, strong) NSArray * temporaryArray;


@end

@implementation DemoMessagesViewController

#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    audioEnabled = @"No";
    self.messageArr = [NSMutableArray new];
    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];
    
    /**
     *  You MUST set your senderId and display name
     */
    
    [self.navigationItem setHidesBackButton:YES];
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    
    self.senderId = [Utilities getSenderId];
    self.receiverId = [Utilities getReceiverId];
    
    [self setChatTitleView];
    
    self.senderDisplayName =  [Utilities getReceiverName].capitalizedString;
    labeltitle.text = self.senderDisplayName;
    
    /**
     *  You can set custom avatar sizes
     */
    
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    self.showLoadEarlierMessagesHeader = NO;
    

//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:@selector(receiveMessagePressed:)];

    /**
     *  Register custom menu actions for cells.
     */
    
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    
    [UIMenuController sharedMenuController].menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action"
                                                                                      action:@selector(customAction:)] ];

    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];

    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */

    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150
     */
    
    [self performSelector:@selector(loadPreviousMessage) withObject:nil afterDelay:1.0];
    
}

//thangarajan

-(void)loadViewWillAppear{
    
    AppDelegate * app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    app.isChatPage = YES;
    labeltitle.text =  [Utilities getReceiverName].capitalizedString;
    
    if (self.demoData.messages.count > 0) {
        [self updatingMessagesAnyNewMessagesAvialable];
    }
    
    //AMeen
    
    /*CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    
    [self.collectionView scrollRectToVisible:CGRectMake(0.0, collectionViewContentHeight - 1.0f, 1.0f, 1.0f)
                                    animated:YES];*/
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TypingNotification" object:nil];
}

- (void)getlastSeen{
    
    [WebService lastSeenApiCallNew:[Utilities getReceiverId] completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        NSLog(@"%@",responseObject);
        if (errorCode == WebServiceErrorSuccess)
        {
            NSLog(@"Response success");
            [self performSelectorOnMainThread:@selector(successApiCall:) withObject:responseObject waitUntilDone:YES];
        }
        else{
            
        }
    }];
}

- (void)successApiCall:(id)responseobject{
    
    @autoreleasepool {

        NSString *stringstatus = [[XMPPConnect sharedInstance].dictPresence objectForKey:[Utilities getReceiverId]];
        
        [self scrollToBottomAnimated:YES];
        
        
        if(![[Utilities checkNil:stringstatus] isEqualToString:@""]){
            labelStatus.text = @"Online";
        }
        else{
            
            CGFloat lastseen = [[responseobject valueForKey:@"offlineDate"] doubleValue]/1000 - (22*60);
            
            if(lastseen!= 0){
                labelStatus.text = [NSString stringWithFormat:@"Last seen %@",[TGDateUtils stringForRelativeLastSeen:lastseen]];
                
              //  NSLog(@"%d",lastseen);
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initChatSetup];

    [self.navigationController setNavigationBarHidden:NO];
    
//    if (self.delegateModal) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
//                                                                                              target:self
//                                                                                              action:@selector(closePressed:)];
//    }
    
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [addButton setImage:[UIImage imageNamed:@"add_chat"] forState:UIControlStateNormal];
    self.inputToolbar.contentView.leftBarButtonItem = addButton;
    
    [self reinitliazeNotification];
    [self loadViewWillAppear];
    
}

- (void)setChatTitleView{
    
    UIView * customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
    customView.backgroundColor = [UIColor clearColor];
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0,0,55,55);
    backButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [customView addSubview:backButton];
    
    searcheButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searcheButton.frame = CGRectMake((screenWidth - 55),0, 55, 55);
    searcheButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [searcheButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    [searcheButton setImage:[UIImage imageNamed:@"search_chat"] forState:UIControlStateNormal];
    [customView addSubview:searcheButton];
    
    downBtn = [GUIDesign initWithbutton:CGRectMake((screenWidth - 50), (screenHeight - 130), 30, 30) title:@"" img:@""];
    [downBtn addTarget:self action:@selector(scrollDownimd:) forControlEvents:UIControlEventTouchUpInside];
    [downBtn setBackgroundImage:[UIImage imageNamed:@"Down.png"] forState:UIControlStateNormal];
    [downBtn setHidden:YES];
    [self.view addSubview:downBtn];
    
    self.searchString = @"";
    yOffset = 0.0;

    labeltitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 25)];
    labeltitle.font = [UIFont boldSystemFontOfSize:16.0];
    labeltitle.textAlignment = NSTextAlignmentCenter;
    labeltitle.textColor = [UIColor blackColor];
    [customView addSubview:labeltitle];
    
    labelStatus = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 250)/2, 25, 250, 25)];
    labelStatus.font = [UIFont systemFontOfSize:12.0];
    labelStatus.textAlignment = NSTextAlignmentCenter;
    labelStatus.text = @"Tab here for contact info";
    [customView addSubview:labelStatus];
    
    UIButton * profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    profileButton.frame = CGRectMake(80, 0, SCREEN_WIDTH - 120, 55);
    profileButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [profileButton addTarget:self action:@selector(getProfileAction:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:profileButton];
    
    [self.navigationItem setTitleView:customView];
}

- (IBAction)backAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)getProfileAction:(id)sender{
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        
        GroupProfileViewController *profile = [[GroupProfileViewController alloc]init];
        profile.stringGroupId = [Utilities getReceiverId];
        profile.stringGroupName = [Utilities getReceiverName];
        [[self navigationController]pushViewController:profile animated:YES];
        
    }
    else{
        ProfileViewController *profile = [[ProfileViewController alloc]init];
        profile.receiver_id = [Utilities getReceiverId];
        profile.receiver_name = [Utilities getReceiverName];
        profile.receiver_nick_name = [Utilities getReceiverName];
        profile.pageFromChat = YES;
        [[self navigationController]pushViewController:profile animated:YES];
    }
}

// Ameen
- (IBAction)searchAction:(id)sender{
    
    if (searchbgView == nil) {
        
        [self.inputToolbar.contentView.textView resignFirstResponder];
        
        searchbgView = [[UIView alloc]initWithFrame:CGRectMake(0, - 65, screenWidth, 65)];
        searchbgView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        [self.navigationController.view addSubview:searchbgView];
        
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 65)];
        [_searchBar setBarTintColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        _searchBar.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        _searchBar.placeholder = @"Find";
        _searchBar.keyboardType = UIKeyboardTypeDefault;
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = YES;
        [searchbgView addSubview:_searchBar];
        
        searchArr = [[NSMutableArray alloc]init];
        
        self.temporaryArray = [[NSArray alloc]initWithArray:self.demoData.messages];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             searchbgView.frame = CGRectMake(0, 0, screenWidth, 65);
                         } completion:^(BOOL finished) {
                         }];
    }
}


/* Search bar by Ameen */

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{  // called when text changes (including clear)
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self.text contains[c] %@", searchText];
    self.demoData.messages = [NSMutableArray arrayWithArray:[self.temporaryArray filteredArrayUsingPredicate:resultPredicate]];
    [self.collectionView reloadData];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar __TVOS_PROHIBITED{   // called when cancel button pressed
    [searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         searchbgView.frame = CGRectMake(0, -65, screenWidth, 65);
                     } completion:^(BOOL finished) {
                         [searchbgView removeFromSuperview];
                         searchbgView = nil;
                     }];

    self.demoData.messages = [NSMutableArray arrayWithArray:self.temporaryArray];
    [self.collectionView reloadData];
}

/* Search bar Ends here */

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (void)loadPreviousMessage{
    
    __weak DemoMessagesViewController * weakSelf = self;
    
    [self fetchedResultsControllerChatHistoryWithCompletionBlock:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                
            } completion:nil];
        });

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [[ChatStorageDB sharedInstance]updateReadStatus:[Utilities getReceiverId]];
            
            if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
                
                labelStatus.text =  [NSString stringWithFormat:@"%@",[[[[ChatStorageDB sharedInstance]getGroupMembersByName:weakSelf.receiverId] valueForKeyPath:@"member_name"] componentsJoinedByString:@","]];
                
                if([[ChatStorageDB sharedInstance] isGroupActive:weakSelf.receiverId] == NO){
                }
            }
            else{
                NSString *stringstatus = [[XMPPConnect sharedInstance].dictPresence objectForKey:[Utilities getReceiverId]];
                
                if(![[Utilities checkNil:stringstatus] isEqualToString:@""]){
                    labelStatus.text = stringstatus;
                }
                else{
                    labelStatus.text = @"Tab here for contact info";
                    [weakSelf getlastSeen];
                }
            }
            weakSelf.title = @"";
        }];
    }];
}

#pragma mark - Actions

- (void)receiveMessagePressed:(NSDictionary *)messDic
{
    MessageDic * receivedMessage = [MessageDic messageDicWith:messDic];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
//    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    NSLog(@"%@",messDic);
    JSQMessage * copyMessage;
    
    NSString * groupChat = [messDic objectForKey:@"isgroupchat"];
    
    if (![groupChat isEqualToString:@"1"]) {
        [messDic setValue:@"" forKey:@"displayname"];
    }else{
        NSString * username = [[ContactDb sharedInstance]validateUserName:[messDic valueForKey:@"fromjid"]];
        [messDic setValue:username forKey:@"displayname"];
    }
    
//    if([[messDic valueForKey:@"cmd"] isEqualToString:@"zap"]){
//        
//                NSLog(@"%@",[messDic objectForKey:@"messageID"]);
//                
//                [self.demoData.messages removeObject:[messDic objectForKey:@"messageID"]];
//                [self.collectionView reloadData];
// 
//    }
    
    
    if([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){

        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:NO];
        
        NSLog(@"%@",[messDic objectForKey:@"fromjid"]);
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:photoItem message:receivedMessage];
        
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeFile]]){
        
        NSURL * fileUrl = [NSURL URLWithString:receivedMessage.fileurl];

        CSFileItem * fileItem = [[CSFileItem alloc] initWithUrl:fileUrl];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:fileItem message:receivedMessage];

    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
        
        NSURL * videoUrl = [NSURL URLWithString:receivedMessage.fileurl];
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoUrl isReadyToPlay:YES];
        
        UIImage *img = [[UIImage alloc] initWithData:receivedMessage.image];
        videoItem.thumpImage = img;
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:videoItem message:receivedMessage];
    }
    else if([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation]]){
        //
        __weak UICollectionView *weakView = self.collectionView;
        
        copyMessage = [self createLocationMediaMessageCompletion:messDic with:^{
            [weakView reloadData];
        }];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
        
        NSString * number = @"";
        if([messDic objectForKey:@"jsonvalues"] != [NSNull null]){
            NSArray * arrayJsonValues = [NSJSONSerialization JSONObjectWithData:[messDic objectForKey:@"jsonvalues"] options:NSJSONReadingMutableContainers error:nil];
            if (arrayJsonValues.count > 0) {
                NSDictionary * contactDic = [arrayJsonValues objectAtIndex:0];
                if ([contactDic objectForKey:@"number"] != [NSNull null]) {
                    number = [contactDic objectForKey:@"number"] ;
                }
            }
        }
        
        CSContactItem * contactItem = [[CSContactItem alloc] initWithContact:number andContactName:[messDic objectForKey:@"text"] withUserImage:nil];
        
        contactItem.backgroundColor = [UIColor jsq_messageBubbleGreenColor];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"]  displayName:[messDic objectForKey:@"displayname"] media:contactItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
        
        CSAudioItem * audioItem = [[CSAudioItem alloc] initWithAudioiFile:nil];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"]  displayName:[messDic objectForKey:@"displayname"] media:audioItem message:receivedMessage];
    }
    else{
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] text:[messDic objectForKey:@"text"] message:receivedMessage];
    }
    
    /**
     *  Allow typing indicator to show
     */
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                
                JSQPhotoMediaItem * photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                
                //NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",receivedMessage.localid,receivedMessage.file_ext]];
                
                /* Fetch the image from the server... */
                
               // UIImage *img = [[UIImage alloc] initWithData:receivedMessage.image];//blur image
                
                NSData * imgdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:receivedMessage.fileurl]];
                UIImage * img = [[UIImage alloc] initWithData:imgdata];
                
                [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:receivedMessage.localid :@"jpg"] file:imgdata];

                newMediaAttachmentCopy = img;
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                
                JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                
                NSData * videodata = [NSData dataWithContentsOfURL:videoItemCopy.fileURL];
                [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:receivedMessage.localid :@"mp4"] file:videodata];

                UIImage *img = [[UIImage alloc] initWithData:receivedMessage.image];
                videoItemCopy.thumpImage = img;
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = NO;
                
                newMediaData = videoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[CSContactItem class]]) {
                CSContactItem * contactItemCopy = [((CSContactItem *)copyMediaData) copy];
                contactItemCopy.backgroundColor = [UIColor jsq_messageBubbleGreenColor];

                contactItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                newMediaData = contactItemCopy;
            }else if ([copyMediaData isKindOfClass:[CSAudioItem class]]) {
                
                CSAudioItem * audioItemCopy = [((CSAudioItem *)copyMediaData) copy];
                audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
    
                NSURL * fileUrl = [NSURL URLWithString:receivedMessage.fileurl];

                NSData * audiodata = [NSData dataWithContentsOfURL:fileUrl];

                [Utilities saveFilesWithEncryption:[Utilities getAudioFilePath:receivedMessage.localid] file:audiodata];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                newMediaData = audioItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[CSFileItem class]]){
                
                CSFileItem * fileItem = [((CSFileItem *)copyMediaData) copy];
                
                NSURL * fileUrl = [NSURL URLWithString:receivedMessage.fileurl];
                
                NSData * filedata = [NSData dataWithContentsOfURL:fileUrl];
                
                [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:receivedMessage.localid : receivedMessage.file_ext] file:filedata];
                
                fileItem.appliesMediaViewMaskAsOutgoing = NO;
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                newMediaData = fileItem;
            }
            else {

                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:copyMessage.senderId
                                             displayName:copyMessage.senderDisplayName
                                                   media:newMediaData message:receivedMessage];
        }
        else {
            /**
             *  Last message was a text message
             */

            newMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] text:[messDic objectForKey:@"text"] message:receivedMessage];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];

                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }else if ([newMediaData isKindOfClass:[CSContactItem class]]){
                    ;
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
            });
        }
    });
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    //[self.delegateModal didDismissJSQDemoViewController:self];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    
    if([audioEnabled isEqualToString:@"No"]){
        
        if([[Utilities checkNil:text] isEqualToString:@""])
            return;
        
        NSDictionary * messDic = [self sendTextMessage:text];
        
        MessageDic * receivedMessage = [MessageDic messageDicWith:messDic];
        
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        JSQMessage * typedMessage = [JSQMessage messageWithSenderId:self.senderId displayName:senderDisplayName text:text message:receivedMessage];
        
        [self insertNewMessage:typedMessage];
        [self finishSendingMessageAnimated:YES];
        
    }else{
        [self removeRecordView];
        [self audioTransfer];
    }
}

- (void)insertNewMessage:(JSQMessage*)message{
    
    [self.collectionView performBatchUpdates:^{
        
        [self.demoData.messages addObject:message];
        
        NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
        
        [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:self.demoData.messages.count - 1
                                                          inSection:0]];
        [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
    } completion:^(BOOL finished) {
        //[self sentoServer:message.text];
    }];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
//
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
//    
//    [sheet showFromToolbar:self.inputToolbar];
//
    
    if (sender.tag == 1) {
        [self removeRecordView];
    }else{
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        
        showFileFolder = [storyboard instantiateViewControllerWithIdentifier:@"CSGetFilesViewController"];
        showFileFolder.delegate = self;
        
        showFileFolder.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.navigationController.view addSubview:showFileFolder.view];
        
        [UIView animateWithDuration:0.5 animations:^{
            showFileFolder.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }];
    }
}

#pragma mark - Text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_searchBar resignFirstResponder];
    
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    NSLog(@"typing:start");

    NSLog(@"start");
   // [self ddingNotification];
    
    [textView becomeFirstResponder];
    
    [self removeRecordView];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"typing:End");

    if (textView != self.inputToolbar.contentView.textView) {
        return;
    }
    
    [textView resignFirstResponder];
    NSLog(@"finish");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSDate* timeStamp = [NSDate date];
    
    if (checkTimer == NO) {
        checkTimer = YES;
        [self sendTypingNotification];
    }
    
    _timeStamp = timeStamp;
    
    CGFloat END_TYPING_TIME = 1;
    [self performSelector:@selector(endTyping:) withObject:timeStamp afterDelay:END_TYPING_TIME];
    return YES;
}

- (void) endTyping:(NSDate*) timeStamp {
    
    if ([timeStamp isEqualToDate:_timeStamp]) {
        checkTimer = NO;
        [self sendTypingNotification];
        //if it is the last typing...
        //TODO: do what ever you want to do at the end of typing...
    }
}

- (void)sendTypingNotification{
    
    NSString * jid = [Utilities getReceiverId];
    
    NSString * groupChat = [Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[XMPPConnect sharedInstance]sendTypingMessage:jid isGroupChat:groupChat];
    });
}

#pragma mark Image Picker at CTAssetsPickerController

- (void)openGallery
{
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:^{
                [showFileFolder.view removeFromSuperview];
            }];
        });
    }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [self didselectedAssets:assets];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma Mark - Showfiles Delegate methods

- (void)didselectedAssets:(NSArray*)assets{
    self.assets = [[NSArray alloc]initWithArray:assets];
    [self performSelector:@selector(finishAsset) withObject:nil afterDelay:0.0];
}

- (void)removeShowFilesView{
    
    [UIView animateWithDuration:0.5 animations:^{
        showFileFolder.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [showFileFolder.view removeFromSuperview];
    }];
}

- (void)getfilesFromGallery:(NSInteger)selectedId{
    
    if (selectedId == 0) {
        //photo gallery
        [self openGallery];
    }else if (selectedId == 1){
        //scedhule
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeShowFilesView];
        });
        [self openScheduling];
    }else if (selectedId == 2){
        //contactt
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeShowFilesView];
        });
        [self openContact];
    }else if (selectedId == 3){
        //location
        [self sendCurrentLocation];
    }else if (selectedId == 4){
        //cloud
        [self openCloud];
        
    }else if (selectedId == 5){
        //audio
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeShowFilesView];
        });
        [self recordAudio];
    }else if (selectedId == 6){
        //camera
        [self openCamera];
    }
}

- (void)openScheduling
{
    ScheduledMessageVC * schedule = [[ScheduledMessageVC alloc]initWithNibName:@"ScheduledMessageVC" bundle:nil];
    schedule.delegate = self;
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:schedule];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark Text
- (void)sendScheduledText:(NSString*)textMessage date:(NSDate*)date{
    
    self.scheduledDate = date;
    
    NSDictionary * messDic = [self sendTextMessage:textMessage];
    
    MessageDic * receivedMessage = [MessageDic messageDicWith:messDic];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage * typedMessage = [JSQMessage messageWithSenderId:self.senderId displayName:self.senderDisplayName text:textMessage message:receivedMessage];
    
    [self insertNewMessage:typedMessage];
    [self finishSendingMessageAnimated:YES];
}

- (void)openCloud{
    
    UIAlertController * alertCloud = [UIAlertController alertControllerWithTitle:@"Message" message:@"Select the Drive" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * dropBox = [UIAlertAction actionWithTitle:@"DropBox" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self openDropbox];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeShowFilesView];
        });
    }];
    
    UIAlertAction * box = [UIAlertAction actionWithTitle:@"Box" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self openBoxFolder];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeShowFilesView];
        });
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertCloud addAction:dropBox];
    [alertCloud addAction:box];
    [alertCloud addAction:cancel];
    
    [self presentViewController:alertCloud animated:YES completion:nil];
    
}

/*
-(void)boxOpen{
    
    [BOXContentClient setClientID:@"75hieijuzfhww9ubtuam2sa7l505b2vs" clientSecret:@"xhbzNG1pN7J5VVQjYJcntYzYsZKQZSMO"];
    
    BOXContentClient *contentClient = [BOXContentClient defaultClient];
    BOXFolderViewController *folderViewController = [[BOXFolderViewController alloc] initWithContentClient:contentClient];
    
    // You must push it to a UINavigationController (i.e. do not 'presentViewController')
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:folderViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
   }
*/

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    /*if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
           // [self openGallery];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion: ^{
                [weakView reloadData];
            }];
        }
            break;
            
        case 2:
            [self.demoData addVideoMediaMessage];
            break;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];*/
    
    if(actionSheet == actionSheetOptionOpenResendMessages)
    {
        switch (buttonIndex) {
            case 0:
                [self resendSingleMessage];
                break;
            case 1:
                [self resendMultipleMessages];
                break;
            case 2:
                [self deleteAction];
                break;
                
            default:
                break;
        }
    }else if(actionSheet == actionSheetOptionOpenSent){
        
        switch (actionSheet.tag) {
            case 1:
                switch (buttonIndex) {
                    case 0:
                        [self infoAction];
                        break;
                    case 1:
                        [self copyAction];
                        
                        break;
                    case 2:
                        [self forwardAction];
                        
                        break;
                    case 3:
                        [self deleteAction];
                        
                        break;
                    case 4:
                        [self zapAction];
                        
                        break;
                    default:
                        break;
                }
                break;
            case 2:
                switch (buttonIndex) {
                    case 0:
                        [self infoAction];
                        break;
                    case 1:
                        [self forwardAction];
                        
                        break;
                    case 2:
                        [self deleteAction];
                        
                        break;
                    case 4:
                        //[self selectAction];
                        
                        [self zapAction];
                        
                        break;
                    default:
                        break;
                }
                break;
            case 3:
                switch (buttonIndex) {
                    case 0:
                        [self infoAction];
                        break;
                    case 1:
                        [self forwardAction];
                        
                        break;
                    case 2:
                        [self deleteAction];
                        
                        break;
                    case 3:
                        //[self selectAction];
                        [self zapAction];
                        
                        break;
                    default:
                        break;
                }
                
                break;
            case 4:
                switch (buttonIndex) {
                    case 0:
                        [self infoAction];
                        break;
                    case 1:
                        [self contactViewAction];
                        
                        break;
                    case 2:
                        [self forwardAction];
                        
                        break;
                    case 3:
                        [self deleteAction];
                        
                        break;
                    case 4:
                        //[self selectAction];
                        [self zapAction];
                        
                        break;
                    default:
                        break;
                }
                
                break;
            case 5:
                switch (buttonIndex) {
                    case 0:
                        [self infoAction];
                        break;
                    case 1:
                        [self locationAction];
                        
                        break;
                    case 2:
                        [self forwardAction];
                        
                        break;
                    case 3:
                        [self deleteAction];
                        
                        break;
                    case 4:
                        //[self selectAction];
                        [self zapAction];
                        
                        break;
                    default:
                        break;
                }
                
                break;
            case 6:
                switch (buttonIndex) {
                    case 0:
                        [self infoAction];
                        break;
                    case 1:
                         [self playAudio];
                        
                        break;
                    case 2:
                        [self forwardAction];
                        
                        break;
                    case 3:
                        [self deleteAction];
                        
                        break;
                    case 4:
                        [self zapAction];
                        
                        break;
                    default:
                        break;
                }
                
                break;
                
            default:
                break;
        }
    }
}

// Ameen did this

- (NSInteger)fetchedObjectCountForSection:(NSInteger)section
{
    //    NSInteger count = 0;
    //    if ([self.fetchController.sections count] > section) {
    //        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections ] objectAtIndex:section];
    //
    //        count = [sectionInfo numberOfObjects];
    //    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.messageArr objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}


- (Message*)objectInFetchedControllerAtIndexPath:(NSIndexPath*)indexPath
{
    Message *messagess = nil;
    
    if ([self fetchedObjectCountForSection:indexPath.section] > indexPath.row) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.messageArr objectAtIndex:indexPath.section];
        
        messagess = [[sectionInfo objects] objectAtIndex:indexPath.row];
    }
    
    return messagess;
}

/* Ameen did this for SIRI */



/* Ameen SIRI ends here */

-(void)zapAction{
    
   /* JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
   
    if(!([[XMPPConnect sharedInstance] getNetworkStatus]==YES)){
        [Utilities alertViewFunction:@"" message:@"Server not connected. Please try again"];
        return;
    }
    
    NSMutableArray * arrLocalId = [[NSMutableArray alloc]init];
    
    if([messagess.fromjid isEqualToString:[Utilities getSenderId]]){
            [arrLocalId addObject:messagess.localid];
        
        [[ChatStorageDB sharedInstance].managedObjectContext deleteObject:messagess];
    }
    
    [[XMPPConnect sharedInstance]zapMessageToReceiver:self.receiverId isgroupchat:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] arraylocalid:arrLocalId];
    
    
    [[ChatStorageDB sharedInstance].managedObjectContext save:nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"zap" forKey:@"cmd"];
    [dict setObject:arrLocalId forKey:@"localid"];
    [dict setObject:[Utilities getSenderId] forKey:@"jid"];
    [dict setObject:jsmessage.messageId forKey:@"messageID"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.demoData.messages removeObject:jsmessage];
        [self.collectionView reloadData];
    
    });
    
    [self receiveMessagePressed:dict];*/
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (JSQMessage*)collectionView:(JSQMessagesCollectionView *)collectionView JSQMessageForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
//    return [[XMPPConnect sharedInstance]getDateFromat:message.messageObj.datestring];
    if (message.date) {
        return  [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
//    if (indexPath.item % 3 == 0) {
//        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
//        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    if ((message.senderDisplayName != nil) && (![message.senderDisplayName isEqualToString:@""])) {
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (message.date) {
        return  [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimesFromDate:message.date];
    }
    
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage * msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
            self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont systemFontOfSize:16.0];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }else{
        
        //do it for media messages added by thangarajan
        
//        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//        dispatch_async(q, ^{
//            
//            NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",messagess.localid,messagess.file_ext]];
//            
//            /* Fetch the image from the server... */
//            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
//            UIImage *img = [[UIImage alloc] initWithData:data];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                cell.messgaeImageView.image = img;
//            });
//        });
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

// Ameen Added

- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  disable menu for media messages
    id<JSQMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    if ([messageItem isMediaMessage]) {
        
        if ([[messageItem media] respondsToSelector:@selector(mediaDataType)]) {
            
            return YES;
        }
        return NO;
    }
    
    self.selectedIndexPath = indexPath;
    
    //  textviews are selectable to allow data detectors
    //  however, this allows the 'copy, define, select' UIMenuController to show
    //  which conflicts with the collection view's UIMenuController
    //  temporarily disable 'selectable' to prevent this issue
    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    selectedCell.textView.selectable = NO;
    
    //  it will reset the font and fontcolor when selectable is NO
    //  however, the actual font and fontcolor in textView do not get changed
    //  in order to preserve link colors, we need to re-assign the font and fontcolor when selectable is NO
    //  see GitHub issues #1675 and #1759
    selectedCell.textView.textColor = selectedCell.textView.textColor;
    selectedCell.textView.font = selectedCell.textView.font;
    
    return YES;
}


- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }

    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:indexPath];
        return;
    }

    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(NSIndexPath*)indexPath
{
    NSLog(@"Custom action received! Sender: %ld", (long)indexPath.row);
    self.commonPath = indexPath;
    self.selectedIndexPath = indexPath;

    JSQMessage * msg = [self.demoData.messages objectAtIndex:indexPath.row];

    /*if([msg.messageDic.fromjid isEqualToString:self.senderId]){
        
        
    }
    else{
        
    }*/
    
    /* Ameen Commented
    
    switch (msg.messageDic.messagetype.integerValue) {
        case MessageTypeText:{
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Copy",@"Forward",@"Delete", nil];
            actionSheetOptionOpenSent.tag = 1;
            break;
        }
        case MessageTypeImage:
        {
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Forward",@"Delete", nil];
            actionSheetOptionOpenSent.tag = 2;
            break;
        }
            
        case MessageTypeVideo:{
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Forward",@"Delete", nil];
            actionSheetOptionOpenSent.tag = 3;
            
            break;
        }
        case MessageTypeContact:{
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"View",@"Forward",@"Delete", nil];
            actionSheetOptionOpenSent.tag = 4;
            break;
        }
        case MessageTypeLocation:
        {
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"View",@"Forward",@"Delete", nil];
            actionSheetOptionOpenSent.tag = 5;
            break;
        }
        case MessageTypeAudio:
        {
            actionSheetOptionOpenSent =[[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Play",@"Forward",@"Delete", nil];
            actionSheetOptionOpenSent.tag = 6;
            break;
        }
        default:
            break;
    }*/
    // Ameen Did this
    
    switch (msg.messageDic.messagetype.integerValue) {
        case MessageTypeText:{
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Copy",@"Forward",@"Delete",@"Zap", nil];
            actionSheetOptionOpenSent.tag = 1;
            break;
        }
        case MessageTypeImage:
        {
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Forward",@"Delete",@"Zap", nil];
            actionSheetOptionOpenSent.tag = 2;
            break;
        }
            
        case MessageTypeVideo:{
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Forward",@"Delete",@"Zap", nil];
            actionSheetOptionOpenSent.tag = 3;
            
            break;
        }
        case MessageTypeContact:{
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"View",@"Forward",@"Delete",@"Zap", nil];
            actionSheetOptionOpenSent.tag = 4;
            break;
        }
        case MessageTypeLocation:
        {
            actionSheetOptionOpenSent = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"View",@"Forward",@"Delete",@"Zap", nil];
            actionSheetOptionOpenSent.tag = 5;
            break;
        }
        case MessageTypeAudio:
        {
            actionSheetOptionOpenSent =[[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",@"Play",@"Forward",@"Delete",@"Zap", nil];
            actionSheetOptionOpenSent.tag = 6;
            break;
        }
        default:
            break;
    }
    
    [actionSheetOptionOpenSent showInView:self.view];
    
}


// Ameen just Addded

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    
    if (collectionViewContentHeight >= 1000) {
        
        if (screenHeight <= 568) {
            
            if (scrollView.contentOffset.y <= (collectionViewContentHeight - 1000)) {
                
                // scrolls down.
                yOffset = scrollView.contentOffset.y;
                
                downBtn.hidden = NO;
            }
            else
            {
                // scrolls up.
                yOffset = scrollView.contentOffset.y;
                
                downBtn.hidden = YES;
                
                // Your Action goes here...
            }
        }
        
            else{
                
                if (scrollView.contentOffset.y <= (collectionViewContentHeight - 100)) {
                    
                    // scrolls down.
                    yOffset = scrollView.contentOffset.y;
                    
                    downBtn.hidden = NO;
                }
                else
                {
                    // scrolls up.
                    yOffset = scrollView.contentOffset.y;
                    
                    downBtn.hidden = YES;
                    
                    // Your Action goes here...
                }

            }
      
       }

    
}

-(IBAction)scrollDownimd:(id)sender{
    
    [self scrollToBottomAnimated:YES];
    downBtn.hidden = YES;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
//    if (indexPath.item % 3 == 0) {
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;
//    }

    JSQMessage * message = [self.demoData.messages objectAtIndex:indexPath.item];
    
//    return [[XMPPConnect sharedInstance]getDateFromat:message.messageObj.datestring];
    if (indexPath.item == 0) {
        if (message.date) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }else{
        
//        if (indexPath.item < self.demoData.messages.count) {
//            
//            NSLog(@"crash8");
//            NSLog(@"%lu,***%ld,***%ld",(unsigned long)self.demoData.messages.count,(long)indexPath.item,(long)indexPath.row);
//            
//            JSQMessage * previousMessage = [self.demoData.messages objectAtIndex:(indexPath.item - 1)];
//            
//            NSCalendar* calendar = [NSCalendar currentCalendar];
//            //        NSLog(@"%@,%@",message.date,previousMessage.date);
//            BOOL sameday = [calendar isDate:message.date inSameDayAsDate:previousMessage.date];
//            if (!sameday) {
//                return kJSQMessagesCollectionViewCellLabelHeightDefault;
//            }
//        }
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    
    if (indexPath.item < self.demoData.messages.count) {
        
        JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
        if ([[currentMessage senderId] isEqualToString:self.senderId]) {
            return 0.0f;
        }
        
        if (indexPath.item - 1 > 0) {
            JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
            if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
                return 0.0f;
            }
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    
    JSQMessage * msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([ msg.messageDic.messagetype integerValue] == MessageTypeText){
        //nothing
    }else if ([ msg.messageDic.messagetype integerValue] == MessageTypeLocation){
        
        MapDetailViewController *map = [[MapDetailViewController alloc]init];
        NSArray *array = [ msg.messageDic.text componentsSeparatedByString:@","];
        if(array.count > 0){
            map.lattitude = [array objectAtIndex:0];
            map.longtitude = [array objectAtIndex:1];
        }
        [[self navigationController]pushViewController:map animated:YES];
        
    }else if ([msg.messageDic.messagetype integerValue] == MessageTypeContact){
        
        AddToContactsViewController *add = [[AddToContactsViewController alloc]init];
        NSData  *imgData =  msg.messageDic.image;
        if(imgData){
            add.userImage = [UIImage imageWithData:imgData];
        }
        else{
            add.userImage = [UIImage imageNamed:@"ment.png"];
        }
        
        NSString *strname = [Utilities checkNil:msg.messageDic.text];
        add.stringUsername = strname;
        
        if(msg.messageDic.jsonvalues){
            add.arrayJsonValues = [NSJSONSerialization JSONObjectWithData:msg.messageDic.jsonvalues options:NSJSONReadingMutableContainers error:nil];
        }
        
        [[self navigationController]pushViewController:add animated:YES];
        
    }else if ([msg.messageDic.messagetype integerValue] == MessageTypeFile){
        
        NSString * filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",msg.messageDic.localid,[msg.messageDic.fileName lastPathComponent]]];
        
//        previewFilePath = filePath;
//        
//        CustomQLPreviewController * previewController = [[CustomQLPreviewController alloc] init];
//        [previewController setCurrentPreviewItemIndex:0];
//        previewController.delegate = self;
//        previewController.dataSource = self;
//        [self presentViewController:previewController animated:YES completion:nil];
        
        UIDocumentInteractionController * previewController = [[UIDocumentInteractionController alloc] init];
        previewController.delegate = self;
        previewController.URL = [NSURL fileURLWithPath:filePath];
        [previewController presentPreviewAnimated:YES];
        
        self.automaticallyScrollsToMostRecentMessage = NO;

    }
    else if ([msg.messageDic.messagetype integerValue] == MessageTypeAudio){
        
        NSString * filePath = [Utilities getAudioFilePath:msg.messageDic.localid];
        //NSString * filePath = [[NSBundle mainBundle]pathForResource:@"Andha_Arabi_Kadaloram" ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                                       error:nil];
        [_audioPlayer play];
        
    }else {
        
        int currentcount = 0;
        int presentationIndex = 0;
        
        NSMutableArray * galleryDataSource = [[NSMutableArray alloc]init];
        NSArray *array;
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
            
            array = [[ChatStorageDB sharedInstance]getMediaFilesGroups:[Utilities getSenderId] receiver:[Utilities getReceiverId]];
        }
        else{
            array = [[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:[Utilities getReceiverId]];
        }
        
        if(array.count > 0){
            
            for (NSManagedObject *s in array) {
                
                NSString *type = @"Video";
                
                int typee = 0;
                
                switch ([[s valueForKey:@"messagetype"] integerValue]) {
                    case MessageTypeImage:{
                        type = @"Image";
                        typee = MHGalleryTypeImage;
                        break;
                    }
                    case MessageTypeVideo:{
                        type = @"Video";
                        typee = MHGalleryTypeVideo;
                        break;
                    }
                    default:
                        break;
                }

                if([[s valueForKey:@"localid"] isEqualToString:msg.messageDic.localid]){
                    presentationIndex = currentcount;
                }

                NSLog(@"%@",[Utilities getFilePath:[s valueForKey:@"localid"] :type]);
                
                MHGalleryItem * landschaft1;
                
//                if([[s valueForKey:@"messagetype"] integerValue] == MessageTypeAudio){
//                    landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:[Utilities getAudioFilePath:[s valueForKey:@"localid"]]]]
//                                                       galleryType:typee];
//                    
//                }
                
                if(([[s valueForKey:@"messagetype"] integerValue] == MessageTypeImage) || ([[s valueForKey:@"messagetype"] integerValue] == MessageTypeVideo)){
                    
                    landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:[Utilities getFilePath:[s valueForKey:@"localid"] :type]]]
                                                       galleryType:typee];
                    
                    [galleryDataSource addObject:landschaft1];
                    
                    currentcount++;
                }
                else{
//                    landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:[Utilities getFilePath:[s valueForKey:@"localid"] :type]]]
//                                                       galleryType:typee];
                    
                }
            }
        }
        else{
            return;
        }
        
        MHGalleryController * gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
        gallery.galleryItems = galleryDataSource;
        gallery.presentingFromImageView = nil;
        gallery.presentationIndex = presentationIndex;
        
        // gallery.UICustomization.hideShare = YES;
        //  gallery.galleryDelegate = self;
        //  gallery.dataSource = self;
        
        __weak MHGalleryController * blockGallery = gallery;
        
        gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
            if (viewMode == MHGalleryViewModeOverView) {
                [blockGallery dismissViewControllerAnimated:YES completion:^{
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            }else{
                // NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
                //  CGRect cellFrame  = [[self collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
                //                 [collectionView scrollRectToVisible:cellFrame
                //                                            animated:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //   [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
                    //  [collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    
                    
                    [blockGallery dismissViewControllerAnimated:YES dismissImageView:nil completion:^{
                        
                        [self setNeedsStatusBarAppearanceUpdate];
                        
                    }];
                });
            }
        };
        self.automaticallyScrollsToMostRecentMessage = NO;
        [self presentMHGalleryController:gallery animated:YES completion:nil];
    }
}


#pragma mark -
#pragma mark QLPreviewController Data Source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSURL * url = nil;
    
    if (previewFilePath) {
        //[cell setCellData:[self.arrayOfFiles objectAtIndex:indexPath.row]];
        url = [[NSURL alloc] initFileURLWithPath:previewFilePath];
    }
    return url;
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
    #warning to do for paste action
        /*
        MessageDic * msgDic = [MessageDic messageDicWith:messDic];

        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item message:<#(MessageDic *)#>];
        [self.demoData.messages addObject:message];
        [self finishSendingMessage];*/
        return NO;
    }
    return YES;
}

/*
 Chat notification Configuration Thangarajan
 */
#pragma mark - Chat Configure

- (void)reinitliazeNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadTable" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messageReceived" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TypingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateGroupName" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updatePresence" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable:)
                                                 name:@"reloadTable"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceivedNotification:)
                                                 name:@"messageReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTypingNotification:)
                                                 name:@"TypingNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateGroupName:)
                                                 name:@"updateGroupName"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePresence:)
                                                 name:@"updatePresence"
                                               object:nil];
    
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        [[XMPPConnect sharedInstance]addRoaster:[Utilities getReceiverId]];
    }
    
}

- (void)reloadTable:(NSNotification*)notificationObj{
    
    NSDictionary *dictIncoming = [notificationObj userInfo];
    NSLog(@"%@",dictIncoming);

//    [[ChatStorageDB sharedInstance]updateUploadDB:[dictIncoming objectForKey:@"messageId"] status:[dictIncoming objectForKey:@"deliveryStatus"] keyvalue:@"deliver"];
    
    NSString * str = [NSString stringWithFormat:@"messageId == '%@'",[dictIncoming objectForKey:@"messageId"]];
    
    NSPredicate *applePred = [NSPredicate predicateWithFormat:str];
    
    NSArray * appleEmployees = [self.demoData.messages filteredArrayUsingPredicate:applePred];
    
    if (appleEmployees.count > 0) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            JSQMessage * msg = [self.demoData.messages objectAtIndex:[self.demoData.messages indexOfObject:[appleEmployees objectAtIndex:0]]];
            [msg.messageDic setValue:[dictIncoming objectForKey:@"deliveryStatus"] forKey:@"deliver"];
            
            [self.collectionView reloadData];
            [self.collectionView layoutIfNeeded];
        });
    }else{
        //[self performSelector:@selector(reloadTable:) withObject:notificationObj afterDelay:1.0];
    }
    

}

- (void)initChatSetup{
    
    NSString *downloadsPath = [Utilities documentsPath:@"downloads"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadsPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
}

- (void)messageReceivedNotification:(NSNotification*)notification{
    
    NSDictionary * dictIncoming = [notification userInfo];
    
    [self receiveMessagePressed:dictIncoming];
     NSLog(@"Entered");
    
     NSLog(@"%@",dictIncoming);
    

    /*if(dictIncoming){
     
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [[ChatStorageDB sharedInstance]updateReadStatus:[Utilities getReceiverId]];
            
            //                    [weakSelf.tableView reloadData];
            //                    [weakSelf scrollToBottomAnimated:YES];
            
            if([[dictIncoming valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]||[[dictIncoming valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]||[[dictIncoming valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]] || [[dictIncoming valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeFile]]){
                
                ASIHTTPRequest *requesst = [[XMPPConnect sharedInstance].dictDownloadrequest objectForKey:[dictIncoming valueForKey:@"localid"]];
                
                if(requesst==nil){
                    [[ChatStorageDB sharedInstance]downloadFiles1:dictIncoming];
                }
            }
        }];
    }*/
    
    
}

- (void)updateGroupName:(NSNotification*)notification{
    
    NSDictionary *dictIncoming = [notification userInfo];
    self.senderDisplayName  = [Utilities checkNil:[dictIncoming valueForKey:@"updatename"]];
}

- (void)receiveTypingNotification:(NSNotification*)notification{
    
    NSDictionary * dictIncoming = [notification userInfo];
    
    if([[dictIncoming valueForKey:@"isgroupchat"] isEqualToString:@"0"]||[[dictIncoming valueForKey:@"isgroupchat"] isEqualToString:@""]){
        
        if([[Utilities getReceiverId] isEqualToString:[dictIncoming valueForKey:@"senderid"]]){
            if (typingTimer == NO) {
                typingTimer = YES;
                labelStatus.text = @"typing...";
                
            }else{
                [self cancelTyping];
            }
        }
    }
    else{
        //group chat
        if([[Utilities getReceiverId] isEqualToString:[dictIncoming valueForKey:@"group_id"]]){
            
            NSString * username = [[ContactDb sharedInstance]validateUserName:[dictIncoming valueForKey:@"senderid"]];

            if (typingTimer == NO) {
                typingTimer = YES;
                labelStatus.text = [NSString stringWithFormat:@"%@ is typing...",username];
                
            }else{
                typingTimer = NO;
            }
        }
    }
    
   // self.showTypingIndicator = !self.showTypingIndicator;
   // [self scrollToBottomAnimated:YES];
}

- (void)cancelTyping{
    typingTimer = NO;
    labelStatus.text = @"Online";
}

- (void)updatePresence:(NSNotification*)notification{
    
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        NSString *stringstatus = [[XMPPConnect sharedInstance].dictPresence objectForKey:[Utilities getReceiverId]];
        if(![[Utilities checkNil:stringstatus] isEqualToString:@""]){
             labelStatus.text = stringstatus;
        }
        else{
            labelStatus.text = @"Tab here for contact info";
            [self getlastSeen];
        }
        
    }
}

- (NSDictionary * )sendTextMessage:(NSString*)text{
    // send typed text

    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverName] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeText] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"text"];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:@"" forKey:@"file_ext"];
    [dict setObject:localid forKey:@"fileName"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]);
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendPushNotification:@"text" localid:localid text:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }];

/*
    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];

    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverName] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeText] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"text"];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:@"" forKey:@"file_ext"];
    [dict setObject:localid forKey:@"fileName"];
    
    //enabled scheduleddate
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    //__weak DemoMessagesViewController * weakSelf = self;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self sendPushNotification:@"text" localid:localid text:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }];*/
    
    return dict;
}
/*
- (void)sentoServer:(NSString*)text{
    
    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverName] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeText] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"text"];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:@"" forKey:@"file_ext"];
    [dict setObject:localid forKey:@"fileName"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]);
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendPushNotification:@"text" localid:localid text:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }];
}
*/

- (NSString *)checkandreturnValue:(NSString *)value{
    return  value == nil? @"" : value;
}

- (NSString *)checkDeliverValue:(NSString *)value{
    return  value == nil? @"0" : value;
}

- (NSDate *)checkDateValue:(NSDate *)value{
    return  value == nil? [NSDate date] : value;
}

- (NSDictionary * )convertMessageObjtoDic:(Message *)messageObj{
    
    NSMutableDictionary * dict = [NSMutableDictionary new];
    
    [dict setObject:[self checkandreturnValue:messageObj.fromjid] forKey:@"fromjid"];
    [dict setObject:[self checkandreturnValue:messageObj.tojid] forKey:@"tojid"];
    [dict setObject:[self checkandreturnValue:messageObj.displayname] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%@",messageObj.messagetype] forKey:@"messagetype"];
    [dict setObject:[self checkDateValue:messageObj.sentdate] forKey:@"sentdate"];
    [dict setObject:[self checkDeliverValue:messageObj.deliver] forKey:@"deliver"];
    [dict setObject:[[self checkandreturnValue:messageObj.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:@"text"];
    [dict setObject:[self checkandreturnValue:messageObj.localid] forKey:@"localid"];
    [dict setObject:[self checkandreturnValue:messageObj.jid] forKey:@"jid"];
    [dict setObject:[self checkandreturnValue:messageObj.readstatus] forKey:@"readstatus"];
    [dict setObject:[self checkandreturnValue:messageObj.file_ext] forKey:@"file_ext"];
    [dict setObject:[self checkandreturnValue:messageObj.fileName] forKey:@"fileName"];
    [dict setObject:[self checkandreturnValue:messageObj.datestring] forKey:@"datestring"];
    [dict setObject:[self checkandreturnValue:messageObj.isgroupchat] forKey:@"isgroupchat"];
    
    if (messageObj.jsonvalues != nil) {
        [dict setObject:messageObj.jsonvalues forKey:@"jsonvalues"];
    }
    return dict;
}

- (Message *)convertDicToMessage:(MessageDic *)messageDic{
    
    NSManagedObjectContext * moc = [[ChatStorageDB sharedInstance] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];

    Message * dict = [[Message alloc] initWithEntity:entity insertIntoManagedObjectContext:moc];
    
    dict.fromjid = messageDic.fromjid;
    dict.tojid = messageDic.tojid;
    dict.displayname = messageDic.displayname;
    dict.messagetype = messageDic.messagetype;
    dict.sentdate = messageDic.sentdate;
    dict.deliver = messageDic.deliver;
    dict.text = messageDic.text;
    dict.jid = messageDic.jid;
    dict.readstatus = messageDic.readstatus;
    dict.file_ext = messageDic.file_ext;
    dict.fileName = messageDic.fileName;
    dict.datestring = messageDic.datestring;
    dict.isgroupchat = messageDic.isgroupchat;
    dict.localid = messageDic.localid;

    return dict;
}

- (void)sendPushNotification:(NSString*)type localid:(NSString*)localid text:(NSString*)textmessage{
    
//    if(self.scheduledDate)
//        return;
    
    if(![labelStatus.text.lowercaseString isEqualToString:@"Online"]){
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
        [dict setObject:[Utilities getReceiverId] forKey:@"receiver"];
        
        NSString * groupChat;
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isgroupchat"] isEqualToString:@"1"]) {
            groupChat = @"1";
        }else{
            groupChat = @"0";
        }
        [dict setObject:groupChat forKey:@"isgroupchat"];
        [dict setObject:textmessage forKey:@"text_message"];
        [dict setObject:type forKey:@"type"];
        [dict setObject:localid forKey:@"localid"];
        [dict setObject:@"sendpushnotification" forKey:@"cmd"];
        
        [WebService sendForPushNotification:dict completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        }];
    }
}


- (UIImage*)blur:(UIImage*)theImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:3.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    
    return returnImage;
    
    // *************** if you need scaling
    // return [self scaleIfNeeded:cgImage];
}

-(UIImage*) scaleIfNeeded:(CGImageRef)cgimg {
    
    bool isRetina = [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0;
    if (isRetina) {
        return [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
    } else {
        return [UIImage imageWithCGImage:cgimg];
    }
}

- (void)finishAsset{
    
    PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = false;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    // assets contains PHAsset objects.
    __block UIImage *ima;
    
    for (PHAsset *asset in self.assets) {
        
        // Do something with the asset
        if (asset.mediaType == PHAssetMediaTypeImage) {
            
            [manager requestImageForAsset:asset
                               targetSize:PHImageManagerMaximumSize
                              contentMode:PHImageContentModeDefault
                                  options:requestOptions
             
                            resultHandler:^void(UIImage *image, NSDictionary *info) {
                                ima = image;
                                
                                [[XMPPConnect sharedInstance].dictFileInputs removeAllObjects];
                                
                                self.localidforfile = [[XMPPConnect sharedInstance] getLocalId];
                                
                                [[XMPPConnect sharedInstance].dictFileInputs setObject:self.localidforfile forKey:@"localid"];
                                
                                [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:self.localidforfile :@"jpg"] file:UIImageJPEGRepresentation(image, 0.5)];
                                
                                [[XMPPConnect sharedInstance].dictFileInputs setObject:image forKey:@"image"];
                                
                                [self filetransfer:@"Image" image:image];

                            }];

        }else if (asset.mediaType == PHAssetMediaTypeVideo){
            
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHVideoRequestOptionsVersionOriginal;
            
            [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
                NSURL *selectedVideoUrl = [(AVURLAsset *)asset URL];

                [[XMPPConnect sharedInstance].dictFileInputs removeAllObjects];
                self.localidforfile = [[XMPPConnect sharedInstance] getLocalId];
                [[XMPPConnect sharedInstance].dictFileInputs setObject:self.localidforfile forKey:@"localid"];
                
                if(selectedVideoUrl) {
                    
                    trimTempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"trimTmpMov1.MOV"];
                    [Utilities deleteTmpFile:trimTempPath];
                    
                    self.stringOriginalPath = selectedVideoUrl.path;
                    
                    videoSize = [Utilities getVideoFileSize:self.stringOriginalPath];
                    videoDuration = [Utilities durationOfVideo:self.stringOriginalPath];
                    
                    [self VideofileTransfer];
                }
            }];
            
        }else if (asset.mediaType == PHAssetResourceTypeAudio){
            
            [manager requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                
            }];
        }else{
            //Unknown filetype
        }
    }
    
    // [self reloadCollectionView];
}

/*
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(PHAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}
*/

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    return (picker.selectedAssets.count < 10);
}


- (void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagepic = [[UIImagePickerController alloc]init];
        imagepic.delegate = self;
        imagepic.allowsEditing = YES;
        imagepic.sourceType = UIImagePickerControllerSourceTypeCamera;

        [self presentViewController:imagepic animated:YES completion:nil];
        
    }
    else
    {
     
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    [[XMPPConnect sharedInstance].dictFileInputs removeAllObjects];
    
    self.localidforfile = [[XMPPConnect sharedInstance] getLocalId];
    
    [[XMPPConnect sharedInstance].dictFileInputs setObject:self.localidforfile forKey:@"localid"];
    
    UIImage * img = [Utilities fixOrientation:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    
    [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:self.localidforfile :@"jpg"] file:UIImageJPEGRepresentation(img, 0.5)];
    
    [[XMPPConnect sharedInstance].dictFileInputs setObject:img forKey:@"image"];
    [self filetransfer:@"Image" image:img];

}

#pragma video filetransfer
-(void)VideofileTransfer{
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:self.stringOriginalPath];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        
        self.startTime= 0;
        
        NSURL *furl = [NSURL fileURLWithPath:trimTempPath];
        
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeMPEG4;
        
        
        CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);

        CMTimeRange range = CMTimeRangeMake(start, anAsset.duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self videoTrimSuccess:[NSURL fileURLWithPath:trimTempPath]];
                    });
                    
                    break;
            }
        }];
    }
}

-(void)videoTrimSuccess:(NSURL*)url{

    UIImage *thumb = [self getMovieFrmeFromSecond:0 url:url];
    
    UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:thumb];
    if(scaledImgH){
        
    }
    else{
        NSData *data = UIImageJPEGRepresentation(thumb, 0.5);
        scaledImgH = [UIImage imageWithData:data];
    }
    
    NSData *videodata  = [NSData dataWithContentsOfURL:url];
    [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:self.localidforfile :@"mp4"] file:videodata];
    [self filetransferWithVideoAndOtherFiles:@"Video" image:scaledImgH withFileUrl:url];
}

- (UIImage*)getMovieFrmeFromSecond:(Float64)seconds url:(NSURL*)_videoUrl{
    
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    imageGenerator.appliesPreferredTrackTransform=TRUE;
    imageGenerator.maximumSize = CGSizeMake(320*2, 460*2);
    
    NSError *error;
    CMTime timeFrame = CMTimeMakeWithSeconds(seconds, 600);
    
    CMTime actualTime;
    
    CGImageRef halfWayImage = [imageGenerator  copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
    
    UIImage *videoScreen;
    // videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
    videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
    //  videoScreen =[Utilities scaleAndRotateImageUIImage:videoScreen];
    
    return videoScreen;
}

- (void)filetransfer:(NSString*)filetype image:(UIImage*)thumbimage{
    
    // NSString *localId = [[XMPPConnect sharedInstance] getLocalId];
    
    NSMutableDictionary * dict = [NSMutableDictionary new];
    
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:[Utilities checkNil:[Utilities getReceiverName]] forKey:@"displayname"];
    
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)([filetype isEqualToString:@"Image"] ? MessageTypeImage : MessageTypeVideo)] forKey:@"messagetype"];
    
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:@"" forKey:@"text"];
    
    [dict setObject:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"] forKey:@"localid"];
    
    [dict setObject:@"yes" forKey:@"readstatus"];
    
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    
    NSString * filePath = [Utilities getFilePathNew:self.localidforfile :@"jpg"];
    
    [dict setObject:[filePath lastPathComponent] forKey:@"fileName"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
//    [Utilities configureprogressview:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"]];
    
    if([filetype isEqualToString:@"Image"]){
        
        [dict setObject:@"jpg" forKey:@"file_ext"];
        
        UIImage * img = [[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"image"];
        
        UIImage * scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(150, 100) scaleIfSmaller:YES image:img];
        
        scaledImgH = [self blur:scaledImgH];
        
        if(scaledImgH == nil){
            scaledImgH = [[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"image"];
        }
       
        [dict setObject: UIImageJPEGRepresentation(scaledImgH, 0.05) forKey:@"image"];
        
        [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];

//        NSData * data =  UIImageJPEGRepresentation(scaledImgH, 0.05);
//        [dict removeObjectForKey:@"image"];
//        
//        [dict setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"image"];
        
    }
    else{
        
        [dict setObject:@"mp4" forKey:@"file_ext"];
        
        [dict setObject: UIImageJPEGRepresentation(thumbimage, 0.05) forKey:@"image"];
        
        [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
        
//        NSData * data = UIImageJPEGRepresentation(thumbimage, 0.05);
//        [dict removeObjectForKey:@"image"];
//        
//        [dict setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"image"];
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    MessageDic * msgDic = [MessageDic messageDicWith:dict];
    
    /****************/
    JSQMessage * photoMessage;
    
    if([filetype isEqualToString:@"Image"]){
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:thumbimage];
        
        photoMessage = [JSQMessage messageWithSenderId:self.senderId displayName:self.senderDisplayName media:photoItem message:msgDic];
        
    }else if([filetype isEqualToString:@"Video"]){
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:nil isReadyToPlay:YES];
        videoItem.thumpImage = thumbimage;
        
        photoMessage = [JSQMessage messageWithSenderId:self.senderId displayName:self.senderDisplayName media:videoItem message:msgDic];
    }
    
    [self.collectionView performBatchUpdates:^{
        
        [self insertNewMessage:photoMessage];
        
    } completion:^(BOOL finished) {
        
        [self scrollToBottomAnimated:YES];
    }];
    
    /****************/
}


- (void)filetransferWithVideoAndOtherFiles:(NSString*)filetype image:(UIImage*)thumbimage withFileUrl:(NSURL *)fileurl{
    
    NSMutableDictionary * dict = [NSMutableDictionary new];
    
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:[Utilities checkNil:[Utilities getReceiverName]] forKey:@"displayname"];
    
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)([filetype isEqualToString:@"Image"] ? MessageTypeImage : MessageTypeVideo)] forKey:@"messagetype"];
    
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:@"" forKey:@"text"];
    
    [dict setObject:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"] forKey:@"localid"];
    
    [dict setObject:@"yes" forKey:@"readstatus"];
    
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    
    NSString * filePath = [Utilities getFilePathNew:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"] :@"jpg"];
    
    [dict setObject:[filePath lastPathComponent] forKey:@"fileName"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
//    [Utilities configureprogressview:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"]];

    JSQMessage * photoMessage;

    if([filetype isEqualToString:@"Video"]){
        
        [dict setObject:@"mp4" forKey:@"file_ext"];
        
        [dict setObject: UIImageJPEGRepresentation(thumbimage, 0.05) forKey:@"image"];
        
        [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
        
//        NSData * data = UIImageJPEGRepresentation(thumbimage, 0.05);
//        [dict removeObjectForKey:@"image"];
//        [dict setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"image"];
//        
        MessageDic * msgDic = [MessageDic messageDicWith:dict];
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:fileurl isReadyToPlay:YES];
        videoItem.thumpImage = thumbimage;
        photoMessage = [JSQMessage messageWithSenderId:self.senderId displayName:self.senderDisplayName media:videoItem message:msgDic];
    }

    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self.collectionView performBatchUpdates:^{
        
        [self insertNewMessage:photoMessage];
        
    } completion:^(BOOL finished) {
        
        [self scrollToBottomAnimated:YES];
    }];
    
    /****************/
}


- (void)reloadCollectionView{
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

#pragma mark get messages

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}

- (void)fetchedResultsControllerChatHistoryWithCompletionBlock:(void (^)())completion
{
    if(self.fetchedResultsController)
        self.fetchedResultsController = nil;
    
    self.searchString = @"";
    
    NSManagedObjectContext * moc = [[ChatStorageDB sharedInstance] managedObjectContext];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:entity];
//    
    [fetchRequest setFetchLimit:100];         // Let's say limit fetch to 100
    [fetchRequest setFetchBatchSize:20];      // After 20 are faulted
    
    NSPredicate *predicate;
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        
        if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
            predicate = [NSPredicate predicateWithFormat:@"jid=%@",self.receiverId];
        }
        else{
            predicate = [NSPredicate predicateWithFormat:@"jid=%@ AND text contains[c] %@",self.receiverId,self.searchString];
        }
    }
    else{
        if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
            predicate = [NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (fromjid=%@ AND tojid=%@)",self.senderId,self.receiverId,self.receiverId,self.senderId];
        }
        else{
            predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@ AND text contains[c] %@) OR (fromjid=%@ AND tojid=%@ AND text contains[c] %@)",self.senderId,self.receiverId,self.searchString,self.receiverId,self.senderId,self.searchString];
        }
    }
    

    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    
//    NSError * error;
//    NSArray * objects = [moc executeFetchRequest:fetchRequest error:&error];
//
//    for (Message * messagess in objects) {
//         NSLog(@"%@",messagess);
//    }

    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"datestring" cacheName:nil];
    
    NSError *error = nil;
    
    [self.fetchedResultsController.managedObjectContext performBlock:^{
        NSError * fetchError = nil;
        
        if (![self.fetchedResultsController performFetch:&fetchError]){
            /// handle the error. Don't just log it.
            NSLog(@"Error performing fetch: %@", error);
        } else {
            
            if (completion) {
                
                for (id<NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
                    
                    for (Message * messagess in [sectionInfo objects]) {
                        
                        NSLog(@"%@",messagess);
                        NSDictionary * dic = [self convertMessageObjtoDic:messagess];
                        
                        if ([self.senderId isEqualToString:[messagess valueForKey:@"fromjid"]]) {
                            [self updateOutGoingMessages:dic with:messagess];
                        }else{
                            [self updateIncomingMessages:dic];
                        }
                    }
                }
                
                //[self reloadCollectionView];
                completion();
            }
        }
    }];
}

/*************************************************************/

- (void)updatingMessagesAnyNewMessagesAvialable{
    
    if(self.fetchedResultsController)
        self.fetchedResultsController = nil;
    
    NSManagedObjectContext * moc = [[ChatStorageDB sharedInstance] managedObjectContext];
    
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchLimit:100];         // Let's say limit fetch to 100
    [fetchRequest setFetchBatchSize:20];      // After 20 are faulted
    [fetchRequest setFetchOffset:self.demoData.messages.count];
    
    NSPredicate *predicate;
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        
        if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
            predicate = [NSPredicate predicateWithFormat:@"jid=%@",self.receiverId];

        }
        else{
            predicate=[NSPredicate predicateWithFormat:@"jid=%@ AND text contains[c] %@",self.receiverId,self.searchString];

        }
    }
    else{
        if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
            predicate = [NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (fromjid=%@ AND tojid=%@)",self.senderId,self.receiverId,self.receiverId,self.senderId];

        }
        else{
            predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@ AND text contains[c] %@) OR (fromjid=%@ AND tojid=%@ AND text contains[c] %@) ",self.senderId,self.receiverId,self.searchString,self.receiverId,self.senderId,self.searchString];

        }
    }
    
    //[fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate:predicate];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:moc sectionNameKeyPath:@"datestring" cacheName:nil];
    
    NSError *error = nil;
    
    [self.fetchedResultsController.managedObjectContext performBlock:^{
        NSError * fetchError = nil;
        
        if (![self.fetchedResultsController performFetch:&fetchError]){
            /// handle the error. Don't just log it.
            NSLog(@"Error performing fetch: %@", error);
        } else {
            for (id<NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
                
                for (Message * messagess in [sectionInfo objects]) {
                    
                    NSLog(@"%@",messagess);
                    NSDictionary * dic = [self convertMessageObjtoDic:messagess];
                    
                    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.messageDic.localid contains[cd] %@",messagess.localid];
                    NSArray * filteredArray = [self.demoData.messages filteredArrayUsingPredicate:bPredicate];
                    NSLog(@"HERE %@",filteredArray);
                    
                    if (filteredArray.count == 0) {
                        if ([self.senderId isEqualToString:[messagess valueForKey:@"fromjid"]]) {
                            [self updateOutGoingMessages:dic with:messagess];
                        }else{
                            [self updateIncomingMessages:dic];
                        }
                    }
                }
            }
            
            [self reloadCollectionView];
        }
    }];
}

- (void)updateOutGoingMessages:(NSDictionary*)messDic with:(Message*)messagess{
    
    /*MessageDic * receivedMessage = [MessageDic messageDicWith:dic];
     
     NSString * meesgetext = [messagess.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     
     JSQMessage * typedMessage = [JSQMessage messageWithSenderId:self.senderId displayName:messagess.displayname text:meesgetext message:receivedMessage];
     
     [self.demoData.messages addObject:typedMessage];*/
    
    /******/
    
    MessageDic * receivedMessage = [MessageDic messageDicWith:messDic];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    //    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    NSLog(@"%@",messDic);
    JSQMessage * copyMessage;
    
    if([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:photoItem message:receivedMessage];
        
    }else if([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeFile]]){
        
        NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",messagess.localid,[messagess.fileName pathExtension]]];
        
        CSFileItem * fileItem = [[CSFileItem alloc] initWithFilePath:filePath];
        
         copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:fileItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
        
        NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",receivedMessage.localid,[receivedMessage.fileName pathExtension]]];
        NSURL * videoUrl = [[NSURL alloc] initFileURLWithPath:filePath];
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoUrl isReadyToPlay:YES];
        
        //UIImage *img = [[UIImage alloc] initWithData:receivedMessage.image];
       // videoItem.thumpImage = img;

        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:videoItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation]]){
        
        JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:locationItem message:receivedMessage];
        
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
        
        CSContactItem * contactItem = [[CSContactItem alloc] initWithContact:@"" andContactName:[messDic objectForKey:@"text"] withUserImage:nil];
        
        contactItem.backgroundColor = [UIColor jsq_messageBubbleGreenColor];
        
        NSString * number = @"";
        if(receivedMessage.jsonvalues != nil){
            NSArray * arrayJsonValues = [NSJSONSerialization JSONObjectWithData:receivedMessage.jsonvalues options:NSJSONReadingMutableContainers error:nil];
            if (arrayJsonValues.count > 0) {
                NSDictionary * contactDic = [arrayJsonValues objectAtIndex:0];
                if ([contactDic objectForKey:@"number"] != [NSNull null]) {
                    number = [contactDic objectForKey:@"number"] ;
                    contactItem.phoneNumber = number;
                }
            }
        }        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"]  displayName:[messDic objectForKey:@"displayname"] media:contactItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
        
        CSAudioItem * audioItem = [[CSAudioItem alloc] initWithAudioiFile:nil];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"]  displayName:[messDic objectForKey:@"displayname"] media:audioItem message:receivedMessage];
    }
    else{
        
        NSString * meesgetext = [messagess.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        copyMessage = [JSQMessage messageWithSenderId:self.senderId displayName:messagess.displayname text:meesgetext message:receivedMessage];
    }
    
    JSQMessage *newMessage = nil;
    id<JSQMessageMediaData> newMediaData = nil;
    id newMediaAttachmentCopy = nil;
    
    if (copyMessage.isMediaMessage) {
        /**
         *  Last message was a media message
         */
        id<JSQMessageMediaData> copyMediaData = copyMessage.media;
        
        if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
            JSQPhotoMediaItem * photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
            photoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
//            newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
            
            /**
             *  Set image to nil to simulate "downloading" the image
             *  and show the placeholder view
             */
            photoItemCopy.image = nil;
            
            newMediaData = photoItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
            
//            copyMessage = [self createLocationMediaMessageCompletion:messDic with:^{
//            }];
//            
            JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
            locationItemCopy.appliesMediaViewMaskAsOutgoing = YES;
//            newMediaAttachmentCopy = [locationItemCopy.location copy];
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            locationItemCopy.location = nil;
            newMediaData = locationItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
            JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
            videoItemCopy.appliesMediaViewMaskAsOutgoing = YES;
            newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
            
            UIImage *img = [[UIImage alloc] initWithData:messagess.image];
            videoItemCopy.thumpImage = img;
            /**
             *  Reset video item to simulate "downloading" the video
             */
            videoItemCopy.fileURL = nil;
            videoItemCopy.isReadyToPlay = NO;
            
            newMediaData = videoItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[CSContactItem class]]) {
            CSContactItem * contactItemCopy = [((CSContactItem *)copyMediaData) copy];
            contactItemCopy.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];
            
            contactItemCopy.appliesMediaViewMaskAsOutgoing = YES;
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            newMediaData = contactItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[CSAudioItem class]]){
            
            CSAudioItem * audioItem = [((CSAudioItem *)copyMediaData) copy];

            audioItem.appliesMediaViewMaskAsOutgoing = YES;
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            newMediaData = audioItem;
        }
        else if ([copyMediaData isKindOfClass:[CSFileItem class]]){
            
            CSFileItem * fileItem = [((CSFileItem *)copyMediaData) copy];
            
            fileItem.appliesMediaViewMaskAsOutgoing = YES;
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            newMediaData = fileItem;
        }
        else {
            NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
        }
        
        newMessage = [JSQMessage messageWithSenderId:self.senderId
                                         displayName:copyMessage.senderDisplayName
                                               media:newMediaData message:receivedMessage];
    }
    else {
        /**
         *  Last message was a text message
         */
        newMessage = [JSQMessage messageWithSenderId:self.senderId displayName:messagess.displayname text:[messDic objectForKey:@"text"] message:receivedMessage];
    }
    
    if (![self.demoData.messages containsObject:newMessage]) {
        
        [self.demoData.messages addObject:newMessage];
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    
                    NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",newMessage.messageDic.localid,newMessage.messageDic.file_ext]];
                    
                    /* Fetch the image from the server... */
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                    
                    UIImage *img = [[UIImage alloc] initWithData:data];
        
                    ((JSQPhotoMediaItem *)newMediaData).image = img;
                    [self.collectionView reloadData];
                    
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    
                    
                    NSArray * arr = [newMessage.messageDic.text componentsSeparatedByString:@","];
                    
                    CLLocation * ferryBuildingInSF;
                    
                    if (arr.count > 0) {
                        ferryBuildingInSF = [[CLLocation alloc]initWithLatitude:[[arr objectAtIndex:0] floatValue] longitude:[[arr objectAtIndex:1] floatValue]];
                    }
                    
                    [((JSQLocationMediaItem *)newMediaData)setLocation:ferryBuildingInSF withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }else if ([newMediaData isKindOfClass:[CSContactItem class]]){
                    
                    ;
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
            });
        }
    }else{

    }
}

- (void)updateIncomingMessages:(NSDictionary*)messDic{
    
    MessageDic * receivedMessage = [MessageDic messageDicWith:messDic];
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    //    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    NSLog(@"%@",messDic);
    
    NSString * groupChat = [messDic objectForKey:@"isgroupchat"];
    
    if (![groupChat isEqualToString:@"1"]) {
        [messDic setValue:@"" forKey:@"displayname"];
    }else{
        NSString * username = [[ContactDb sharedInstance]validateUserName:[messDic valueForKey:@"fromjid"]];
        [messDic setValue:username forKey:@"displayname"];
        receivedMessage.displayname = username;
    }
    
    JSQMessage * copyMessage;
    
    if([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:photoItem message:receivedMessage];
        
    }else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation]]){
        
        JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:locationItem message:receivedMessage];
    }
    else if([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeFile]]){
        
        NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",receivedMessage.localid,[receivedMessage.fileName pathExtension]]];
        
        CSFileItem * fileItem = [[CSFileItem alloc] initWithFilePath:filePath];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:fileItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
        
        NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",receivedMessage.localid,[receivedMessage.fileName pathExtension]]];
        NSURL * videoUrl = [[NSURL alloc] initFileURLWithPath:filePath];
        
        JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoUrl isReadyToPlay:YES];
        
        UIImage *img = [[UIImage alloc] initWithData:receivedMessage.image];
        videoItem.thumpImage = img;
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:videoItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
    
        CSContactItem * contactItem = [[CSContactItem alloc] initWithContact:@"" andContactName:[messDic objectForKey:@"text"] withUserImage:nil];
        contactItem.jsonData = receivedMessage.jsonvalues;

        NSString * number = @"";
        if(receivedMessage.jsonvalues != nil){
            NSArray * arrayJsonValues = [NSJSONSerialization JSONObjectWithData:receivedMessage.jsonvalues options:NSJSONReadingMutableContainers error:nil];
            if (arrayJsonValues.count > 0) {
                NSDictionary * contactDic = [arrayJsonValues objectAtIndex:0];
                if ([contactDic objectForKey:@"number"] != [NSNull null]) {
                    number = [contactDic objectForKey:@"number"] ;
                    contactItem.phoneNumber = number;
                }
            }
        }
        contactItem.backgroundColor = [UIColor jsq_messageBubbleGreenColor];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"]  displayName:[messDic objectForKey:@"displayname"] media:contactItem message:receivedMessage];
    }
    else if ([[messDic valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
        
        CSAudioItem * audioItem = [[CSAudioItem alloc] initWithAudioiFile:nil];
        
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"]  displayName:[messDic objectForKey:@"displayname"] media:audioItem message:receivedMessage];
    }
    else{
        copyMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] text:[messDic objectForKey:@"text"] message:receivedMessage];
    }
    
    JSQMessage *newMessage = nil;
    id<JSQMessageMediaData> newMediaData = nil;
    id newMediaAttachmentCopy = nil;
    
    if (copyMessage.isMediaMessage) {
        /**
         *  Last message was a media message
         */
        id<JSQMessageMediaData> copyMediaData = copyMessage.media;
        
        if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
            
            JSQPhotoMediaItem * photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
            photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
            //newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
            
            /**
             *  Set image to nil to simulate "downloading" the image
             *  and show the placeholder view
             */
            photoItemCopy.image = nil;
            
            newMediaData = photoItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
            JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
            locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
            //newMediaAttachmentCopy = [locationItemCopy.location copy];
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            locationItemCopy.location = nil;
            newMediaData = locationItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
            JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
            videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
            newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
            
            UIImage *img = [[UIImage alloc] initWithData:receivedMessage.image];
            videoItemCopy.thumpImage = img;
            
            /**
             *  Reset video item to simulate "downloading" the video
             */
            videoItemCopy.fileURL = nil;
            videoItemCopy.isReadyToPlay = NO;
            
            newMediaData = videoItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[CSContactItem class]]) {
            CSContactItem * contactItemCopy = [((CSContactItem *)copyMediaData) copy];
            contactItemCopy.backgroundColor = [UIColor jsq_messageBubbleGreenColor];
            
            contactItemCopy.appliesMediaViewMaskAsOutgoing = NO;
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            newMediaData = contactItemCopy;
        }
        else if ([copyMediaData isKindOfClass:[CSAudioItem class]]){
            
            CSAudioItem * audioItem = [((CSAudioItem *)copyMediaData) copy];
            
            audioItem.appliesMediaViewMaskAsOutgoing = NO;
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            newMediaData = audioItem;
        }
        else if ([copyMediaData isKindOfClass:[CSFileItem class]]){
            
            CSFileItem * fileItem = [((CSFileItem *)copyMediaData) copy];
            
            fileItem.appliesMediaViewMaskAsOutgoing = NO;
            
            /**
             *  Set location to nil to simulate "downloading" the location data
             */
            newMediaData = fileItem;
        }
        else {
            NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
        }
        
        newMessage = [JSQMessage messageWithSenderId:copyMessage.senderId
                                         displayName:copyMessage.senderDisplayName
                                               media:newMediaData message:receivedMessage];
    }
    else {
        /**
         *  Last message was a text message
         */
        newMessage =[JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] text:[messDic objectForKey:@"text"] message:receivedMessage];
    }
    
    if (![self.demoData.messages containsObject:newMessage]) {
        [self.demoData.messages addObject:newMessage];
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    
                    NSString *filePath = [Utilities documentsPath:[NSString stringWithFormat:@"%@.%@",newMessage.messageDic.localid,newMessage.messageDic.file_ext]];
                    
                    /* Fetch the image from the server... */
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                    
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    ((JSQPhotoMediaItem *)newMediaData).image = img;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    
                    NSArray * arr = [newMessage.messageDic.text componentsSeparatedByString:@","];
                    
                    CLLocation * ferryBuildingInSF;
                    
                    if (arr.count > 0) {
                        ferryBuildingInSF = [[CLLocation alloc]initWithLatitude:[[arr objectAtIndex:0] floatValue] longitude:[[arr objectAtIndex:1] floatValue]];
                    }
                    
                    [((JSQLocationMediaItem *)newMediaData)setLocation:ferryBuildingInSF withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }else if ([newMediaData isKindOfClass:[CSContactItem class]]){
//                    NSString * number = @"";
//                    if(newMessage.messageDic.jsonvalues != nil){
//                        NSArray * arrayJsonValues = [NSJSONSerialization JSONObjectWithData:newMessage.messageDic.jsonvalues options:NSJSONReadingMutableContainers error:nil];
//                        if (arrayJsonValues.count > 0) {
//                            NSDictionary * contactDic = [arrayJsonValues objectAtIndex:0];
//                            if ([contactDic objectForKey:@"number"] != [NSNull null]) {
//                                number = [contactDic objectForKey:@"number"] ;
//                                
//                                ((CSContactItem *)newMediaData).phoneNumber = number;
//                                [self.collectionView reloadData];
//                            }
//                        }
//                    }
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
            });
        }
    }else{
        return;
    }
}

#pragma mark Contact

- (void)openContact{
    
    ABPeoplePickerNavigationController * peoplePicker =
    [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = (id<ABPeoplePickerNavigationControllerDelegate>)self;
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    });
    
    if(ABRecordGetRecordType(person) ==  kABPersonType) // this check execute if it is person group
    {
        NSMutableArray *arrayvalues = [[NSMutableArray alloc]init];
        
        NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        if(imgData){
            
        }
        else{
            
        }
        
        NSString * strname = @"";
        
        NSString * firstNameString = [Utilities checkNil:(__bridge NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty)];
        NSString * lastNameString = [Utilities checkNil:(__bridge NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty)];
        
        if(([firstNameString isEqualToString:@""])&&(![lastNameString isEqualToString:@""])){
            strname = lastNameString;
        }else if((![firstNameString isEqualToString:@""])&&([lastNameString isEqualToString:@""])){
            strname = firstNameString;
        }else if((![firstNameString isEqualToString:@""])&&(![lastNameString isEqualToString:@""])){
            strname = [NSString stringWithFormat:@"%@ %@",firstNameString,lastNameString];
        }
       
        ABMultiValueRef *phones = (ABMultiValueRef*)ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        for(CFIndex j = 0; j <ABMultiValueGetCount(phones) ; j++)
        {
            CFStringRef labelStingRef = ABMultiValueCopyLabelAtIndex (phones, j);
            
            NSString *phoness = [Utilities checkNil:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)];
            NSString* label = [Utilities checkNil:(__bridge NSString*)ABAddressBookCopyLocalizedLabel(labelStingRef)];
            if(![phoness isEqualToString:@""]){
                NSMutableDictionary *dictValues = [[NSMutableDictionary alloc]init];
                [dictValues setObject:[Utilities checkNil:phoness] forKey:@"number"];
                [dictValues setObject:[Utilities checkNil:label] forKey:@"label"];
                [dictValues setObject:@"Mobile" forKey:@"Type"];
                [arrayvalues addObject:dictValues];
            }
        }
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
            CFStringRef labelStingRef = ABMultiValueCopyLabelAtIndex (emails, j);
            
            NSString* email = [Utilities checkNil:(__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j)];
            NSString* label = [Utilities checkNil:(__bridge NSString*)ABAddressBookCopyLocalizedLabel(labelStingRef)];
            if(![email isEqualToString:@""]){
                
                if([label isEqualToString:@""]){
                    label = @"Other";
                }
                
                email =[email stringByReplacingOccurrencesOfString:@"," withString:@""];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:email forKey:@"number"];
                [dict setObject:label forKey:@"label"];
                [dict setObject:@"Email" forKey:@"Type"];
                [arrayvalues addObject:dict];
            }
        }
        
        // if(arrayvalues.count>0){
        [self shareContact:arrayvalues name:strname imagedata:imgData];
        //}
    }
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    
    if(ABRecordGetRecordType(person) ==  kABPersonType) // this check execute if it is person group
    {
        NSMutableArray *arrayvalues = [[NSMutableArray alloc]init];
        
        NSData  *imgData = (__bridge_transfer NSData *) ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        if(imgData){
            
        }
        else{
            
        }
        NSString *strname = @"";
        
        NSString *firstNameString = [Utilities checkNil:(__bridge NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty)];
        NSString *lastNameString = [Utilities checkNil:(__bridge NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty)];
        if(([firstNameString isEqualToString:@""])&&(![lastNameString isEqualToString:@""])){
            strname = lastNameString;
        }
        else if((![firstNameString isEqualToString:@""])&&([lastNameString isEqualToString:@""])){
            strname = firstNameString;
        }
        else if((![firstNameString isEqualToString:@""])&&(![lastNameString isEqualToString:@""])){
            strname = [NSString stringWithFormat:@"%@ %@",firstNameString,lastNameString];
        }
        ABMultiValueRef *phones = (ABMultiValueRef*)ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        for(CFIndex j = 0; j <ABMultiValueGetCount(phones) ; j++)
        {
            CFStringRef labelStingRef = ABMultiValueCopyLabelAtIndex (phones, j);
            
            NSString *phoness = [Utilities checkNil:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)];
            NSString* label = [Utilities checkNil:(__bridge NSString*)ABAddressBookCopyLocalizedLabel(labelStingRef)];
            if(![phoness isEqualToString:@""]){
                NSMutableDictionary *dictValues = [[NSMutableDictionary alloc]init];
                [dictValues setObject:[Utilities checkNil:phoness] forKey:@"number"];
                [dictValues setObject:[Utilities checkNil:label] forKey:@"label"];
                [dictValues setObject:@"Mobile" forKey:@"Type"];
                
                [arrayvalues addObject:dictValues];
            }
        }
        
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
            CFStringRef labelStingRef = ABMultiValueCopyLabelAtIndex (emails, j);
            
            NSString* email = [Utilities checkNil:(__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j)];
            NSString* label = [Utilities checkNil:(__bridge NSString*)ABAddressBookCopyLocalizedLabel(labelStingRef)];
            if(![email isEqualToString:@""]){
                
                if([label isEqualToString:@""]){
                    label = @"Other";
                }
                
                email =[email stringByReplacingOccurrencesOfString:@"," withString:@""];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:email forKey:@"number"];
                [dict setObject:label forKey:@"label"];
                [dict setObject:@"Email" forKey:@"Type"];
                
                [arrayvalues addObject:dict];
            }
        }

        [self shareContact:arrayvalues name:strname imagedata:imgData];
    }
    return NO;
}

- (void)shareContact:(NSMutableArray*)array name:(NSString*)name imagedata:(NSData*)imagedata{
    
    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities checkNil:[Utilities getReceiverName]] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact] forKey:@"messagetype"];
    
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:name forKey:@"text"];
    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setObject:localid forKey:@"fileName"];
    
    if(imagedata){
        [dict setObject:imagedata forKey:@"image"];
    }
    
    if(array.count > 0){
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
        [dict setObject:data forKey:@"jsonvalues"];
    }
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }

    /*************/
    MessageDic * msgDic = [MessageDic messageDicWith:dict];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    NSString * number = @"";
    if (array.count > 0) {
        NSDictionary * contactDic = [array objectAtIndex:0];
        if ([contactDic objectForKey:@"number"] != [NSNull null]) {
            number = [contactDic objectForKey:@"number"] ;
        }
    }
    CSContactItem * contactItem = [[CSContactItem alloc] initWithContact:number andContactName:name withUserImage:imagedata];

    contactItem.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];
    JSQMessage * contactMessage = [JSQMessage messageWithSenderId:[Utilities getSenderId]
                                                      displayName:[Utilities getSenderNickname]
                                                            media:contactItem
                                   message:msgDic];
    [self insertNewMessage:contactMessage];
    [self finishSendingMessageAnimated:YES];
    /*************/
    
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendPushNotification:@"contact" localid:localid text:@""];
        self.scheduledDate = nil;
    }];
}

#pragma mark Location

- (void)sendCurrentLocation{
    
    [self removeShowFilesView];

    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    
    CLLocation * ferryBuildingInSF = [self.locationManager location];
    
    NSLog(@"%f",ferryBuildingInSF.coordinate.latitude);
    
    self.currentLocLat = [NSString stringWithFormat:@"%f",ferryBuildingInSF.coordinate.latitude];
    self.currentLocLon = [NSString stringWithFormat:@"%f",ferryBuildingInSF.coordinate.longitude];

    [self transferLocation:[NSString stringWithFormat:@"%@,%@",self.currentLocLat,self.currentLocLon]];
}

- (JSQMessage*)createLocationMediaMessageCompletion:(NSDictionary *)messDic with:(JSQLocationMediaItemCompletionBlock)completion
{
    MessageDic * msgDic = [MessageDic messageDicWith:messDic];
    
    NSArray * arr = [[messDic objectForKey:@"text"] componentsSeparatedByString:@","];
    
    CLLocation * ferryBuildingInSF;
    
    if (arr.count > 0) {
        ferryBuildingInSF = [[CLLocation alloc]initWithLatitude:[[arr objectAtIndex:0] floatValue] longitude:[[arr objectAtIndex:1] floatValue]];
    }
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:[messDic objectForKey:@"fromjid"] displayName:[messDic objectForKey:@"displayname"] media:locationItem message:msgDic];
    
    return locationMessage;
}

- (void)addLocationMediaMessageCompletion:(NSDictionary*)messDic withCompletion:(JSQLocationMediaItemCompletionBlock)completion{
    
    MessageDic * msgDic = [MessageDic messageDicWith:messDic];

    CLLocation * ferryBuildingInSF = [[CLLocation alloc]initWithLatitude:[self.currentLocLat floatValue] longitude:[self.currentLocLon floatValue]];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:[Utilities getSenderId]
                                                      displayName:[Utilities getSenderNickname]
                                                            media:locationItem message:msgDic];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [self.demoData.messages addObject:locationMessage];
}

- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    [Utilities alertViewFunction:@"" message:error.localizedDescription];
    NSLog(@"%@", @"Core location can't get a fix.");
}



- (void)transferLocation:(NSString*)location{
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:[Utilities checkNil:[Utilities getReceiverName]] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:location forKey:@"text"];
    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:@"" forKey:@"serverid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setObject:localid forKey:@"fileName"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
    /*************/
    __weak DemoMessagesViewController * demoView = self;
    __weak UICollectionView *weakView = self.collectionView;
    
    [self addLocationMediaMessageCompletion:dict withCompletion:^{
        [weakView reloadData];
        [demoView scrollToBottomAnimated:YES];
    }];
    /*************/
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self sendPushNotification:@"location" localid:localid text:@""];
    }];
}
/************/
//Record Audio
/************/

- (void)recordAudio{

    if([audioEnabled isEqualToString:@"No"]){
        
        if(self.recordView){
            [self.recordView.view removeFromSuperview];
            self.recordView = nil;
        }
        
        audioEnabled = @"Yes";
        self.recordView = [[RecordViewController alloc]init];
        
       [self.view bringSubviewToFront:self.recordView.view];
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.2];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromTop];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        [self.recordView.view setFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.height, 180)];
        
        self.inputToolbar.frame = CGRectMake(self.inputToolbar.contentView.frame.origin.x, [UIScreen mainScreen].bounds.size.height - 224, self.inputToolbar.contentView.frame.size.width, self.inputToolbar.contentView.frame.size.height + 180);
        
        [[self.recordView.view layer] addAnimation:animation forKey:nil];
        
        recordCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //recordCancelButton.frame = CGRectMake(6,12,24,24);
        //recordCancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [recordCancelButton setImage:[UIImage imageNamed:@"delete_cross_icon"] forState:UIControlStateNormal];
        recordCancelButton.tag = 1;
        self.inputToolbar.contentView.leftBarButtonItem = recordCancelButton;
        
        [self scrollToBottomAnimated:YES];
        [self.inputToolbar addSubview:self.recordView.view];
        self.inputToolbar.contentView.rightBarButtonItem.enabled = YES;
    }
    else{
        [self resetAudioView];
    }
}

- (void)removeRecordView{
    
    if ([audioEnabled isEqualToString:@"Yes"]) {
        //addButton.hidden = NO;
        [self.recordView.voice stopRecordWithCompletionBlock:^{
            
        }];
        self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;

        [recordCancelButton removeFromSuperview];
        
        [self.recordView.view removeFromSuperview];
        self.recordView = nil;
        
        [self resetAudioView];
        audioEnabled = @"No";
        
        UIButton * addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        addButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [addButton setImage:[UIImage imageNamed:@"add_chat"] forState:UIControlStateNormal];
        addButton.tag = 0;
        self.inputToolbar.contentView.leftBarButtonItem = addButton;

    }
}

- (void)resetAudioView{

    if(self.recordView){
        [self.recordView.view removeFromSuperview];
        self.recordView = nil;
    }
    self.inputToolbar.frame= CGRectMake(self.inputToolbar.contentView.frame.origin.x,[UIScreen mainScreen].bounds.size.height - (self.inputToolbar.contentView.frame.size.height), self.inputToolbar.contentView.frame.size.width, self.inputToolbar.contentView.frame.size.height);
}

- (void)audioTransfer{
    
    NSString *localid = [[XMPPConnect sharedInstance]getLocalId];
    
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()] toPath:[Utilities getAudioFilePath:localid] error:nil];

    NSMutableDictionary * dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:[Utilities checkNil:[Utilities getReceiverName]] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:@"" forKey:@"text"];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setObject:@"caf" forKey:@"file_ext"];
    
    NSString * filepath = [Utilities getAudioFilePath:localid];
    [dict setObject:[filepath lastPathComponent] forKey:@"fileName"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
    [Utilities configureprogressview:localid];
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    /*************/
    MessageDic * msgDic = [MessageDic messageDicWith:dict];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    CSAudioItem * audioItem = [[CSAudioItem alloc] initWithAudioiFile:nil];
    audioItem.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];
    JSQMessage * contactMessage = [JSQMessage messageWithSenderId:[Utilities getSenderId]
                                                      displayName:[Utilities getSenderNickname]
                                                            media:audioItem
                                                          message:msgDic];
    [self insertNewMessage:contactMessage];
    [self finishSendingMessageAnimated:YES];
    /*************/

}

//no use , so commented
/*
-(void) recordStart
{

    [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
}

-(void)recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime > 0.0f) {
            
        }
    }];
}

-(void)recordCancel
{
    [self.voice cancelled];
    
}*/


#pragma mark - dropBox

- (void)openDropbox
{
    DBSession *dbSession = [[DBSession alloc] initWithAppKey:Dropbox_App_Key appSecret:Dropbox_App_Secret_Key root:kDBRootDropbox];
    [DBSession setSharedSession:dbSession];
    
    DropboxBrowserViewController * dropboxBrowser = [[DropboxBrowserViewController alloc] init];
    dbSession.delegate = dropboxBrowser;
    dropboxBrowser.allowedFileTypes = @[
                                        @"jpg",@"tiff", @"gif", @"jpeg",
                                        @"mp3", @"aiff", @"m4a", @"wav",
                                        @"mov", @"mp4", @"m4v",
                                        @"doc",@"docx",
                                        @"ppt",@"pptx",
                                        @"xls",@"xlsx",
                                        @"pdf",
                                        @"key",
                                        @"pages",
                                        @"numbers",
                                        @"htm",@"html",
                                        @"txt",@"rtf"]; // Uncomment to filter file types. Create an array of allowed types. To allow all file types simply don't set the property
    // dropboxBrowser.tableCellID = @"DropboxBrowserCell"; // Uncomment to use a custom UITableViewCell ID. This property is not required
    
    // When a file is downloaded (either successfully or unsuccessfully) you can have DBBrowser notify the user with Notification Center. Default property is NO.
    // dropboxBrowser.deliverDownloadNotifications = YES;
    
    // Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.
    dropboxBrowser.shouldDisplaySearchBar = YES;
    
    // Set the delegate property to recieve delegate method calls
    dropboxBrowser.rootViewDelegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dropboxBrowser];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (FileType)fileType:(NSString*)fileName
{
    FileType type = FileTypeUnknown;
    
    NSString *pathExtension = [fileName pathExtension];
    if ([pathExtension isEqualToString:@"png"] || [pathExtension isEqualToString:@"jpg"] || [pathExtension isEqualToString:@"jpeg"] || [pathExtension isEqualToString:@"JPG"]) {
        type = FileTypeImage;
    }
    else if([pathExtension isEqualToString:@"mov"] || [pathExtension isEqualToString:@"mp4"]){
        type = FileTypeVideo;
    }
    
    return type;
}

- (FileType)checkBoxfileType:(NSString*)fileName
{
    FileType type = FileTypeUnknown;
    
    if ([fileName isEqualToString:@"png"] || [fileName isEqualToString:@"jpg"] || [fileName isEqualToString:@"jpeg"] || [fileName isEqualToString:@"JPG"]) {
        type = FileTypeImage;
    }
    else if([fileName isEqualToString:@"mov"] || [fileName isEqualToString:@"mp4"]){
        type = FileTypeVideo;
    }
    
    return type;
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (void)sendFiles:(NSArray*)files
{
    NSDate *scheduledDateCopy = [_scheduledDate copy];
    
    __weak DemoMessagesViewController *weakSelf = self;
    
    [files enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString * path = [obj objectForKey:@"filePath"];
        weakSelf.scheduledDate = scheduledDateCopy;
        [self shareFile:path fileType:[self fileType:[path lastPathComponent]] message:[obj objectForKey:@"message"]];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)BoxfileDownloaded:(NSString*)filePath withExtension:(NSString*)fileExtension{
    [self shareFile:filePath fileType:[self checkBoxfileType:fileExtension] message:@""];
}

//- (void)sendFilesfromGoogleDrive:(NSString *)filePath
//{
//    [self shareFile:filePath fileType:[self fileType:[filePath lastPathComponent]] message:@""];
//}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten {
    
    if (isLocalFileOverwritten == YES) {
        NSLog(@"Downloaded %@ by overwriting local file", fileName);
    } else {
        NSLog(@"Downloaded %@ without overwriting", fileName);
    }
    
    [self shareFile:[DropboxBrowserViewController dropboxFilePath:fileName] fileType:[self fileType:fileName] message:@""];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)shareFile:(NSString*)filePath fileType:(FileType)fileType message:(NSString*)message
{
    [[XMPPConnect sharedInstance].dictFileInputs removeAllObjects];
    self.localidforfile = [[XMPPConnect sharedInstance] getLocalId];
    [[XMPPConnect sharedInstance].dictFileInputs setObject:self.localidforfile forKey:@"localid"];
    
    if(fileType == FileTypeVideo) {
        
        trimTempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"trimTmpMov1.MOV"];
        [Utilities deleteTmpFile:trimTempPath];
        
        self.stringOriginalPath = filePath;
        
        videoSize = [Utilities getVideoFileSize:self.stringOriginalPath];
        videoDuration = [Utilities durationOfVideo:self.stringOriginalPath];
        [self trim1];
    }
    else if(fileType == FileTypeImage){
        
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        
        [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:self.localidforfile:@"jpg"] file:UIImageJPEGRepresentation(image, 0.5)];
        
        [[XMPPConnect sharedInstance].dictFileInputs setObject:image forKey:@"image"];
        
        [self filetransfer:@"Image" image:image];
    }
    else{
        [self transferData:[NSData dataWithContentsOfFile:filePath] path:filePath fileType:FileTypeUnknown message:message];
    }
}

- (void)transferData:(NSData*)data path:(NSString*)path fileType:(FileType)type message:(NSString*)message
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"tojid"];
    [dict setObject:[Utilities getReceiverId] forKey:@"jid"];
    [dict setObject:[Utilities checkNil:[Utilities getReceiverName]] forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeFile] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:(message?message:@"") forKey:@"text"];
    [dict setObject:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"] forKey:@"localid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:[Utilities checkNil:[path lastPathComponent]] forKey:@"fileName"];
    [dict setObject:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    
    [Utilities configureprogressview:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"]];
    
    [dict setObject:[Utilities checkNil:[path pathExtension]] forKey:@"file_ext"];
    
    if (self.scheduledDate) {
        [dict setObject:self.scheduledDate forKey:@"scheduled_date"];
    }
    
    [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"] :[Utilities checkNil:[path pathExtension]]] file:data];
    
    // [dict setObject:data forKey:@"file"];
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:NO];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    MessageDic * msgDic = [MessageDic messageDicWith:dict];
    
    /****************/
    JSQMessage * fileMessage;
    
    NSString * filePath = [Utilities getFilePathNew:[[XMPPConnect sharedInstance].dictFileInputs objectForKey:@"localid"] :[Utilities checkNil:[path pathExtension]]];
    
    CSFileItem * fileItem = [[CSFileItem alloc] initWithFilePath:filePath];
    
    fileMessage = [JSQMessage messageWithSenderId:self.senderId displayName:self.senderDisplayName media:fileItem message:msgDic];
    
    [self.collectionView performBatchUpdates:^{
        
        [self insertNewMessage:fileMessage];
        
    } completion:^(BOOL finished) {
        
        [self scrollToBottomAnimated:YES];
    }];

    /*
    __weak DemoMessagesViewController * weakSelf = self;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if ([message length]) {
            [weakSelf sendTextMessage:message];
        }
        weakSelf.scheduledDate = nil;
    }];*/
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName {
    NSLog(@"Failed to download %@", fileName);
}

- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error {
    NSLog(@"File conflict between %@ and %@\n%@ last modified on %@\nError: %@", localFileURL.lastPathComponent, dropboxFile.filename, dropboxFile.filename, dropboxFile.lastModifiedDate, error);
}

- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser {
    // This method is called after Dropbox Browser is dismissed. Do NOT dismiss DropboxBrowser from this method
    // Perform any UI updates here to display any new data from Dropbox Browser
    // ex. Update a UITableView that shows downloaded files or get the name of the most recently selected file:
    //     NSString *fileName = [DropboxBrowserViewController currentFileName];
}

#pragma mark Trim


-(void) trim1{
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:self.stringOriginalPath];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        self.startTime= 0;
        
        NSURL *furl = [NSURL fileURLWithPath:trimTempPath];
        
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeMPEG4;
        
        
        CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
        //        CMTime duration = CMTimeMakeWithSeconds(self.stopTime-self.startTime, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, anAsset.duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self trimSuccess1:[NSURL fileURLWithPath:trimTempPath]];
                    });
                    
                    break;
            }
        }];
    }
}

- (void)trimSuccess1:(NSURL*)url{
    
    UIImage * thumb = [self getMovieFrmeFromSecond:0 url:url];
    
    UIImage * scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:thumb];
    
    if(scaledImgH){
        
    }
    else{
        NSData *data = UIImageJPEGRepresentation(thumb, 0.5);
        scaledImgH = [UIImage imageWithData:data];
    }
    
    NSData * videodata  = [NSData dataWithContentsOfURL:url];
    
    [Utilities saveFilesWithEncryption:[Utilities getFilePathNew:self.localidforfile :@"mp4"] file:videodata];
    
    [self filetransferWithVideoAndOtherFiles:@"Video" image:thumb withFileUrl:url];
}

/**************************/
#pragma mark -
#pragma mark Box SDK integration

- (void)openBoxFolder
{
    BOXSampleAccountsViewController *accountsViewController = nil;
    accountsViewController = [[BOXSampleAccountsViewController alloc]initWithAppUsers:NO];
    accountsViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:accountsViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark Resend Failure Messages

- (void)didResendMessage:(NSIndexPath *)path{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    if([messagess.deliver isEqualToString:@"3"]||[messagess.deliver isEqualToString:@"4"]){
        
        self.selectedIndexPath = path;
        
        NSArray *array = [[ChatStorageDB sharedInstance]getFailedMessages:[Utilities getSenderId] receiver:self.receiverId];
        
        actionSheetOptionOpenResendMessages = [[UIActionSheet alloc]initWithTitle:@"Resend" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send again",[NSString stringWithFormat:@"Resend %lu from today",(unsigned long)array.count],@"Delete", nil];
        
        [actionSheetOptionOpenResendMessages showInView:self.view];
        
    }
    
}

- (void)resendSingleMessage{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    [self resendMessages:messagess];
    
    //raj
    /*__weak DemoMessagesViewController *weakSelf = self;
    
    [self fetchedResultsControllerChatHistoryWithCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf.collectionView reloadData];
        }];
    }];*/
}

- (void)resendMessages:(Message*)tempS{
    
    [[ChatStorageDB sharedInstance]updateUploadDB:tempS.localid status:@"1" keyvalue:@"deliver"];
    
    NSString *localId = tempS.localid;
    
    NSArray *keys = [[[tempS entity] attributesByName] allKeys];
    
    NSDictionary *dict1 = [tempS dictionaryWithValuesForKeys:keys];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
    [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
    [dict setValue:[Utilities getReceiverId] forKeyPath:@"jid"];
    [dict setValue:[Utilities getReceiverId] forKeyPath:@"tojid"];
    [dict setValue:localId forKeyPath:@"localid"];
    [dict setValue:[NSDate date] forKey:@"sentdate"];
    [dict setValue:@"1" forKey:@"deliver"];
    [dict setValue:@"yes" forKey:@"readstatus"];
    [dict setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setValue:[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dict setValue:[Utilities checkNil:tempS.fileName] forKeyPath:@"fileName"];
    
    NSString *strname = @"";
    if([tempS.isgroupchat isEqualToString:@"1"]){
        strname = [[ChatStorageDB sharedInstance]validateGroupName:tempS.jid].capitalizedString;
    }
    else{
        strname = [[ContactDb sharedInstance]validateUserName:tempS.jid].capitalizedString;
    }
    
    [dict setValue:[Utilities checkNil:strname] forKey:@"displayname"];
    
    
    if(![[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
        [dict removeObjectForKey:@"jsonvalues"];
    }
    
    
    if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
        [dict removeObjectForKey:@"image"];
    }
    else if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
        [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[tempS valueForKey:@"localid"] :@"Image"] toPath:[Utilities getFilePath:localId :@"Image"] error:nil];
        
        
    }
    else if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
        [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[tempS valueForKey:@"localid"] :@"Video"] toPath:[Utilities getFilePath:localId :@"Video"] error:nil];
        
    }
    else if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
        [dict removeObjectForKey:@"image"];
        [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[tempS valueForKey:@"localid"] :@"Audio"] toPath:[Utilities getFilePath:localId :@"Audio"] error:nil];
    }
    else if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
        
        NSData *dataimage = [tempS valueForKey:@"image"];
        
        if(dataimage){
            // [dict setValue:[NSString stringWithFormat:@"%@",[dataimage base64Encoded]] forKey:@"image"];
            
        }
        else{
            [dict removeObjectForKey:@"image"];
        }
        
        
    }
    [dict removeObjectForKey:@"deliverydate"];
    
    // [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:dict incoming:YES];
    [dict removeObjectForKey:@"sentdate"];
    
    if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]||[[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]||[[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
        
        if([[tempS valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
            
            NSData *data = [tempS valueForKey:@"jsonvalues"];
            [dict setValue:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"jsonvalues"];
            
            NSData *dataimage = [tempS valueForKey:@"image"];
            
            if(dataimage){
                [dict setValue:[NSString stringWithFormat:@"%@",[dataimage xmpp_base64Encoded]] forKey:@"image"];
                
            }
            else{
                [dict removeObjectForKey:@"image"];
            }
        }
        else{
            [dict setValue:[NSString stringWithFormat:@"%@",[[tempS valueForKey:@"image"] xmpp_base64Encoded]] forKey:@"image"];
        }
    }
    
    [[XMPPConnect sharedInstance]messageSendToReceiver:dict];
    
}

- (void)resendMultipleMessages{
    
    NSArray *array = [[ChatStorageDB sharedInstance]getFailedMessages:[Utilities getSenderId] receiver:self.receiverId];
    
    for (Message *tempS in  array) {
        [self resendMessages:tempS];
        
    }
    //raj
    /*
    __weak DemoMessagesViewController *weakSelf = self;
    
    [self fetchedResultsControllerChatHistoryWithCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf.collectionView reloadData];
        }];
    }];*/
}

#pragma Delete Action

- (void)locationAction{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    MapDetailViewController *map = [[MapDetailViewController alloc]init];
    NSArray *array = [messagess.text componentsSeparatedByString:@","];
    if(array.count > 0){
        map.lattitude = [array objectAtIndex:0];
        map.longtitude = [array objectAtIndex:1];
    }
    [[self navigationController]pushViewController:map animated:YES];
}

- (void)contactViewAction{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    //Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    
    AddToContactsViewController *add = [[AddToContactsViewController alloc]init];
    NSData  *imgData =  jsmessage.messageDic.image;
    if(imgData){
        add.userImage = [UIImage imageWithData:imgData];
    }
    else{
        add.userImage = [UIImage imageNamed:@"ment.png"];
    }
    
    NSString *strname = [Utilities checkNil:jsmessage.messageDic.text];
    add.stringUsername = strname;
    
    if(jsmessage.messageDic.jsonvalues){
        add.arrayJsonValues = [NSJSONSerialization JSONObjectWithData:jsmessage.messageDic.jsonvalues options:NSJSONReadingMutableContainers error:nil];
    }
    
    [[self navigationController]pushViewController:add animated:YES];
}

- (void)deleteAction{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dict setObject:messagess.localid forKey:@"localid"];
    [dict setObject:@"deleteschedulemessages" forKey:@"cmd"];
    
    [WebService runCMD:dict completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [[ChatStorageDB sharedInstance]deleteRecord:messagess.localid];
        
        [[ChatStorageDB sharedInstance] updateChatSession:self.receiverId isgroupchat:[Utilities checkNil:[[NSUserDefaults standardUserDefaults] objectForKey:@"isgroupchat"]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.demoData.messages removeObject:jsmessage];
            [self.collectionView reloadData];
        });

        /*__weak DemoMessagesViewController *weakSelf = self;
        [self fetchedResultsControllerChatHistoryWithCompletionBlock:^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf.collectionView reloadData];
            }];
        }];*/
        
    }];
}

- (void)infoAction{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    MessageInfoViewController *info = [[MessageInfoViewController alloc]init];
    info.object = messagess;
    info.cellCopy  = self.selectedIndexCell;
    
    [[self navigationController] pushViewController:info animated:YES];
}

#pragma Copy Action

- (void)copyAction{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
        [[UIPasteboard generalPasteboard] setString:messagess.text];
    }
    else{
        
        if([messagess.transferstatus isEqualToString:@"uploadcompleted"]||[messagess.transferstatus isEqualToString:@"downloadcompleted"]|[messagess.transferstatus isEqualToString:@"uploadprogress"]||[messagess.transferstatus isEqualToString:@"uploadfailed"]||[messagess.transferstatus isEqualToString:@"uploadstart"]){
            
            NSData *dat = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[Utilities getFilePath:[messagess valueForKey:@"localid"] :@"Image"]]];
            [[UIPasteboard generalPasteboard] setImage:[UIImage imageWithData:dat]];
        }
    }
}

#pragma Forward Action

- (void)forwardAction{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    CurrentChatsViewController * chats = [[CurrentChatsViewController alloc]init];
    [chats.arrayObjects addObject:messagess];
    [[self navigationController]pushViewController:chats animated:YES];
}

- (void)playAudio{
    
    JSQMessage * jsmessage = [self.demoData.messages objectAtIndex:self.selectedIndexPath.row];
    Message * messagess = [self convertDicToMessage:jsmessage.messageDic];
    
    NSString * filePath = [Utilities getAudioFilePath:messagess.localid];
    NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL
                                                          error:nil];
    [_audioPlayer play];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:YES];
    [self scrollToBottomAnimated:YES];
}

@end
