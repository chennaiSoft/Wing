//
//  ViewController.m
//  Wing
//
//  Created by CSCS on 1/7/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "ViewController.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "XMPPConnect.h"
#import "ContactsObj.h"
#import "ContactTableViewCell.h"
#import "AddressBookContacts.h"
#import "ChatStorageDB.h"
#import "ContactDb.h"
#import <CoreData/CoreData.h>

#import "DemoMessagesViewController.h"

typedef enum MessageType : NSInteger
{
    MessageTypeText = 1,
    MessageTypeImage = 2,
    MessageTypeVideo = 3,
    MessageTypeLocation = 4,
    MessageTypeContact = 5,
    MessageTypeAudio = 6,
    MessageTypeFile = 7,
    MessageTypeYouTube = 8
}MessageType;

@interface ViewController ()
{
    NSMutableArray * contactsArr;
    IBOutlet UITableView * contactTableView;
}
@property (nonatomic, strong)NSMutableArray * ChatViewControllersArr;
@property (nonatomic, strong)NSFetchedResultsController * fetchRequestController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    contactsArr = [[NSMutableArray alloc]init];
    self.ChatViewControllersArr = [[NSMutableArray alloc]init];
    
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    if ([user boolForKey:@"login"]) {
        [self actionskip:nil];
        [self getContacts:nil];

    }else{
        [self getMobileNumber];
    }
}
- (void)getMobileNumber{
    if ([UIAlertController class]) {
        
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@"\u00A0"
                                      message:@"Please enter the Mobile Number."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                  NSString *alerttext = ((UITextField *)[alert.textFields objectAtIndex:0]).text;
                                 
                                 if (alerttext.length < 10 ) {
                                     
                                 }else{
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     [self loginService:alerttext];
                                 }

                             }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *K2TextField)
         {
             K2TextField.placeholder = NSLocalizedString(@"Please enter the Mobile number.", @"Please enter the Mobile Number.");
        }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];

        /*
        UIAlertController *alertControllerK2 = [UIAlertController
                                                alertControllerWithTitle:@"\u00A0"
                                                message:@"Please enter the Mobile Number."
                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *K2okAction = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:nil];
        [alertControllerK2 addTextFieldWithConfigurationHandler:^(UITextField *K2TextField)
         {
             K2TextField.placeholder = NSLocalizedString(@"Please enter the Mobile number.", @"Please enter the Mobile Number.");
             if (K2TextField.text.length < 10 ) {
                 
             }else{
                 [self loginService:K2TextField.text];
             }
         }];
        [alertControllerK2 addAction:K2okAction];
        [self presentViewController:alertControllerK2 animated:YES completion:nil];*/
    } else {
        UIAlertView *alertK2;
        alertK2 = [[UIAlertView alloc]
                   initWithTitle:@"\u00A0"
                   message:@"Please enter the mobile number."
                   delegate: self
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil];
        alertK2.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertK2 show];
    }
}

- (void)loginService:(NSString*)mobile{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"userlogin" forKey:@"cmd"];
    [dic setObject:@"ios" forKey:@"platform"];
    [dic setObject:mobile forKey:@"mobile_number"];
    [dic setObject:@"91"  forKey:@"mobile_code"];

    [dic  setObject:@"044" forKey:@"country_code"];
    [dic  setObject:@"dshjfbsakljdna;" forKey:@"device_id"];
    
    
    [WebService loginApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
                [user setObject:[responseObject valueForKey:@"user_type"] forKey:@"user_type"];
                [user setObject:[responseObject valueForKey:@"user_id"] forKey:@"user_id"];
                [user setObject:[responseObject valueForKey:@"chatapp_id"] forKey:@"chatapp_id"];
                [user synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sucesslogin];
                });
            }
            else{
                [Utilities alertViewFunction:@"" message:[responseObject valueForKey:@"message"]];
            }
        }
        else{
            [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
        
    }];
}

- (void)sucesslogin{
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    [user setBool:YES forKey:@"login"];
    [user synchronize];
    
    [[XMPPConnect sharedInstance] connectWithXMPP];
    [self actionskip:nil];
    [self getContacts:nil];
}

- (IBAction)actionskip:(id)sender{
    
    if([[UIDevice currentDevice].systemVersion integerValue] >= 6){
        __block ABAddressBookRef addressBook1 = NULL; // create address book reference object
        __block BOOL accessGranted = NO;
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook1, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        
        if (accessGranted)
        {
            [[AddressBookContacts sharedInstance] loadAddressbook];
        }
        else{
//            switchSyncContacts.on = NO;
//            
//            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//            [app setupViewControllers];
        }
    }
    else{
        
//        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//        [app setupViewControllers];
    }
}

- (IBAction)getContacts:(id)sender{
    
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    [SVProgressHUD show];
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setObject:@"updateprofilevisibility" forKey:@"cmd"];
//    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
//    [dic setObject:[NSString stringWithFormat:@"%d",1] forKey:@"profile_visibility"];
//    
//    [WebService contactSyncApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
//        
//        [SVProgressHUD dismiss];
//        
//        if(responseObject){
//            NSLog(@"%@",responseObject);
//        }
//    }];
    
//    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
//    [user objectForKey:@"chatapp_id"];
    [self getUsers];
//    ContactDb * db = [ContactDb sharedInstance];
//    NSArray * contaArr = [db getFavorites:ContactsTypeWINGS];
//    NSLog(@"%@",contaArr);
}

