//
//  ChatStorageDB.m
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "ChatStorageDB.h"
#import "UploadClass.h"
#import "NSData+XMPP.h"
#import "DownloadClass.h"
#import "MessgaeTypeConstant.h"
#import "ContactDb.h"
#import "Message.h"

@implementation ChatStorageDB

static ChatStorageDB *shared = NULL;

- (id)init
{
	if ( self = [super init] )
	{
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    }
    return self;
}


+ (ChatStorageDB *)sharedInstance
{
	if ( !shared || shared == NULL)
	{
		shared = [[ChatStorageDB alloc] init];
	}
	return shared;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        //  __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
   // NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Wing" withExtension:@"momd"];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ChatStorage" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL * storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ChatStorage.sqlite"];
    
    NSError *error = nil;
    
    NSNumber *optionYes = [NSNumber numberWithBool:YES];
    
    
    NSDictionary *options = [NSDictionary dictionaryWithObjects:@[optionYes] forKeys:@[NSMigratePersistentStoresAutomaticallyOption]];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    NSDictionary *fileAttributes = [NSDictionary
                                    dictionaryWithObject:NSFileProtectionComplete
                                    forKey:NSFileProtectionKey];
    if(![[NSFileManager defaultManager] setAttributes:fileAttributes
                                         ofItemAtPath:[storeURL path] error: &error]) {
        NSLog(@"Unresolved error with store encryption %@, %@",
              error, [error userInfo]);
        //abort();
    }
    NSLog(@"SqlitePath:%@",[storeURL path]);
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString*)getPathExtenstion:(NSString*)localid{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"localid=%@",localid];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    if(objects.count>0){
        NSManagedObject *s = [objects objectAtIndex:0];
        return [Utilities checkNil:[s valueForKey:@"file_ext"]];
    }

    return @"";
}

- (void)saveChatSession:(NSMutableDictionary*)dictresponse{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChatSession" inManagedObjectContext:context];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"jid=%@",[dictresponse objectForKey:@"jid"]];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    
    NSArray *objects = [context executeFetchRequest:req error:&error];
    if(objects.count > 0){
        for (NSManagedObject *s in objects) {
            [context deleteObject:s];
        }
    }
    
    NSManagedObject *newContext = [NSEntityDescription insertNewObjectForEntityForName:@"ChatSession" inManagedObjectContext:context];
    [newContext setValue:[dictresponse valueForKey:@"localid"] forKey:@"localid"];
    [newContext setValue:[dictresponse valueForKey:@"sentdate"] forKey:@"sentdate"];
    [newContext setValue:[dictresponse valueForKey:@"isgroupchat"] forKey:@"isgroupchat"];
    [newContext setValue:[dictresponse valueForKey:@"jid"] forKey:@"jid"];
    [newContext setValue:[dictresponse valueForKey:@"fromjid"] forKey:@"fromjid"];
    [newContext setValue:[dictresponse valueForKey:@"text"] forKey:@"text"];
    [newContext setValue:[dictresponse valueForKey:@"messagetype"] forKey:@"messagetype"];
    [newContext setValue:[dictresponse valueForKey:@"displayname"] forKey:@"displayname"];
    
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)saveIncomingAndOutgoingmessages:(NSMutableDictionary*)dictresponse incoming:(BOOL)incoming{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSManagedObject *newContext = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    for (NSString *strinKey in dictresponse.allKeys) {
        id tempValue = [dictresponse valueForKey:strinKey];
        
        if(![tempValue isKindOfClass:[NSNull class]]){
            [newContext setValue:[dictresponse valueForKey:strinKey] forKey:strinKey];
        }
    }
    
    NSError *error;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self saveChatSession:dictresponse];
    
    if(incoming == NO){
        
        [self performSelectorOnMainThread:@selector(callLoad:) withObject:dictresponse waitUntilDone:YES];
    }
}

- (void)callLoad:(NSDictionary*)dict{
    @autoreleasepool {
        UploadClass *upload = [[UploadClass alloc]init];
        upload.delegate = (id<uploadDeleagtes>)self;
        [upload getInputs];
        upload.dictInputs = dict;
        //upload.fileDetails = [ChatConnection sharedInstance].dictFiles;
        [upload uploadToServer];
    }
}


