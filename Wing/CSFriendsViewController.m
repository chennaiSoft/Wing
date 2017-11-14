
#import "CSFriendsViewController.h"

#import "AppDelegate.h"
#import "GUIDesign.h"
#import "ContactDb.h"
#import "ChatStorageDB.h"

#import "AddressBookContacts.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>

#import "CSFriendsObjects.h"
#import "CSFriendsTableViewCell.h"
#import "DemoMessagesViewController.h"
#import "CSChatmainViewController.h"
#import "HeaderTableViewCell.h"
#import "SCFacebook.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#import "WebService.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"

@interface CSFriendsViewController ()<ABPeoplePickerNavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate>{
    
    AppDelegate* appDelegate;
    NSMutableArray* arrayfriends;
    NSMutableArray* contactData;
    
    UIBarButtonItem* addBtn;
    
    UIButton * btn_fb_connect;
    
    CFTypeRef generalrefObjectId;
    UITapGestureRecognizer * gesture1;
}

@property (nonatomic, strong)NSMutableArray * alphabetsArray;
@property (nonatomic, strong)NSString * searchString;
@property (nonatomic, strong)UISearchBar * searchBar;
@property (nonatomic, strong)NSFetchedResultsController *fetchRequestController;
@property (nonatomic, strong)NSString *receiver_id;
@property (nonatomic, strong)NSString *isgroupchat;
@end

@implementation CSFriendsViewController

- (id)init{
    self = [super init];
    if (self) {
        self.title = @"Friends";
        UIImage *deselectedimage = [[UIImage imageNamed:@"friends"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedimage = [[UIImage imageNamed:@"friendsSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:deselectedimage];
        [self.tabBarItem setSelectedImage:selectedimage];
        
    }
    return self;
}

- (void)callAddressBook{
    @autoreleasepool {
        
        int  count = [[ContactDb sharedInstance] getContactsCount];
        if(count==0){
            [[AddressBookContacts sharedInstance] loadAddressbook];
            
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelectorOnMainThread:@selector(callAddressBook) withObject:nil waitUntilDone:YES];
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    self.view.backgroundColor = [UIColor whiteColor];

    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Friends";
    
    addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact)];
    addBtn.tintColor = [UIColor blackColor];

    self.navigationItem.rightBarButtonItem = addBtn;
    
    UIImageView* appbg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appbg.image = [UIImage imageNamed:@"appBg.png"];
    [self.view addSubview:appbg];
    
    contactTable = [[UITableView alloc]init];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 65, screenWidth, 44)];
    _searchBar.placeholder = @"Search";
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [GUIDesign GrayColor];
    [self.view addSubview:_searchBar];
    
    self.searchString = @"";
    
    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    
    contactTable = [GUIDesign initWithTabelview:self frmae:CGRectMake(0, 109, screenWidth, screenHeight - 109 - 46)];
    contactTable.delegate = self;
    contactTable.dataSource = self;
    [self.view addSubview:contactTable];
    
    [contactTable setContentOffset:CGPointMake(0, 0)];
    contactTable.backgroundColor = [UIColor clearColor];
    
    
    arrayfriends = [[NSMutableArray alloc]init];
    
    indexx = 2;

    [self setGesture];
    
    // initlizing notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactNotification:)
                                                 name:@"UpdateContacts"
                                               object:nil];
    
    btn_fb_connect = [GUIDesign initWithbutton:CGRectMake((screenWidth - 160)/2, (screenHeight - 38)/2, 160, 38) title:nil img:nil];
    [btn_fb_connect setImage:[UIImage imageNamed:@"fb_connect"] forState:UIControlStateNormal];
    [btn_fb_connect addTarget:self action:@selector(action_FBConnect:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_fb_connect];
    
    btn_fb_connect.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getUsers];

    if((self.checkPage==YES&&(![self.receiver_id isEqualToString:@""]))){
        
        self.checkPage = NO;
        CSChatmainViewController * chatViewController = [[CSChatmainViewController alloc]init];
        [Utilities saveDefaultsValues:self.receiver_id :@"receiver_id"];
        NSString *name;

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
       // chatViewController.pageFromChat = NO;
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:NO];
        return;
    }
}

- (void)receiveContactNotification:(NSNotification *) notification
{
    [self getUsers];
}

