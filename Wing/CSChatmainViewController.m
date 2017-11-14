
#import "CSChatmainViewController.h"
#import "AppDelegate.h"
#import "GUIDesign.h"
#import <QuartzCore/QuartzCore.h>
#import "MHGallery.h"

#import "ContactDb.h"
#import "ChatSession.h"
#import "ChatStorageDB.h"
#import "ChatMainTableViewCell.h"

#import "MessgaeTypeConstant.h"
#import "UIImageView+AFNetworking.h"

#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

#import <MessageUI/MessageUI.h>
#import "WebService.h"
#import "Utilities.h"
#import "SVProgressHUD.h"

#import "DemoMessagesViewController.h"
#import "CSPersonChooseViewController.h"
#import "DeleteAllViewController.h"
#import "ProfileViewController.h"
#import "GroupProfileViewController.h"

@interface UserObj : NSObject

@property (nonatomic, copy) NSString * userName;
@property (nonatomic, copy) NSString * userStatus;
@property (nonatomic, copy) NSString * userLocation;
@property (nonatomic, copy) UIImage * userImage;

@end

@implementation UserObj

@end


@interface CSChatmainViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UISearchControllerDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate,MFMailComposeViewControllerDelegate>{
    
    AppDelegate* appDelegate;
    
    NSIndexPath * indexPathCommon;
    
    MHImageViewController * imageViewController;
    
    UIActionSheet *actionSheetMore;
    UIActionSheet *actionSheetMore1;
    UIActionSheet *actionSheetLongPress;
    
    NSTimer *timerTypingNotification;
    
    UITapGestureRecognizer *gesture1;
    UITapGestureRecognizer *singleTap;
    
    UIActionSheet *actionSheetEmailChat;
    
    BOOL openGrid;
    BOOL checkPage;
    
    CGFloat firstX;
    CGFloat firstY;
    
    UIActionSheet *actionsheetimage;
    
}

@property (nonatomic) BOOL isSearchEnabled;

@property (strong, nonatomic) UIImage * imageAnimation;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * cancelBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * editBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * addButton;

@property (nonatomic, strong) NSMutableDictionary * dictTyping;

@property(nonatomic,retain) NSFetchedResultsController *fetchRequestController;
@property (nonatomic, assign) BOOL showPanel;

@property(nonatomic,retain)MHGalleryController * gallery;

@property (nonatomic, assign) BOOL initialLoad;

@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic, strong) NSString *receiver_id;
@property (nonatomic, strong) NSString *isgroupchat;

@property (nonatomic, assign) BOOL animatingPane;
@property (nonatomic, assign) BOOL animatingRotation;
@property (nonatomic, assign) CGPoint paneStartLocation;
@property (nonatomic, assign) CGPoint paneStartLocationInSuperview;
@property (nonatomic, assign) CGFloat paneVelocity;

@property (nonatomic, strong) UserObj * userObj;

- (void)forwardFromMedia:(NSMutableArray*)arrayobjects;

@property(nonatomic) UISearchBar *seaarchBar;

@end

@implementation CSChatmainViewController
@synthesize arraymessages;
@synthesize chatTableView;

- (id)init{
    self = [super init];
    if (self) {
        
        self.title = @"Chats";
        
        UIImage * deselectedimage = [[UIImage imageNamed:@"chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage * selectedimage = [[UIImage imageNamed:@"chatSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:deselectedimage];
        [self.tabBarItem setSelectedImage:selectedimage];
        
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(-5, 0, 5, 0);
        
        if (screenHeight == 667) {
            
            self.tabBarItem.imageInsets = UIEdgeInsetsMake(-12, 0, 12, 0);
        }

        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    self.arraymessages = [[NSMutableArray alloc]init];
    self.dictTyping = [[NSMutableDictionary alloc]init];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Chats";
    
    self.editBtn = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editSelection:)];
    self.editBtn.tintColor = [UIColor blackColor];
    
    self.cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelSelection:)];
    self.cancelBtn.tintColor = [UIColor blackColor];
    
    self.addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionAdd:)];
    self.addButton.tintColor = [UIColor blackColor];
    
    self.deleteAllBtn = [[UIBarButtonItem alloc]initWithTitle:@"Delete(0)" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllSelection:)];
    self.deleteAllBtn.tintColor = [UIColor blackColor];

    self.navigationItem.leftBarButtonItem = self.editBtn;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    self.seaarchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    self.seaarchBar.placeholder = @"Search";
    self.seaarchBar.delegate = (id<UISearchBarDelegate>)self;
//    self.seaarchBar.searchResultsUpdater = (id<UISearchResultsUpdating>)self;
    self.seaarchBar.backgroundColor = [GUIDesign GrayColor];
    [self.view addSubview:self.seaarchBar];
    
    self.userObj = [[UserObj alloc]init];
    
    [[UITableViewCell appearance] setTintColor:[UIColor blackColor]];

    
    chatTableView = [GUIDesign initWithTabelview:self frmae:CGRectMake(0, self.seaarchBar.frame.size.height, screenWidth, screenHeight - self.seaarchBar.frame.size.height - 65 - 44)];
    
    [chatTableView setBackgroundView:[GUIDesign initWithImageView:CGRectMake(0, 0, screenWidth, screenHeight) img:@"appBg.png"]];
    chatTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    chatTableView.separatorColor = [UIColor lightTextColor];
    chatTableView.showsVerticalScrollIndicator = NO;
    self.chatTableView.allowsMultipleSelection = YES;
    self.chatTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:chatTableView];

}

/* Top Edit, Delete Cancel Selections Starts */

- (IBAction)editSelection:(id)sender{
    
    if(self.arraymessages.count == 0)
        return;
    
    self.navigationItem.rightBarButtonItem = self.deleteAllBtn;
    
    if(self.arraymessages.count == 1){
        self.addButton.title = @"Delete";
    }
    else{
        self.addButton.title = @"Delete All";
    }
    
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    self.title  = [NSString stringWithFormat:@"Chats (%lu)",(unsigned long)self.arraymessages.count];
    [self.chatTableView setEditing:YES animated:YES];

}

-(IBAction)deleteAllSelection:(id)sender{
    
    DeleteAllViewController *deleteall  =[[DeleteAllViewController alloc]init];
    deleteall.hidesBottomBarWhenPushed = YES;
    
    [[self navigationController]pushViewController:deleteall animated:YES];
}

-(IBAction)cancelSelection:(id)sender{
    
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.leftBarButtonItem = self.editBtn;
        self.title  = [NSString stringWithFormat:@"Chats"];
        
        [self.chatTableView setEditing:NO animated:YES];
        
    
}

/* Edit, Delete and Cancel Ends Here */
- (void)setGesture{
    
    gesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabelViewTapped:)];
    gesture1.cancelsTouchesInView = YES;
    [chatTableView addGestureRecognizer:gesture1];
}