- (NSArray *)getChatHistoryForUsers:(NSString*)search{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"ChatSession" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    [req setEntity:entity];
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sentdate" ascending:NO];
    [req setSortDescriptors:@[sd]];

    if(![search isEqualToString:@""]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayname contains[c] %@",search];
        [req setPredicate:predicate];
    }
    
    [req setResultType:NSManagedObjectResultType];
    req.returnsDistinctResults = YES;
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    return objects;
    
}

- (NSArray*)getFailedMessages:(NSString*)sender receiver:(NSString*)receiver{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@ AND (deliver=%@ OR deliver=%@))",sender,receiver,@"3",@"4"];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;

}



- (NSArray*)getChatHistoryBetweenUsers:(NSString*)sender receiver:(NSString*)receiver{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (fromjid=%@ AND tojid=%@)",sender,receiver,receiver,sender];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
}

- (NSArray*)getChatHistoryBetweenGroups:(NSString*)sender receiver:(NSString*)receiver{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"jid=%@",receiver];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
}

- (NSArray*)getFailedChatHistoryBetweenUsers:(NSString*)sender receiver:(NSString*)receiver{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@ and (transferstatus=%@ or transferstatus=%@)) OR (fromjid=%@ AND tojid=%@ and (transferstatus=%@ or transferstatus=%@))",sender,receiver,@"downloadstart",@"downloadfailed",receiver,sender,@"downloadstart",@"downloadfailed"];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
}


- (void)deleteChatHistoryBetweenUsers:(NSString*)sender receiver:(NSString*)receiver{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (fromjid=%@ AND tojid=%@)",sender,receiver,receiver,sender];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];

    for (NSManagedObject *s in objects) {
        [context deleteObject:s];
    }
    
    [context save:nil];
}

- (void)deleteChatHistoryBetweenGroups:(NSString*)sender receiver:(NSString*)receiver{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"jid=%@",receiver];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    
    for (NSManagedObject *s in objects) {
        [context deleteObject:s];
    }
    
    [context save:nil];
}

- (void)deleteChatSession:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"ChatSession" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
  
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"jid=%@",jid];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    
    for (NSManagedObject *s in objects) {
        [context deleteObject:s];
    }
    
    [context save:nil];
}



- (int)getReadStatusBetweenUsers:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"jid=%@ AND readstatus=%@",jid,@"no"];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return (int)objects.count;
}

- (NSArray*)getMediaFiles :(NSString*)sender receiver:(NSString*)receiver{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (fromjid=%@ AND tojid=%@)",[sender lowercaseString],[receiver lowercaseString],[receiver lowercaseString],[sender lowercaseString]];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    return objects;
    
}

- (NSArray*)getMediaFilesGroups :(NSString*)sender receiver:(NSString*)receiver{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(jid=%@ AND  (messagetype=%@ OR messagetype=%@ OR  messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@)) OR (jid=%@ AND  (messagetype=%@ OR messagetype=%@  OR messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@))",receiver,[NSString stringWithFormat:@"%ld",(long)MessageTypeImage],[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo],[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed",receiver,[NSString stringWithFormat:@"%ld",(long)MessageTypeImage],[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo],[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio],[NSString stringWithFormat:@"%ld",(long)MessageTypeFile], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed"];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    return objects;
    
}

-(NSArray*)getFiles :(NSString*)sender receiver:(NSString*)receiver{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@ AND  (messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@)) OR (fromjid=%@ AND tojid=%@ AND  (messagetype=%@ ) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@))",[sender lowercaseString],[receiver lowercaseString],[NSString stringWithFormat:@"%ld",(long)MessageTypeFile], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed",[receiver lowercaseString],[sender lowercaseString],[NSString stringWithFormat:@"%ld",(long)MessageTypeFile], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed"];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
    
}

