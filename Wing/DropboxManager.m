//
//  DropboxManager.m
//  ChatApp
//
//  Created by Jeeva on 5/14/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "DropboxManager.h"
#import <DropboxSDK/DropboxSDK.h>
#import "SSZipArchive.h"
#import "Utilities.h"
#import "WebService.h"
#import "Constants.h"
#import "AppDelegate.h"

static NSUInteger const kSignInAlertViewTag = 1;
static NSUInteger const kSignOutAlertViewTag = 3;


@interface DropboxManager () <DBRestClientDelegate>

//@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, assign) BOOL isShowingLoginAlertView;
@property (nonatomic, copy) void(^uploadCompletionBlock)(BOOL success);
@property (nonatomic, copy) void(^downloadCompletionBlock)(BOOL success);
@property (nonatomic, copy) void(^loginCompletionBlock)(BOOL success);
@property (nonatomic, copy) void(^logoutCompletionBlock)(BOOL success);
@property (nonatomic, copy) void(^uploadProgressBlock)(CGFloat progress);
@property (nonatomic, copy) void(^downloadProgressBlock)(CGFloat progress);

@property (assign) SEL loginSuccessSelector;
//- (DBRestClient *)restClient;
@end

@implementation DropboxManager

@synthesize delegate;

+ (instancetype)shared
{
    static DropboxManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [DropboxManager new];
    });
      [[NSNotificationCenter defaultCenter] addObserver:sharedManager selector:@selector(isDropboxLinkedHandle:) name:@"isDropboxLinked" object:nil];
    return sharedManager;
}

- (void)isDropboxLinkedHandle:(id)sender
{
    if ([[sender object] intValue]) {
        if (_loginSuccessSelector) {
            if (self.loginSuccessSelector == @selector(restoreBackup:progress:)) {
                [self performSelector:self.loginSuccessSelector withObject:_downloadCompletionBlock withObject:_downloadProgressBlock];
            }
            else{
                [self performSelector:self.loginSuccessSelector withObject:_uploadCompletionBlock withObject:_uploadProgressBlock];
            }
            _loginSuccessSelector = nil;
        }
        if (self.loginCompletionBlock) {
            self.loginCompletionBlock(YES);
        }
    }
    else {
        //is not linked
        if (self.loginCompletionBlock) {
            self.loginCompletionBlock(NO);
        }
    }
}

- (void)loginOfDropboxWithCompletionHandler:(void(^)(BOOL success))completion
{
    self.loginCompletionBlock = completion;
    [self loginOfDropbox];
}

- (void)logoutOfDropboxWithCompletionHandler:(void(^)(BOOL success))completion
{
    self.logoutCompletionBlock = completion;
    [self logoutOfDropbox];
    
}

+ (NSString*)dropboxPath
{
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"dropbox"];
    return documentsPath;
}

+ (NSString*)dropboxFilePath:(NSString*)fileName
{
    return [[DropboxManager dropboxPath] stringByAppendingPathComponent:fileName];
}


+ (NSString*)localThumbnailPathForFile:(NSString*)fileName
{
    return [[[DropboxManager dropboxPath] stringByAppendingPathComponent:@"thumbnail"] stringByAppendingPathComponent:fileName];
}


#pragma mark - DBRestClientDelegate Methods

- (DBRestClient *)restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

