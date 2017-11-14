//
//  XMPPConnect.m
//  ChatApp
//
//  Created by theen on 30/11/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "XMPPConnect.h"

#import "XMPPFramework.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSData+XMPP.h"
//#import "AFHTTPRequestOperationManager.h"
#import "XMPPMessage+XEP_0184.h"
#import "XMPPIQ+LastActivity.h"
#import "XMPPAutoTime.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPLastActivity.h"
#import "ChatStorageDB.h"
//#import "JSQSystemSoundPlayer+JSQMessages.h"
#import "XMPPRoomMemoryStorage.h"
#import "XMPPRoomCoreDataStorage.h"
#import "XMPPvCardTemp.h"
#import "MessgaeTypeConstant.h"
#import "ContactDb.h"
//#import "addParticpants.h"
#import "WebService.h"
#import "XMPPMessageDeliveryReceipts.h"

#define XMPPPWD @"149d81bcafbb2334f3eec50228e4791b"
//#define XMPPPWD @"Goldking89"

//static const char *graphQueueSpecific = "com.chatazap.graphdispatchqueue";
static dispatch_queue_t mainGraphQueue = nil;
static dispatch_queue_t globalGraphQueue = nil;
static dispatch_queue_t highPriorityGraphQueue = nil;

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif
static NSThread *networkThread = nil;


@interface XMPPConnect (){
    XMPPStream                          *xmppStream;
	XMPPReconnect                       *xmppReconnect;
    XMPPRoster                          *xmppRoster;
	XMPPRosterCoreDataStorage           *xmppRosterStorage;
    XMPPvCardCoreDataStorage            *xmppvCardStorage;
	XMPPvCardTempModule                 *xmppvCardTempModule;
	XMPPvCardAvatarModule               *xmppvCardAvatarModule;
	XMPPCapabilities                    *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage     *xmppCapabilitiesStorage;
    XMPPvCardCoreDataStorage            *xmppvCardStorage1;
	XMPPvCardTempModule                 *xmppvCardTempModule1;
	XMPPvCardAvatarModule               *xmppvCardAvatarModule1;
    XMPPCoreDataStorage                 *coredata;
    XMPPAutoTime                        *xmppAutoTime;
    XMPPLastActivity                    *xmppLastActivity;
    
    XMPPRoom *xmppRoom;
    XMPPMUC *xmppMuc;
    XMPPRoomCoreDataStorage *RoomCoreDataStorage;
    XMPPRoomMemoryStorage *memorystorage;
    
    BOOL allowSelfSignedCertificates;
    BOOL allowSSLHostNameMismatch;
    
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, strong, readonly) XMPPStream                          *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect                       *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster                          *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage           *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule                 *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule               *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities                    *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage     *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly) XMPPLastActivity                    *xmppLastActivity;


@property (nonatomic, strong, readonly)XMPPRoom *xmppRoom;
@property (nonatomic, strong, readonly)XMPPMUC *xmppMuc;
@property (nonatomic, strong, readonly)XMPPRoomCoreDataStorage *RoomCoreDataStorage;
@property (nonatomic, strong, readonly)XMPPRoomMemoryStorage *memorystorage;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableArray *alphabetsArray;



@end

@implementation XMPPConnect
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize xmppJID;
@synthesize dictFileInputs;
@synthesize dictLoading;
@synthesize dictUploadrequest;
@synthesize dictDownloadrequest;
@synthesize dateFormat;
@synthesize dateFormatFull;
@synthesize dateFormatter;
@synthesize xmppRoom;
@synthesize RoomCoreDataStorage;
@synthesize xmppLastActivity;
@synthesize memorystorage;
@synthesize xmppMuc;
@synthesize dictRooms;

static XMPPConnect *shared = NULL;

- (id)init
{
	if ( self = [super init] )
	{
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        self.dictFileInputs = [[NSMutableDictionary alloc]init];
        self.dictLoading = [[NSMutableDictionary alloc]init];
        self.dictUploadrequest = [[NSMutableDictionary alloc]init];
        self.dictDownloadrequest = [[NSMutableDictionary alloc]init];
        self.dictRooms = [[NSMutableDictionary alloc]init];
        self.dictPresence = [[NSMutableDictionary alloc]init];
        self.xmppJID = [Utilities getSenderId];
        password = XMPPPWD;
        
        self.dateFormat = [[NSDateFormatter alloc]init];
        [self.dateFormat setDateFormat:@"dd MMM YYYY"];
        
        self.dateFormatFull = [[NSDateFormatter alloc]init];
        [self.dateFormatFull setDateFormat:@"dd MMM YYYY hh:mm a"];

        self.dateFormatSchedule = [[NSDateFormatter alloc]init];
        [self.dateFormatSchedule setDateFormat:@"YYYY-MM-dd hh:mm"];
        
        [self setupStream];
        
    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
        
        if(![[Utilities checkNil:[Utilities getSenderId]] isEqualToString:@""]){
            //[self performSelector:@selector(connectWithXMPP) withObject:nil afterDelay:4];

          //  [self performSelectorInBackground:@selector(connectWithXMPP) withObject:nil];
          //  [self performSelectorOnMainThread:@selector(connectWithXMPP) withObject:nil waitUntilDone:YES];
        }
        
        [self enableDevliveryStatus];
    }
    return self;
}

- (BOOL)getSortingString:(NSString*)inputstring{
    
    if([self.alphabetsArray containsObject:inputstring.uppercaseString])
        return YES;
    
    return NO;
}

- (NSString*)getDateFromat:(NSString*)inputString{
    
    NSString *datestring = [self.dateFormat stringFromDate:[NSDate date]];
    
    if([datestring isEqualToString:inputString]){
        return @"Today";
    }
    return inputString;
}


+ (XMPPConnect*)sharedInstance
{
	if ( !shared || shared == NULL)
	{
        
		shared = [[XMPPConnect alloc] init];
	}
	return shared;
}

#pragma mark SETUP/TEAR STREAM
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
	{
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif

	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
    xmppReconnect.autoReconnect = YES;
    [xmppReconnect activate:xmppStream];
    
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
//    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];

    
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppAutoTime = [[XMPPAutoTime alloc]init];
    [xmppAutoTime activate:xmppStream];
    
    xmppLastActivity = [[XMPPLastActivity alloc]init];

    RoomCoreDataStorage = [[XMPPRoomCoreDataStorage alloc] init];
    memorystorage = [[XMPPRoomMemoryStorage  alloc]init];
    xmppMuc = [[XMPPMUC alloc]init];

    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
	// Activate xmpp modules
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
  //  [xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    [xmppMuc      activate:xmppStream];
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppMuc addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppLastActivity activate:xmppStream];
    [xmppStream setHostName:HOSTURL];
    [xmppStream setHostPort:[HOSTPORT intValue]];
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
}