-(NSArray*)getMediaFilesForGroups :(NSString*)jid islocation:(BOOL)location{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate;
    if(location){
        predicate=[NSPredicate predicateWithFormat:@"(jid=%@ AND messagetype=%@)",jid,[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation]];
    }
    else{
            predicate=[NSPredicate predicateWithFormat:@"(jid=%@ AND (messagetype=%@ OR messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@)) OR (jid=%@ AND  (messagetype=%@ OR messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@))",jid,[NSString stringWithFormat:@"%ld",(long)MessageTypeImage],[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed",jid,[NSString stringWithFormat:@"%ld",(long)MessageTypeImage],[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed"];
    }

    
    [req setEntity:entity];
    [req setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:req error:&error];
    return objects;
    
}

- (void)saveYouTubeFavorites:(NSMutableDictionary*)dictresponse{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"Youtube" inManagedObjectContext:context];
    
    
    for (NSString *strinKey in dictresponse.allKeys) {
        if(![strinKey isEqualToString:@"type"]){
            [newContext setValue:[dictresponse valueForKey:strinKey] forKey:strinKey];

        }
    }
    
    NSError *error;
    if(![context save:&error])
    {
        
    }
    
    
}

- (void)saveYouTubeShare:(NSMutableDictionary*)dictresponse type:(NSString*)type{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"YoutubeShare" inManagedObjectContext:context];
    
    
    for (NSString *strinKey in dictresponse.allKeys) {
        [newContext setValue:[dictresponse valueForKey:strinKey] forKey:strinKey];
    }
    
    [newContext setValue:type forKey:@"type"];

    
    NSError *error;
    if(![context save:&error])
    {
        
    }
}

- (int)getUnreadCountForYoutube{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"YoutubeShare" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@ and readstatus=%@",@"R",@"no"];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:&error];
    return [results count];
}

- (void)updateUnreadCountForYoutube{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"YoutubeShare" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@ and readstatus=%@",@"R",@"no"];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:&error];
    for (NSManagedObject *s in results) {
        [s setValue:@"yes" forKey:@"readstatus"];
    }
    
    [context save:nil];
}


- (BOOL)validateYouTubeVideoShare:(NSString*)idd  type:(NSString*)type delete:(BOOL)deletestatus{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"YoutubeShare" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@ and type=%@",idd,type];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        
        for (NSManagedObject *s in results) {
            if(deletestatus){
                [context deleteObject:s];
                [context save:nil];
                
            }
        }
        
        return YES;
    }
    
    return NO;
    
}

- (NSArray*)getYouTubeFavorites:(NSString*)searchStr{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Youtube" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    
    if(![searchStr isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@",searchStr];
        [req setPredicate:predicate];

    }
    
    
    [req setResultType:NSDictionaryResultType];
    
    // NSPredicate *predicate;
    // predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (tojid=%@ AND fromjid=%@)",sender,receiver,receiver,sender];
    
    [req setEntity:entity];
    // [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
}


- (NSArray*)getYouTubeShare:(NSString*)searchStr type:(NSString*)type{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"YoutubeShare" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    
    if(![searchStr isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@ and title contains[c] %@",searchStr,type];
        [req setPredicate:predicate];
        
    }
    else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@",type];
        [req setPredicate:predicate];
    }
    [req setResultType:NSDictionaryResultType];

    // NSPredicate *predicate;
    // predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (tojid=%@ AND fromjid=%@)",sender,receiver,receiver,sender];
    
    [req setEntity:entity];
    // [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
}


- (BOOL)validateYouTubeVideo:(NSString*)idd delete:(BOOL)deletestatus{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Youtube" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id=%@",idd];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if(results.count > 0){
        
        for (NSManagedObject *s in results) {
            if(deletestatus){
                [context deleteObject:s];
                [context save:nil];
                
            }
        }
        
        return YES;
    }
    
    return NO;

}


- (void)deleteAllYoutubeVideo:(NSString*)entity_name type:(NSString*)type{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entity_name inManagedObjectContext:context]];
    NSError *error = nil;
    if(![type isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@",type];
        [request setPredicate:predicate];

    }
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        
        for (NSManagedObject *s in results) {
                [context deleteObject:s];
        }
        
    }
    [context save:nil];

}


#pragma mark Update DB

- (void)updateMessage:(NSString*)localID statsu:(NSString*)stringStatus keyValue:(NSString*)key{
    
    NSLog(@"%@,%@",key,stringStatus);
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"localid=%@", localID];
    [req setPredicate:predicate];
    [req setEntity:entity];
    
    NSError * error = nil;
    NSArray * objects = [context executeFetchRequest:req error:&error];
    
    if([objects count] > 0){
        
        for (NSManagedObject *s in objects) {
            
            [s setValue:stringStatus forKey:key];
            
            if([context save:&error])
            {
                /*if ([key isEqualToString:@"deliver"]) {
                    
                    if (![s isFault]) {
                        [context refreshObject:s mergeChanges:YES];
                    }
                }*/
            }
        }
    }
}

