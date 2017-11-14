//
//  XMPPConnect.h
//  ChatApp
//
//  Created by theen on 30/11/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
//#import "XMPPRoomMemoryStorage.h"
#import "Constants.h"
#import "Utilities.h"
#import "XMPPMUC.h"
#import "XMPPMessage.h"
#import <CoreLocation/CoreLocation.h>

@interface XMPPConnect : NSObject{
    
    AppDelegate * appDelegate;
    NSString    * xmppJID;
    NSString    * password;
    BOOL        isXmppConnected;
    
    NSMutableDictionary *dictFileInputs;
    NSMutableDictionary *dictLoading;
    NSMutableDictionary *dictUploadrequest;
    NSMutableDictionary *dictRooms;
    NSDateFormatter *dateFormat;
    NSDateFormatter *dateFormatFull;
}

@property (nonatomic,retain) NSDateFormatter *dateFormat;
@property (nonatomic,retain) NSDateFormatter *dateFormatFull;
@property (nonatomic,retain) NSDateFormatter *dateFormatSchedule;

@property (nonatomic,retain) NSMutableDictionary *dictFileInputs;
@property (nonatomic,retain) NSMutableDictionary *dictLoading;
@property (nonatomic,retain) NSMutableDictionary *dictUploadrequest;
@property (nonatomic,retain) NSMutableDictionary *dictDownloadrequest;
@property (nonatomic,retain) NSMutableDictionary *dictRooms;
@property (nonatomic,retain) NSMutableDictionary *dictPresence;

@property (nonatomic)int connectingStatus;
@property (nonatomic,retain)NSString    *xmppJID;
- (BOOL)connectWithXMPP;
+ (XMPPConnect*)sharedInstance;
- (void)messageSendToReceiver:(NSMutableDictionary*)dictInput;
-(NSString*)getLocalId;
-(void)addRoaster:(NSString*)strjid;
-(void)sendTypingMessage:(NSString*)toJID isGroupChat:(NSString*)isGroupChat;
- (NSString*)timeForDate:(NSDate*)date;
- (NSString*)getDateFromat:(NSString*)inputString;
- (void)inviteUsersToGroup:(NSString*)username roomJid:(NSString*)roomJD roomName:(NSString*)roomName invite:(NSString*)invite;
- (void)xmppMUC:(XMPPMUC *)sender didReceiveRoomInvitation:(XMPPMessage *)message;
- (void)joinGroupChat:(NSDictionary *)dictonary;
- (void)createChatRoom:(NSString*)chatName;
- (void)groupInviteSendToReciever:(NSMutableDictionary*)dictInput;
- (void)joingGroupChatForUsers:(NSString*)group_id;
- (BOOL)getSortingString:(NSString*)inputstring;
- (void)getConnectionStatus;
- (NSArray*)getFailedMessages:(NSString*)sender receiver:(NSString*)receiver;
@property (nonatomic, retain) CLLocationManager *locationManager;
- (NSData*)photoDataForJID:(NSString*)jid;
- (void)uploadImage:(UIImage*)tmpImage;
- (void)goOffline;
-(BOOL)getNetworkStatus;
- (void)goOnline;
- (BOOL)connectXMPPStream;
- (void)sendYouTubeVideo:(NSMutableDictionary*)dictInput tojid:(NSString*)tojid isgroupchat:(NSString*)isgroupchat;
- (void)zapMessageToReceiver:(NSString*)jid isgroupchat:(NSString*)isgroupchat arraylocalid:(NSMutableArray*)arraylocalid;
- (void)sendGroupNotification:(NSMutableDictionary*)dictInput;
- (void)moneyTransferNotificationToReceiver:(NSMutableDictionary*)dictInput amount:(NSString*)amount paymentType:(NSString*)paymentType;
@end
