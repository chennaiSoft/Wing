//
//  AppDelegate.h
//  Wing
//
//  Created by CSCS on 1/7/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <XMPP.h>
#import "ReachabilityNew.h"
#import "CSIntroViewController.h"

#import "CSChatmainViewController.h"
#import "CSFavouritesViewController.h"
#import "CSFriendsViewController.h"
#import "CSSettingsViewController.h"
#import "CSYoutubeViewController.h"
#import "ViewController.h"
#import "CSloginViewController.h"
#import "SplashViewController.h"

#import "JDSideMenu.h"
#import "ImageGridViewController.h"
#import "Passcode.h"
#import <CoreLocation/CoreLocation.h>

@class MSNavigationPaneViewController;
@class MainMenuViewController;
@class SlideMenuViewController;

#define screenWidth ([UIScreen mainScreen].bounds.size.width)
#define screenHeight ([UIScreen mainScreen].bounds.size.height)

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    XMPPStream * xmppStream;
    NSString *password;
    BOOL isOpen;
    CLLocationManager * locationmanager;
}

@property (nonatomic, strong) NSMutableDictionary * chatViewControllersDic;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) XMPPStream * xmppStream;

@property (strong, nonatomic) CSloginViewController *loginController;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) SplashViewController *splashController;
@property (strong, nonatomic) UIViewController * currentRootView;

@property (strong, nonatomic) NSString *strdevicetoken;
@property (nonatomic)BOOL isChatPage;

@property (nonatomic, assign) ReachabilityNew *hostReachability;
@property (nonatomic, assign) ReachabilityNew *internetReachability;
@property (nonatomic, assign) ReachabilityNew *wifiReachability;
@property (nonatomic) BOOL applaunch;
@property (nonatomic, strong) UITabBarController *tabBarController;

@property (nonatomic, strong) CSChatmainViewController *thirdViewController;
@property (nonatomic, strong) JDSideMenu *mainMenuViewController;
@property (nonatomic, strong) ImageGridViewController *imageFullView;
@property (nonatomic, strong) CSYoutubeViewController *fourthViewController;
@property (nonatomic, strong) CSFavouritesViewController *firstViewController;
@property (nonatomic, strong) UIImage * appImageAnimation;
@property (strong, nonatomic) MSNavigationPaneViewController *navigationPaneViewController;
@property (strong, nonatomic) MainMenuViewController *menu;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)setupViewControllers;
- (BOOL)connect;
- (void)disconnect;
- (UIViewController *)topViewController;
- (void)showPopUopView:(NSMutableDictionary*)dictResponse;
- (void)popupviewclick:(NSMutableDictionary*)dictoutput;
- (void)actioHideOrShow:(NSString*)chatsession viewcontrol:(UIViewController*)controller isgroupchat:(NSString*)isgroupchat;
- (void)actioHideOrShowPasscode:(NSString*)chatsession viewcontrol:(UIViewController*)controller isgroupchat:(NSString*)isgroupchat unhide:(BOOL)unhide;
@end