- (void)updateUploadDB:(NSString*)localid status:(NSString*)stringStatus keyvalue:(NSString*)stringKey{
    
    [self updateMessage:localid statsu:stringStatus keyValue:stringKey];
}

-(void)updateDeliveryDate:(NSString*)localid status:(NSDate*)stringStatus keyvalue:(NSString*)stringKey{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localid=%@", localid];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    
    NSArray *objects = [context executeFetchRequest:req error:&error];
    if([objects count] > 0)
    {
        for (NSManagedObject *s in objects) {
            [s setValue:stringStatus forKey:stringKey];
            [context save:nil];
        }
    }
    
}

- (NSString*)getDeliveryStatus:(NSString*)localid{
  
    NSString *string = @"0";
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localid=%@", localid];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    if([objects count]>0)
    {
        for (NSManagedObject *s in objects) {
            
            return [s valueForKey:@"deliver"];
        }
    }
    
    return string;
    
}

-(BOOL)validateMessage:(NSString*)localid{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localid=%@", localid];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    if([objects count]>0)
    {
        //for (NSManagedObject *s in objects) {
            
            return YES;
        //}
    }
    
    return NO;
    
}

-(NSData*)getThumbImage:(NSString*)localid{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localid=%@", localid];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    if([objects count]>0)
    {
        for (NSManagedObject *s in objects) {
            
            return [s valueForKey:@"image"];
        }
    }
    
    return nil;
    
}

- (int)getCountForSentReceiveMessage:(NSString*)user_id sent:(BOOL)sent{
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    if(sent)
        [fr setPredicate:([Utilities getResetDate] ?  [NSPredicate predicateWithFormat:@"fromjid=%@ and sentdate>%@",user_id,[Utilities getResetDate]] : [NSPredicate predicateWithFormat:@"fromjid=%@",user_id])];
    else
        [fr setPredicate:([Utilities getResetDate] ?  [NSPredicate predicateWithFormat:@"fromjid!=%@ and sentdate>%@",user_id,[Utilities getResetDate]] : [NSPredicate predicateWithFormat:@"fromjid!=%@",user_id])];
 
    return (int)[[[self managedObjectContext] executeFetchRequest:fr error:nil] count];
    
    
}

- (NSArray*)getAllMessagesForStatistics{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    if([Utilities getResetDate]){
        [fr setPredicate:[NSPredicate predicateWithFormat:@"sentdate>%@",[Utilities getResetDate]]];
        
    }
    return [[self managedObjectContext] executeFetchRequest:fr error:nil];
    
}

#pragma mark Upload Delegates

-(void)uploadSuccess:(NSMutableDictionary*)dictInput responFromServer:(NSDictionary*)dictResponse{
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjects:@[[dictInput valueForKey:@"localid"],@"1"] forKeys:@[@"messageId",@"deliveryStatus"]];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter postNotificationName:@"reloadTable" object:nil userInfo:dictionary];
    
    if([[dictInput valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
        
        NSData * data = [dictInput valueForKey:@"jsonvalues"];
        [dictInput setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"jsonvalues"];

        NSData *dataimage = [dictInput valueForKey:@"image"];
        
        if(dataimage){
            [dictInput setObject:[NSString stringWithFormat:@"%@",[dataimage xmpp_base64Encoded]] forKey:@"image"];
        }
    }
    else if([[dictInput valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]] || [[dictInput valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
        
        [dictInput removeObjectForKey:@"image"];
        
        NSData *data = [self getThumbImage:[dictInput objectForKey:@"localid"]];
        [dictInput removeObjectForKey:@"image"];
        [dictInput setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"image"];
        
    }
    else{
       // NSData *data = [dictInput objectForKey:@"file"];
        [dictInput removeObjectForKey:@"file"];
        //[dictInput setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"file"];
        [dictInput removeObjectForKey:@"image"];
        
      //  NSData *data = [self getThumbImage:[dictInput objectForKey:@"localid"]];
//        [dictInput setObject:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"image"];

    }
    [[XMPPConnect sharedInstance]messageSendToReceiver:dictInput];
}

-(void)uploadFailure:(NSMutableDictionary*)dictInput{
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjects:@[[dictInput valueForKey:@"localid"],@"3"] forKeys:@[@"messageId",@"deliveryStatus"]];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter postNotificationName:@"reloadTable" object:nil userInfo:dictionary];

}
-(void)uploadProgress:(NSMutableDictionary*)dictInput{
    
}

-(void)resetUploadAndDownloadStatus{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"transferstatus=%@ OR transferstatus=%@ or transferstatus=%@",@"uploadprogress",@"uploadstart",@"downloadprogress"];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        for(NSManagedObject *s in results){
            if([[s valueForKey:@"transferstatus"] isEqualToString:@"downloadprogress"]){
                [s setValue:@"downloadfailed" forKey:@"transferstatus"];
            }
            else{
                [s setValue:@"uploadfailed" forKey:@"transferstatus"];
            }
            [context save:nil];
        }
    }
}