- (void)teardownStream
{
    if(xmppStream){
        [xmppStream removeDelegate:self];
        [xmppRoster removeDelegate:self];
        
        [xmppReconnect         deactivate];
        [xmppRoster            deactivate];
        [xmppvCardTempModule   deactivate];
     //   [xmppvCardAvatarModule deactivate];
        [xmppCapabilities      deactivate];
        
        [xmppvCardTempModule1   deactivate];
    //    [xmppvCardAvatarModule1 deactivate];
        [xmppAutoTime           deactivate];
        [xmppMuc deactivate];
        [xmppStream disconnect];
        
        xmppStream = nil;
        xmppReconnect = nil;
        xmppRoster = nil;
        xmppRosterStorage = nil;
        xmppvCardStorage = nil;
        xmppvCardTempModule = nil;
      //  xmppvCardAvatarModule = nil;
        xmppCapabilities = nil;
        xmppCapabilitiesStorage = nil;
        xmppAutoTime = nil;
        
        xmppvCardStorage1 = nil;
        xmppvCardTempModule1 = nil;
      //  xmppvCardAvatarModule1 = nil;
        RoomCoreDataStorage = nil;
        
    }
    
	
}

-(BOOL)getNetworkStatus{
    if([self.xmppStream isConnected]){
        return YES;
    }
    return NO;
}

- (void)goOnline
{    
    self.connectingStatus = 1;
    [self getConnectionStatus];

    XMPPPresence *presence = [XMPPPresence  presenceWithType:@"available"];
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:[Utilities getSenderStatus]];
    [presence addChild:status];
    [self.xmppStream sendElement:presence];
    [[ChatStorageDB sharedInstance]fetchandjoingrouphat];
}

- (BOOL)connectXMPPStream{
    if(xmppStream){
        [xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
    }
    else{
        [self connectWithXMPP];
    }
    return YES;
}


- (BOOL)getConnectionXMPPStatus{
    //XMPPStreamState state = [xmppStream getConnectionState];
    return YES;
}

- (void)goOffline
{
    [self.dictPresence removeAllObjects];
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    NSXMLElement *show = [NSXMLElement elementWithName:@"show"];
    [show setStringValue:@""];
    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
    [status setStringValue:[Utilities getSenderStatus]];
    [presence addChild:status];
    [presence addChild:show];
	[self.xmppStream sendElement:presence];
}

- (void)getConnectionStatus{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"getConnectionStatus" object:nil userInfo:nil];
}

- (BOOL)connectWithXMPP
{
    self.connectingStatus = 1;
    [self getConnectionStatus];

    if (![xmppStream isDisconnected]) {
        [xmppStream disconnect];
    }
    self.xmppJID = [Utilities getSenderId];

    [xmppStream setMyJID:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",self.xmppJID] domain:HOSTNAME1 resource:@"chatazapunique"]];

    NSError *error = nil;
    
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
        
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
    return YES;
}


- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}


#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
  //  [settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];

    [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
	NSString *expectedCertName = [xmppStream.myJID domain];
	if (expectedCertName)
	{
		[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
	}
	
//if (customCertEvaluation)
	//{
		[settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
	//}
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	// The delegate method should likely have code similar to this,
	// but will presumably perform some extra security code stuff.
	// For example, allowing a specific self-signed certificate that is known to the app.
	
	dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(bgQueue, ^{
		
		SecTrustResultType result = kSecTrustResultDeny;
		OSStatus status = SecTrustEvaluate(trust, &result);
		
		if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
			completionHandler(YES);
		}
		else {
			completionHandler(NO);
		}
	});
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
}
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    self.connectingStatus = 2;
    [self getConnectionStatus];

	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:password error:&error])
	{
		NSLog(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
    
   // [self locationStart];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSError *errorr;
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    if(![[self xmppStream] registerWithPassword:password error:&errorr])
    {
        NSLog(@"Error registering: %@", errorr);
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"did register");
    //  [HUD removeFromSuperview];
    
    if (![[self xmppStream] authenticateWithPassword:password error:nil])
	{
        
	}
}

/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    NSLog(@"did not register");
    // [HUD removeFromSuperview];

}


- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    self.connectingStatus = 2;
    [self getConnectionStatus];

	return NO;
}

