
#import "CSNicknameViewController.h"
#import "AppDelegate.h"
#import "GUIDesign.h"
#import "CSChatmainViewController.h"

//#import "CSFriendsViewController.h"
//#import "CSYoutubeViewController.h"
//#import "SettingsViewController.h"
//#import "CSFavouritesViewController.h"
//#import "YouTubeLoginViewController.h"
//#import "YouTubeViewController.h"
//#import "ContactsViewController.h"

#import "GUIDesign.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "Constants.h"
#import "DropboxManager.h"

#import "AddressBookContacts.h"
#import "ContactDb.h"

@interface CSNicknameViewController ()<UITextFieldDelegate>{
    
    AppDelegate* appDelegate;
    UITextField* nameField;
    UIButton * addPhoto;
    
    UIView * shadowView;
    UIView * discoveryView;
    UISwitch * switchSyncContacts;
    UISwitch * switchDiscovery;
}

@end


@implementation CSNicknameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (screenHeight == 480) {
        scrollview.contentSize = CGSizeMake(screenWidth, screenHeight + 100);
    }
    [self.view addSubview:scrollview];
    
    UIImageView * appbg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appbg.image = [UIImage imageNamed:@"appBg.png"];
    [scrollview addSubview:appbg];
    
    UIImageView * topLogo = [GUIDesign initWithImageView:CGRectMake((screenWidth - 99)/2, 50, 99, 99) img:@"login_logo.png"];
    [scrollview addSubview:topLogo];
    
    UIButton * btn1 = [GUIDesign initWithbutton:CGRectMake(((screenWidth-17)/2)-70 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"1" img:@" "];
    btn1.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn1.backgroundColor = [GUIDesign GrayColor];
    btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn1.layer.cornerRadius =0.5* btn1.bounds.size.width;
    [btn1 addTarget:self action:@selector(forstepOne) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:btn1];
    
    UIImageView * stepline1 = [GUIDesign initWithImageView:CGRectMake(btn1.frame.origin.x +17, topLogo.frame.origin.y +99 +30+ 8.5f, 50, 1) img:@"step_line.png"];
    [scrollview addSubview:stepline1];
    
    UIButton * btn2 = [GUIDesign initWithbutton:CGRectMake(stepline1.frame.origin.x+50 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"2" img:@" "];
    btn2.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn2.backgroundColor = [GUIDesign GrayColor];
    btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn2.layer.cornerRadius =0.5* btn2.bounds.size.width;
    [btn2 addTarget:self action:@selector(nothing) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:btn2];
    
    UIImageView * stepline2 = [GUIDesign initWithImageView:CGRectMake(btn2.frame.origin.x +17, topLogo.frame.origin.y +99 +30+ 8.5f, 50, 1) img:@"step_line.png"];
    [scrollview addSubview:stepline2];
    
    UIButton * btn3 = [GUIDesign initWithbutton:CGRectMake(stepline2.frame.origin.x+50 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"3" img:@" "];
    btn3.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn3.backgroundColor = [GUIDesign yellowColor];
    btn3.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn3.layer.cornerRadius =0.5* btn3.bounds.size.width;
    [btn3 addTarget:self action:@selector(nothing) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:btn3];
    
//    UIImageView * addPhoto = [GUIDesign initWithImageView:CGRectMake((screenWidth-75)/2, btn2.frame.origin.y+17 +20, 75, 75) img:@"add_photo.png"];
//    [self.view addSubview:addPhoto];
    
    addPhoto = [GUIDesign initWithbutton:CGRectMake((screenWidth-75)/2, btn2.frame.origin.y+17 +20, 75, 75) title:@"" img:nil];
    [addPhoto setBackgroundImage:[UIImage imageNamed:@"add_photo.png"] forState:UIControlStateNormal];
    [addPhoto addTarget:self action:@selector(take_photo_from_Gallery) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:addPhoto];
    
    addPhoto.clipsToBounds = YES;
    [addPhoto setNeedsDisplay];
    addPhoto.layer.cornerRadius = 75/2;
    
    nameField = [GUIDesign initWithtxtField:CGRectMake((screenWidth - 204)/2, addPhoto.frame.origin.y+ 75 + 30, 204, 28) Placeholder:@"Name" delegate:self];
    nameField.textAlignment = NSTextAlignmentCenter;
    nameField.keyboardType = UIKeyboardTypeNamePhonePad;
    nameField.background = [UIImage imageNamed:@"name.png"];
    [scrollview addSubview:nameField];
    
    UIButton * submitBtn = [GUIDesign initWithbutton:CGRectMake((screenWidth - 160)/2, nameField.frame.origin.y + 28+ 40, 160, 34) title:@"Submit" img:nil];
    submitBtn.layer.cornerRadius = 37/2;
    submitBtn.backgroundColor = [GUIDesign yellowColor];
    [submitBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(updateName:) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:submitBtn];
    
    UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabView)];
    [scrollview addGestureRecognizer:recogniser];
    
    // updating fields
    [nameField setText:[Utilities getSenderNickname]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL * fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[Utilities getSenderId] lowercaseString]]];
            UIImage * img = [UIImage imageWithData:[NSData dataWithContentsOfURL:fileUrl]];
            if (img != nil) {
                [addPhoto setBackgroundImage:img forState:UIControlStateNormal];
                addPhoto.layer.cornerRadius = addPhoto.frame.size.width / 2;
                addPhoto.clipsToBounds = YES;
                [addPhoto setNeedsDisplay];
            }
    });
}