- (void)downloadFiles:(NSManagedObject*)objects{
    
    NSArray *keys = [[[objects entity] attributesByName] allKeys];
    NSDictionary *dictInput1 =[objects dictionaryWithValuesForKeys:keys];

    DownloadClass *download = [[DownloadClass alloc]init];
    download.downloaddelegate = (id<downloaddelegate>)self;
    [download downloadStart:dictInput1];
}

- (void)downloadFiles1:(NSDictionary*)objects{
    
    DownloadClass *download = [[DownloadClass alloc]init];
    download.downloaddelegate = (id<downloaddelegate>)self;
    [download downloadStart:objects];
    
}

-(void)downloadsuccess:(NSManagedObject*)dictInput{
    
}

- (void)downloadfailure:(NSManagedObject*)dictInput{
}

-(void)updateReadStatus:(NSString*)jid{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"readstatus=%@ and jid=%@", @"no",jid];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count]>0){
        NSLog(@"update records");
        for(NSManagedObject *s in results){
            [s setValue:@"yes" forKey:@"readstatus"];
            [context save:&error];
        }
    }
    
}

#pragma mark Groups

- (void)saveRoomsWhenCreate:(NSString*)group_id subject:(NSString*)group_subject{
    
    if([self validateGroups:group_id])
        return;
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"Groups" inManagedObjectContext:context];
    [newContext setValue:[Utilities getSenderId] forKey:@"owner_jid"];
    [newContext setValue:group_id forKey:@"group_id"];
    [newContext setValue:group_subject forKey:@"group_subject"];
    [newContext setValue:[NSDate date] forKey:@"created_date"];
    [newContext setValue:@"active" forKey:@"group_status"];

    if([[Utilities checkNil:group_subject] length]>=1){
        if([[XMPPConnect sharedInstance] getSortingString:[group_subject substringToIndex:1]]){
            [newContext setValue:[group_subject substringToIndex:1].uppercaseString forKey:@"sorting"];
        }
        else{
            [newContext setValue:@"#" forKey:@"sorting"];
            
        }
    }
    else{
        [newContext setValue:@"#" forKey:@"sorting"];
        
    }

    
    NSError *error;
    if(![context save:&error])
    {
        
    }

}


- (void)saveRoomsWhenReceive:(NSString*)group_id subject:(NSString*)group_subject owner_jid:(NSString*)owner_jid{
    
    if([self validateGroups:group_id])
        return;
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"Groups" inManagedObjectContext:context];
    [newContext setValue:owner_jid forKey:@"owner_jid"];
    [newContext setValue:group_id forKey:@"group_id"];
    [newContext setValue:group_subject forKey:@"group_subject"];
    [newContext setValue:[NSDate date] forKey:@"created_date"];
    [newContext setValue:@"active" forKey:@"group_status"];

    
    
    if([[Utilities checkNil:group_subject] length]>=1){
        if([[XMPPConnect sharedInstance] getSortingString:[group_subject substringToIndex:1]]){
            [newContext setValue:[group_subject substringToIndex:1].uppercaseString forKey:@"sorting"];
        }
        else{
            [newContext setValue:@"#" forKey:@"sorting"];
            
        }
    }
    else{
        [newContext setValue:@"#" forKey:@"sorting"];
        
    }

    NSError *error;
    if(![context save:&error])
    {
        
    }
    
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:owner_jid forKey:@"fromjid"];
    [dict setObject:group_id forKey:@"tojid"];
    [dict setObject:group_subject forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeText] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    
    [dict setObject:[NSString stringWithFormat:@"%@ Created a Group",[[ContactDb sharedInstance]validateUserName:owner_jid]] forKey:@"text"];
    [dict setObject:[[XMPPConnect sharedInstance] getLocalId] forKey:@"localid"];
    [dict setObject:group_id forKey:@"jid"];
    [dict setObject:@"no" forKey:@"readstatus"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setObject:@"1" forKey:@"isgroupchat"];
    
    [self saveIncomingAndOutgoingmessages:dict incoming:YES];
