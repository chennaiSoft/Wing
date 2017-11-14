//
//  ContactDb.h
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Utilities.h"

typedef enum ContactsType : NSInteger
{
    ContactsTypeWINGS,
    ContactsTypePhones,
    ContactsTypeGroups,
    ContactsTypeFacebook
}ContactsType;

typedef void(^DBCompletionBlock) (NSObject *responseObject, NSInteger errorCode);


@interface ContactDb : NSObject{
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel   *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    AppDelegate *appDelegate;

}
-(BOOL)validateAppUser:(NSString*)contactid;
+ (ContactDb*)sharedInstance;
- (NSManagedObjectContext *)managedObjectContext;
- (void)saveContactsValue:(NSArray*)array completionBlock:(DBCompletionBlock)completionBlock;
- (void)saveContactsValueLocal:(NSArray*)array completionBlock:(DBCompletionBlock)completionBlock;
- (NSArray*)getFavorites:(NSString*)type;
- (void)saveSocialContactsValue:(NSArray*)array;
- (NSString*)validateUserName:(NSString*)jid;
- (void)validateFavorites:(NSString*)jid;
- (NSArray*)getFavorites1:(NSString*)type;
- (NSArray*)getUserDetails:(NSString*)chatappid;
- (void)updateFavorites:(NSString*)type;
- (void)validateBlocked:(NSString*)jid;
- (void)deleteAllDB:(NSString*)entityName;
- (NSString*)validateUserStatus:(NSString*)jid;

- (int)getContactsCount;
- (void)updateStatusMessage:(NSString*)chatappid status_message:(NSString*)status_message;

@end