- (void)tabelViewTapped:(UIGestureRecognizer*)sender{
    
    NSIndexPath *indexPath = [chatTableView indexPathForRowAtPoint:[sender locationInView:chatTableView]];
    
    if(indexPath){
        
        [chatTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
        // If you have custom logic in table view delegate method, also invoke this method too
        [self tableView:chatTableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)receiceLocationUpdate:(NSNotification*)notification{
    
    self.userObj.userLocation = [Utilities getLocation];
    [chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

//thangarajan
-(void)loadViewWillAppear{
    
    if(self.isSearchEnabled){
        self.isSearchEnabled = NO;
        return;
    }
    
    [chatTableView setEditing:NO animated:YES];
    
    self.navigationController.navigationBarHidden = NO;
    
    chatTableView.tableHeaderView  = nil;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.showingLeftPanel = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePresence:)
                                                 name:@"updatePresence"
                                               object:nil];
    [self getUsers];
    
    self.userObj.userName = [Utilities getSenderNickname];
    self.userObj.userLocation = [Utilities getLocation];
    self.userObj.userStatus = [Utilities getSenderStatus];
    
    [chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceivedNotification:)
                                                 name:@"messageReceived"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTypingNotification:)
                                                 name:@"TypingNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiceLocationUpdate:)
                                                 name:@"LocationUpdate"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTable)
                                                 name:@"reloadTable"
                                               object:nil];
    self.title = @"Chats";
}

- (void)getUsers{
    
    [self.arraymessages removeAllObjects];
    [self.arraymessages addObjectsFromArray:[[ChatStorageDB sharedInstance] getChatHistoryForUsers:[Utilities checkNil:self.searchString]]];
    [chatTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
//    NSData * arrayData = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatArray"];
//    self.ChatViewControllersArr = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
//    
//    NSLog(@"%@",self.ChatViewControllersArr);
//    
    [self loadViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated{
     [super viewDidAppear:YES];
}

-(void) didTapNavView
{
    NSLog(@"doSomething");
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{              // Default is 1 if not implemented
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arraymessages.count + 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0)
        return NO;
    
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
        return 189;
    
    return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        
        static NSString * identifier = @"Cell";

        ChatMainTableViewCell * cell = (ChatMainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(cell == nil){
            cell = [[ChatMainTableViewCell alloc] initWithStyle1:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.txt_name.text = self.userObj.userName;
        [cell.lblLocation setText:self.userObj.userLocation];
        cell.txt_status.text = self.userObj.userStatus = [Utilities getSenderStatus];

        cell.imageUser.layer.cornerRadius = cell.imageUser.frame.size.width / 2;
        cell.imageUser.clipsToBounds = YES;

        cell.imageBig.image = [UIImage imageNamed:@"banner_1_blur"];
        
        [cell.btnImagEdit addTarget:self action:@selector(imageEdit:) forControlEvents:UIControlEventTouchUpInside];
        cell.imageUser.image = [UIImage imageNamed:@"contactPlaceholder"];

        if(self.userObj.userImage == nil){
            
             cell.imageUser.image = [UIImage imageNamed:@"contactPlaceholder"];
            
            NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[Utilities getSenderId]]];
            
            dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(postImageQueue, ^{
                NSData *image = [[NSData alloc] initWithContentsOfURL:imageURL];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image != nil) {
                        cell.imageUser.image = [UIImage imageWithData:image];
                        self.userObj.userImage = [UIImage imageWithData:image];
                    }
                });
            });
        }
        else{
            //[UIImage imageWithContentsOfFile:[Utilities getUserImageFile:@"userimage_thumb.png"];
            [cell.imageUser setImage:self.userObj.userImage];
        }

        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    else{
        
        static NSString * identifier = @"chatCell";

        ChatMainTableViewCell * tempcell = (ChatMainTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if(tempcell == nil){
            tempcell = [[ChatMainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        tempcell.delegate = (id<MGSwipeTableCellDelegate>)self;

        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]init];
        [longpress addTarget:self action:@selector(longPressCell:)];
        longpress.minimumPressDuration = 0.3;
        
        [tempcell addGestureRecognizer:longpress];

        ChatSession *s = [self.arraymessages objectAtIndex:indexPath.row - 1];
        tempcell.lblName.text = s.displayname;
        
        [tempcell setBackgroundColor:[UIColor clearColor]];
        
        [tempcell.imageUser setHidden:NO];
        [tempcell.lblStatus setHidden:NO];
        tempcell.labelIcon.hidden = YES;
        
        [tempcell.lblTime setText:[Utilities relativeDateStringForDate:[s valueForKey:@"sentdate"]]];
        
        int count = [[ChatStorageDB sharedInstance]getReadStatusBetweenUsers:s.jid];

        if([s.isgroupchat isEqualToString:@"1"]){
            
            tempcell.lblName.text = [[ChatStorageDB sharedInstance]validateGroupName:s.jid].capitalizedString;
            [tempcell.btnBadge setHidden:YES];
            
            if(count > 0){
                tempcell.btnBadge.hidden = NO;
                [tempcell.btnBadge setTitle:(count==0 ? @"": [NSString stringWithFormat:@"%d",count]) forState:UIControlStateNormal];
            }
        }
        else{
            
            tempcell.lblName.text = [[ContactDb sharedInstance]validateUserName:s.jid].capitalizedString;
            
            [tempcell.btnBadge setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
            
            NSString *stringstatus = [[XMPPConnect sharedInstance].dictPresence objectForKey:s.jid];
            
            if(![[Utilities checkNil:stringstatus] isEqualToString:@""]){
                [tempcell.btnBadge setBackgroundImage:[UIImage imageNamed:@"green.png"] forState:UIControlStateNormal];
            }
            tempcell.btnBadge.hidden = NO;
            [tempcell.btnBadge setTitle:(count==0 ? @"": [NSString stringWithFormat:@"%d",count]) forState:UIControlStateNormal];
        }

        switch ([[s valueForKey:@"messagetype"] integerValue]) {
                
            case MessageTypeText:{
                tempcell.labelIcon.hidden = YES;
                [tempcell.lblStatus setText:[s valueForKey:@"text"]];
                break;
            }
            case MessageTypeImage:{
                tempcell.lblStatus.text = @"Image";
                tempcell.labelIcon.hidden = NO;
                [tempcell.labelIcon setImage:[UIImage imageNamed:@"image.png"]];
                
            }
                break;
            case MessageTypeVideo:{
                
                tempcell.lblStatus.text = @"Video";
                tempcell.labelIcon.hidden = NO;
                [tempcell.labelIcon setImage:[UIImage imageNamed:@"video_audio.png"]];
                
                [tempcell.labelIcon setFrame:CGRectMake(tempcell.labelIcon.frame.origin.x,tempcell.labelIcon.frame.origin.y, 18, 18)];
            }
                break;
            case MessageTypeLocation:{
                tempcell.labelIcon.hidden = YES;
                tempcell.lblStatus.text = @"Location";
                break;
            }
            case MessageTypeContact:{
                tempcell.labelIcon.hidden = YES;
                tempcell.lblStatus.text = @"Contact";
                break;
            }
            case MessageTypeAudio:{
                tempcell.labelIcon.hidden = YES;
                tempcell.lblStatus.text = @"Audio";
                break;
            }
            case MessageTypeFile:
                tempcell.labelIcon.hidden = YES;
                tempcell.lblStatus.text = @"File";
                
                break;
            default:
                break;
        }
        
        if (tempcell.labelIcon.hidden) {
            [tempcell.lblStatus setFrame:CGRectMake(CGRectGetMaxX(tempcell.imageUser.frame) + 15, tempcell.lblStatus.frame.origin.y, tempcell.frame.size.width - 75, 30)];
        }else{
            [tempcell.lblStatus setFrame:CGRectMake(CGRectGetMaxX(tempcell.labelIcon.frame) + 5, tempcell.lblStatus.frame.origin.y, tempcell.frame.size.width - 75, 30)];
        }

        [tempcell.dotTypingView setHidden:YES];
        
        [tempcell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[s.jid lowercaseString]]] placeholderImage:[UIImage imageNamed:@"contactPlaceholder"]];
        
        if([[self.dictTyping valueForKey:s.jid] isEqualToString:@"yes"]){
            if([s.isgroupchat isEqualToString:@"1"]){
                
                tempcell.lblStatus.text = [NSString stringWithFormat:@"%@ is typing...",[[ContactDb sharedInstance]validateUserName:[self.dictTyping valueForKey:@"senderid"]]];
            }
            else{
                tempcell.lblStatus.text = @"Typing...";
            }
        }
        return tempcell;
    }
    
    return nil;
}


- (void)longPressCell:(UILongPressGestureRecognizer*)sender{
    
    [self resignKeyBoard];
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [chatTableView indexPathForRowAtPoint:[sender locationInView:chatTableView]];
        
        if(indexPath){
            
            ChatSession *s = [self.arraymessages objectAtIndex:indexPath.row-1];
            
            indexPathCommon  = indexPath;
            
            if([s.isgroupchat isEqualToString:@"1"]){
                actionSheetLongPress = [[UIActionSheet alloc]initWithTitle:@"More" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Group Info",@"Exit Group",@"Delete This Conversation",@"Clear All Conversation", nil];
                actionSheetLongPress.tag = 2;
                [actionSheetLongPress showInView:self.view];
            }
            else{
                actionSheetLongPress = [[UIActionSheet alloc]initWithTitle:@"More" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call",@"View Info",@"Delete This Conversation",@"Clear All Conversation", nil];
                actionSheetLongPress.tag = 1;
                
                [actionSheetLongPress showInView:self.view];
            }
            
        }
    }
}


- (void)passcodeValidated:(NSString*)strjid isgroupchat:(NSString*)isgroupchat{
    self.receiver_id = strjid;
    self.isgroupchat = isgroupchat;
    checkPage = YES;
}

- (BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}


-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
    NSLog(@"Swipe state: %@ ::: Gesture: %@", str, gestureIsActive ? @"Active" : @"Ended");
}


- (NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = 0;
    
    __weak CSChatmainViewController * me = self;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
        expansionSettings.fillOnTrigger = NO;
        expansionSettings.threshold = 2;
        return @[[MGSwipeButton buttonWithTitle:@"" backgroundColor:[UIColor clearColor] padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
            return YES;
        }]];
    }
    else {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 5;
        
        NSIndexPath * indexPath = [me.chatTableView indexPathForCell:cell];
        
        ChatSession *s = [self.arraymessages objectAtIndex:indexPath.row - 1];
        
        NSString * hideString = @"Hide";
    
        NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:s.jid]];
        
        if(![str isEqualToString:@""]){
            hideString = @"Unhide";
        }
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"More"  icon:[UIImage imageNamed:@"more"] backgroundColor:[UIColor colorWithRed:253.0/255.0 green:195.0/255.0 blue:12.0/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            return YES;
        }];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:hideString  icon:[UIImage imageNamed:@"hide"] backgroundColor:[UIColor colorWithRed:253.0/255.0 green:195.0/255.0 blue:12.0/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [cell refreshContentView]; //needed to refresh cell contents while swipping
            return YES;
        }];
        
        if([s.isgroupchat isEqualToString:@"0"]){
            
            MGSwipeButton * more = [MGSwipeButton buttonWithTitle:@"Call"  icon:[UIImage imageNamed:@"call"] backgroundColor:[UIColor colorWithRed:253.0/255.0 green:195.0/255.0 blue:12.0/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                
                return NO;
            }];
            
            
            MGSwipeButton * empty = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage imageNamed:@""] backgroundColor:[UIColor clearColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                
                return YES;
            }];
            
            MGSwipeButton * empty1 = [MGSwipeButton buttonWithTitle:@"Close"  icon:[UIImage imageNamed:@"close"] backgroundColor:[UIColor clearColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
                
                return YES;
            }];
            
            return @[trash, flag, more,empty1];
        }
        
        MGSwipeButton * empty = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage imageNamed:@""] backgroundColor:[UIColor clearColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            return YES;
        }];
        
        MGSwipeButton * empty1 = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage imageNamed:@""] backgroundColor:[UIColor clearColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            return YES;
        }];
        
        MGSwipeButton * empty2 = [MGSwipeButton buttonWithTitle:@"Close"  icon:[UIImage imageNamed:@"close.png"] backgroundColor:[UIColor clearColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            return YES;
        }];

        return @[trash, flag,empty,empty2];
    }
    
    return nil;
    
}


