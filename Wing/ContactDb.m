//
//  ContactDb.m
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "ContactDb.h"
#import "Phone.h"
#import "ErrorConstant.h"

@implementation ContactDb


static ContactDb *shared = NULL;

- (id)init
{
	if ( self = [super init] )
	{
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [self managedObjectContext];
    }
    return self;
}


+ (ContactDb*)sharedInstance
{
	if ( !shared || shared == NULL)
	{
		shared = [[ContactDb alloc] init];
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
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Contacts" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Contacts.sqlite"];
    
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
    
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


-(BOOL)validateAppUser:(NSString*)contactid{
    NSManagedObjectContext *context=[self managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactid=%@",contactid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        return YES;
    }
    return NO;
}

- (int)getContactsCount{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Phone"];
   
    [fr setPredicate:[NSPredicate predicateWithFormat:@"type=%@",[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]]];
    
    return (int)[[[self managedObjectContext] executeFetchRequest:fr error:nil] count];
    
}

-(NSArray*)getUserDetails:(NSString*)chatappid{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatappid=%@",chatappid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        return results;
    }
    return nil;
}

- (NSArray*)getFavorites:(NSString*)type{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByName]];

    
    if(![type isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@",type];
        [request setPredicate:predicate];
    }
   
    NSArray *results = [context executeFetchRequest:request error:&error];
    return results;
}

- (NSArray*)getFavorites1:(NSString*)type{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortByName]];
    
    
    if(![type isEqualToString:@""]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@ and isfavorite=%@",type,@"1"];
        [request setPredicate:predicate];
    }
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    return results;
}


- (void)updateFavorites:(NSString*)type{
    NSManagedObjectContext *context=[self managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type=%@ and isfavorite=%@",type,@"1"];
        [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    for (NSManagedObject *s in results) {
        [s setValue:@"0" forKey:@"isfavorite"];
        
    }
    [context save:nil];
}


- (NSString*)validateUserStatus:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatappid=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        return [Utilities checkNil:[s valueForKey:@"status_message"]];
        
    }
    
    return @"I'm using Wing";
}


- (NSString*)validateUserName:(NSString*)jid{
    
    NSManagedObjectContext *context=[self managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatappid=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        return [s valueForKey:@"name"];
    }
    return jid;
}


- (void)validateFavorites:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatappid=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];

        [s setValue:@"1" forKey:@"isfavorite"];
    }
    
    [context save:nil];
}

- (void)validateBlocked:(NSString*)jid{
    NSManagedObjectContext *context=[self managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatappid=%@",jid];
    [request setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        NSManagedObject *s = [results objectAtIndex:0];
        
        [s setValue:@"1" forKey:@"isblocked"];
    }
    
    [context save:nil];
}


- (void)saveContactsValue:(NSArray*)array completionBlock:(DBCompletionBlock)completionBlock{
    
 /*   NSManagedObjectContext *_childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_childContext setParentContext:managedObjectContext];
//    NSEntityDescription *contactsDescription = [NSEntityDescription entityForName:@"Phone"
//                                                           inManagedObjectContext:managedObjectContext];
    
    [_childContext performBlock:^{
        for (int i=0; i<array.count; i++) {
            NSDictionary *dic = [array objectAtIndex:i];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Phone"];
            NSError *error = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactid=%@",[dic valueForKey:@"contactid"]];
            [request setPredicate:predicate];
            NSArray *arrayresults = [managedObjectContext executeFetchRequest:request error:nil];
            
            if(arrayresults.count==0){
                
                
                
                
                
            }
            else{

                
                
                Phone *phonedb = [arrayresults objectAtIndex:0];
                phonedb.nickname = [Utilities checkNil:[dic valueForKey:@"nickname"]];
                phonedb.status_message = [Utilities checkNil:[dic valueForKey:@"status_message"]];
                phonedb.chatappid = [dic valueForKey:@"chatapp_id"];
               // phonedb.name = [Utilities checkNil:[dic valueForKey:@"name"]];
                phonedb.phone = [Utilities checkNil:[dic valueForKey:@"phone"]];
              //  phonedb.sorting = [Utilities checkNil:[dic valueForKey:@"sorting"]];
                phonedb.hide_status = [Utilities checkNil:[dic valueForKey:@"hide_status"]];
                phonedb.hide_photo = [Utilities checkNil:[dic valueForKey:@"hide_photo"]];
                phonedb.hide_lastseen = [Utilities checkNil:[dic valueForKey:@"hide_lastseen"]];
                phonedb.type = [NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS];
   
            }
            
            [_childContext save:nil];
            
        }

        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Done write test: Saving parent");
           // self.managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;

            [managedObjectContext save:nil];
            
            if (completionBlock)
                completionBlock(nil,DBErrorSuccess);
            
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UpdateContacts"
             object:self];
            
        });

        
    }];*/
    
    
    NSManagedObjectContext *context=[self managedObjectContext];
    for (int i=0; i<array.count; i++) {
        NSDictionary *dic = [array objectAtIndex:i];

   // for (NSDictionary *dic in array) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
        NSError *error = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactid=%@",[dic valueForKey:@"contactid"]];
        [request setPredicate:predicate];
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        if(results.count>0){
            for (NSManagedObject *s in results) {
                [s setValue:[Utilities checkNil:[dic valueForKey:@"nickname"]] forKey:@"nickname"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"status_message"]] forKey:@"status_message"];
                [s setValue:[dic valueForKey:@"chatapp_id"] forKey:@"chatappid"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"hide_lastseen"]] forKey:@"hide_lastseen"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"hide_photo"]] forKey:@"hide_photo"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"hide_status"]] forKey:@"hide_status"];

               // [s setValue:[dic valueForKey:@"name"] forKey:@"name"];
                [s setValue:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS] forKey:@"type"];