#pragma mark FetchResult

- (void)getUsers{
    
    if(self.fetchRequestController)
        self.fetchRequestController = nil;
    
    NSString *type;

    type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS];
    
    NSPredicate *predicate;
    
    NSManagedObjectContext *context;
    NSEntityDescription *entity;
    context =[[ContactDb sharedInstance] managedObjectContext];
    entity = [NSEntityDescription entityForName:@"Phone"
                         inManagedObjectContext:[[ContactDb sharedInstance] managedObjectContext]];
//    predicate = [NSPredicate predicateWithFormat:@"(type=%@ or type=%d) and name contains[c] %@",type,ContactsTypeWINGS,@""];
    
    predicate = [NSPredicate predicateWithFormat:@"type=%@ or type=%d",type,ContactsTypeWINGS];
    
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
            [self loadContacts];
        }
    }];
}

- (void)loadContacts{
    
    NSInteger sectionCount = [[self.fetchRequestController sections] count];
    for (int i = 0; i < sectionCount; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchRequestController sections] objectAtIndex:i];
        
        for (int j = 0; j < [sectionInfo numberOfObjects]; j++) {
            
            NSIndexPath * path = [NSIndexPath indexPathForRow:j inSection:i];
            
            NSManagedObject * user = [self.fetchRequestController objectAtIndexPath:path];
            NSLog(@"%@",user);
            ContactsObj * contact = [[ContactsObj alloc]init];
            contact.displayname = [user valueForKey:@"name"];
            contact.jid = [user valueForKey:@"chatappid"];
//            contact.displayname = [user valueForKey:@"group_subject"];
//            contact.displayname = [user valueForKey:@"name"];
//            contact.displayname = [user valueForKey:@"name"];
//            
//            [Utilities saveDefaultsValues:[user valueForKey:@"group_id"] :@"receiver_id"];
//            [Utilities saveDefaultsValues:[Utilities checkNil:[user valueForKey:@"group_subject"] ]:@"receiver_name"];
//            [Utilities saveDefaultsValues:[user valueForKey:@"group_id"] :@"receiver_nick_name"];
//            [Utilities saveDefaultsValues:@"1" :@"isgroupchat"];

            
            [contactsArr addObject:contact];
        }
    }
    [contactTableView reloadData];
}

#pragma mark - tableView Functions.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contactsArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.001;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell * cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Contacts"];
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Contacts"];
    }
    
    ContactsObj * contactObj = [contactsArr objectAtIndex:indexPath.row];
    cell.name.text = contactObj.displayname;
    cell.phone.text = contactObj.jid;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactsObj * contactObj = [contactsArr objectAtIndex:indexPath.row];
    NSLog(@"%@",contactObj);
    
    if (self.ChatViewControllersArr.count > 0) {
        
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        
        dic = [self.ChatViewControllersArr objectAtIndex:0];
        
        if ([dic objectForKey:contactObj.jid]==nil) {
            
            //raj showing passcode
            /*NSString * str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:contactObj.jid]];
            
            if(![str isEqualToString:@""])
            {
//                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//                [app actioHideOrShowPasscode:[object valueForKey:@"jid"] viewcontrol:self isgroupchat:[object valueForKey:@"isgroupchat"] unhide:NO];
//                return;
            }*/
            

            DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
            //vc.delegateModal = self;
        
            [Utilities saveDefaultsValues:contactObj.jid :@"receiver_id"];
            NSString *name;
            
//            if([[object valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
//                name = [[ChatStorageDB sharedInstance]validateGroupName:[object valueForKey:@"jid"]].capitalizedString;
//                [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
//            }
//            else{
//                [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
//                name = [[ContactDb sharedInstance]validateUserName:[object valueForKey:@"jid"]];
//            }
            
            [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_name"];
            [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_nick_name"];
            
            // vc.pageFromChat = YES;
            
            [self.navigationController pushViewController:vc animated:YES];
            [dic setObject:vc forKey:contactObj.jid];
            [self.ChatViewControllersArr removeAllObjects];
            [self.ChatViewControllersArr addObject:dic];
            
        }else{
            NSLog(@"%@",@"fast");
            
            DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
            //vc.delegateModal = self;
            [self.navigationController pushViewController:vc animated:YES];
            
            NSLog(@"%@",@"Completed");
        }
    }else{
        
        //raj showing passcode
        /* NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:contactObj.jid]];
        
        if(![str isEqualToString:@""])
        {
//            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//            [app actioHideOrShowPasscode:[object valueForKey:@"jid"] viewcontrol:self isgroupchat:[object valueForKey:@"isgroupchat"] unhide:NO];
//            return;
        }
        */
    
        DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
       // vc.delegateModal = self;

        [Utilities saveDefaultsValues:contactObj.jid :@"receiver_id"];
        NSString *name;
        
//        if([[object valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
//            name = [[ChatStorageDB sharedInstance]validateGroupName:[object valueForKey:@"jid"]].capitalizedString;
//            [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
//        }
//        else{
//            [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
//            name = [[ContactDb sharedInstance]validateUserName:[object valueForKey:@"jid"]];
//        }
        
        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_name"];
        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_nick_name"];
        
        [self.navigationController pushViewController:vc animated:YES];
        
        NSMutableDictionary * Controllerdic = [[NSMutableDictionary alloc]init];
        [Controllerdic setObject:vc forKey:contactObj.jid];
        [self.ChatViewControllersArr addObject:Controllerdic];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