- (void)setGesture{
    
    gesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabelViewTapped:)];
    gesture1.cancelsTouchesInView = YES;
    [contactTable addGestureRecognizer:gesture1];
    
}
- (void)tabelViewTapped:(UIGestureRecognizer*)sender{
    
    [self.searchBar resignFirstResponder];
    
    NSIndexPath *indexPath = [contactTable indexPathForRowAtPoint:[sender locationInView:contactTable]];
    
    if(indexPath){
        [contactTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        // If you have custom logic in table view delegate method, also invoke this method too
        [self tableView:contactTable didSelectRowAtIndexPath:indexPath];
        
    }
}

- (void)getUsers{
    
    if(self.fetchRequestController)
        self.fetchRequestController = nil;
    
    NSString *type;
    switch (indexx) {
        case 1:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypePhones];
            break;
        case 2:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS];
            break;
        case 3:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeGroups];
            break;
        case 4:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeFacebook];
            break;
            
        default:
            break;
    }
    
    // NSString *db_name = @"Phone";
    NSPredicate *predicate;
    
    NSManagedObjectContext *context;
    NSEntityDescription *entity;
    
    if([type isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeGroups]]){
        
        context =[[ChatStorageDB sharedInstance] managedObjectContext];
        
        entity = [NSEntityDescription entityForName:@"Groups"
                             inManagedObjectContext:[[ChatStorageDB sharedInstance] managedObjectContext]];
        
        if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
            
        }
        else{
            predicate = [NSPredicate predicateWithFormat:@"group_subject contains[c] %@",self.searchString];
        }
        
    }
    else{
        context =[[ContactDb sharedInstance] managedObjectContext];
        entity = [NSEntityDescription entityForName:@"Phone"
                             inManagedObjectContext:[[ContactDb sharedInstance] managedObjectContext]];
        
        
        if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
            if(indexx==1){
                predicate = [NSPredicate predicateWithFormat:@"type=%@ or type=%d",type,ContactsTypeWINGS];
                
            }
            else{
                predicate = [NSPredicate predicateWithFormat:@"type=%@",type];
                
            }
            
        }
        else{
            if(indexx==1){
                predicate = [NSPredicate predicateWithFormat:@"(type=%@ or type=%d) and name contains[c] %@",type,ContactsTypeWINGS,self.searchString];
                
            }
            else{
                predicate = [NSPredicate predicateWithFormat:@"type=%@ and name contains[c] %@",type,self.searchString];
            }
            
        }
    }
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    //    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sorting"
                                                         ascending:YES];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    
    
    if(predicate)
        [fr setPredicate:predicate];
    
    self.fetchRequestController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                        managedObjectContext:context
                                          sectionNameKeyPath:@"sorting"
                                                   cacheName:nil];
    
    if (![self.fetchRequestController performFetch:nil])
    {
        
    }
    
    [contactTable reloadData];
}