//    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//    if(appdelegate.thirdViewController){
//        [appdelegate.thirdViewController reloadTable];
//    }

    
    
     [[ChatStorageDB sharedInstance] saveAndInviteMembers:group_id memeberid:[Utilities getSenderId] invite:NO group_subject:group_subject member_name:[Utilities getSenderNickname] member_nick_name:[Utilities getSenderNickname]];

    
    NSString *name  = [[ContactDb sharedInstance] validateUserName:owner_jid];
    
    [[ChatStorageDB sharedInstance] saveAndInviteMembers:group_id memeberid:owner_jid invite:NO group_subject:group_subject member_name:name member_nick_name:name];

    
}

- (BOOL)isGroupActive:(NSString*)group_id{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@",group_id];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count]>0){
        for (NSManagedObject *s in results) {
            NSString *status = [Utilities checkNil:[s valueForKey:@"group_status"]];
            if([status isEqualToString:@"inactive"])
                return NO;
        }
        return YES;
    }
    
    return NO;

}


-(BOOL)validateGroups:(NSString*)group_id{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@",group_id];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count]>0){
        return YES;
    }
    
    return NO;
    
}


-(NSArray*)getGroupDetails:(NSString*)group_id{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@",group_id];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count]>0){
        return results;
    }
    return nil;
}

- (BOOL)validateMembers:(NSString*)group_id memeberid:(NSString*)member_id{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"GroupMembers" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@ and member_jid=%@",group_id,member_id];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count]>0){
        return YES;
    }
    
    return NO;
    
}

- (void)removeParticpant:(NSString*)group_id member_id:(NSString*)member_id{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"GroupMembers" inManagedObjectContext:context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@ and member_jid=%@",group_id,member_id];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if([results count]>0){
        for (NSManagedObject *s in results) {
            [context deleteObject:s];
        }
    }
    
    [context save:nil];
    

}

- (void)saveAndInviteMembers:(NSString*)group_id memeberid:(NSString*)member_id invite:(BOOL)invite group_subject:(NSString*)group_subject member_name:(NSString*)member_name member_nick_name:(NSString*)member_nick_name{
    if([self validateMembers:group_id memeberid:member_id])
        return;
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"GroupMembers" inManagedObjectContext:context];
    [newContext setValue:[Utilities getSenderId] forKey:@"owner_id"];
    [newContext setValue:group_id forKey:@"group_id"];
    [newContext setValue:member_id forKey:@"member_jid"];
    [newContext setValue:member_name forKey:@"member_name"];
    [newContext setValue:member_nick_name forKey:@"member_nick_name"];
    [newContext setValue:group_subject forKey:@"group_subject"];

    
    NSError *error;
    if(![context save:&error])
    {
        
    }
    
//    if(invite){
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
//        [dict setObject:@"groupinvite" forKey:@"cmd"];
//        [dict setObject:[Utilities getSenderId] forKey:@"owner_id"];
//        [dict setObject:member_id forKey:@"tojid"];
//        [dict setObject:group_id forKey:@"group_id"];
//        [dict setObject:group_subject forKey:@"group_subject"];
//       [[XMPPConnect sharedInstance]groupInviteSendToReciever:dict];
//
//    }

    
    
}