-(void)addRoaster:(NSString*)strjid{
    
    strjid = [strjid stringByReplacingOccurrencesOfString:HOSTNAME withString:@""];
    [self.xmppRoster addUser:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",strjid] domain:HOSTNAME1 resource:@"chatazapunique"] withNickname:strjid];
}

/*
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
	// A simple example of inbound message handling.
    
    NSLog(@"%@",message);
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    if ([message hasComposingChatState] == YES){
        
//        NSError *err;
//        NSData *data = [[[message attributeForName:@"inputs"] stringValue] dataUsingEncoding:NSASCIIStringEncoding];
//        data = [data xmpp_base64Decoded];
//        NSMutableDictionary * dictInput;
//        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"TypingNotification" object:nil userInfo:nil];
        
    }else if ([message isChatMessageWithBody]){
        
        NSError *err;
        NSData *data = [[[message attributeForName:@"inputs"] stringValue] dataUsingEncoding:NSASCIIStringEncoding];
        data = [data xmpp_base64Decoded];
        NSMutableDictionary * dictInput;

        if(data){
            
            dictInput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"youtube"]){
               // NSString *fromstr = [dictInput objectForKey:@"fromjid"];
                [dictInput setObject:@"no" forKey:@"readstatus"];
                [dictInput removeObjectForKey:@"cmd"];
                [dictInput removeObjectForKey:@"fromjid"];

                [[ChatStorageDB sharedInstance]saveYouTubeShare:dictInput type:@"R"];

//                if(appdelegate.fourthViewController){
//                    [appdelegate.fourthViewController reloadTable];
//                }
            }else if([[dictInput valueForKey:@"cmd"] isEqualToString:@"groupinvite"]){
                [self joinGroupChat:dictInput];
                
                if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:@""]){
                    [appDelegate showPopUopView:dictInput];
//                        if(appDelegate.thirdViewController){
//                        [appDelegate.thirdViewController reloadTable];
                }
            }else if(![[dictInput valueForKey:@"cmd"] isEqualToString:@"zap"]){

                //[[ChatStorageDB sharedInstance]zapMessages:dictInput];
                
//                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//                [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                
//                if(appdelegate.thirdViewController){
//                    [appdelegate.thirdViewController reloadTable];
//                }

            }else if([[dictInput objectForKey:@"messagetype"] integerValue] == MessageTypeImage||[[dictInput objectForKey:@"messagetype"] integerValue] == MessageTypeVideo){
                
                [dictInput removeObjectForKey:@"file"];
                [dictInput setValue:[NSDate date] forKey:@"sentdate"];
                
                NSData *data = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                data = [data xmpp_base64Decoded];
                [dictInput setValue:data forKey:@"image"];
                
                 [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeContact){
                
                [dictInput removeObjectForKey:@"file"];
                [dictInput setValue:[NSDate date] forKey:@"sentdate"];
                
                 NSData *data = [[dictInput objectForKey:@"jsonvalues"] dataUsingEncoding:NSASCIIStringEncoding];
                if(data){
                    data = [data xmpp_base64Decoded];
                    [dictInput setValue:data forKey:@"jsonvalues"];
                }
                
                NSData *imgdata = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                imgdata = [imgdata xmpp_base64Decoded];
                if(imgdata){
                    [dictInput setValue:imgdata forKey:@"image"];

                }
                 [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeText){
                [dictInput removeObjectForKey:@"file"];
                [dictInput setValue:[NSDate date] forKey:@"sentdate"];
                [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeFile){
                [dictInput removeObjectForKey:@"file"];
                [dictInput setValue:[NSDate date] forKey:@"sentdate"];
                [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            
            [dictInput setValue:[dictInput valueForKey:@"fromjid"] forKey:@"jid"];
            [dictInput setValue:@"2" forKey:@"deliver"];
           
            [dictInput setValue:@"no" forKey:@"readstatus"];
            [dictInput setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];

            NSLog(@"%@",dictInput);
            
            NSString *strName = [[ContactDb sharedInstance]validateUserName:[dictInput valueForKey:@"fromjid"]].capitalizedString;
            
            [dictRooms setValue:[Utilities checkNil:strName] forKey:@"displayname"];

            [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:[dictInput mutableCopy] incoming:YES];
            
           // UIViewController *currentVc = [appDelegate topViewController];
            
            if(appDelegate.isChatPage == NO){
                
                AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [appdelegate showPopUopView:dictInput];
                
//                if(appdelegate.thirdViewController){
//                    [appdelegate.thirdViewController reloadTable];
//                }
//                if(appdelegate.firstViewController){
//                    [appdelegate.firstViewController reloadTable1];
//                }

            }
            else{
                
                if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:[dictInput valueForKey:@"jid"]]){
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];

                }
                else{
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [appdelegate showPopUopView:dictInput];
                }
            }

            if([message hasReceiptRequest]){
                [self.xmppStream sendElement:[message generateReceiptResponse]];
            }
        }
	}
    else if ([message isGroupChatMessage]){
        NSError *err;
        NSData *data = [[[message attributeForName:@"inputs"] stringValue] dataUsingEncoding:NSASCIIStringEncoding];
        data = [data xmpp_base64Decoded];
        NSMutableDictionary *dictInput;
        
        if(data){
            dictInput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"groupinvite"]){
                [self joinGroupChat:dictInput];
                return;
            }
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"exitgroup"]||[[dictInput valueForKey:@"cmd"] isEqualToString:@"removepartcipant"]||[[dictInput valueForKey:@"cmd"] isEqualToString:@"addpartcipant"]||[[dictInput valueForKey:@"cmd"] isEqualToString:@"updategroupname"]){
                [[ChatStorageDB sharedInstance]handelgroupnotifications:dictInput];
                
                return;
            }
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"youtube"]){
                // NSString *fromstr = [dictInput objectForKey:@"fromjid"];
                [dictInput setObject:@"no" forKey:@"readstatus"];
                [dictInput removeObjectForKey:@"cmd"];
                [dictInput removeObjectForKey:@"fromjid"];

                [[ChatStorageDB sharedInstance]saveYouTubeShare:dictInput type:@"R"];
                
//                if(appdelegate.fourthViewController){
//                    [appdelegate.fourthViewController reloadTable];
//                    int unread_count = [[ChatStorageDB sharedInstance]getUnreadCountForYoutube];
//                    [appdelegate.fourthViewController.tabBarController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",unread_count]];
//                    
//                }
                
                return;
                
            }
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"zap"]){
                
                [[ChatStorageDB sharedInstance]zapMessages:dictInput];
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                
//                if(appdelegate.thirdViewController){
//                    [appdelegate.thirdViewController reloadTable];
//                }
                return;
                
            }
  
            if([[ChatStorageDB sharedInstance] validateMessage:[dictInput objectForKey:@"localid"]]==YES){
                return;
            }
            
            if([[ChatStorageDB sharedInstance] isGroupActive:[dictInput valueForKey:@"jid"]]==NO){
                return;
            }

            
            [dictInput setValue:[NSDate date] forKey:@"sentdate"];
            
            if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeImage||[[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeVideo){
                NSData *data = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                data = [data xmpp_base64Decoded];
                [dictInput setValue:data forKey:@"image"];
                 [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeContact){
                NSData *data = [[dictInput objectForKey:@"jsonvalues"] dataUsingEncoding:NSASCIIStringEncoding];
                if(data){
                    data = [data xmpp_base64Decoded];
                    [dictInput setValue:data forKey:@"jsonvalues"];
                    
                }
                
                NSData *imgdata = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                imgdata = [imgdata xmpp_base64Decoded];
                if(imgdata){
                    [dictInput setValue:imgdata forKey:@"image"];
                    
                }
                [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeText){
                  [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeFile)
            {

                [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
           // [dictInput setValue:[dictInput valueForKey:@"fromjid"] forKey:@"jid"];
            [dictInput setValue:@"2" forKey:@"deliver"];
           
            [dictInput setValue:@"no" forKey:@"readstatus"];
            [dictInput setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];

            NSLog(@"%@",dictInput);
            
            [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:[dictInput mutableCopy] incoming:YES];
           //thangarajan
            if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:[dictInput valueForKey:@"jid"]]){
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                
            }
            //thangarajan
            
            if(appDelegate.isChatPage == NO){
                
                AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [appdelegate showPopUopView:dictInput];
                
//                if(appdelegate.thirdViewController){
//                    [appdelegate.thirdViewController reloadTable];
//                }
            }
            else{

                
                if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:[dictInput valueForKey:@"jid"]]){
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                    
                }
                else{
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [appdelegate showPopUopView:dictInput];
                }
            }

        }else{
            
            if([message hasComposingChatState]){
                
                if([[Utilities getSenderId] isEqualToString:[[message attributeForName:@"senderid"] stringValue]]){
                    return;
                }

                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
 
                [dict setValue:[[message attributeForName:@"senderid"] stringValue] forKey:@"senderid"];
                [dict setValue:[[message attributeForName:@"group_id"] stringValue] forKey:@"group_id"];
                [dict setValue:@"1" forKey:@"isgroupchat"];

                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"TypingNotification" object:nil userInfo:dict.mutableCopy];
            }
        }
    }else if([message hasComposingChatState]){
        
        if([[Utilities getSenderId] isEqualToString:[[message attributeForName:@"senderid"] stringValue]]){
            return;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:@"0" forKey:@"isgroupchat"];

        [dict setValue:[[message attributeForName:@"senderid"] stringValue] forKey:@"senderid"];

        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"TypingNotification" object:nil userInfo:dict.mutableCopy];
    }else{
        if([message hasReceiptResponse]){
            NSLog(@"has response");
//            [[ChatStorageDB sharedInstance]updateUploadDB:[message extractReceiptResponseID] status:@"2" keyvalue:@"deliver"];
            if(![[[message attributeForName:@"deliverydate"] stringValue] isEqualToString:@""]){

               // NSDateFormatter *format = [[NSDateFormatter alloc]init];
                
               // [format setDateFormat:@"dd/MM/yy hh:mm:ss ZZZ"];
                
               // [format setDateStyle:kCFDateFormatterMediumStyle];
               // [format setTimeStyle:kCFDateFormatterLongStyle];
                
              //  NSDate *daa = [format dateFromString:[[message attributeForName:@"deliverydate"] stringValue]];
                

                
//                [[ChatStorageDB sharedInstance] updateDeliveryDate:[message extractReceiptResponseID] status:[NSDate date] keyvalue:@"deliverydate"];

            }
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"reloadTable" object:nil userInfo:nil];
        }else{
            NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
            NSXMLElement * invite  = [x elementForName:@"invite"];
//            NSXMLElement * decline = [x elementForName:@"decline"];
            NSXMLElement * directInvite = [message elementForName:@"x" xmlns:@"jabber:x:conference"];
//            NSString *msg = [[message elementForName:@"body"]stringValue];
            NSString *from = [[message attributeForName:@"from"]stringValue];
            NSString *subject = [[invite elementForName:@"reason"]stringValue];

            if (invite || directInvite)
            {
                NSLog(@"%@",from);
                [self createChatRoom1:from subject:subject];
               // [self createAndEnterRoom:from Message:msg];
                return;
            }
        }
    }
}
*/

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // A simple example of inbound message handling.
    NSLog(@"%@",message);

    if ([message isChatMessageWithBody])
    {
        NSError *err;
        NSData *data = [[[message attributeForName:@"inputs"] stringValue] dataUsingEncoding:NSASCIIStringEncoding];
        data = [data xmpp_base64Decoded];
        NSMutableDictionary *dictInput;
        
        if(data){
            dictInput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
            
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"youtube"]){
                // NSString *fromstr = [dictInput objectForKey:@"fromjid"];
                [dictInput setObject:@"no" forKey:@"readstatus"];
                [dictInput removeObjectForKey:@"cmd"];
                [dictInput removeObjectForKey:@"fromjid"];
                
                [[ChatStorageDB sharedInstance]saveYouTubeShare:dictInput type:@"R"];
                
                if(appdelegate.fourthViewController){
                    [appdelegate.fourthViewController reloadTable];
                }
                return;
                
            }
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"groupinvite"]){
                [self joinGroupChat:dictInput];
                
                if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:@""]){
                    
                    [appdelegate showPopUopView:dictInput];
                    
                    if(appdelegate.thirdViewController){
                        [appdelegate.thirdViewController reloadTable];
                    }
                    
                    
                }
                return;
            }
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"zap"]){
                
                [[ChatStorageDB sharedInstance]zapMessages:dictInput];
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                
                if(appdelegate.thirdViewController){
                    [appdelegate.thirdViewController reloadTable];
                }
                return;
            }
            
            [dictInput removeObjectForKey:@"file"];
            
            [dictInput setValue:[NSDate date] forKey:@"sentdate"];
            
            if([[dictInput objectForKey:@"messagetype"] integerValue] == MessageTypeImage ||[[dictInput objectForKey:@"messagetype"] integerValue] == MessageTypeVideo){
                NSData *data = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                data = [data xmpp_base64Decoded];
                [dictInput setValue:data forKey:@"image"];
                
                [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeContact){
                NSData *data = [[dictInput objectForKey:@"jsonvalues"] dataUsingEncoding:NSASCIIStringEncoding];
                if(data){
                    data = [data xmpp_base64Decoded];
                    [dictInput setValue:data forKey:@"jsonvalues"];
                }
                
                NSData *imgdata = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                imgdata = [imgdata xmpp_base64Decoded];
                if(imgdata){
                    [dictInput setValue:imgdata forKey:@"image"];
                }
                [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];                
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeText){
                [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeFile)
            {
                 NSData *data = [[dictInput objectForKey:@"file"] dataUsingEncoding:NSASCIIStringEncoding];
                 data = [data xmpp_base64Decoded];
                 NSString *fileName = [dictInput objectForKey:@"fileName"];
                 [Utilities saveFilesWithEncryption:[Utilities downloadsPathWithFileName:fileName] file:data];
                 [dictInput setValue:data forKey:@"file"];
                
                [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            
            [dictInput setValue:[dictInput valueForKey:@"fromjid"] forKey:@"jid"];
            [dictInput setValue:@"2" forKey:@"deliver"];
            
            [dictInput setValue:@"no" forKey:@"readstatus"];
            [dictInput setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
            
            NSLog(@"%@",dictInput);
            
            NSString *strName = [[ContactDb sharedInstance]validateUserName:[dictInput valueForKey:@"fromjid"]].capitalizedString;
            
            [dictRooms setValue:[Utilities checkNil:strName] forKey:@"displayname"];
            
            [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:[dictInput mutableCopy] incoming:YES];
            
            // UIViewController *currentVc = [appDelegate topViewController];
            
            if(appDelegate.isChatPage == NO){
                
                AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [appdelegate showPopUopView:dictInput];
                
                if(appdelegate.thirdViewController){
                    [appdelegate.thirdViewController reloadTable];
                }
                
                if(appdelegate.firstViewController){
                    [appdelegate.firstViewController reloadTable1];
                }
            }
            else{
                
                if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:[dictInput valueForKey:@"jid"]]){
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                    
                }
                else{
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [appdelegate showPopUopView:dictInput];
                }
            }
            
            if([message hasReceiptRequest]){
                [self.xmppStream sendElement:[message generateReceiptResponse:[dictInput valueForKey:@"localid"]]];
               // [self.xmppStream sendElement:[message generateReceiptResponse]];

            }
            
        }
        
    }
    else if ([message isGroupChatMessage]){
        NSError *err;
        NSData *data = [[[message attributeForName:@"inputs"] stringValue] dataUsingEncoding:NSASCIIStringEncoding];
        data = [data xmpp_base64Decoded];
        NSMutableDictionary *dictInput;
        
        if(data){
            dictInput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
//            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"groupinvite"]){
                [self joinGroupChat:dictInput];
                return;
            }
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"exitgroup"]||[[dictInput valueForKey:@"cmd"] isEqualToString:@"removepartcipant"]||[[dictInput valueForKey:@"cmd"] isEqualToString:@"addpartcipant"]||[[dictInput valueForKey:@"cmd"] isEqualToString:@"updategroupname"]){
                [[ChatStorageDB sharedInstance]handelgroupnotifications:dictInput];
                return;
            }
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"youtube"]){
                // NSString *fromstr = [dictInput objectForKey:@"fromjid"];
                [dictInput setObject:@"no" forKey:@"readstatus"];
                [dictInput removeObjectForKey:@"cmd"];
                [dictInput removeObjectForKey:@"fromjid"];
                
                [[ChatStorageDB sharedInstance]saveYouTubeShare:dictInput type:@"R"];
                
//                if(appdelegate.fourthViewController){
//                    [appdelegate.fourthViewController reloadTable];
//                    int unread_count = [[ChatStorageDB sharedInstance]getUnreadCountForYoutube];
//                    [appdelegate.fourthViewController.tabBarController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",unread_count]];
//                    
//                }
                
                return;
                
            }
            
            if([[dictInput valueForKey:@"cmd"] isEqualToString:@"zap"]){
                
                [[ChatStorageDB sharedInstance]zapMessages:dictInput];
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                
//                if(appdelegate.thirdViewController){
//                    [appdelegate.thirdViewController reloadTable];
//                }
                return;
            }
            
            if([[ChatStorageDB sharedInstance] validateMessage:[dictInput objectForKey:@"localid"]]==YES){
                return;
            }
            
            if([[ChatStorageDB sharedInstance] isGroupActive:[dictInput valueForKey:@"jid"]]==NO){
                return;
            }
            
            [dictInput setValue:[NSDate date] forKey:@"sentdate"];
            
            if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeImage||[[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeVideo){
                NSData *data = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                data = [data xmpp_base64Decoded];
                [dictInput setValue:data forKey:@"image"];
                [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeContact){
                NSData *data = [[dictInput objectForKey:@"jsonvalues"] dataUsingEncoding:NSASCIIStringEncoding];
                if(data){
                    data = [data xmpp_base64Decoded];
                    [dictInput setValue:data forKey:@"jsonvalues"];
                    
                }
                
                NSData *imgdata = [[dictInput objectForKey:@"image"] dataUsingEncoding:NSASCIIStringEncoding];
                imgdata = [imgdata xmpp_base64Decoded];
                if(imgdata){
                    [dictInput setValue:imgdata forKey:@"image"];
                    
                }
                
                [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
                
                
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeText){
                [dictInput setValue:@"textsuccess" forKey:@"transferstatus"];
            }
            else if([[dictInput objectForKey:@"messagetype"] integerValue]==MessageTypeFile)
            {
                /*
                 NSData *data = [[dictInput objectForKey:@"file"] dataUsingEncoding:NSASCIIStringEncoding];
                 data = [data base64Decoded];
                 NSString *fileName = [dictInput objectForKey:@"fileName"];
                 [Utilities saveFilesWithEncryption:[Utilities downloadsPathWithFileName:fileName] file:data];
                 [dictInput setValue:data forKey:@"file"];
                 */
                [dictInput setValue:@"downloadstart" forKey:@"transferstatus"];
            }
            // [dictInput setValue:[dictInput valueForKey:@"fromjid"] forKey:@"jid"];
            [dictInput setValue:@"2" forKey:@"deliver"];
            
            [dictInput setValue:@"no" forKey:@"readstatus"];
            [dictInput setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
            
            NSLog(@"%@",dictInput);
            
            [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:[dictInput mutableCopy] incoming:YES];
            
            
            if(appDelegate.isChatPage==NO){
                AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                [appdelegate showPopUopView:dictInput];
                
                if(appdelegate.thirdViewController){
                    [appdelegate.thirdViewController reloadTable];
                }
            }
            else{
                
                
                if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]] isEqualToString:[dictInput valueForKey:@"jid"]]){
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:@"messageReceived" object:nil userInfo:dictInput];
                    
                }
                else{
                    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [appdelegate showPopUopView:dictInput];
                    
                }
            }
            //[JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        }
        else{
            
            if([message hasComposingChatState]){
                
                if([[Utilities getSenderId] isEqualToString:[[message attributeForName:@"senderid"] stringValue]]){
                    return;
                }
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setValue:[[message attributeForName:@"senderid"] stringValue] forKey:@"senderid"];
                [dict setValue:[[message attributeForName:@"group_id"] stringValue] forKey:@"group_id"];
                [dict setValue:@"1" forKey:@"isgroupchat"];
                
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:@"TypingNotification" object:nil userInfo:dict.mutableCopy];
            }
        }
        
    }
    else if([message hasComposingChatState]){
        
        if([[Utilities getSenderId] isEqualToString:[[message attributeForName:@"senderid"] stringValue]]){
            return;
        }
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:@"0" forKey:@"isgroupchat"];
        
        [dict setValue:[[message attributeForName:@"senderid"] stringValue] forKey:@"senderid"];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"TypingNotification" object:nil userInfo:dict.mutableCopy];
    }
    else{
        if([message hasReceiptResponse]){
            NSLog(@"has response");
            
          [[ChatStorageDB sharedInstance]updateUploadDB:[message extractReceiptResponseID] status:@"2" keyvalue:@"deliver"];
            
            NSDictionary * dictionary = [NSDictionary dictionaryWithObjects:@[[message extractReceiptResponseID],@"2"] forKeys:@[@"messageId",@"deliveryStatus"]];
            
            NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
            
            [notificationCenter postNotificationName:@"reloadTable" object:nil userInfo:dictionary];
            
            if(![[[message attributeForName:@"deliverydate"] stringValue] isEqualToString:@""]){
                
                [[ChatStorageDB sharedInstance] updateDeliveryDate:[message extractReceiptResponseID] status:[NSDate date] keyvalue:@"deliverydate"];
            }

        }
        else{
            NSXMLElement * x = [message elementForName:@"x" xmlns:XMPPMUCUserNamespace];
            NSXMLElement * invite  = [x elementForName:@"invite"];
            //            NSXMLElement * decline = [x elementForName:@"decline"];
            NSXMLElement * directInvite = [message elementForName:@"x" xmlns:@"jabber:x:conference"];
            //            NSString *msg = [[message elementForName:@"body"]stringValue];
            NSString *from = [[message attributeForName:@"from"]stringValue];
            NSString *subject = [[invite elementForName:@"reason"]stringValue];
            
            if (invite || directInvite)
            {
                
                NSLog(@"%@",from);
                [self createChatRoom1:from subject:subject];
                // [self createAndEnterRoom:from Message:msg];
                return;
            }
        }
    }
}