//                if([[Utilities checkNil:[dic valueForKey:@"name"]] length]>=1){
//                    [s setValue:[Utilities checkNil:[[[dic valueForKey:@"name"] substringToIndex:1] uppercaseString]] forKey:@"sorting"];
//                    
//                }
//                else{
//                    [s setValue:[Utilities checkNil:@"#"] forKey:@"sorting"];
//                    
//                }


            }
        }
        else{
            NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:context];
            [newContext setValue:[dic valueForKey:@"contactid"] forKey:@"contactid"];
            [newContext setValue:[dic valueForKey:@"chatapp_id"] forKey:@"chatappid"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"status_message"]] forKey:@"status_message"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"nickname"]] forKey:@"nickname"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"name"]] forKey:@"name"];
            [newContext setValue:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS] forKey:@"type"];
            if([[Utilities checkNil:[dic valueForKey:@"name"]] length]>=1){
                [newContext setValue:[Utilities checkNil:[[[dic valueForKey:@"name"] substringToIndex:1] uppercaseString]] forKey:@"sorting"];
                
            }
            else{
                [newContext setValue:[Utilities checkNil:@"#"] forKey:@"sorting"];
                
            }

           // [newContext setValue:[dic valueForKey:@"user_id"] forKey:@"user_id"];

        }
    }
    
    [context save:nil];
    
    if (completionBlock)
        completionBlock(nil,DBErrorSuccess);

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UpdateContacts"
     object:self];
}

- (void)saveSocialContactsValue:(NSArray*)array{
    
    NSManagedObjectContext *context=[self managedObjectContext];
    
    for (NSDictionary *dic in array) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
        NSError *error = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactid=%@ ",[dic valueForKey:@"id"]];
        [request setPredicate:predicate];
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        if(results.count>0){
            for (NSManagedObject *s in results) {
                [s setValue:[dic valueForKey:@"nickname"] forKey:@"nickname"];
                [s setValue:[dic valueForKey:@"status_message"] forKey:@"status_message"];
                [s setValue:[dic valueForKey:@"chatapp_id"] forKey:@"chatappid"];
                // [s setValue:[dic valueForKey:@"name"] forKey:@"name"];
                [s setValue:[NSString stringWithFormat:@"%ld",(long)ContactsTypeFacebook] forKey:@"type"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"hide_lastseen"]] forKey:@"hide_lastseen"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"hide_photo"]] forKey:@"hide_photo"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"hide_status"]] forKey:@"hide_status"];

                
            }
        }
        else{
            NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:context];
            [newContext setValue:[dic valueForKey:@"id"] forKey:@"contactid"];
            [newContext setValue:@"" forKey:@"chatappid"];
            [newContext setValue:@"" forKey:@"status_message"];
            [newContext setValue:@"" forKey:@"nickname"];
            [newContext setValue:[dic valueForKey:@"name"] forKey:@"name"];
            [newContext setValue:[NSString stringWithFormat:@"%ld",(long)ContactsTypeFacebook] forKey:@"type"];
            
                      if([[Utilities checkNil:[dic valueForKey:@"name"]] length]>=1){
                          [newContext setValue:[Utilities checkNil:[[[dic valueForKey:@"name"] substringToIndex:1] uppercaseString]] forKey:@"sorting"];
          
                      }
                      else{
                          [newContext setValue:[Utilities checkNil:@"#"] forKey:@"sorting"];
                          
                      }
          
            [newContext setValue:@"1" forKey:@"hide_lastseen"];
            [newContext setValue:@"1" forKey:@"hide_photo"];
            [newContext setValue:@"1" forKey:@"hide_status"];

           //[newContext setValue:[dic valueForKey:@"id"] forKey:@"user_id"];
          
        }
    }
    
    [context save:nil];
    
}