#pragma mark navigation


- (void)reloadTable{
    [self getUsers];
    [self.chatTableView reloadData];
}

- (IBAction)actionAdd:(id)sender{
    //thangarajan
    CSPersonChooseViewController * person = [[CSPersonChooseViewController alloc]init];
    person.hidesBottomBarWhenPushed = YES;
    person.deletgate = (id<GoToChatViewDeletagte>)self;
    [[self navigationController]pushViewController:person animated:YES];
}

-(void)messageReceivedNotification:(NSNotification*)notification{
    
    [self getUsers];
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    if (direction == MGSwipeDirectionLeftToRight) {
        return YES;
    }
    
    switch (index) {
        case 0:
            [self actioMore:cell];
            
            break;
        case 1:
            [self actioHide:cell];
            
            break;
        case 2:
            [self actioCall:cell];
            break;
        case 4:
            [self deleConv:cell];
            break;
        default:
            break;
    }
    
    NSLog(@"%ld",(long)index);;
    
    return NO;
}

- (void)actioCall:(MGSwipeTableCell*)cell{
    __weak CSChatmainViewController * me = self;
    NSIndexPath * indexPath = [me.chatTableView indexPathForCell:cell];
    [self callAction:indexPath];
}

- (void)callAction:(NSIndexPath*)indexPath{

    ChatSession *s = [self.arraymessages objectAtIndex:indexPath.row-1];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",s.jid]]];
}