- (void)sendTypingMessage:(NSString*)toJID isGroupChat:(NSString*)isGroupChat{
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"senderid" stringValue:[Utilities getSenderId]];
    [message addAttributeWithName:@"TypingState" stringValue:@"End"];
    
    if([isGroupChat isEqualToString:@"1"]){
        
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        [message addAttributeWithName:@"group_id" stringValue:[Utilities getReceiverId]];

        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[Utilities getReceiverId] lowercaseString],GROUPCHAT]];
    }
    else{
        [message addAttributeWithName:@"to" stringValue: [NSString stringWithFormat:@"%@%@/%@",[toJID lowercaseString],HOSTNAME,UNIQUERESOURCE]];
        
        //[message addAttributeWithName:@"to" stringValue:toJID];
    }

    
    NSXMLElement *composing = [NSXMLElement elementWithName:@"composing"];
    [composing addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/chatstates"];
    [message addChild:composing];
    XMPPMessage *xmppMessage = [XMPPMessage messageFromElement:message];
    [self.xmppStream sendElement:xmppMessage];

}

- (void)sendGroupNotification:(NSMutableDictionary*)dictInput{
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"GROUPUPDATES"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"cmd" stringValue:@"GROUPUPDTES"];
    
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictInput
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    
    
    [message addAttributeWithName:@"inputs" stringValue:[NSString stringWithFormat:@"%@",[Utilities encodingBase64Data:jsonData]]];
    
    
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[dictInput valueForKey:@"group_id"] lowercaseString],GROUPCHAT]];
    
    [message addAttributeWithName:@"id" stringValue:[dictInput valueForKey:@"localid"]];
    [message addChild:body];
    NSLog(@"%@",message);
    [self.xmppStream sendElement:message];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
   // NSLog(@"%@",presence);
    
    if  ([[presence type] isEqualToString:@"subscribe"]) {
        
      //  [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"localhost"]];
     //   NSLog(@"presence user wants to subscribe %@",[presence fromStr]);
        
        [xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
        //For reject button
    }

    NSString *presenceType = [presence type]; // online/offline
    NSString *myUsername = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    NSString *strstatus = [presence status];
    
    if (![presenceFromUser isEqualToString:myUsername]) {
        
        if ([presenceType isEqualToString:@"available"]) {
            [self.dictPresence setObject:@"Online" forKey:presenceFromUser];
//            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
            
        } else if ([presenceType isEqualToString:@"unavailable"]) {
            [self.dictPresence removeObjectForKey:presenceFromUser];

//            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
            
        }
        
        if(![[Utilities checkNil:strstatus] isEqualToString:@""]){
            [[ContactDb sharedInstance]updateStatusMessage:presenceFromUser status_message:strstatus];
        }
        
        NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"updatePresence" object:nil userInfo:nil];
    }
    
	//DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	NSLog(@"%@",error.localizedDescription);
    self.connectingStatus = 3;
    [self getConnectionStatus];
    
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