- (void)tabView{
    [nameField resignFirstResponder];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, - 100, screenWidth, screenHeight);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }];
    }
    return YES; // We do not want UITextField to insert line-breaks.
}

- (IBAction)updateName:(id)sender{
    
    if (nameField.text.length == 0) {
        [self showAlert:@"Please enter name"];
    }else{
        [self updateNickNameService:nameField.text];
    }
}

-(void)continueAction{
    
    shadowView = [GUIDesign initWithView:CGRectMake(0,0, screenWidth, screenHeight)];
    shadowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"appBg.png"]];
    [self.view addSubview:shadowView];
    
    UIImageView * bgImg = [GUIDesign initWithImageView:CGRectMake(0,0, screenWidth, screenHeight) img:@"appBg.png"];
    [self.view addSubview:bgImg];
    
    discoveryView = [GUIDesign initWithView:CGRectMake((screenWidth-304)/2, (screenHeight-267)/2, 304, 267)];
    
    discoveryView.backgroundColor = [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:0.8];
    discoveryView.layer.cornerRadius = 8;
    [self.view addSubview:discoveryView];
    
    UIImageView* allowContacts = [GUIDesign initWithImageView:CGRectMake((discoveryView.frame.size.width -94)/2, 15, 94, 37) img:@"Connect-Contacts.png"];
    [discoveryView addSubview:allowContacts];
    
    UILabel * allowdiscoverylbl = [GUIDesign initWithLabel:CGRectMake((discoveryView.frame.size.width- 200)/2, allowContacts.frame.origin.y +30+10, 200, 20) title:@"Allow Discovery" font:16 txtcolor:[UIColor blackColor]];
    allowdiscoverylbl.textAlignment = NSTextAlignmentCenter;
    [discoveryView addSubview:allowdiscoverylbl];
    
    UILabel * allowdiscoveryscriptlbl = [GUIDesign initWithLabel:CGRectMake((discoveryView.frame.size.width- 280)/2, allowdiscoverylbl.frame.origin.y +30+10, 280,50 ) title:@"Turn on to allow your phone number to be displayed in your friends Contacts." font:16 txtcolor:[UIColor blackColor]];
    
    allowdiscoveryscriptlbl.textAlignment = NSTextAlignmentCenter;
    allowdiscoveryscriptlbl.lineBreakMode = NSLineBreakByWordWrapping;
    allowdiscoveryscriptlbl.numberOfLines = 0;
    [discoveryView addSubview:allowdiscoveryscriptlbl];
    
    switchDiscovery = [[UISwitch alloc]initWithFrame:CGRectMake((discoveryView.frame.size.width-49)/2, allowdiscoveryscriptlbl.frame.origin.y+ 50 + 20, 49, 31)];
    
    [discoveryView addSubview:switchDiscovery];
    [switchDiscovery setOn:YES];
    switchDiscovery.onTintColor = [GUIDesign yellowColor];
    