- (void)actioHide:(MGSwipeTableCell*)cell{
    
    __weak CSChatmainViewController * me = self;
    NSIndexPath * indexPath = [me.chatTableView indexPathForCell:cell];
    NSDictionary *s1 = [self.arraymessages objectAtIndex:indexPath.row-1];

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];

    BOOL unhide = NO;
    
    NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:[s1 valueForKey:@"jid"]]];
    
    if(![str isEqualToString:@""])
    {
        unhide = YES;
    }
    
    [app actioHideOrShowPasscode:[s1 valueForKey:@"jid"] viewcontrol:self isgroupchat:[s1 valueForKey:@"isgroupchat"] unhide:unhide];
}

- (void)passcodeSucceded{
    NSLog(@"success");
}

- (void)deleConv:(MGSwipeTableCell*)cell{
    
    __weak CSChatmainViewController * me = self;
    
    NSIndexPath * indexPath = [me.chatTableView indexPathForCell:cell];
    indexPathCommon = indexPath;
    
    [self showDeleteAlert:@"Do you want to delete this chat?"];
}

- (void)showDeleteAlert:(NSString *)message{
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Message"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"YES"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self deleteSingleConversation];
                             
                         }];
    UIAlertAction* no = [UIAlertAction
                         actionWithTitle:@"No"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    [alert addAction:no];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)actioMore:(MGSwipeTableCell*)cell{
    
    __weak CSChatmainViewController * me = self;
    
    NSIndexPath * indexPath = [me.chatTableView indexPathForCell:cell];
    
    ChatSession *s = [self.arraymessages objectAtIndex:indexPath.row-1];
    
    indexPathCommon = indexPath;
    
    if([s.isgroupchat isEqualToString:@"1"]){
        actionSheetMore1 = [[UIActionSheet alloc]initWithTitle:@"More" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Group Info",@"Exit Group",@"Delete Conversation",@"Email Conversation", nil];
        [actionSheetMore1 showInView:self.view];
        //raj @"Archive Conversation"
    }
    else{
        actionSheetMore = [[UIActionSheet alloc]initWithTitle:@"More" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Contact",@"Delete Conversation",@"Email Conversation", nil];
        //raj @"Add Conversation Shortcut",@"Archive Conversation",
        [actionSheetMore showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet == actionSheetMore){
        if(buttonIndex == 0){
            [self viewProfileInfo];
        }
        else if(buttonIndex==1){
            [self deleteSingleConversation];
        }
        else if(buttonIndex==2){
            [self emailChat];
        }
    }
    else if(actionSheet==actionSheetMore1){
        if(buttonIndex==0){
            [self viewGroupInfo];
        }
        else if(buttonIndex==1){
            [self exitGroupChat];
        }
        else if(buttonIndex==2){
            [self deleteSingleConversation];
        }
        else if(buttonIndex==3){
            [self emailChat];
        }
    }
    else if(actionSheet==actionSheetLongPress){
        
        if(actionSheetLongPress.tag == 1){
            if(buttonIndex==0){
                [self callAction:indexPathCommon];
            }
            else if(buttonIndex==1){
                [self viewProfileInfo];
            }
            else if(buttonIndex==2){
                [self deleteSingleConversation];
            }
            else if(buttonIndex==3){
                [self deleteAllConevrsations];
            }
        }
        else{
            if(buttonIndex==0){
                [self viewGroupInfo];
            }
            else if(buttonIndex==1){
                [self exitGroupChat];
            }
            else if(buttonIndex==2){
                [self deleteSingleConversation];
            }
            else if(buttonIndex==3){
                [self deleteAllConevrsations];
            }
            
        }
    }
    else if(actionSheet==actionSheetEmailChat){
        if(buttonIndex==0){
            [self createEmailForChat:YES];
        }
        else if(buttonIndex==1){
            [self createEmailForChat:NO];
        }
    }
    
    else if(actionSheet==actionsheetimage){
        if(buttonIndex==0){
            [self gallery:nil];
        }
        else if(buttonIndex==1){
            [self camera:nil];
        }else if (buttonIndex == 2){
            
            [self openImg];
        }
    }
}

// Ameen viewing image

-(void)openImg{
    
    
    MHGalleryItem * landschaft1;
    
    int presentationIndex = 0;
    
    NSMutableArray * galleryDataSource = [[NSMutableArray alloc]init];
    [galleryDataSource removeAllObjects];
    
    NSString * urlStr =[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[Utilities getSenderId]];
    

    
    NSURL * imageURL = [NSURL URLWithString:urlStr];
    
    NSData *image = [[NSData alloc] initWithContentsOfURL:imageURL];

    UIImage * usrImage = [UIImage imageWithData:image];
    
//    NSURL * urlString = [[NSURL alloc]initWithString:urlStr];
    
//    landschaft1 = [[MHGalleryItem alloc]initWithURL:urlStr galleryType:MHGalleryTypeImage];
//
    landschaft1 = [[MHGalleryItem alloc]initWithImage:usrImage];

        [galleryDataSource addObject:landschaft1];

    
    MHGalleryController * gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarHidden];
    gallery.galleryItems = galleryDataSource;
    gallery.presentingFromImageView = nil;
    gallery.UICustomization.showOverView =NO;
    gallery.UICustomization.barStyle = UIBarStyleBlackTranslucent;
    gallery.UICustomization.hideShare = YES;

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
    [self presentMHGalleryController:gallery animated:YES completion:nil];

}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor blackColor];
        }
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.textColor = [UIColor blackColor];
            
        }
    }
}

- (void)viewProfileInfo{
    
    ProfileViewController *profile = [[ProfileViewController alloc]init];
    
    ChatSession *object = [self.arraymessages objectAtIndex:indexPathCommon.row-1];
    NSString *name;
    name = [[ContactDb sharedInstance]validateUserName:[object valueForKey:@"jid"]];
    profile.receiver_id = [object valueForKey:@"jid"];
    profile.receiver_name = name;
    profile.receiver_nick_name = name;
    
    profile.pageFromChat = NO;
    [[self navigationController]pushViewController:profile animated:YES];
}

- (void)viewGroupInfo{
   
    ChatSession *object = [self.arraymessages objectAtIndex:indexPathCommon.row-1];
    NSString *name;
    name = [[ChatStorageDB sharedInstance]validateGroupName:[object valueForKey:@"jid"]].capitalizedString;
    GroupProfileViewController *profile = [[GroupProfileViewController alloc]init];
    profile.stringGroupId = [object valueForKey:@"jid"];
    profile.stringGroupName = name;
    [[self navigationController]pushViewController:profile animated:YES];
    
}

#pragma mark Email Chat

- (void)emailChat{
    
    actionSheetEmailChat = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Include Attachments",@"Without Attachements", nil];
    actionSheetEmailChat.tag = 3;
    [actionSheetEmailChat showInView:self.view];
    
}