- (void)saveContactsValueLocal:(NSArray*)array completionBlock:(DBCompletionBlock)completionBlock{
    // creat the child one with concurrency type NSPrivateQueueConcurrenyType
   /* NSManagedObjectContext *_childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_childContext setParentContext:managedObjectContext];
    NSEntityDescription *contactsDescription = [NSEntityDescription entityForName:@"Phone"
                                                         inManagedObjectContext:managedObjectContext];
    
    __block BOOL done = NO;
    [_childContext performBlock:^{
        for (int i=0; i<array.count; i++) {
            NSDictionary *dic = [array objectAtIndex:i];
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Phone"];
          //  NSError *error = nil;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactid=%@",[dic valueForKey:@"contactid"]];
            [request setPredicate:predicate];
            NSArray *arrayresults = [managedObjectContext executeFetchRequest:request error:nil];
            
            if(arrayresults.count==0){
                Phone *phonedb = [[Phone alloc] initWithEntity:contactsDescription
                                              insertIntoManagedObjectContext:_childContext];
                
                phonedb.contactid = [dic valueForKey:@"contactid"];
                phonedb.chatappid = [dic valueForKey:@"chatapp_id"];
                phonedb.status_message = [Utilities checkNil:[dic valueForKey:@"status_message"]];
                phonedb.nickname = [Utilities checkNil:[dic valueForKey:@"nickname"]];
                phonedb.name = [Utilities checkNil:[dic valueForKey:@"name"]];
                phonedb.type = [dic valueForKey:@"type"];
                phonedb.phone = [Utilities checkNil:[dic valueForKey:@"phone"]];
                phonedb.sorting = [Utilities checkNil:[dic valueForKey:@"sorting"]];
                phonedb.hide_photo = @"1";
                phonedb.hide_lastseen = @"1";
                phonedb.hide_status = @"1";


                
            }
            else{
                Phone *phonedb = [arrayresults objectAtIndex:0];
                phonedb.name = [Utilities checkNil:[dic valueForKey:@"name"]];
                phonedb.phone = [Utilities checkNil:[dic valueForKey:@"phone"]];
                phonedb.sorting = [Utilities checkNil:[dic valueForKey:@"sorting"]];
                
            }

            [_childContext save:nil];

        }
        
        
        
        done = YES;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"Done write test: Saving parent");
          //  self.managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;

            [managedObjectContext save:nil];

            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"UpdateContacts"
             object:self];
            
            if (completionBlock)
                completionBlock(nil,DBErrorSuccess);
            
        });

    }];*/
    
    
    NSManagedObjectContext *context=[self managedObjectContext];
    for (int i=0; i<array.count; i++) {
        NSDictionary *dic = [array objectAtIndex:i];
    //for (NSDictionary *dic in array) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
        NSError *error = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactid=%@",[dic valueForKey:@"contactid"]];
        [request setPredicate:predicate];
        
        NSArray *results = [context executeFetchRequest:request error:&error];
        if(results.count>0){
            for (NSManagedObject *s in results) {
                [s setValue:[Utilities checkNil:[dic valueForKey:@"name"]] forKey:@"name"];
                [s setValue:[dic valueForKey:@"phone"] forKey:@"phone"];
                [s setValue:[Utilities checkNil:[dic valueForKey:@"sorting"]] forKey:@"sorting"];


            }
        }
        else{
            NSManagedObject *newContext=[NSEntityDescription insertNewObjectForEntityForName:@"Phone" inManagedObjectContext:context];
            [newContext setValue:[dic valueForKey:@"contactid"] forKey:@"contactid"];
            [newContext setValue:[dic valueForKey:@"chatapp_id"] forKey:@"chatappid"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"status_message"]] forKey:@"status_message"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"nickname"]] forKey:@"nickname"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"name"]] forKey:@"name"];
            [newContext setValue:[dic valueForKey:@"type"] forKey:@"type"];
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"phone"]] forKey:@"phone"];
            
            [newContext setValue:[Utilities checkNil:[dic valueForKey:@"sorting"]] forKey:@"sorting"];
            [newContext setValue:@"1" forKey:@"hide_lastseen"];
            [newContext setValue:@"1" forKey:@"hide_photo"];
            [newContext setValue:@"1" forKey:@"hide_status"];
            
            
        }
    }
    
    [context save:nil];
    
    if (completionBlock)
        completionBlock(nil,DBErrorSuccess);

   
}

- (void)updateStatusMessage:(NSString*)chatappid status_message:(NSString*)status_message{
    NSManagedObjectContext *context=[self managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Phone" inManagedObjectContext:context]];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chatappid=%@",chatappid];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:&error];
    if(results.count>0){
        for (NSManagedObject *s in results) {
            [s setValue:[Utilities checkNil:status_message] forKey:@"status_message"];
            
        }
    }
    
    [context save:nil];

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



@end
