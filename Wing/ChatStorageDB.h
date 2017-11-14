//
//  ChatStorageDB.h
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Utilities.h"
#import "XMPPConnect.h"

@interface ChatStorageDB : NSObject{
    
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel   *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    AppDelegate *appDelegate;

}

+ (ChatStorageDB*)sharedInstance;
- (NSManagedObjectContext *)managedObjectContext;
- (void)saveIncomingAndOutgoingmessages:(NSMutableDictionary*)dictresponse incoming:(BOOL)incoming;
- (NSArray*)getChatHistoryBetweenUsers:(NSString*)sender receiver:(NSString*)receiver;
-(NSArray*)getChatHistoryForUsers :(NSString*)search;
- (void)saveYouTubeFavorites:(NSMutableDictionary*)dictresponse;
- (NSArray*)getYouTubeFavorites:(NSString*)searchStr;
- (BOOL)validateYouTubeVideo:(NSString*)idd delete:(BOOL)deletestatus;
- (BOOL)validateYouTubeVideoShare:(NSString*)idd  type:(NSString*)type delete:(BOOL)deletestatus;
- (void)saveYouTubeShare:(NSMutableDictionary*)dictresponse type:(NSString*)type;
- (NSArray*)getYouTubeShare:(NSString*)searchStr type:(NSString*)type;
- (void)updateUploadDB:(NSString*)localid status:(NSString*)stringStatus keyvalue:(NSString*)stringKey;
-(NSString*)getDeliveryStatus:(NSString*)localid;
-(NSArray*)getMediaFiles :(NSString*)sender receiver:(NSString*)receiver;
- (int)getReadStatusBetweenUsers:(NSString*)jid;
-(void)resetUploadAndDownloadStatus;
- (void)downloadFiles:(NSManagedObject*)objects;
- (void)downloadFiles1:(NSDictionary*)objects;
-(void)updateReadStatus:(NSString*)jid;

- (void)saveRoomsWhenCreate:(NSString*)group_id subject:(NSString*)group_subject;
- (void)saveAndInviteMembers:(NSString*)group_id memeberid:(NSString*)member_id invite:(BOOL)invite group_subject:(NSString*)group_subject member_name:(NSString*)member_name member_nick_name:(NSString*)member_nick_name;

- (int)getCommonGroupsFromDB:(NSString*)stringTable member_jid:(NSString*)member_jid;
- (void)deleteChatHistoryBetweenUsers:(NSString*)sender receiver:(NSString*)receiver;

-(void)updateDeliveryDate:(NSString*)localid status:(NSDate*)stringStatus keyvalue:(NSString*)stringKey;
- (void)saveRoomsWhenReceive:(NSString*)group_id subject:(NSString*)group_subject owner_jid:(NSString*)owner_jid;
- (NSString*)validateGroupName:(NSString*)jid;
- (NSArray*)getFailedChatHistoryBetweenUsers:(NSString*)sender receiver:(NSString*)receiver;

-(void)deleteAllDB:(NSString*)entityName;
-(NSString*)getPassodeStatus:(NSString*)jid;
- (void)updatePasscode:(NSString*)value jid:(NSString*)jid;
-(void)deleteRecord:(NSString*)localid;
- (void)fetchandjoingrouphat;
-(BOOL)validateMessage:(NSString*)localid;
- (NSArray*)getChatHistoryBetweenGroups:(NSString*)sender receiver:(NSString*)receiver;
- (void)deleteChatHistoryBetweenGroups:(NSString*)sender receiver:(NSString*)receiver;
-(NSArray*)getCommonGroupsForUsers:(NSString*)member_jid search:(NSString*)search;
-(NSArray*)getMediaFilesForGroups :(NSString*)jid islocation:(BOOL)location;
-(NSArray*)getGroupMembers:(NSString*)group_id;
-(NSArray*)getGroupDetails:(NSString*)group_id;
-(NSArray*)getGroupMembersByName:(NSString*)group_id;
- (void)updateGroupName:(NSString*)group_id group_subject:(NSString*)group_subject;
- (void)removeParticpant:(NSString*)group_id member_id:(NSString*)member_id;
- (int)getCountForSentReceiveMessage:(NSString*)user_id sent:(BOOL)sent;
- (NSArray*)getAllMessagesForStatistics;
- (NSArray*)getFailedMessages:(NSString*)sender receiver:(NSString*)receiver;
- (void)leaveFromGroup:(NSString*)group_id;
- (void)callLoad:(NSDictionary*)dict;
- (BOOL)isGroupActive:(NSString*)group_id;
- (NSString*)getPathExtenstion:(NSString*)localid;
- (NSArray*)getFiles :(NSString*)sender receiver:(NSString*)receiver;
- (int)getUnreadCountForYoutube;
- (void)updateUnreadCountForYoutube;
- (void)deleteAllYoutubeVideo:(NSString*)entity_name type:(NSString*)type;
- (void)saveChatSession:(NSMutableDictionary*)dictresponse;
- (void)deleteChatSession:(NSString*)jid;
- (NSString*)getDateSring:(NSString*)jid;
- (void)removePasscode:(NSString*)value jid:(NSString*)jid;
- (void)zapMessages:(NSMutableDictionary*)dictInput;
- (void)updateChatSession:(NSString*)jid isgroupchat:(NSString*)isgroupchat;

- (void)handelgroupnotifications:(NSMutableDictionary*)dict;
- (NSArray*)getMediaFilesGroups :(NSString*)sender receiver:(NSString*)receiver;

@end