- (void)createEmailForChat:(BOOL)includeFiles{
    
    ChatSession *object = [self.arraymessages objectAtIndex:indexPathCommon.row-1];
    
    NSMutableString *string = [[NSMutableString alloc]init];
    NSArray *array  =     [[ChatStorageDB sharedInstance]getChatHistoryBetweenUsers:[Utilities getSenderId] receiver:object.jid];
    NSString *name = @"";
    
    if([object.isgroupchat isEqualToString:@"1"]){
        name = [[ChatStorageDB sharedInstance]validateGroupName:[object valueForKey:@"jid"]];
        
    }
    else{
        name = [[ContactDb sharedInstance]validateUserName:[object valueForKey:@"jid"]];
    }

    NSDateFormatter *dateforma = [[NSDateFormatter alloc]init];
    [dateforma setDateFormat:@"dd MMM YYYY hh:mm:ss a"];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    [picker setSubject:[NSString stringWithFormat:@"WING Chat with %@",name.capitalizedString]];
    
    
    for (NSManagedObject *s in array) {
        
        if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation]]){
            if([string isEqualToString:@""]){
                [string appendString:@"\n"];
            }
            
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
                [string appendString:[NSString stringWithFormat:@"%@: %@: %@",[dateforma stringFromDate:[s valueForKey:@"sentdate"]],[[ContactDb sharedInstance]validateUserName:[s valueForKey:@"jid"]].capitalizedString,[s valueForKey:@"text"]]];
            }
            else{
                [string appendString:[NSString stringWithFormat:@"%@: %@: https://maps.google.com/?q=%@",[dateforma stringFromDate:[s valueForKey:@"sentdate"]],[[ContactDb sharedInstance]validateUserName:[s valueForKey:@"jid"]].capitalizedString,[s valueForKey:@"text"]]];
            }
        }
        
        if(includeFiles==YES){
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
                [picker addAttachmentData:[NSData dataWithContentsOfFile:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Image"]] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",[s valueForKey:@"localid"]]];
            }
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
                [picker addAttachmentData:[NSData dataWithContentsOfFile:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Video"]] mimeType:@"video/MOV" fileName:[NSString stringWithFormat:@"%@.MOV",[s valueForKey:@"localid"]]];
            }
            
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
                [picker addAttachmentData:[NSData dataWithContentsOfFile:[Utilities getAudioFilePath:[s valueForKey:@"localid"]]] mimeType:@"audio/caf" fileName:[NSString stringWithFormat:@"%@.caf",[s valueForKey:@"localid"]]];
            }
        }
    }
    
    if(![string isEqualToString:@""]){
        [string writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"] atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];

        [picker addAttachmentData:[NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"]] mimeType:@"text/txt" fileName:@"ChatHistory.txt"];
    }
    [picker setMessageBody:[NSString stringWithFormat:@"WING Chat: %@.txt",name] isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exitGroupChat{
    
    if([[XMPPConnect sharedInstance]getNetworkStatus]==NO){
        [Utilities alertViewFunction:@"" message:@"Unable to connect to remote server. Please try again"];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSDictionary *messagess1 = [self.arraymessages objectAtIndex:indexPathCommon.row-1];
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"exitgroup" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[messagess1 valueForKey:@"jid"] forKey:@"group_id"];
    
    [WebService groupChatUpdates:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms valueForKey:[messagess1 valueForKey:@"jid"]];
                if(room){
                    [room leaveRoom];
                }
                
                [[ChatStorageDB sharedInstance]leaveFromGroup:[messagess1 valueForKey:@"jid"]];
                [[XMPPConnect sharedInstance]sendGroupNotification:dic];
            }
        }
    }];
}

- (void)deleteSingleConversation{
    
    NSDictionary * object1 = [self.arraymessages objectAtIndex:indexPathCommon.row - 1];
    
    if ([appDelegate.chatViewControllersDic objectForKey:[object1 valueForKey:@"jid"]]) {
        [appDelegate.chatViewControllersDic removeObjectForKey:[object1 valueForKey:@"jid"]];
    }
    
    ChatSession *messagess = [self.arraymessages objectAtIndex:indexPathCommon.row - 1];
    [[ChatStorageDB sharedInstance]deleteChatHistoryBetweenGroups:[Utilities getSenderId] receiver:messagess.jid];
    [[ChatStorageDB sharedInstance]deleteChatSession:messagess.jid];
    
    [self.arraymessages removeObjectAtIndex:indexPathCommon.row - 1];

    [self.chatTableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathCommon, nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.chatTableView reloadData];
}

- (void)deleteAllConevrsations{
    
    [self deleteAllSelection:nil];
}

/*
- (UIView*)getLeftView{

    UIView *view1 = self.swiploginController.view;
    return view1;
    
    int currentcount = 0;
    NSMutableArray *galleryDataSource = [[NSMutableArray alloc]init];
    
    NSArray *array =[[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:[Utilities getReceiverId]];
    if(array.count>0){
        
        for (NSManagedObject *s in array) {
            NSString *type = @"Video";
            int typee = MHGalleryTypeVideo;
            switch ([[s valueForKey:@"messagetype"] integerValue]) {
                case MessageTypeImage:{
                    type = @"Image";
                    typee = MHGalleryTypeImage;
                    break;
                }
                default:
                    break;
            }
        
            NSLog(@"%@",[Utilities getFilePath:[s valueForKey:@"localid"] :type]);

            MHGalleryItem *landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:[Utilities getFilePath:[s valueForKey:@"localid"] :type]]]
                                                              galleryType:typee];
            [galleryDataSource addObject:landschaft1];
            
            currentcount++;
            
        }
    }
    
    MHGalleryItem *landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:[Utilities getFilePath:@"898E72B8-A8C4-42F8-A721-FC6AC62AA8E6" :@"Image"]]]
                                                      galleryType:MHGalleryTypeImage];
    [galleryDataSource addObject:landschaft1];
    
    
    if(self.gallery==nil){
        
        self.loginController =[[ LoginViewController alloc]init];
                [self.view addSubview:self.loginController.view];
        
        [self addChildViewController:self.loginController];
        [self.loginController didMoveToParentViewController:self];
        
    }
    
    
    
    
    UIView *view = self.loginController.view;
    return view;
    
}


-(void)movePanel:(id)sender {
}

-(void)movePanelToOriginalPosition {
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}



-(void)resetMainView {
    // remove left and right views, and reset variables, if needed
    if (self.gallery != nil) {
        [self.loginController.view removeFromSuperview];
        self.loginController = nil;
    }
    // remove view shadows
}
*/

- (IBAction)actionEdit:(id)sender{
    
    if(self.arraymessages.count==0)
        return;
    
    //self.navigationItem.rightBarButtonItem = self.deleteAllBtn;
    
    if(self.arraymessages.count==1){
        self.addButton.title = @"Delete";
    }
    else{
        self.addButton.title = @"Delete All";
    }
    
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    self.title  = [NSString stringWithFormat:@"Chats (%lu)",(unsigned long)self.arraymessages.count];
    [self.chatTableView setEditing:YES animated:YES];
}

- (IBAction)actionCancel:(id)sender{
    self.addButton.title = @"Add";
    self.cancelBtn.title = @"Cancel";
    
//    self.navigationItem.rightBarButtonItem = self.addBtn;
//    self.navigationItem.leftBarButtonItem = self.editBtn;
    self.title  = [NSString stringWithFormat:@"Chats"];
    
    [self.chatTableView setEditing:NO animated:YES];
    
}