/*
- (void)getUsers{
    
    if(self.fetchRequestController)
        self.fetchRequestController = nil;
    
    NSString *type;
    
    type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS];
    
    NSPredicate *predicate;
    
    NSManagedObjectContext *context;
    NSEntityDescription *entity;
    context =[[ContactDb sharedInstance] managedObjectContext];
    
//    entity = [NSEntityDescription entityForName:@"Groups"
//                         inManagedObjectContext:[[ChatStorageDB sharedInstance] managedObjectContext]];
    
    entity = [NSEntityDescription entityForName:@"Phone"
                         inManagedObjectContext:[[ContactDb sharedInstance] managedObjectContext]];
    
//    predicate = [NSPredicate predicateWithFormat:@"(type=%@ or type=%d) and name contains[c] %@",type,ContactsTypeWINGS,@""];
    predicate = [NSPredicate predicateWithFormat:@"type=%@",type];
//    predicate = [NSPredicate predicateWithFormat:@"type=%@ or type=%d",type,ContactsTypePhones];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sorting"
                                                         ascending:YES];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    
    
    if(predicate)
        [fr setPredicate:predicate];
    
    self.fetchRequestController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                        managedObjectContext:context
                                          sectionNameKeyPath:@"sorting"
                                                   cacheName:nil];
    
    NSError *error = nil;
    
    [self.fetchRequestController.managedObjectContext performBlock:^{
        NSError * fetchError = nil;
        
        if (![self.fetchRequestController performFetch:&fetchError]){
            /// handle the error. Don't just log it.
            NSLog(@"Error performing fetch: %@", error);
        } else {
            [contactTable reloadData];
        }
    }];
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark - Tableview

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if(![self.searchString isEqualToString:@""])
        return nil;
    
    return self.alphabetsArray;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if(sectionIndex==0)
        return nil;
    
    return [[[self.fetchRequestController sections] objectAtIndex:sectionIndex-1] name];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [btn_fb_connect setHidden:YES];
    
    if([[self.fetchRequestController sections] count] == 0 && indexx == 4){
        [btn_fb_connect setHidden:NO];
    }
    NSLog(@"%lu",[[self.fetchRequestController sections] count]);
    return [[self.fetchRequestController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchRequestController sections] objectAtIndex:section - 1];
    
    return [sectionInfo numberOfObjects];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 44;
    
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSFriendsTableViewCell * cell = nil;
    
    if(indexPath.section == 0) {
        
        static NSString *cellIdentifier = @"category";
        
        HeaderTableViewCell * headerCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(headerCell == nil)
        {
            NSArray *nibArray= [[NSBundle mainBundle] loadNibNamed:@"HeaderTableViewCell" owner:self options:nil];
            headerCell = [nibArray objectAtIndex:0];
        }

        [headerCell.buttonSub4 setBackgroundImage:[UIImage imageNamed:@"fb_2.png"] forState:UIControlStateNormal];
        
        [headerCell.buttonSub3 setBackgroundImage:[UIImage imageNamed:@"group_wing_2.png"] forState:UIControlStateNormal];
        
        [headerCell.buttonSub2 setBackgroundImage:[UIImage imageNamed:@"wing_2.png"] forState:UIControlStateNormal];
        
        [headerCell.buttonSub1 setBackgroundImage:[UIImage imageNamed:@"contact_2.png"] forState:UIControlStateNormal];
        
        [headerCell.buttonMain1 addTarget:self action:@selector(actiontopselect1:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerCell.buttonMain2 addTarget:self action:@selector(actiontopselect1:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerCell.buttonMain3 addTarget:self action:@selector(actiontopselect1:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerCell.buttonMain4 addTarget:self action:@selector(actiontopselect1:) forControlEvents:UIControlEventTouchUpInside];

        switch (indexx) {
            case 1:
                [headerCell.buttonSub1 setBackgroundImage:[UIImage imageNamed:@"contact_1.png"] forState:UIControlStateNormal];
                break;
            case 2:
                [headerCell.buttonSub2 setBackgroundImage:[UIImage imageNamed:@"wing_1.png"] forState:UIControlStateNormal];
                
                break;
            case 3:
                [headerCell.buttonSub3 setBackgroundImage:[UIImage imageNamed:@"group_wing_1.png"] forState:UIControlStateNormal];
                break;
            case 4:
                [headerCell.buttonSub4 setBackgroundImage:[UIImage imageNamed:@"fb_1.png"] forState:UIControlStateNormal];
                
                break;
            default:
                break;
        }
        
        return headerCell;

    }else{
        
        static NSString *cellIdentifier = @"friendsCell";
        
        // Similar to UITableViewCell, but
        cell = (CSFriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[CSFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSIndexPath *path  = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
        CSFriendsObjects * friendsDetails = [[CSFriendsObjects alloc]init];
        
        if(indexx == 3){
            
            NSManagedObject * user = [self.fetchRequestController objectAtIndexPath:path];
            
            friendsDetails.title = [user valueForKey:@"group_subject"];

            [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"group_id"] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
            
            friendsDetails.desc = [NSString stringWithFormat:@"%@",[[[[ChatStorageDB sharedInstance]getGroupMembersByName:[user valueForKey:@"group_id"]] valueForKeyPath:@"member_name"] componentsJoinedByString:@","]];

            [cell.btnWings setHidden:YES];
            
        }
        else{
            [cell.btnWings setHidden:NO];
            
            NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
            
            friendsDetails.title = [user valueForKey:@"name"];
            
            if([[user valueForKey:@"type"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]]||[[user valueForKey:@"type"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeFacebook]]){
                
                friendsDetails.desc = @"I'm using Wing";
                
                if([[Utilities checkNil:[user valueForKey:@"chatappid"]] isEqualToString:@""]){
                    friendsDetails.desc = @"";
                    
                    [cell.btnWings setImage:[UIImage imageNamed:@"add_contact"] forState:UIControlStateNormal];
                }
                else{

                    [cell.btnWings setImage:[UIImage imageNamed:@"wing_contact"] forState:UIControlStateNormal];
                    
                    [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"chatappid"] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
                }
                

                if(![[user valueForKey:@"status_message"] isEqualToString:@""]){
                    friendsDetails.desc = [user valueForKey:@"status_message"];
                }
            }
            else{
                
                [cell.btnWings setImage:[UIImage imageNamed:@"add_contact"] forState:UIControlStateNormal];
                friendsDetails.desc = @"";
            }
        }
        
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.size.width / 2;
        cell.iconImageView.clipsToBounds = YES;
        cell.btnWings.frame = CGRectMake(screenWidth - 55, (68 - 50)/2, 50, 50);
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.friendsObj = friendsDetails;
        [cell updateValues];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    //  [self updateTopButtons];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexx == 1){
        
        NSIndexPath *path  =[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        
        NSManagedObject *object = [self.fetchRequestController objectAtIndexPath:path];
        
        if([[object valueForKey:@"type"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]]){
            [self pushToProfile:object];
        }
        else{
            [self openSMSComposer:[object valueForKey:@"phone"]];
        }
    }
    
    else if(indexx == 2||indexx == 4){
        
        NSIndexPath *path  =[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        
        NSManagedObject *object = [self.fetchRequestController objectAtIndexPath:path];
        
        if([[object valueForKey:@"type"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]]||[[object valueForKey:@"type"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeFacebook]]){
            
            if([[Utilities checkNil:[object valueForKey:@"chatappid"]] isEqualToString:@""]){
                return;
            }
            
            [self pushToProfile:object];
            
        }
        
    }
    
    else if (indexx == 3 || indexx == 0){
        [self gotoChatView:indexPath];
    }
}

- (void)gotoChatView:(NSIndexPath*)indexPath{
    
    
    NSIndexPath *path  = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section -1];
    
    NSManagedObject * user = [self.fetchRequestController objectAtIndexPath:path];
    
//    NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:[user valueForKey:@"group_id"]]];
//    
//    if(![str isEqualToString:@""])
//    {
//        //AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//        //            [app actioHideOrShowPasscode:[user valueForKey:@"group_id"] viewcontrol:self isgroupchat:@"1" unhide:NO];
//        return;
//    }
//
    [Utilities saveDefaultsValues:@"0" :@"isgroupchat"];
    
    [Utilities saveDefaultsValues:[user valueForKey:@"chatappid"] :@"receiver_id"];
    [Utilities saveDefaultsValues:[Utilities checkNil:[user valueForKey:@"name"]] :@"receiver_name"];
    [Utilities saveDefaultsValues:[Utilities checkNil:[user valueForKey:@"name"]] :@"receiver_nick_name"];

    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)passcodeValidated:(NSString*)strjid isgroupchat:(NSString*)isgroupchat{
    self.receiver_id = strjid;
    self.isgroupchat = isgroupchat;
    self.checkPage = YES;
}

- (void)pushToProfile:(NSManagedObject*)object{
    
    ProfileViewController *profile = [[ProfileViewController alloc]init];
    profile.pageFromChat = NO;
    profile.receiver_id = [object valueForKey:@"chatappid"];
    profile.receiver_name = [object valueForKey:@"name"];
    profile.receiver_nick_name = [object valueForKey:@"name"];
    profile.isgroupchat = @"0";
    
    [[self navigationController]pushViewController:profile animated:YES];
}

#pragma mark navigation


- (IBAction)actiontopselect1:(id)sender{
    
   [btn_fb_connect setHidden:YES];
    
    NSString * type;
    
    NSInteger tag = ((UIControl*)sender).tag;
    
    switch (tag) {
        case 1:
            type = @"";
            break;
        case 2:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS];
            
            break;
        case 3:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeGroups];
            
            break;
        case 4:
            type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeFacebook];
            
            break;
        default:
            type = @"";
            break;
    }
    
    indexx = tag;
    
    [self getUsers];

     [btn_fb_connect setHidden:YES];
    if(self.fetchRequestController.fetchedObjects.count == 0 && indexx == 4){
       [btn_fb_connect setHidden:NO];
    }
}

- (IBAction)action_FBConnect:(id)sender {
    
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    
    if (![accessToken.permissions containsObject:@"user_friends"]) {
        
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        
        [loginManager logInWithReadPermissions:@[@"user_friends"]
                            fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"Failed to login:%@", error);
                return;
            }
            
            FBSDKAccessToken *newToken = [FBSDKAccessToken currentAccessToken];
            if (![newToken.permissions containsObject:@"user_friends"]) {
                // Show alert
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed"
                                                                    message:@"You must login and grant access to your firends list to use this feature"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            [self updateFriendsTable];
        }];

    } else {
        [self updateFriendsTable];
    }
}

- (void)updateFriendsTable {
    // We limit the friends list to only 50 results for this sample. In production you should
    // use paging to dynamically grab more users.
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             [Utilities saveDefaultsValues:[result valueForKey:@"name"] :@"fb_name"];
             [Utilities saveDefaultsValues:[result valueForKey:@"id"] :@"fb_id"];
             
             
             NSDictionary *parameters = @{
                                          @"fields": @"name",
                                          @"limit" : @"50"
                                          };
             // This will only return the list of friends who have this app installed
             FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:parameters];
             
             FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
             [connection addRequest:friendsRequest
                  completionHandler:^(FBSDKGraphRequestConnection *innerConnection, NSDictionary *result, NSError *error) {
                      if (error) {
                          NSLog(@"%@", error);
                          return;
                      }
                      
                      if (result) {
                          NSArray *data = result[@"data"];
                          [[ContactDb sharedInstance]saveSocialContactsValue:data];
                          
                          NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                          NSString *documentsDirectory = [paths objectAtIndex:0];
                          NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Social.json"];
                          NSData *data1 = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
                          
                          [data1 writeToFile:path atomically: YES];
                          
                          
                          NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                          [dic setObject:@"validatesocialjson" forKey:@"cmd"];
                          [dic setObject:[Utilities getSenderId] forKey:@"user_id"];
                          [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
                          
                          [dic setObject:[Utilities getFacebookID] forKey:@"social_id"];
                          [dic setObject:[Utilities getFacebookName] forKey:@"social_name"];
                          
                          
                          [btn_fb_connect setHidden:YES];
                          
                          [self getUsers];
                          
                          
                          [WebService socialContactSyncApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
                              if(responseObject){
                                  NSArray *array = [responseObject valueForKeyPath:@"mobile_list"];
                                  if(array&&array.count>0){
                                      [[ContactDb sharedInstance] saveSocialContactsValue:array];
                                      [contactTable reloadData];
                                  }
                              }
                              NSLog(@"%@",responseObject);
                              
                          }];
                          
                      }
                  }];
             // start the actual request
             [connection start];
             NSLog(@"fetched user:%@", result);
         }
     }];
    
    return;
    
    
}

-(void)openSMSComposer:(NSString*)mobileNumber{
    
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
        [picker setSubject:CAPTION];
        [picker setBody:[NSString stringWithFormat:@"%@",INVITESMS]];
        NSArray *toRecipients = [NSArray arrayWithObjects:mobileNumber, nil];
        [picker setRecipients:toRecipients];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result)
    {
        case MessageComposeResultCancelled:
            // [Utilities alertViewFunction:@"" message:@"Message cancelled"];
            break;
        case MessageComposeResultSent:{
            break;
        }
        case MessageComposeResultFailed:
            // [Utilities alertViewFunction:@"" message:@"Sending failed"];
            return;
            break;
            
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // [self performSelector:@selector(callForOpenMailComposer) withObject:nil afterDelay:2];
    
    //  [self performSelectorOnMainThread:@selector(callForOpenMailComposer) withObject:nil waitUntilDone:YES];
    
    //    [self.arrayMobile removeAllObjects];
    //    [self.arrayEmail removeAllObjects];
    //    [self.dictSelect removeAllObjects];
    //    [tableViewListing reloadData];
}

- (void)addContact{
    //Adding new contact
    [self createNewPerson];
}

- (void)createNewPerson
{
    // Create the pre-filled properties
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, CFSTR(""), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, CFSTR(""), &error);
    
    // Create and set-up the new person view controller
    ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] initWithNibName:nil bundle:nil];
    [newPersonViewController setDisplayedPerson:newPerson];
    [newPersonViewController setNewPersonViewDelegate:(id<ABNewPersonViewControllerDelegate>)self];
    
    // Wrap in a nav controller and display
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    // [self presentModalViewController:navController animated:YES];
    [self presentViewController:navController animated:YES completion:nil];
    
    // Clean up everything
    CFRelease(newPerson);
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionAdd{
    [self createNewPerson];
}

#pragma searchbar delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.searchString = searchBar.text;
    [self getUsers];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchString = @"";
    [self getUsers];
}

// called
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