- (NSString*)timeForDate:(NSDate*)date{
    
    if(!self.dateFormatter)
        self.dateFormatter = [[NSDateFormatter alloc] init];
    
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    [self.dateFormatter setDoesRelativeDateFormatting:YES];

    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [self.dateFormatter stringFromDate:date];
}

#pragma mark Zap Messages 

- (void)zapMessageToReceiver:(NSString*)jid isgroupchat:(NSString*)isgroupchat arraylocalid:(NSMutableArray*)arraylocalid{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"zap" forKey:@"cmd"];
    [dict setObject:arraylocalid forKey:@"localid"];
    [dict setObject:[Utilities getSenderId] forKey:@"jid"];
    [dict setObject:isgroupchat forKey:@"isgroupchat"];

    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"Zap"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"cmd" stringValue:@"zap"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    [message addAttributeWithName:@"inputs" stringValue:[NSString stringWithFormat:@"%@",[jsonData xmpp_base64Decoded]]];
    
    
    if([isgroupchat isEqualToString:@"1"]){
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[jid lowercaseString],GROUPCHAT]];
        
    }
    else{
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@/%@",[jid lowercaseString],HOSTNAME,UNIQUERESOURCE]];
        
    }
    
    
    // [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[dictInput valueForKey:@"tojid"] lowercaseString],HOSTNAME]];
    
    [message addAttributeWithName:@"id" stringValue:[self getLocalId]];
    [message addChild:body];
    
    [self.xmppStream sendElement:message];
}