-(NSArray*)getCommonGroupsForUsers:(NSString*)member_jid search:(NSString*)search{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"GroupMembers" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    

    
    if(![search isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_subject contains[c] %@ and member_jid=%@",search,member_jid];
        [req setPredicate:predicate];
    }
    else{
         [req setPredicate:[NSPredicate predicateWithFormat:@"member_jid=%@",[Utilities checkNil:member_jid]]];
    }
    [req setEntity:entity];
    [req setResultType:NSDictionaryResultType];
    req.returnsDistinctResults = YES;
    
    [req setPropertiesToFetch:[NSArray arrayWithObject:@"group_id"]];
    
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
    
}


-(NSArray*)getGroupMembers:(NSString*)group_id{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"GroupMembers" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    
    [req setPredicate:[NSPredicate predicateWithFormat:@"group_id=%@",[Utilities checkNil:group_id]]];
    [req setEntity:entity];
    [req setResultType:NSDictionaryResultType];
    req.returnsDistinctResults = YES;
    
    [req setPropertiesToFetch:[NSArray arrayWithObject:@"member_jid"]];
    
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
    
}

-(NSArray*)getGroupMembersByName:(NSString*)group_id{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"GroupMembers" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    
    [req setPredicate:[NSPredicate predicateWithFormat:@"group_id=%@",[Utilities checkNil:group_id]]];
    [req setEntity:entity];
    [req setResultType:NSDictionaryResultType];
  //  req.returnsDistinctResults = YES;
    
    [req setPropertiesToFetch:[NSArray arrayWithObject:@"member_name"]];
    
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    return objects;
    
}



- (int)getCommonGroupsFromDB:(NSString*)stringTable member_jid:(NSString*)member_jid{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:stringTable];
    [fr setResultType:NSDictionaryResultType];
    fr.returnsDistinctResults = YES;
    [fr setPredicate:[NSPredicate predicateWithFormat:@"member_jid=%@",[Utilities checkNil:member_jid]]];
    return (int)[[[self managedObjectContext] executeFetchRequest:fr error:nil] count];

    
}

- (NSString*)validateGroupName:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        return [s valueForKey:@"group_subject"];
        
    }
    
    return jid;
}


- (void)updateGroupName:(NSString*)group_id group_subject:(NSString*)group_subject{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@",group_id];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        [s setValue:group_subject forKey:@"group_subject"];
        
    }
    [context save:nil];
    
}


- (void)leaveFromGroup:(NSString*)group_id{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_id=%@",group_id];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        [s setValue:@"inactive" forKey:@"group_status"];
        
    }
    [context save:nil];
    
    [self removeParticpant:group_id member_id:[Utilities getReceiverId]];
    
}


-(void)deleteAllDB:(NSString*)entityName{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    [req setEntity:entity];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    for (NSManagedObject *s in objects) {
        [context deleteObject:s];
        [context save:nil];
    }
}


#pragma mark Passcode Features

- (NSString*)getPassodeStatus:(NSString*)jid{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PasscodeEntry" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatsession=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        return [s valueForKey:@"passcode"];
        
    }
    return @"";

}

- (void)updatePasscode:(NSString*)value jid:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];

    if(![[self getPassodeStatus:jid] isEqualToString:@""]){
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"PasscodeEntry" inManagedObjectContext:context]];
        NSError *error = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatsession=%@",jid];
        [request setPredicate:predicate];
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        if(results.count>0){
            NSManagedObject *s = [results objectAtIndex:0];
            [s setValue:value forKey:@"passcode"];
        }

    }
    
    else{
        NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"PasscodeEntry" inManagedObjectContext:context];
        [newContext setValue:value forKey:@"passcode"];
        [newContext setValue:jid forKey:@"chatsession"];

    }
    
    [context save:nil];
}

- (void)removePasscode:(NSString*)value jid:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PasscodeEntry" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatsession=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
       
        [context deleteObject:s];
    }
    [context save:nil];

}


-(void)deleteRecord:(NSString*)localid{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localid=%@", localid];
    [req setPredicate:predicate];
    [req setEntity:entity];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    if([objects count]>0)
    {
        for (NSManagedObject *s in objects) {
            [context deleteObject:s];
        }
    }
    
    [context save:nil];

    
}


- (void)fetchandjoingrouphat{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Groups" inManagedObjectContext:context]];
    NSError *error = nil;
    NSArray *objects=[context executeFetchRequest:request error:&error];
    if([objects count]>0)
    {
        for (NSManagedObject *s in objects) {
            [[XMPPConnect sharedInstance]joingGroupChatForUsers:[s valueForKey:@"group_id"]];
        }
    }

}