- (void)backup:(void(^)(BOOL success))completion progress:(void(^)(CGFloat progress))progress
{
    self.uploadCompletionBlock = completion;
    self.uploadProgressBlock = progress;
    
    if (![self isDropboxLinked]) {
        self.loginSuccessSelector = @selector(backup:progress:);
        [self loginOfDropbox];
    }
    else{
        [self performSelectorOnMainThread:@selector(doUpload) withObject:nil waitUntilDone:NO];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains
//        (NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        // NSLog(@"files array %@", filePathsArray);
//        //make a file name to write the data to using the documents directory:
//        NSArray *cacheArray = NSSearchPathForDirectoriesInDomains
//        (NSCachesDirectory, NSUserDomainMask, YES);
//        NSString *cacheDirectory = [cacheArray objectAtIndex:0];
//        NSString *fileName = [NSString stringWithFormat:@"%@/%@",
//                              cacheDirectory,@"DropBox.zip"];
//        NSLog(@"sender id---%@",[Utilities getSenderId]);
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
////            [SSZipArchive createZipFileAtPath:fileName withContentsOfDirectory:documentsDirectory];
////            NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_chatBackup",[Utilities getSenderId]];
////            [[self restClient] uploadFile:@"dropboxbackup.zip" toPath:folder_name fromPath:fileName];
////            //[[self restClient] uploadFile:@"dropboxbackup.zip"  toPath:folder_name withParentRev:nil fromPath:fileName];
////        });
//        [SSZipArchive createZipFileAtPath:fileName withContentsOfDirectory:documentsDirectory];
//        NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_chatBackup",[Utilities getSenderId]];
//        [[self restClient] uploadFile:@"dropboxbackup.zip" toPath:folder_name fromPath:fileName];
    }
    
    
    
}
- (void)saveToDropBox:(void(^)(BOOL success))completion progress:(void(^)(CGFloat progress))progress fileURL:(NSString *)fileURL
{
    self.uploadCompletionBlock = completion;
    self.uploadProgressBlock = progress;
    
    if (![self isDropboxLinked]) {
        self.loginSuccessSelector = @selector(saveToDropBox:progress:fileURL:);
        [self loginOfDropbox];
    }
    else{
        [self doSave:fileURL];
        //[self performSelectorOnMainThread:@selector(doSave) withObject:fileURL waitUntilDone:NO];
        
    }
    
    
    
}
- (void)restoreBackup:(void(^)(BOOL success))completion progress:(void(^)(CGFloat progress))progress
{
    self.downloadCompletionBlock = completion;
    self.downloadProgressBlock = progress;
    if (![self isDropboxLinked]) {
        self.loginSuccessSelector = @selector(restoreBackup:progress:);
        [self loginOfDropbox];
    }
    else{
        [self performSelectorOnMainThread:@selector(DBdownload:) withObject:nil waitUntilDone:NO];
    }
    
    
    
}
- (void)doUpload
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // NSLog(@"files array %@", filePathsArray);
    //make a file name to write the data to using the documents directory:
    NSArray *cacheArray = NSSearchPathForDirectoriesInDomains
    (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cacheArray objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
                          cacheDirectory,@"DropBox.zip"];
    NSLog(@"sender id---%@",[Utilities getSenderId]);
    [SSZipArchive createZipFileAtPath:fileName withContentsOfDirectory:documentsDirectory];
    NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_chatBackup",[Utilities getSenderId]];
    [[self restClient] uploadFile:@"dropboxbackup.zip" toPath:folder_name fromPath:fileName];
    //[[self restClient] uploadFile:@"dropboxbackup.zip"  toPath:folder_name withParentRev:folder_name fromPath:fileName];
}

- (void)doSave:(NSString *)fileName
{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_Gallery",[Utilities getSenderId]];
        
        // [[self restClient] uploadFile:[fileName lastPathComponent]  toPath:folder_name withParentRev:nil fromPath:fileName];
        
        [[self restClient] uploadFile:[fileName lastPathComponent] toPath:folder_name fromPath:fileName];
    }
}


-(void) DBdownload:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"dropboxbackup1.zip"];
    NSString *folder_name = [NSString stringWithFormat:@"/%@_Wing_chatBackup",[Utilities getSenderId]];
    NSString *fileName = @"dropboxbackup.zip";
    NSString *downloadFilePath = [NSString stringWithFormat:@"/%@/%@",folder_name,fileName];
    [self.restClient loadFile:downloadFilePath intoPath:filePath];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    NSLog(@"uploadedFile--%@",destPath);
    NSLog(@"uploadedFile--%@",destPath);
    [self updateBackUpStatus:@"1"];
    
    if ([[self delegate] respondsToSelector:@selector(uploadedChatHistory:)]) {
        [[self delegate] uploadedChatHistory:@"1"];
    }
    
    if (self.uploadCompletionBlock) {
        self.uploadCompletionBlock(YES);
    }
    // [self closePage];
    
    
}
- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
           forFile:(NSString*)destPath from:(NSString*)srcPath
{
    
    NSLog(@"DropboxuploadProgress--%f",progress);
    if (self.uploadProgressBlock) {
        self.uploadProgressBlock(progress);
    }
    
}
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSLog(@"DropboxuploadProgress--%@",error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Chat Backup failed, Please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self updateBackUpStatus:@"0"];
    if ([[self delegate] respondsToSelector:@selector(uploadedChatHistory:)]) {
        [[self delegate] uploadedChatHistory:@"0"];
    }
    
    if (self.uploadCompletionBlock) {
        self.uploadCompletionBlock(NO);
    }
    //[self closePage];
}

// Deprecated upload callback
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    NSLog(@"uploadedFile--%@",destPath);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wing" message:@"Chat Backup Success" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self updateBackUpStatus:@"1"];
    if (self.uploadCompletionBlock) {
        self.uploadCompletionBlock(YES);
    }
    //[self closePage];
    
}

