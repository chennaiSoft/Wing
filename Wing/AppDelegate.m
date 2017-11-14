//
//  AppDelegate.m
//  Wing
//
//  Created by CSCS on 1/7/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPConnect.h"
#import "WebService.h"
#import "ChatStorageDB.h"

//
#import "CommonPopUpView.h"
#import "ContactDb.h"
#import "MessgaeTypeConstant.h"
#import "DemoMessagesViewController.h"
#import "AddressBookContacts.h"

#import <DropboxSDK/DropboxSDK.h>
#import "DropboxManager.h"

#import <BoxContentSDK/BOXContentSDK.h>

#import "SCFacebook.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Fabric/Fabric.h>
#import <DigitsKit/DigitsKit.h>
#import <Intents/Intents.h>



@interface AppDelegate ()

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;

@end

@implementation AppDelegate

@synthesize xmppStream;
@synthesize isChatPage;
@synthesize strdevicetoken;

@synthesize loginController;
@synthesize navController;
@synthesize splashController;
@synthesize navigationPaneViewController;
@synthesize chatViewControllersDic;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Digits class]]];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    chatViewControllersDic = [[NSMutableDictionary alloc]init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification1 object:nil];
    
    self.applaunch = YES;
    self.strdevicetoken = @"";
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    self.internetReachability = [ReachabilityNew reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    [XMPPConnect sharedInstance];
    
    self.internetReachability = [ReachabilityNew reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    [SCFacebook initWithReadPermissions:@[@"user_about_me",
                                          @"user_birthday",
                                          @"email",
                                          @"user_photos",
                                          @"user_events",
                                          @"friends_events",
                                          @"share_item",
                                          @"user_friends",
                                          @"user_videos",
                                          @"public_profile"] publishPermissions:@[@"user_about_me",
                                                                                  @"user_birthday",
                                                                                  @"email",
                                                                                  @"user_photos",
                                                                                  @"user_events",
                                                                                  @"friends_events",
                                                                                  @"share_item",
                                                                                  @"user_friends",
                                                                                  @"user_videos",
                                                                                  @"public_profile"]];
    
    if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"isFirstInstall"]] isEqualToString:@""]){
        self.splashController = [[SplashViewController alloc]init];
        self.navController = [[UINavigationController alloc]initWithRootViewController:self.splashController];
        [self.window setRootViewController:self.navController];
    }
    else{
        
        NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
        if ([user boolForKey:@"userLogin"]) {
            //Already logined
            [self setupViewControllers];
            
            [XMPPConnect sharedInstance].connectingStatus  = 1;
            [[XMPPConnect sharedInstance]getConnectionStatus];

            [self performSelector:@selector(connectWithXMPP) withObject:nil afterDelay:4];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AddressBookContacts sharedInstance]loadAddressbook1];
            });
            
        }else{
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CSIntroViewController * introController = (CSIntroViewController *)[sb instantiateViewControllerWithIdentifier:@"CSIntroViewController"];
            
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:introController];
            [nav setNavigationBarHidden:YES];
            
            self.window.rootViewController = nav;
        }
    }
    
    [self.window makeKeyAndVisible];
    
    if([UIDevice currentDevice].systemVersion.intValue >= 8){
        
        [[UIAlertView appearance]setTintColor:[UIColor blackColor]];
        
        [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor blackColor]];
    }
    
    [[UINavigationBar appearance]setTintColor:[UIColor blackColor]];
    [[UIToolbar appearance]setTintColor:[UIColor blackColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor blackColor];
    }

   dispatch_async(dispatch_get_main_queue(), ^{
        
        [[SDImageCache sharedImageCache] cleanDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        
        DBSession *dbSession = [[DBSession alloc] initWithAppKey:Dropbox_App_Key appSecret:Dropbox_App_Secret_Key root:kDBRootDropbox];
        [DBSession setSharedSession:dbSession];
        
        [[DropboxManager shared] autoBackup];
    });
    
    
    [BOXContentClient setClientID:Box_Client_ID clientSecret:Box_Client_Secret];

    // Override point for customization after application launch.
   // [GMSServices provideAPIKey:@"AIzaSyBXdLyxM3Lzpd8l9PIXkvCrCXH55ljKb-o"];
    
    if (locationmanager == nil)
    {
        locationmanager = [[CLLocationManager alloc] init];
        locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    if ([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationmanager requestWhenInUseAuthorization];
    }
    
    [locationmanager startUpdatingLocation];
    
//    [self requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
//        
//        NSLog(@"Siri Used");
//        
//    }];
//    
    return YES;
}

-(void)requestSiriAuthorization:(void (^)(INSiriAuthorizationStatus status))handler{
    

    
}
 

- (void)application:(UIApplication *)application   didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    self.strdevicetoken = [NSString stringWithFormat:@"%@",[deviceToken description]];
    
    self.strdevicetoken = [self.strdevicetoken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    self.strdevicetoken = [self.strdevicetoken stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    self.strdevicetoken = [self.strdevicetoken stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSLog(@"My token is: %@", self.strdevicetoken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0){
    
    NSLog(@"%@",userInfo);
}

#pragma mark PopUp View

- (void)showPopUopView:(NSMutableDictionary*)dictResponse{
    
    [[CommonPopUpView sharedInstance] setDelegate:(id<popUpViewDelegate>)self];
    
    [[CommonPopUpView sharedInstance].dictResponse removeAllObjects];
    [CommonPopUpView sharedInstance].dictResponse = dictResponse;
    
    NSString *name;
    
    if([[dictResponse valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        name = [[ChatStorageDB sharedInstance]validateGroupName:[dictResponse valueForKey:@"jid"]].capitalizedString;
        [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
    }
    else{
        
        [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
        name = [[ContactDb sharedInstance]validateUserName:[dictResponse valueForKey:@"jid"]];
    }
    
    [CommonPopUpView sharedInstance].labelName.text = [[ContactDb sharedInstance]validateUserName:name].capitalizedString;
    
    NSString *strmessage = @"";
    switch ([[dictResponse valueForKey:@"messagetype"] integerValue]) {
        case MessageTypeText:
            strmessage = @"Sent you a message";
            break;
            
        case MessageTypeImage:
            strmessage = @"Sent you a photo";
            break;
        case MessageTypeVideo:
            strmessage = @"Sent you a video";
            break;
        case MessageTypeContact:
            strmessage = @"Shared you a contact";
            break;
        case MessageTypeLocation:
            strmessage = @"Shared you a location";
            break;
        case MessageTypeAudio:
            strmessage = @"Sent you a audio";
            break;
        case MessageTypeFile:
            strmessage = @"Sent you a file";
            break;
            
        default:
            break;
    }
    [CommonPopUpView sharedInstance].labelMessage.text = strmessage;
    
    [[CommonPopUpView sharedInstance]show:self.tabBarController.selectedViewController];
    [self.window bringSubviewToFront:[CommonPopUpView sharedInstance]];
}



- (void)popupviewclick:(NSMutableDictionary*)object{

    UINavigationController * nav = [self.tabBarController.viewControllers objectAtIndex:2];
    
    CSChatmainViewController * chatViewController = [nav.viewControllers objectAtIndex:0];
    
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
    
    if ([self.chatViewControllersDic objectForKey:[object valueForKey:@"jid"]] == nil) {
        
        DemoMessagesViewController * vc = [DemoMessagesViewController messagesViewController];
        vc.hidesBottomBarWhenPushed = YES;
        
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
        [self.chatViewControllersDic setObject:vc forKey:[object valueForKey:@"jid"]];

        [chatViewController.navigationController pushViewController:vc animated:YES];
        
    }else{
        NSLog(@"%@",@"fast");
        
        DemoMessagesViewController * chat = [self.chatViewControllersDic objectForKey:[object valueForKey:@"jid"]];
        
        [chatViewController.navigationController pushViewController:chat animated:YES];
        NSLog(@"%@",@"Completed");
    }
}


#pragma mark Reachability

- (void) reachabilityChanged:(NSNotification *)note
{
    ReachabilityNew * curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[ReachabilityNew class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(ReachabilityNew *)reachability
{
    [self configureTextField:nil imageView:nil reachability:reachability];
}

- (void)configureTextField:(UITextField *)textField imageView:(UIImageView *)imageView reachability:(ReachabilityNew *)reachability
{
    
    NetworkStatus1 netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    NSString* statusString = @"";
    
    switch (netStatus)
    {
        case NotReachable1:        {
            statusString = NSLocalizedString(@"Access Not Available", @"Text field text for access is not available");
            
            NSLog(@"CONN REQ: %d",connectionRequired);
            
            /*
             Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
             */
            connectionRequired = NO;
            
            if(self.applaunch){
                NSString *msg=[NSString stringWithFormat:@"%@ \n \n %@",@"No working internet connection is found.",@"If Wi-Fi is enabled, try disabling Wi-Fi or try another Wi-Fi hotspot."];
                
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Internet!" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                
                [alert show];
                self.applaunch = NO;
                
            }
            
            if(![[Utilities checkNil:[Utilities getSenderId]] isEqualToString:@""]){
                [[XMPPConnect sharedInstance]goOffline];
            }

            break;
        }
            
        case ReachableViaWWAN1:{

            self.applaunch = YES;
            
            if(![[Utilities checkNil:[Utilities getSenderId]] isEqualToString:@""]){
                [[XMPPConnect sharedInstance]goOnline];
            }
            
            statusString = NSLocalizedString(@"Reachable WWAN", @"");
            break;
        }
        case ReachableViaWiFi1:        {
            self.applaunch = YES;
            
            statusString= NSLocalizedString(@"Reachable WiFi", @"");

            if(![[Utilities checkNil:[Utilities getSenderId]] isEqualToString:@""]){
                [[XMPPConnect sharedInstance]goOnline];
            }
            
            break;
        }
    }
    
    if (connectionRequired)
    {
        NSString *connectionRequiredFormatString = NSLocalizedString(@"%@, Connection Required", @"Concatenation of status string with connection requirement");
        statusString= [NSString stringWithFormat:connectionRequiredFormatString, statusString];
    }
}

- (void)connectWithXMPP{
    [[XMPPConnect sharedInstance]connectWithXMPP];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self disconnect];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connect];
    [FBSDKAppEvents activateApp];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if(![[Utilities checkNil:[Utilities getSenderId]] isEqualToString:@""]){
        [[XMPPConnect sharedInstance]goOffline];
        [WebService updateLastSeen:[Utilities getSenderId] completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if(![[Utilities checkNil:[Utilities getSenderId]] isEqualToString:@""]){
        if([[XMPPConnect sharedInstance] getNetworkStatus]==NO){
            [[XMPPConnect sharedInstance] connectXMPPStream];
        }
        else{
            NSLog(@"go online");
            [[XMPPConnect sharedInstance] goOnline];
        }
        
        [WebService updateLastSeen:[Utilities getSenderId] completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        }];
    }
    [[DropboxManager shared] autoBackup];
    

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.CSCS.Wing" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wing" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wing.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma Mark - XMPP Implementation

- (void)setupStream {
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

- (BOOL)connect {
    
    [self setupStream];
    
    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userID"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"userPassword"];
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;
    
//    NSError *error = nil;
//    if (![xmppStream connect:&amp:error])
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//        
//        
//        return NO;
//    }
    
    return YES;
}

- (void)disconnect {
    [self goOffline];
    [xmppStream disconnect];
}

/*
 Configuring view controller
 */

- (void)setupViewControllers {
    
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    [user setBool:YES forKey:@"userLogin"];
    [user synchronize];
    
    self.firstViewController = [[CSFavouritesViewController alloc] init];
    UIViewController * secondViewController = [[CSFriendsViewController alloc] init];
    
    self.thirdViewController = [[CSChatmainViewController alloc] init];
    
    self.fourthViewController = [[CSYoutubeViewController alloc] init];
    UIViewController * fifthViewController = [[CSSettingsViewController alloc] init];
    
    UINavigationController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:self.firstViewController];
    

    UINavigationController *secondNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:secondViewController];
    UINavigationController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:self.thirdViewController];
    UINavigationController *fourthNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:self.fourthViewController];
    UINavigationController *fifthNavigationController = [[UINavigationController alloc]
                                                          initWithRootViewController:fifthViewController];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    [self.tabBarController setViewControllers:@[firstNavigationController, secondNavigationController,thirdNavigationController,fourthNavigationController,fifthNavigationController]];
    
    self.tabBarController.tabBar.barStyle = UIBarStyleBlack;
    
// Ameen commented
    
    UIImage * bgImg = [UIImage imageNamed:@"bottom_tab_bg"];
    [self.tabBarController.tabBar setBackgroundImage:bgImg];
    
    if(screenHeight == 667){
        
        UIImage * bgImg = [UIImage imageNamed:@"bottom_tab_bg6"];
        [self.tabBarController.tabBar setBackgroundImage:bgImg];
        
    }else if(screenHeight > 667){
        
        UIImage * bgImg = [UIImage imageNamed:@"bottom_tab_6+"];
        [self.tabBarController.tabBar setBackgroundImage:bgImg];
        
    }
        
//    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bottom_tab_bg"]];
    
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    self.tabBarController.selectedIndex = 2;
    
//    [[UIActionSheet appearance]setTintColor:[UIColor blackColor]];
//    
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];
    
    self.imageFullView = [[ImageGridViewController alloc]init];
    
    self.mainMenuViewController = [[JDSideMenu alloc] initWithContentController:self.tabBarController menuController:self.imageFullView];
    
    [self.window setRootViewController:self.tabBarController];
    
    [self performSelectorOnMainThread:@selector(updateStatus) withObject:nil waitUntilDone:YES];
    
    //commented by thangarajan
//    if(self.fourthViewController){
//        [self.fourthViewController reloadTable];
//    }

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
   
    NSLog(@"%@",url);

    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"isDropboxLinked"
             object:[NSNumber numberWithBool:[[DBSession sharedSession] isLinked]]];
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    else{
        
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation];
    }
    
//    NSString *deeppath  = [url path];
//    NSString *squery = [url query];
    
    
    // take some action based on the path and query
    
}

- (void)updateStatus{
    @autoreleasepool {
        [[ChatStorageDB sharedInstance]resetUploadAndDownloadStatus];
    }
}

#pragma mark Open passcode lock
- (void)actioHideOrShow:(NSString*)chatsession viewcontrol:(UIViewController*)controller isgroupchat:(NSString*)isgroupchat{
    
    Passcode * passcode = [[Passcode alloc]init];
    passcode.stringJid  =chatsession;
    passcode.isgroupchat = isgroupchat;
    
    NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:chatsession]];
    if([str isEqualToString:@""])
    {
        passcode.checkForPasscodeSetup = YES;
        passcode.checkForPasscodeOff = NO;
        passcode.checkForInitialLoad = NO;
    }
    else{
        passcode.checkForPasscodeSetup = NO;
        passcode.checkForPasscodeOff = YES;
        passcode.checkForInitialLoad = NO;
    }
    
    [passcode setDelegate:(id<PasscodeDelegate>)controller];
    [controller.navigationController presentViewController:passcode animated:YES completion:nil];
}


- (void)actioHideOrShowPasscode:(NSString*)chatsession viewcontrol:(UIViewController*)controller isgroupchat:(NSString*)isgroupchat unhide:(BOOL)unhide{
    
    Passcode *passcode = [[Passcode alloc]init];
    passcode.stringJid  =chatsession;
    passcode.isgroupchat = isgroupchat;
    
    NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:chatsession]];
    if([str isEqualToString:@""])
    {
        passcode.checkForPasscodeSetup = YES;
        passcode.checkForPasscodeOff = NO;
        passcode.checkForInitialLoad = NO;
        
    }
    else{
        passcode.checkForPasscodeSetup = NO;
        passcode.checkForPasscodeOff = YES;
        passcode.checkForInitialLoad = NO;
    }
    passcode.checkForUnHide = unhide;
    
    [passcode setDelegate:(id<PasscodeDelegate>)controller];
    [controller.navigationController presentViewController:passcode animated:YES completion:nil];
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