//    if (switchDiscovery.on == YES) {
//        [self callContact];
//    }
    
    UIButton * continueBtn = [GUIDesign initWithbutton:CGRectMake((discoveryView.frame.size.width-160)/2,switchDiscovery.frame.origin.y + 31+ 20, 160, 34) title:@"Continue" img:nil];
    continueBtn.layer.cornerRadius = 37/2;
    continueBtn.backgroundColor = [GUIDesign yellowColor];
    [continueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [continueBtn addTarget:self action:@selector(actionvisibleontacts:) forControlEvents:UIControlEventTouchUpInside];
    [discoveryView addSubview:continueBtn];
}

- (void)addRestoreView
{
    UIView * restoreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    restoreView.backgroundColor = [UIColor grayColor];
    restoreView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [self.view addSubview:restoreView];

    discoveryView = [GUIDesign initWithView:CGRectMake((screenWidth - 282)/2, (screenHeight - 169)/2, 282, 169)];
    discoveryView.backgroundColor = [UIColor darkGrayColor];
    discoveryView.layer.cornerRadius = 3;
    [self.view addSubview:discoveryView];

    UILabel * allowdiscoverylbl = [GUIDesign initWithLabel:CGRectMake(10, 20, discoveryView.frame.size.width - 20, 60) title:@"Do you want to restore backup?" font:16 txtcolor:[UIColor blackColor]];
    allowdiscoverylbl.font = [UIFont boldSystemFontOfSize:18.0];
    allowdiscoverylbl.textAlignment = NSTextAlignmentLeft;
    allowdiscoverylbl.numberOfLines = 2;
    [discoveryView addSubview:allowdiscoverylbl];
    
    UIButton * continueBtn = [GUIDesign initWithbutton:CGRectMake(10, 100, (discoveryView.frame.size.width - 30)/2, 40) title:@"Restore" img:nil];
    continueBtn.backgroundColor = [UIColor clearColor];
    [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueBtn addTarget:self action:@selector(chatAction) forControlEvents:UIControlEventTouchUpInside];
    [discoveryView addSubview:continueBtn];
    
    UIButton * skipBtn = [GUIDesign initWithbutton:CGRectMake((discoveryView.frame.size.width - 30)/2 + 10, 100, (discoveryView.frame.size.width - 30)/2, 40) title:@"Skip" img:nil];
    skipBtn.backgroundColor = [UIColor clearColor];
    [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(chatAction) forControlEvents:UIControlEventTouchUpInside];
    [discoveryView addSubview:skipBtn];
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        restoreView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            restoreView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                restoreView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (IBAction)restoreAction:(id)sender {
  
    [[DropboxManager shared] restoreBackup:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success == YES) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your chat history has been restored successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, could not restore your backup." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        });
    } progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];
}

-(void)chatAction{
    
    tabBar = [[UITabBarController alloc]init];
    
//    CSFavoritesViewController* favView = [[CSFavoritesViewController alloc]initWithNibName:nil bundle:nil];
//    favView.tabBarItem.title = @"Chats";
//    favView.tabBarItem.image = [UIImage imageNamed:@""];
//    
//    CSFavouritesViewController * favouritesView = [[CSFavouritesViewController alloc]initWithNibName:nil bundle:nil];
//    favouritesView.tabBarItem.title = @"Favourites";
//    favouritesView.tabBarItem.image = [UIImage imageNamed:@"fav_normal.png"];
//    
//    UINavigationController* favouritesNav = [[UINavigationController alloc]initWithRootViewController:favouritesView];
//    
//    CSFriendsViewController * friendsView = [[CSFriendsViewController alloc]initWithNibName:nil bundle:nil];
//    friendsView.tabBarItem.title = @"Friends";
//    friendsView.tabBarItem.image = [UIImage imageNamed:@"friend_normal.png"];
//    
//    UINavigationController* friendsNav = [[UINavigationController alloc]initWithRootViewController:friendsView];
//    
//    
//    chatView = [[CSChatmainViewController alloc]initWithNibName:nil bundle:nil];
//    chatView.tabBarItem.title = @"Chats";
//    chatView.tabBarItem.image = [UIImage imageNamed:@"chat_normal.png"];
//    
//    UINavigationController* chatNav = [[UINavigationController alloc]initWithRootViewController:chatView];
//    
//
//    YouTubeViewController* youtubeView = [[YouTubeViewController alloc]initWithNibName:nil bundle:nil];
//    youtubeView.tabBarItem.title = @"Youtube";
//    youtubeView.tabBarItem.image = [UIImage imageNamed:@"youtube_normal.png"];
//    
//    UINavigationController* youtubeNav = [[UINavigationController alloc]initWithRootViewController:youtubeView];
//
//    
//    SettingsViewController* settingsView = [[SettingsViewController alloc]initWithNibName:nil bundle:nil];
//    settingsView.tabBarItem.title = @"Settings";
//    settingsView.tabBarItem.image = [UIImage imageNamed:@"setting_normal.png"];
//    
//    UINavigationController* settingsNav = [[UINavigationController alloc]initWithRootViewController:settingsView];
//    
//    tabBar.viewControllers = [NSArray arrayWithObjects:favouritesNav,friendsNav,chatNav,youtubeNav,settingsNav, nil];
//    [tabBar.tabBar setTintColor:[GUIDesign yellowColor]];
//    
//    chatView.tabBarController.navigationItem.hidesBackButton = YES;
//    
//    tabBar.selectedIndex = 2;
//    
//    [tabBar.tabBar setBackgroundImage:[UIImage imageNamed:@"tab_bar_bg.png"]];
//    
//    //tabBar.hidesBottomBarWhenPushed = YES;
//    
//   // [[UIActionSheet appearance]setTintColor:[UIColor blackColor]];
//    
//    //  [[UITabBar appearance] setTintColor:[UIColor blackColor]];
//    
//    [self.navigationController pushViewController:tabBar animated:YES];
//    
//    chatView.tabBarItem.imageInsets = UIEdgeInsetsMake(-5, 0, 5, 0);
//    
//    CSChatmainViewController* nextView = [[CSChatmainViewController alloc]init];
//    [self.navigationController pushViewController:nextView animated:YES];
    
    
}