/*- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
 
 
 self.searchBar.text  = searchBar.text;
 
 [self getUsers];
 
 }*/// called when text changes (including clear)

/*- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
 [searchBar resignFirstResponder];
 }//*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![textField.text isEqualToString:@""]){
        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] error:nil];
        
        [self uploadPhoto];
    }
    //  [Utilities saveDefaultsValues:textField.text :@"nickname"];
    return YES;
}

- (void)imageEdit:(id)sender{
    actionsheetimage = [[UIActionSheet alloc]initWithTitle:@"Choose" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Goto Camera Roll",@"Take Photo",@"View", nil];
    actionsheetimage.tag = 1;
    [actionsheetimage showInView:self.view];
}

- (void)imageTapped:(UIGestureRecognizer*)sender{
    
    //    if([imageUser.image isEqual:[UIImage imageNamed:@"ment.png"]])
    //        return;
    //
    //    ProfilePhotoViewController *photo = [[ProfilePhotoViewController alloc]init];
    //    photo.stringtitle = @"Info";
    //    photo.jid = [Utilities getSenderId];
    //    photo.hidesBottomBarWhenPushed = YES;
    //    [[self navigationController]pushViewController:photo animated:YES];
    //    return;
    
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    
//    if([text isEqualToString:@"\n"]){
//        [self updateStatus:txt_status.text];
//        [textView resignFirstResponder];
//        return NO;
//    }
//    
//    return YES;
//}

- (void)uploadPhoto{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatenickname" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    
    [dic setObject:[Utilities  encodingBase64:self.userObj.userName] forKey:@"nickname"];
    
    [WebService updateNickname:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){
            //            [self performSelectorOnMainThread:@selector(hideHUD) withObject:nil waitUntilDone:YES];
            
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [Utilities saveDefaultsValues:self.userObj.userName :@"nickname"];
                
                
                UIImage *image1=[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"]];
                if(image1){
                    
                    UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:image1];
                    
                    [Utilities saveUserImage:@"userimage_thumb.png" filedata:UIImagePNGRepresentation(scaledImgH)];
                    
                    [self.chatTableView reloadData];
                }
                
            }
            else{
                [Utilities alertViewFunction:@"" message:[responseObject valueForKey:@"messsage"]];
            }
        }
        else{
            //            [self performSelectorOnMainThread:@selector(hideHUD) withObject:nil waitUntilDone:YES];
            
            [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)receiveTypingNotification:(NSNotification*)notification{
    
    NSDictionary *dictIncoming = [notification userInfo];
    
    if([[dictIncoming valueForKey:@"isgroupchat"] isEqualToString:@"0"]||[[dictIncoming valueForKey:@"isgroupchat"] isEqualToString:@""]){
        
        [self.dictTyping setObject:@"yes" forKey:[Utilities checkNil:[dictIncoming valueForKey:@"senderid"]]];
    }
    else{
        [self.dictTyping setObject:@"yes" forKey:[Utilities checkNil:[dictIncoming valueForKey:@"group_id"]]];
        [self.dictTyping setObject:[Utilities checkNil:[dictIncoming valueForKey:@"senderid"]] forKey:@"senderid"];
    }
    
    [self.chatTableView reloadData];
    
    if(timerTypingNotification){
        
        [timerTypingNotification invalidate];
        timerTypingNotification = nil;
    }
    
    timerTypingNotification = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(callTimer:) userInfo:nil repeats:NO];
    
}

- (void)callTimer:(NSTimer*)timer{
    [self.dictTyping removeAllObjects];
    [self.chatTableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

// Code by Ameen can change Later.


- (void)searchDisplayController:(UISearchController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    
    //tableView = self.tableViewList;
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];
    
    [tableView setBackgroundColor:[UIColor whiteColor]];
    NSLog(@"show");
}

- (void)searchDisplayController:(UISearchController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    //[viewTop setHidden:NO];
    
    [self.chatTableView setContentOffset:CGPointMake(0, 0)];
    self.searchString = @"";
    
}


- (void) searchDisplayControllerWillBeginSearch:(UISearchController *)controller{
    //[self.tableViewList setContentOffset:CGPointMake(0, 0) animated:NO];
    
    //[viewTop setHidden:YES];
    
    // [viewTop setHidden:YES];
    
}


- (void) searchDisplayControllerDidBeginSearch:(UISearchController *)controller{
}


- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    // [viewTop setHidden:NO];
    self.isSearchEnabled = NO;
    
    [self.chatTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    self.searchString =@"";
    
    [self getUsers];
}// called

//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
//{
//    NSString *searchString = searchController.searchBar.text;
//    self.searchString =searchString;
//
//    [self getUsers];
//
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchString = searchBar.text;
    [self getUsers];
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.isSearchEnabled = YES;
    [searchBar resignFirstResponder];
}

- (void)resignKeyBoard{
    [self.seaarchBar resignFirstResponder];
    
}

// Ameen code for search bar ends here

/*
// any offset changes
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    
    //tableView = self.tableViewList;
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];
    
    [tableView setBackgroundColor:[UIColor whiteColor]];
    NSLog(@"show");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    //[viewTop setHidden:NO];
    
    [self.chatTableView setContentOffset:CGPointMake(0, 0)];
    self.searchString = @"";
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    // [viewTop setHidden:NO];
    self.isSearchEnabled = NO;
    
    [self.tableViewList setContentOffset:CGPointMake(0, 0) animated:YES];
    
    self.searchString =@"";
    
    [self getUsers];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchString = searchBar.text;
    [self getUsers];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.isSearchEnabled = YES;
    [searchBar resignFirstResponder];
}

- (void)resignKeyBoard{
    [self.searchController.searchBar resignFirstResponder];
    
}

*/

#pragma mark Update Status

- (void)updateStatus:(NSString*)stringtatus{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatestatus" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[Utilities  encodingBase64:stringtatus]  forKey:@"status_message"];
    
    [WebService updateNickname:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success:) withObject:stringtatus waitUntilDone:YES];
            }
            else{
                [self performSelectorOnMainThread:@selector(failure:) withObject:[responseObject valueForKey:@"messsage"] waitUntilDone:YES];
                
                //                [Utilities alertViewFunction:@"" message:[responseObject valueForKey:@"messsage"]];
            }
        }
        else{
            
            [self performSelectorOnMainThread:@selector(failure:) withObject:@"Connection error. Please try again" waitUntilDone:YES];
            
        }
        NSLog(@"%@",responseObject);
        
    }];
}

- (void)success:(NSString*)status{
    [Utilities setStatusBsedOnSelection:status];
    self.userObj.userStatus = [Utilities getSenderStatus];
}

- (void)failure:(NSString*)message{
    self.userObj.userStatus = [Utilities getSenderStatus];
    [Utilities alertViewFunction:@"" message:message];
}

