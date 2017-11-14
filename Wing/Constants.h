//
//  Constants.h
//  ChatApp
//
//  Created by theen on 30/11/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#ifndef ChatApp_Constants_h
#define ChatApp_Constants_h

#define FTPURL @"http://54.169.119.103/api.php?"

#define UPLOADFILE @"http://54.169.119.103/uploadfile.php?"
#define CONTACTSSYNC @"http://54.169.119.103/contactssync.php?"
#define SOCIALSYNC @"http://54.169.119.103/socialsync.php?"

#define CMDLOGIN @"login"
#define BACKUPCHAT @"http://54.169.119.103/updatebackup.php?"
#define YOUTUBEAPIKEY @"AIzaSyBvWgIHegQX5iiWGJ-3FPdDK8XGxLP0RgQ"

#define IMGURL @"http://54.169.119.103/userimage/"
#define FBIMAGEURL @"https://graph.facebook.com/"

#define HOSTURL  @"54.169.119.103"
#define HOSTPORT @"5222"
#define HOSTNAME @"@ec2-54-169-119-103.ap-southeast-1.compute.amazonaws.com"
#define HOSTNAME1 @"ec2-54-169-119-103.ap-southeast-1.compute.amazonaws.com"
#define UNIQUERESOURCE @"chatazapunique"
#define GROUPCHAT @"@conference.ec2-54-169-119-103.ap-southeast-1.compute.amazonaws.com"

#define CAPTION @"Invitation to WING"

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

#define Dropbox_Last_Back_Date @"Dropbox_Last_Back_Date"
#define Dropbox_App_Key @"weds4qichkdog3c"
#define Dropbox_App_Secret_Key @"vi0tlkdvffpzcsl"

#define Box_Client_ID @"hc5f0fpyrwsg8r9r3cc9ajikoyi67wgv"
#define Box_Client_Secret @"TCGF82euRQRv2Di2HjwCYrv1RWM9V3VK"


typedef enum : NSUInteger {
    AutoBackupDaily,
    AutoBackupWeekly,
    AutoBackupMothly,
    AutoBackupOff,
} AutoBackup;

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define APPURL @"https://itunes.apple.com/in/app/wing/id990203702?mt=8"
#define APPID @"990203702"

#define INVITEMSG @"I'm using Wing to send free messages on iPhone http://www.thewing.io"

#define INVITESMS @"Hey, I started using Wing. It's an awsome free app for text messages! - http://www.thewing.io"


#define SHAREIMGURL @"http://54.169.119.103/share_fb_url.png"

#define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define _DEVICE_WINDOW ((UIView*)[UIApplication sharedApplication].keyWindow)


/*
 //This is for development api

 //http://54.254.197.29:9090/index.jsp
 
 #define FTPURL @"http://54.254.197.29/api.php?"
 
 #define UPLOADFILE @"http://54.254.197.29/uploadfile.php?"
 #define CONTACTSSYNC @"http://54.254.197.29/contactssync.php?"
 #define SOCIALSYNC @"http://54.254.197.29/socialsync.php?"
 
 #define CMDLOGIN @"login"
 #define BACKUPCHAT @"http://54.254.197.29/updatebackup.php?"
 #define YOUTUBEAPIKEY @"AIzaSyBvWgIHegQX5iiWGJ-3FPdDK8XGxLP0RgQ"
//allowSelfSignedCertificates = YES;
//allowSSLHostNameMismatch = NO;
 //#define IMGURL @"http://apps4wings.co.in/chatapp1/mobileapp/userimage/"
 #define IMGURL @"http://54.254.197.29/userimage/"
 #define FBIMAGEURL @"https://graph.facebook.com/"
 
 #define HOSTURL  @"54.254.197.29"
 //
 #define HOSTPORT @"5222"
 #define HOSTNAME @"@ip-54.254.197.29"
 #define HOSTNAME1 @"ip-54.254.197.29"
 
 #define UNIQUERESOURCE @"wingunique"
 
 #define GROUPCHAT @"@conference.ip-54.254.197.29"
 
 
 #define CAPTION @"Invitation to WING"
 

 static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
 
 #define Dropbox_Last_Back_Date @"Dropbox_Last_Back_Date"
 #define Dropbox_App_Key @"weds4qichkdog3c"
 #define Dropbox_App_Secret_Key @"vi0tlkdvffpzcsl"
 
 #define Box_Client_ID @"hc5f0fpyrwsg8r9r3cc9ajikoyi67wgv"
 #define Box_Client_Secret @"TCGF82euRQRv2Di2HjwCYrv1RWM9V3VK"

 typedef enum : NSUInteger {
 AutoBackupDaily,
 AutoBackupWeekly,
 AutoBackupMothly,
 AutoBackupOff,
 } AutoBackup;
 
 #define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
 #define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
 
 #define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
 #define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
 
 #define APPURL @"https://itunes.apple.com/in/app/wing/id990203702?mt=8"
 #define APPID @"990203702"
 
 #define INVITEMSG @"I'm using Wing to send free messages on iPhone http://www.thewing.io"
 
 #define INVITESMS @"Hey, I started using Wing. It's an awsome free app for text messages! - http://www.thewing.io"
 
 #define SHAREIMGURL @"http://54.254.197.29/share_fb_url.png"
 
 #define IS_IPHONE_5 ([[UIScreen mainScreen] bounds].size.height == 568.0f)
 #define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height == 480.0f)
 
 #define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

 #define _DEVICE_WINDOW ((UIView*)[UIApplication sharedApplication].keyWindow)
*/

#endif