#pragma mark Send Message To XMPP

- (void)moneyTransferNotificationToReceiver:(NSMutableDictionary*)dictInput amount:(NSString*)amount paymentType:(NSString*)paymentType{
     [dictInput removeObjectForKey:@"sentdate"];
    
    NSString *textMessage = [NSString stringWithFormat:@"You have received $%@ amount via %@",amount,paymentType];
    [dictInput setObject:textMessage forKey:@"text"];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"Forward"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"cmd" stringValue:@"insert"];
    
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictInput
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    [message addAttributeWithName:@"inputs" stringValue:[NSString stringWithFormat:@"%@",[jsonData xmpp_base64Encoded]]];
    
    
    if([[dictInput valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[dictInput valueForKey:@"tojid"] lowercaseString],GROUPCHAT]];
        
    }
    else{
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@/%@",[[dictInput valueForKey:@"tojid"] lowercaseString],HOSTNAME,UNIQUERESOURCE]];
        
    }
    
    
    // [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[dictInput valueForKey:@"tojid"] lowercaseString],HOSTNAME]];
    
    [message addAttributeWithName:@"id" stringValue:[dictInput valueForKey:@"localid"]];
    [message addChild:body];
    NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [request addAttributeWithName:@"id" stringValue:[dictInput valueForKey:@"localid"]];
    [message addChild:request];
    NSLog(@"%@",message);
     [self.xmppStream sendElement:message];
}

- (void)enableDevliveryStatus{
    
    XMPPMessageDeliveryReceipts* xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
    
    [xmppMessageDeliveryRecipts activate:self.xmppStream];
}