- (NSString*)getDateSring:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"ChatSession" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"jid=%@",jid];
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];
    if(objects.count>0){
        for (NSManagedObject *s in objects) {
            return [Utilities relativeDateStringForDate:[s valueForKey:@"sentdate"]];
        }
        
    }
    return @"";
}

- (void)updateChatSession:(NSString*)jid  isgroupchat:(NSString*)isgroupchat{
    NSString *sender = [Utilities getSenderId];
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
    NSFetchRequest *req=[[NSFetchRequest alloc] init];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    [req setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate;
    
    if([isgroupchat isEqualToString:@"1"]){
        predicate=[NSPredicate predicateWithFormat:@"jid=%@",jid];

    }
    else{
        predicate=[NSPredicate predicateWithFormat:@"(fromjid=%@ AND tojid=%@) OR (fromjid=%@ AND tojid=%@)",sender,jid,jid,sender];
 
    }
    
    
    [req setEntity:entity];
    [req setPredicate:predicate];
    NSError *error;
    NSArray *objects=[context executeFetchRequest:req error:&error];

    if(objects.count>0){
        NSDictionary *s = [objects lastObject];
        [self saveChatSession:s.mutableCopy];
        
        
    }
    else{
        [self deleteChatSession:jid];
    }
}

#pragma mark Zap Messages

- (void)zapMessages:(NSMutableDictionary*)dictInput{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];

    NSArray *arrayLocalid = [dictInput objectForKey:@"localid"];
    for (NSString *localid in arrayLocalid) {
        NSFetchRequest *req=[[NSFetchRequest alloc] init];
        NSPredicate *predicate;
        predicate=[NSPredicate predicateWithFormat:@"localid=%@",localid];
        
        [req setEntity:entity];
        [req setPredicate:predicate];
        NSError *error;
        NSArray *objects=[context executeFetchRequest:req error:&error];
        if(objects.count>0){
            for (NSManagedObject *s in objects) {
                [context deleteObject:s];
            }
            
        }
    }
    
    [context save:nil];
    
    [self updateChatSession:[dictInput objectForKey:@"jid"] isgroupchat:[dictInput objectForKey:@"isgroupchat"]];
}

- (void)handelgroupnotifications:(NSMutableDictionary*)dict{
    if([[dict valueForKey:@"cmd"] isEqualToString:@"exitgroup"]){
        [[ChatStorageDB sharedInstance]removeParticpant:[dict valueForKey:@"group_id"] member_id:[dict valueForKey:@"chatapp_id"]];
        
        if([[Utilities getSenderId] isEqualToString:[dict valueForKey:@"chatapp_id"]]){
            [[ChatStorageDB sharedInstance]leaveFromGroup:[dict valueForKey:@"group_id"]];
            XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms valueForKey:[dict valueForKey:@"group_id"]];
            if(room){
                [room leaveRoom];
            }
        }

    }
    else if([[dict valueForKey:@"cmd"] isEqualToString:@"removepartcipant"]){
        [[ChatStorageDB sharedInstance]removeParticpant:[dict valueForKey:@"group_id"] member_id:[dict valueForKey:@"member_jid"]];
        if([[dict valueForKey:@"member_jid"] isEqualToString:[Utilities getSenderId]]){
            XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms valueForKey:[dict valueForKey:@"group_id"]];
            if(room){
                [room leaveRoom];
            }
            
            [[ChatStorageDB sharedInstance]leaveFromGroup:[dict valueForKey:@"group_id"]];
        }
    }
    else if([[dict valueForKey:@"cmd"] isEqualToString:@"addpartcipant"]){
        NSArray *array = [[dict valueForKey:@"members_id"] componentsSeparatedByString:@","];
        for (NSString *string in array) {
            NSString *strname = [[ContactDb sharedInstance]validateUserName:string];
            //else{
            [self saveAndInviteMembers:[dict valueForKey:@"group_id"] memeberid:string invite:NO group_subject:[dict valueForKey:@"group_subject"] member_name:strname member_nick_name:strname];
        }
    }
    else if([[dict valueForKey:@"cmd"] isEqualToString:@"updategroupname"]){
        [self updateGroupName:[dict valueForKey:@"group_id"] group_subject:[Utilities decodebase64:[dict valueForKey:@"group_subject"]]];
    }
}

@end