- (void)restClient:(DBRestClient *)client uploadFromUploadIdFailedWithError:(NSError *)error;
{
    
    NSLog(@"uploadFromUploadIdFailedWithError--%@",error);
    
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata
{
    [self processDownloadedFile:destPath];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath
{
    if (self.downloadProgressBlock) {
        self.downloadProgressBlock(progress);
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error
{
    NSLog(@"DownloadFailedWithError--%@",error);
    if (self.downloadCompletionBlock) {
        self.downloadCompletionBlock(NO);
    }
}


- (void)updateBackUpStatus:(NSString *)flag
{
    
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
    NSString* dateString = [f stringFromDate:[NSDate date]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    if([Utilities getSenderId]){
        [dict setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
        [dict setObject:flag forKey:@"enable_backup"];
        [dict setObject:dateString forKey:@"backup_date"];
        
        
        if ([flag isEqualToString:@"1"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:Dropbox_Last_Back_Date];
        }
        
        [WebService runCMDBackUp:dict completionBlock:^(NSObject *responseObject, NSInteger errorCode)
         {
             NSLog(@"responseObject---%@",responseObject);
         }];
    }
}

- (BOOL)isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    
}

- (void)loginOfDropbox
{
    if (self.isShowingLoginAlertView == NO) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login to Dropbox", @"DropboxBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"%@ is not linked to your Dropbox. Would you like to login now and allow access?", @"DropboxBrowser: Alert Message. 'APP NAME' is not linked to Dropbox..."), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Login", @"DropboxBrowser: Alert Button"), nil];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login to Dropbox", @"DropboxBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"Wing is not linked to your Dropbox. Would you like to login now and allow access?", @"DropboxBrowser: Alert Message. 'APP NAME' is not linked to Dropbox...")] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Login", @"DropboxBrowser: Alert Button"), nil];

        alertView.tag = kSignInAlertViewTag;
        [alertView show];
        self.isShowingLoginAlertView = YES;
    }
}

- (void)logoutOfDropbox {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Logout of Dropbox", @"DropboxBrowser: Alert Title") message:[NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to logout of Dropbox and revoke Dropbox access for %@?", @"DropboxBrowser: Alert Message. ...revoke Dropbox access for 'APP NAME'"), [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"DropboxBrowser: Alert Button") otherButtonTitles:NSLocalizedString(@"Logout", @"DropboxBrowser: Alert Button"), nil];
    alertView.tag = kSignOutAlertViewTag;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kSignInAlertViewTag) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:{
                AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                UIViewController *topVC = appDelegate.tabBarController.selectedViewController.navigationController;
                [[DBSession sharedSession] linkFromController:[self topViewController]];
                
            }
                
                break;
            default:
                break;
        }
        self.isShowingLoginAlertView = NO;
    }
    else if (alertView.tag == kSignOutAlertViewTag) {
        switch (buttonIndex) {
            case 0: break;
            case 1: {
                [[DBSession sharedSession] unlinkAll];
                if (self.logoutCompletionBlock) {
                    self.logoutCompletionBlock(YES);
                }
            } break;
            default:
                break;
        }
    }
}

- (void)processDownloadedFile:(NSString*)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    if (filePath) { // check if file exists - if so load it:
        [SSZipArchive unzipFileAtPath:filePath toDestination:documentsDirectory delegate:self];
    }
    if (self.downloadCompletionBlock) {
        self.downloadCompletionBlock(YES);
    }
}

- (void)autoBackup
{
    if ([self isDropboxLinked] && [Utilities isExistingUser]) {
        NSDictionary *chatBackupType = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatBackupType"];
        AutoBackup autobackup = [[chatBackupType objectForKey:@"autoBackup"] integerValue];
        NSDate *lastBackupDate = [[NSUserDefaults standardUserDefaults] objectForKey:Dropbox_Last_Back_Date];
        BOOL startBackup = NO;
        
        if (lastBackupDate) {
            NSInteger elapsedDays = [DropboxManager daysBetweenDate:lastBackupDate andDate:[NSDate date]];
            switch (autobackup) {
                case AutoBackupDaily:
                    if (elapsedDays >= 1) {
                        startBackup = YES;
                    }
                    break;
                case AutoBackupWeekly:
                    if (elapsedDays >= 7) {
                        startBackup = YES;
                    }
                    break;
                case AutoBackupMothly:
                    if (elapsedDays >= 30) {
                        startBackup = YES;
                    }
                    break;
                case AutoBackupOff:
                    startBackup = NO;
                    break;
                default:
                    
                    break;
            }
        }
        else{
            startBackup = YES;
        }
        
        if (startBackup == YES) {
            [self backup:nil progress:nil];
        }

    }
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}



-(UIWindow *) returnWindowWithWindowLevelNormal
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for(UIWindow *topWindow in windows)
    {
        if (topWindow.windowLevel == UIWindowLevelNormal)
            return topWindow;
    }
    return [UIApplication sharedApplication].keyWindow;
}

-(UIViewController *) topViewController
{
    UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        topWindow = [self returnWindowWithWindowLevelNormal];
    }
    
    UIViewController *topController = topWindow.rootViewController;
    if(topController == nil)
    {
        topWindow = [UIApplication sharedApplication].delegate.window;
        if (topWindow.windowLevel != UIWindowLevelNormal)
        {
            topWindow = [self returnWindowWithWindowLevelNormal];
        }
        topController = topWindow.rootViewController;
    }
    
    while(topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    if([topController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nav = (UINavigationController*)topController;
        topController = [nav.viewControllers lastObject];
        
        while(topController.presentedViewController)
        {
            topController = topController.presentedViewController;
        }
    }
    
    return topController;
}
@end
