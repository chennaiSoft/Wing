//
//  WebService.h
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@class ASIHTTPRequest;
@class ASIFormDataRequest;

typedef void(^ServiceCompletionBlock) (NSObject *responseObject, NSInteger errorCode);

@interface WebService : NSObject
+ (void)contactSyncApi:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;

+ (void)loginApi:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updateNickname:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updateVerification:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)getYouTubeResult:(NSString*)url  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)socialContactSyncApi:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)createGroupChat:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updateStatusMessage:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updateFeedBack:(NSDictionary*)dictinput arrayInput:(NSMutableArray*)arrayInput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updateGroupChat:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updatePrivacy:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)lastSeenApiCallNew:(NSString*)receiver_id completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)updateLastSeen:(NSString*)sender_id completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)sendForPushNotification:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)sendSchduledMessages:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)runCMD:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
+ (void)runCMDBackUp:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;

+ (void)groupChatUpdates:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock;
@end