-(void)forstepOne{
    [nameField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nothing{
    
}

- (void)updateNickNameService:(NSString *)nickName{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatenickname" forKey:@"cmd"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatapp_id"] forKey:@"chatapp_id"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [dic setObject:[Utilities  encodingBase64:nickName] forKey:@"nickname"];
    
    [WebService loginApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){
            
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
                
                [user setObject:nickName forKey:@"nickname"];
                
                [user synchronize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self nickNameServiceSuccessfull];
                });
            }
            else{
                [self showAlert:[responseObject valueForKey:@"message"]];
            }
        }
        else{
            [self showAlert:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
        
    }];
}
- (void)nickNameServiceSuccessfull{
    
    if([Utilities isExistingUser]){
        [self continueAction];
    }else{
         #warning pls add restore view
//        [self addRestoreView];
        [self continueAction];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ContactsSync:)
                                                 name:@"ContactsSync"
                                               object:nil];
    [super viewWillAppear:YES];
}

-(void)ContactsSync:(NSNotification*)notification{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [app setupViewControllers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (IBAction)actionsyncontacts:(id)sender{
    if(switchSyncContacts.on){
        [[AddressBookContacts sharedInstance] loadAddressbook];
    }
    else{
        [AddressBookContacts sharedInstance].people = nil;
    }
}

- (IBAction)actionvisibleontacts:(id)sender{
    
    int visible = 0;
    if(switchDiscovery.on){
        visible = 1;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updateprofilevisibility" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[NSString stringWithFormat:@"%d",visible] forKey:@"profile_visibility"];
    
    [WebService contactSyncApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        if(responseObject){
            NSLog(@"%@",responseObject);
            [self actionskip:nil];
        }
    }];
}


- (IBAction)actionskip:(id)sender{
    
    if([[UIDevice currentDevice].systemVersion integerValue]>=6){
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
            switchSyncContacts.on = YES;
            
            [[AddressBookContacts sharedInstance] loadAddressbook];
        }
        else{
            switchSyncContacts.on = NO;
            
            AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            [app setupViewControllers];
        }
    }
    else{
        switchSyncContacts.on = YES;
        
        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [app setupViewControllers];
        
    }
}


-(void)take_photo_from_Gallery{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        [self presentViewController:picker animated:YES completion:nil];
        
    }else{
        [self showAlert:@"No photo gallery is available"];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img=[Utilities fixOrientation:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    NSLog(@"%@",[NSHomeDirectory() stringByAppendingPathComponent:@"userimage.png"]);
    
    [UIImagePNGRepresentation(img) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] atomically:YES];
    [addPhoto setBackgroundImage:img forState:UIControlStateNormal];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