- (void)messageSendToReceiver:(NSMutableDictionary*)dictInput{
    
    [dictInput removeObjectForKey:@"sentdate"];
    
    NSDate * scheduled_date = [dictInput objectForKey:@"scheduled_date"];
    
    BOOL schdule = NO;
    double scheduled_timestamp = 0.0;
    double current_timestamp = 0.0;

    if(scheduled_date == nil || [scheduled_date isKindOfClass:[NSNull class]]){
        
    }
    else{

        current_timestamp = [[NSDate date] timeIntervalSince1970];

//        scheduled_date_string = [self.dateFormatSchedule stringFromDate:scheduled_date];
//        
        scheduled_timestamp = [scheduled_date timeIntervalSince1970];

        
        [dictInput removeObjectForKey:@"scheduled_date"];
        schdule = YES;
    }
    
    

 //   NSData *data = [dictInput objectForKey:@"image"];
    //[dictInput removeObjectForKey:@"image"];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"Forward"];
    
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"cmd" stringValue:@"insert"];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dictInput
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    [message addAttributeWithName:@"inputs" stringValue:[NSString stringWithFormat:@"%@",[jsonData xmpp_base64Encoded]]];
    
    if([[dictInput valueForKey:@"isgroupchat"] isEqualToString:@"1"]){
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];

        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[dictInput valueForKey:@"tojid"] lowercaseString],GROUPCHAT]];
    }
    else{
        
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@/%@",[[dictInput valueForKey:@"tojid"] lowercaseString],HOSTNAME,UNIQUERESOURCE]];
    }
 
    [message addAttributeWithName:@"id" stringValue:[dictInput valueForKey:@"localid"]];
    [message addChild:body];
    
    NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [request addAttributeWithName:@"id" stringValue:[dictInput valueForKey:@"localid"]];
    [message addChild:request];
    NSLog(@"%@",message);
    
    if(schdule){
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
        [dict setObject:[dictInput valueForKey:@"tojid"] forKey:@"receiver"];
        [dict setObject:[dictInput valueForKey:@"localid"] forKey:@"localid"];
        //[dict setObject:scheduled_date forKey:@"scheduled_date"];
        double difference_timestamp = scheduled_timestamp - current_timestamp;
        [dict setObject:[NSString stringWithFormat:@"%f",difference_timestamp] forKey:@"time_difference"];

        //[NSString stringWithFormat:@"%@",message];
        
        NSString *base64encode =  [Utilities encodingBase64Data:[[NSString stringWithFormat:@"%@",message] dataUsingEncoding:NSUTF8StringEncoding]];
        [dict setObject:base64encode forKey:@"xmlstring"];
        [dict setObject:@"sendschedulemessages1" forKey:@"cmd"];
        
        [WebService sendSchduledMessages:dict completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        }];
    }
    else{
        [self.xmppStream sendElement:message];
    }
}

- (void)sendYouTubeVideo:(NSMutableDictionary*)dictInput tojid:(NSString*)tojid isgroupchat:(NSString*)isgroupchat{
    
    [dictInput setObject:@"youtube" forKey:@"cmd"];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"Forward"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"cmd" stringValue:@"youtube"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictInput
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    [message addAttributeWithName:@"inputs" stringValue:[NSString stringWithFormat:@"%@",[Utilities encodingBase64Data:jsonData]]];
    
    
    if([isgroupchat isEqualToString:@"1"]){
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[tojid lowercaseString],GROUPCHAT]];
        
    }
    else{
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        
        [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@/%@",[tojid lowercaseString],HOSTNAME,UNIQUERESOURCE]];
        
    }
    
    [message addAttributeWithName:@"id" stringValue:[self getLocalId]];
    [message addChild:body];
    NSLog(@"%@",message);
    
    [self.xmppStream sendElement:message];

}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    
    NSData * data = [[[message attributeForName:@"inputs"] stringValue] dataUsingEncoding:NSASCIIStringEncoding];
    data = [data xmpp_base64Decoded];
    NSMutableDictionary *dictInput;
    
    if(data){
        
        dictInput = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
       [[ChatStorageDB sharedInstance]updateUploadDB:[dictInput valueForKey:@"localid"] status:@"3" keyvalue:@"deliver"];

        NSDictionary * dictionary = [NSDictionary dictionaryWithObjects:@[[dictInput valueForKey:@"localid"],@"3"] forKeys:@[@"messageId",@"deliveryStatus"]];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
       [notificationCenter postNotificationName:@"reloadTable" object:nil userInfo:dictionary];
    }
}

- (void)groupInviteSendToReciever:(NSMutableDictionary*)dictInput{
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"groupinvite"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"cmd" stringValue:@"groupinvite"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictInput
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    [message addAttributeWithName:@"inputs" stringValue:[NSString stringWithFormat:@"%@",[jsonData xmpp_base64Encoded]]];
    
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@/%@",[[dictInput valueForKey:@"tojid"] lowercaseString],HOSTNAME,UNIQUERESOURCE]];
    
   // [message addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@%@",[[dictInput valueForKey:@"group_id"] lowercaseString],GROUPCHAT]];

    
    [message addAttributeWithName:@"id" stringValue:[self getLocalId]];
    [message addChild:body];

    [self.xmppStream sendElement:message];

}

-(NSString*)getLocalId{
    return self.xmppStream.generateUUID;
}

#pragma mark GroupChat

- (void)createChatRoom:(NSString*)chatName{
    
    if([[Utilities checkNil:chatName] isEqualToString:@""])
        return;

    XMPPRoom *xmppRoomTemp = [[XMPPRoom alloc] initWithRoomStorage:memorystorage jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",chatName,GROUPCHAT]] dispatchQueue:dispatch_get_main_queue()];
    [xmppRoomTemp activate:self.xmppStream];
    [xmppRoomTemp joinRoomUsingNickname:[Utilities getSenderNickname] history:nil password:nil];
    [xmppRoomTemp addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.dictRooms setObject:xmppRoomTemp forKey:chatName];
 //   [xmppRoomTemp inviteUser:(XMPPJID *) withMessage:<#(NSString *)#>]
    
}

- (void)createChatRoom1:(NSString*)chatName subject:(NSString*)subject{
    
    if([[Utilities checkNil:chatName] isEqualToString:@""])
        return;
    
    
    XMPPRoom *xmppRoomTemp = [[XMPPRoom alloc] initWithRoomStorage:memorystorage jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@",chatName]] dispatchQueue:dispatch_get_main_queue()];
    [xmppRoomTemp activate:self.xmppStream];
    [xmppRoomTemp joinRoomUsingNickname:[Utilities getSenderNickname] history:nil password:nil];
    [xmppRoomTemp addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.dictRooms setObject:xmppRoomTemp forKey:chatName];
    
    NSString *owner_id = @"";
    
    NSArray *arr = [chatName componentsSeparatedByString:@"@"];
    if(arr.count>0){
        NSString *str= [arr objectAtIndex:0];
        NSArray *arra1 = [str componentsSeparatedByString:@"_"];
        if(arra1.count==2){
            owner_id = [arra1 objectAtIndex:1];
        }
    }
    
    
    chatName = [chatName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",GROUPCHAT] withString:@""];
    
    [[ChatStorageDB sharedInstance]saveRoomsWhenReceive:chatName subject:subject owner_jid:owner_id];

    
    //   [xmppRoomTemp inviteUser:<#(XMPPJID *)#> withMessage:<#(NSString *)#>]
    
    
}


- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    [sender configureRoomUsingOptions:nil];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    
    NSLog(@"%@",[sender roomJID].full);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupChatCreateSuccess"
     object:nil];

    [sender fetchMembersList];
}


- (void)inviteUsersToGroup:(NSString*)username roomJid:(NSString*)roomJD roomName:(NSString*)roomName invite:(NSString*)invite{
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:@"test"];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue: [NSString stringWithFormat:@"%@%@/%@",username.lowercaseString,HOSTNAME,UNIQUERESOURCE]];
    [message addAttributeWithName:@"invite" stringValue:invite];
    [message addAttributeWithName:@"owner_id" stringValue:[Utilities getSenderId]];
    [message addAttributeWithName:@"owner_name" stringValue:[Utilities getSenderId]];
    [message addAttributeWithName:@"group_name" stringValue:roomName];
    [message addAttributeWithName:@"group_id" stringValue:[NSString stringWithFormat:@"%@%@",roomJD,GROUPCHAT]];
    NSXMLElement *composing = [NSXMLElement elementWithName:@"groupinvite"];
    [composing addAttributeWithName:@"xmlns" stringValue:@"http://jabber.org/protocol/chatstates"];
    [message addChild:body];
    [message addChild:composing];
    [xmppStream sendElement:message];
}

- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitation:(XMPPMessage *)message{
    NSLog(@"invite received");
    //    XMPPRoom *xmppRoomTemp = [[XMPPRoom alloc] initWithRoomStorage:memorystorage jid:[XMPPJID jidWithString:[message fromStr]] dispatchQueue:dispatch_get_main_queue()];
    //    [xmppRoomTemp activate:self.xmppStream];
    //    [xmppRoomTemp joinRoomUsingNickname:self.xmppStream.myJID.user history:nil password:nil];
    //    [xmppRoomTemp addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

- (void)joinGroupChat:(NSDictionary *)dictonary{
    
    if([[Utilities checkNil:[dictonary valueForKey:@"group_id"]] isEqualToString:@""])
        return;
    
    XMPPRoom *xmppRoomTemp = [[XMPPRoom alloc] initWithRoomStorage:memorystorage jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",[dictonary valueForKey:@"group_id"],GROUPCHAT]] dispatchQueue:dispatch_get_main_queue()];
    [xmppRoomTemp activate:self.xmppStream];
    [xmppRoomTemp addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [xmppRoomTemp configureRoomUsingOptions:nil];

    [xmppRoomTemp joinRoomUsingNickname:[Utilities getSenderNickname] history:nil password:nil];
  //  [self saveRoomsWhenReceive:message];
    [self.dictRooms setObject:xmppRoomTemp forKey:[dictonary valueForKey:@"group_id"]];

    [[ChatStorageDB sharedInstance]saveRoomsWhenReceive:[dictonary valueForKey:@"group_id"] subject:[dictonary valueForKey:@"group_subject"] owner_jid:[dictonary valueForKey:@"owner_id"]];
    
    [self updateGropChatinDB:[dictonary valueForKey:@"group_id"]];
  
}

- (void)updateGropChatinDB:(NSString*)group_id{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"joingroup" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:group_id forKey:@"group_id"];
    
    [WebService groupChatUpdates:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
              
            }
        }
        
    }];
}

- (void)joingGroupChatForUsers:(NSString*)group_id{
  //  return;
    
    if([[Utilities checkNil:group_id] isEqualToString:@""])
        return;
    
    XMPPRoom *xmppRoomTemp = [[XMPPRoom alloc] initWithRoomStorage:memorystorage jid:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",group_id,GROUPCHAT]] dispatchQueue:dispatch_get_main_queue()];
    [xmppRoomTemp activate:self.xmppStream];
    [xmppRoomTemp joinRoomUsingNickname:[Utilities getSenderNickname] history:nil password:nil];
    [xmppRoomTemp addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.dictRooms setObject:xmppRoomTemp forKey:group_id];
    

  //  [self updateGropChatinDB:group_id];


}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"%@",sender.roomJID);
    NSLog(@"%@",sender.roomSubject);
    
    
//    if(items.count>0){
//        addParticpants *add = [[addParticpants alloc]init];
//        [add receiveMembers:items group_id:sender.roomJID.user];
//    }
    
//    for (NSXMLElement *iems in items){
//        NSLog(@"JID : %@",[[iems attributeForName:@"jid"] stringValue]);
//    }

    NSLog(@"%@",items);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"%@",iqError);

}

#pragma mark Location Update

- (void)locationStart{
    
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];

        if([UIDevice currentDevice].systemVersion.intValue>=8){
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
        }
        
        self.locationManager.desiredAccuracy =
        kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = (id<CLLocationManagerDelegate>)self;
    }
    [self.locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if(self.locationManager==nil)
        return;
    
    CLLocation *curPos = self.locationManager.location;
    
    NSString *latitude = [[NSNumber numberWithDouble:curPos.coordinate.latitude] stringValue];
    
    NSString *longitude = [[NSNumber numberWithDouble:curPos.coordinate.longitude] stringValue];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
    
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark %@",placemark);
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         NSLog(@"addressDictionary %@", placemark.addressDictionary);
         
         NSLog(@"placemark %@",placemark.region);
         NSLog(@"placemark %@",placemark.country);  // Give Country Name
         NSLog(@"placemark %@",placemark.locality); // Extract the city name
         NSLog(@"location %@",placemark.name);
         NSLog(@"location %@",placemark.ocean);
         NSLog(@"location %@",placemark.postalCode);
         NSLog(@"location %@",placemark.subLocality);
         
         NSLog(@"location %@",placemark.location);
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         
         
         [Utilities saveDefaultsValues:[NSString stringWithFormat:@"%@,%@",placemark.locality,placemark.country] :@"user_location"];
         
         NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
         [notificationCenter postNotificationName:@"LocationUpdate" object:nil userInfo:nil];
         
     }];

    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    
    
    NSLog(@"%@", @"Core location has a position.");
}

- (void) locationManager:(CLLocationManager *)manager
        didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (NSArray*)getFailedMessages:(NSString*)sender receiver:(NSString*)receiver{
    return nil;
}

#pragma mark Avatar Image

- (void)uploadImage:(UIImage*)tmpImage{
    
    NSData *imageData1 = UIImageJPEGRepresentation(tmpImage,0.0);
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    NSXMLElement *photoXML = [NSXMLElement elementWithName:@"PHOTO"];
    NSXMLElement *typeXML = [NSXMLElement elementWithName:@"TYPE" stringValue:@"image/jpg"];
    
    NSString *image64 = [NSString stringWithFormat:@"%@",[imageData1 xmpp_base64Encoded]];
    
    NSXMLElement *binvalXML = [NSXMLElement elementWithName:@"BINVAL" stringValue:image64];
    
    [photoXML addChild:typeXML];
    [photoXML addChild:binvalXML];
    [vCardXML addChild:photoXML];
    
    XMPPvCardTemp *myvCardTemp = [self.xmppvCardTempModule myvCardTemp];
    
    if (myvCardTemp) {
        [myvCardTemp  setPhoto:imageData1];
        [self.xmppvCardTempModule  updateMyvCardTemp:myvCardTemp];
    }
}

- (NSData*)photoDataForJID:(NSString*)jid{

    NSData *photoData = [self.xmppvCardAvatarModule photoDataForJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@%@",jid,HOSTNAME]]];
    return photoData;

}

@end