- (void)selectPerson:(NSManagedObject*)user{
    
    checkPage = YES;
    self.receiver_id = [user valueForKey:@"chatappid"];
    self.isgroupchat = @"0";
    
    [Utilities saveDefaultsValues:self.receiver_id :@"receiver_id"];
    NSString *name;
    
    if([[Utilities checkNil:self.isgroupchat] isEqualToString:@""]){
        [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
    }
    else{
        [Utilities saveDefaultsValues:self.isgroupchat :@"isgroupchat"];
    }
    
    if([self.isgroupchat isEqualToString:@"1"]){
        name = [[ChatStorageDB sharedInstance]validateGroupName:self.receiver_id].capitalizedString;
        [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
        
    }
    else{
        [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
        name = [[ContactDb sharedInstance]validateUserName:self.receiver_id];
    }
    
    [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_name"];
    [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_nick_name"];
    
    [Utilities saveDefaultsValues:@"0" :@"isgroupchat"];
    
    [Utilities saveDefaultsValues:[user valueForKey:@"chatappid"] :@"receiver_id"];
    [Utilities saveDefaultsValues:[Utilities checkNil:[user valueForKey:@"name"]] :@"receiver_name"];
    [Utilities saveDefaultsValues:[Utilities checkNil:[user valueForKey:@"name"]] :@"receiver_nick_name"];
    
    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updatePresence:(NSNotification*)notification{
    [self.chatTableView reloadData];
}

/*
-(void)movePanelDetect:(id)sender offsetValue:(CGFloat)offsetValue recognizer:(UIPanGestureRecognizer *) recognizer{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    CGPoint current = [sender translationInView:app.tabBarController.view];
    NSLog(@"swipe left to right %f",current.x);
    
    switch ([(UIPanGestureRecognizer*)sender state]) {
        case UIGestureRecognizerStateBegan: {
            self.paneStartLocation = [sender locationInView:app.tabBarController.view];
            self.paneVelocity = 0.0;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint panLocationInPaneView = [sender locationInView:app.tabBarController.view];
            // Pane Sliding
            CGRect newFrame = app.tabBarController.view.frame;
            
            newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
            if (newFrame.origin.x < 0.0) {
                newFrame.origin.x = 0;
            } else if (newFrame.origin.x > 250) {
                //newFrame.origin.x = (320 + nearbyintf(sqrtf((newFrame.origin.x - 320) * 2.0)));
                // newFrame.origin.x = SCREEN_WIDTH;
            }
            
            if(newFrame.origin.x<=0){
                newFrame.origin.x = 0;
            }
            
            //if(newFrame!=NAN){
            app.tabBarController.view.frame = newFrame;
            
            //}
            NSIndexPath *indexPath = [self.tableViewList indexPathForRowAtPoint:[sender locationInView:self.tableViewList]];
            
            
            if(self.imageGridView==nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
                
                self.imageGridView = [[ImageGridViewController alloc]initWithNibName:@"ImageGridViewController" bundle:nil];
                self.imageGridView.delegate = self;
                [self.imageGridView.view setFrame:app.window.frame];
                [app.window addSubview:self.imageGridView.view];
                [app.window sendSubviewToBack:self.imageGridView.view];
                [self animation:indexPath];
                
                //                [app.tabBarController addChildViewController:self.imageGridView];
                //                [self didMoveToParentViewController:self.imageGridView];
                //                [app.tabBarController.view addSubview:self.imageGridView.view];
                
                
            }
            else{
                [self animation:indexPath];
                
            }
            
            // [self.editProfile.view setFrame:app.window.frame];
            // [app.window addSubview:self.editProfile.view];
            //  [app.window sendSubviewToBack:self.editProfile.view];
            
            //  NSLog(@"%@",indexPath);
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            if(newFrame.origin.x>200){
                if(self.showingLeftPanel==NO){
                    
                    if(indexPath==nil||[indexPath isKindOfClass:[NSNull class]]){
                        
                    }
                    else{
                        
                        
                        
                        // self.showingLeftPanel = YES;
                        newFrame.origin.x = [UIScreen mainScreen].bounds.size.width;
                        app.tabBarController.view.frame = newFrame;
                        
                        
                        //                        CATransition *transition = [CATransition animation];
                        //                        transition.duration = 0.3f;
                        //                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        //                        [transition setType:kCATransitionPush];
                        //                        [transition setSubtype:kCATransitionFromLeft];
                        //                        [app.tabBarController.view.layer addAnimation:transition forKey:nil];
                        
                        
                        [self animation:indexPath];
                        
                    }
                    
                }
                //  [self performSelector:@selector(animation) withObject:nil afterDelay:0.3];
            }
            
            CGFloat velocity;
            velocity = -(self.paneStartLocation.x - panLocationInPaneView.x);
            if (velocity != 0) {
                self.paneVelocity = velocity;
                
            }
            break;
            
            
        }
            
        case UIGestureRecognizerStateCancelled: {
            
            
            break;
        }
            
        case UIGestureRecognizerStateFailed: {
            
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGPoint panLocationInPaneView = [sender locationInView:app.tabBarController.view];
            // Pane Sliding
            CGRect newFrame = app.tabBarController.view.frame;
            
            newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
            if (newFrame.origin.x < 0.0) {
                newFrame.origin.x = 0;
            } else if (newFrame.origin.x > 250) {
                //newFrame.origin.x = (320 + nearbyintf(sqrtf((newFrame.origin.x - 320) * 2.0)));
                newFrame.origin.x = SCREEN_WIDTH;
            }
            else{
                newFrame.origin.x = 0;
            }
            
            if(newFrame.origin.x<=0){
                newFrame.origin.x = 0;
            }
            
            //if(newFrame!=NAN){
            app.tabBarController.view.frame = newFrame;
            
        }
            break;
    }
}
*/

/*
- (void)panRecognized:(UIPanGestureRecognizer*)recognizer
{
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self addMenuControllerView];
            [recognizer setTranslation:CGPointMake(recognizer.view.frame.origin.x, 0) inView:recognizer.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [recognizer.view setTransform:CGAffineTransformMakeTranslation(MAX(0,translation.x), 0)];
            // [self statusBarView].transform = recognizer.view.transform;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (velocity.x > 5.0 || (velocity.x >= -1.0 && translation.x > WSideMenuMinimumRelativePanDistanceToOpen * SCREEN_WIDTH)) {
                CGFloat transformedVelocity = velocity.x/ABS(SCREEN_WIDTH - translation.x);
                CGFloat duration = WSideMenuDefaultOpenAnimationTime * 0.66;
                [self showMenuAnimated:YES duration:duration initialVelocity:transformedVelocity];
            } else {
                [self hideMenuAnimated:YES];
            }
        }
        default:
            break;
    }
}
*/

- (void)addMenuControllerView;
{
    //thangarajan
//    if (self.imageGridView.view.superview == nil) {
//        CGRect menuFrame, restFrame;
//        CGRectDivide(self.view.bounds, &menuFrame, &restFrame, SCREEN_WIDTH, CGRectMinXEdge);
//        self.imageGridView.view.frame = menuFrame;
//        self.imageGridView.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
//        self.view.backgroundColor = self.imageGridView.view.backgroundColor;
//        [self.view insertSubview:self.imageGridView.view atIndex:0];
//    }
}

/*
- (void)showMenuAnimated:(BOOL)animated duration:(CGFloat)duration
         initialVelocity:(CGFloat)velocity;
{
    // add menu view
    [self addMenuControllerView];
    
    // animate
    __weak typeof(self) blockSelf = self;
    [UIView animateWithDuration:animated ? duration : 0.0 delay:0
         usingSpringWithDamping:WSideMenuDefaultDamping initialSpringVelocity:velocity options:UIViewAnimationOptionAllowUserInteraction animations:^{
             blockSelf.view.transform = CGAffineTransformMakeTranslation(SCREEN_WIDTH, 0);
             [self statusBarView].transform = blockSelf.view.transform;
         } completion:nil];
}

- (void)hideMenuAnimated:(BOOL)animated;
{
    __weak typeof(self) blockSelf = self;
    [UIView animateWithDuration:WSideMenuDefaultCloseAnimationTime animations:^{
        blockSelf.view.transform = CGAffineTransformIdentity;
        [self statusBarView].transform = blockSelf.view.transform;
    } completion:^(BOOL finished) {
        [blockSelf.imageGridView.view removeFromSuperview];
    }];
}

#pragma mark State

- (BOOL)isMenuVisible;
{
    return !CGAffineTransformEqualToTransform(self.view.transform,
                                              CGAffineTransformIdentity);
}

#pragma mark Statusbar

- (UIView*)statusBarView;
{
    UIView *statusBar = nil;
    NSData *data = [NSData dataWithBytes:(unsigned char []){0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72} length:9];
    NSString *key = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    id object = [UIApplication sharedApplication];
    if ([object respondsToSelector:NSSelectorFromString(key)]) statusBar = [object valueForKey:key];
    return statusBar;
}


- (void)animation:(NSIndexPath*)path{
    
    NSLog(@"Path:%@",path);
    if (path) {
        if (self.arraymessages.count > (path.row-1)) {
            ChatSession *object = [self.arraymessages objectAtIndex:path.row-1];
            
            [self.imageGridView reloadTable:[object valueForKey:@"jid"] isgrouchattemp:[object valueForKey:@"isgroupchat"]];
            return;
            
            self.showingLeftPanel = YES;
            ImageGridViewController *imageFullView = [[ImageGridViewController alloc]init];
            imageFullView.jid = [object valueForKey:@"jid"];
            imageFullView.isgroupchat = [object valueForKey:@"isgroupchat"];
            imageFullView.hidesBottomBarWhenPushed = YES;
            CATransition *transition = [CATransition animation];
            transition.duration = 0.2f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [transition setType:kCATransitionPush];
            [transition setSubtype:kCATransitionFromLeft];
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self.navigationController pushViewController:imageFullView animated:NO];
        }
    }
}
*/

#pragma mark Image Picker

-(void)gallery:(id)sender
{
    UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
    imagepic.delegate=self;
    imagepic.allowsEditing=YES;
    imagepic.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepic animated:YES completion:nil];
    // [self presentViewController:imagepic animated:YES completion:nil];
    
}

-(void)camera:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
        
        imagepic.delegate=self;
        imagepic.allowsEditing=YES;
        imagepic.sourceType=UIImagePickerControllerSourceTypeCamera;
        //        CGRect overlayRect = imagepic.cameraOverlayView.frame;
        //        overlayRect.size.width=overlayRect.size.width-100.0f;
        //        overlayRect.size.height=overlayRect.size.height-100.0f;
        //        [imagepic.cameraOverlayView setFrame:overlayRect];
        [self presentViewController:imagepic animated:YES completion:nil];
        
    }
    else
    {
        //  [Utilities alertViewFunction:@"" message:@"This device is not supported by camera"];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * img = [Utilities fixOrientation:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    
    
    self.userObj.userImage = img;
    
    __weak CSChatmainViewController * me = self;
    
    ChatMainTableViewCell *cell = (ChatMainTableViewCell*)[me.chatTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    cell.imageUser.image = img;

    [UIImagePNGRepresentation(img) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] atomically:YES];
    
    
    [self uploadPhoto];
    
}

#pragma mark Forward

- (void)forwardFromMedia:(NSMutableArray*)arrayobjects{
    //thangarajan
//    CurrentChatsViewController *chats = [[CurrentChatsViewController alloc]init];
//    chats.arrayObjects = arrayobjects;
//    chats.hidesBottomBarWhenPushed = YES;
//    [[self navigationController]pushViewController:chats animated:NO];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self resignKeyBoard];
    
    if(tableView.editing || indexPath.row == 0){

        return;
    }
    
    NSDictionary * object1 = [self.arraymessages objectAtIndex:indexPath.row - 1];

    if ([appDelegate.chatViewControllersDic objectForKey:[object1 valueForKey:@"jid"]] == nil) {
        
        ChatSession * object = [self.arraymessages objectAtIndex:indexPath.row -1];
        
        NSString * str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:[object valueForKey:@"jid"]]];
        
        if(![str isEqualToString:@""])
        {
            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            [app actioHideOrShowPasscode:[object valueForKey:@"jid"] viewcontrol:self isgroupchat:[object valueForKey:@"isgroupchat"] unhide:YES];
            return;
        }
        
        DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
        vc.hidesBottomBarWhenPushed = YES;
        
        NSLog(@"%@",[object valueForKey:@"jid"]);
        
        [Utilities saveDefaultsValues:[object valueForKey:@"jid"] :@"receiver_id"];
        NSString *name;
        
        if([[object valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
            
            name = [[ChatStorageDB sharedInstance]validateGroupName:[object valueForKey:@"jid"]].capitalizedString;
            [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
        }
        else{
            [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
            
            name = [[ContactDb sharedInstance]validateUserName:[object valueForKey:@"jid"]];
        }
        
        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_name"];
        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_nick_name"];
        
        // vc.pageFromChat = YES;
        
        [appDelegate.chatViewControllersDic setObject:vc forKey:[object1 valueForKey:@"jid"]];

        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        NSLog(@"%@",@"fast");
        
        DemoMessagesViewController * chat = [appDelegate.chatViewControllersDic objectForKey:[object1 valueForKey:@"jid"]];

        ChatSession * object = [self.arraymessages objectAtIndex:indexPath.row -1];
        
        NSString * str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:[object valueForKey:@"jid"]]];
        
        if(![str isEqualToString:@""])
        {
            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            [app actioHideOrShowPasscode:[object valueForKey:@"jid"] viewcontrol:self isgroupchat:[object valueForKey:@"isgroupchat"] unhide:YES];
            return;
        }
        
        [Utilities saveDefaultsValues:[object valueForKey:@"jid"] :@"receiver_id"];
        NSString *name;
        
        if([[object valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
            name = [[ChatStorageDB sharedInstance]validateGroupName:[object valueForKey:@"jid"]].capitalizedString;
            [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
        }
        else{
            [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
            name = [[ContactDb sharedInstance]validateUserName:[object valueForKey:@"jid"]];
        }
        
        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_name"];
        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_nick_name"];
        
        [self.navigationController pushViewController:chat animated:YES];
    }
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:
(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
