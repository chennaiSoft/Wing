//
//  AddressBookContacts.m
//  ChataZap
//
//  Created by Rifluxyss on 3/4/14.
//  Copyright (c) 2014 Rifluxyss. All rights reserved.
//

#import "AddressBookContacts.h"
#import "WebService.h"
#import "ContactDb.h"
#import "ErrorConstant.h"
#import "XMPPConnect.h"

void MyAddressBookExternalChangeCallback (
                                          ABAddressBookRef addressBook,
                                          CFDictionaryRef info,
                                          void *context
                                          )
{
   // NSLog(@"callback called %@",info);
    
    
    [[AddressBookContacts sharedInstance] refresh:addressBook];
}

@implementation AddressBookContacts
@synthesize delegate;
@synthesize people;
+ (AddressBookContacts*)sharedInstance
{
    static AddressBookContacts *sharedInstance = nil;
    
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[AddressBookContacts alloc] init];
        }
    }
    return sharedInstance;
}

- (void)refresh:(ABAddressBookRef)add
{
    NSLog(@"refresh");
    ABAddressBookRevert(add); /*refreshing the address book in case of changes*/
    people = nil;
    people = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(add);
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UpdateContacts"
     object:self];
    
    //[[ChatConnection sharedInstance] saveContacts:people];
    [self saveContacts:people];
    
    
}

-(void)saveContacts:(NSArray*)arraypeople{
    
    
    
    if(arraypeople.count==0){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ContactsSync"
         object:self];
        
        return;
        
    }
    
  //  NSString *lasttimestamp = [Utilities dateInFormat:@"%s"];
    NSMutableArray *arraycommon = [[NSMutableArray alloc]init];
     __block int current=0;
 //  __block  int total = arraypeople.count;
   // NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableDictionary *myDic = [[NSMutableDictionary alloc]init];
    
    NSMutableString *XMLString = [[NSMutableString alloc] init];
    [XMLString appendString:@"<?xml version=\"1.0\"?> \n"];
    [XMLString appendString:[NSString stringWithFormat:@"<ITEM>"]];
    
    NSArray *arrayPeopleCopy = [arraypeople copy];

    
    //dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
   // dispatch_async(backgroundQueue, ^{
    
    for (int m=0; m<arrayPeopleCopy.count; m++)
    //for (id object in arrayPeopleCopy)
    {
        id object = [arrayPeopleCopy objectAtIndex:m];
        ABRecordRef record = (__bridge ABRecordRef)object; // get address book record
        if(ABRecordGetRecordType(record) ==  kABPersonType) // this check execute if it is person group
        {
            
            ABRecordID recordID = ABRecordGetRecordID(record);
            
            NSLog(@"%d",recordID);
            
            NSString *strname = @"No Name";
            
            NSString *firstNameString = [Utilities checkNil:(__bridge NSString*)ABRecordCopyValue(record,kABPersonFirstNameProperty)];
            NSString *lastNameString = [Utilities checkNil:(__bridge NSString*)ABRecordCopyValue(record,kABPersonLastNameProperty)];
            if(([firstNameString isEqualToString:@""])&&(![lastNameString isEqualToString:@""])){
                strname = lastNameString;
            }
            else if((![firstNameString isEqualToString:@""])&&([lastNameString isEqualToString:@""])){
                strname = firstNameString;
            }
            else if((![firstNameString isEqualToString:@""])&&(![lastNameString isEqualToString:@""])){
                strname = [NSString stringWithFormat:@"%@ %@",firstNameString,lastNameString];
            }
            
            NSString *phone = @"";
            NSMutableString *phoneJson = [[NSMutableString alloc] init];
            NSMutableString *phoneXML = [[NSMutableString alloc] init];
            
            ABMultiValueRef *phones = ABRecordCopyValue(record, kABPersonPhoneProperty);
            for(CFIndex j = 0; j <1 ; j++)
            {
                if(ABMultiValueGetCount(phones)>=1){
                    
                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                    phone = (__bridge NSString *)phoneNumberRef;
                    // phone = [Utilities removeSpecialCharacters:phone];
                    // CFRelease(phoneNumberRef);
                }                
            }
            
            phone = [Utilities checkNil:phone];
            
            
            for(CFIndex j = 0; j <ABMultiValueGetCount(phones) ; j++)
            {
                CFStringRef labelStingRef = ABMultiValueCopyLabelAtIndex (phones, j);
                
                NSString *phoness = [Utilities checkNil:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j)];
                NSString* label = [Utilities checkNil:(__bridge NSString*)ABAddressBookCopyLocalizedLabel(labelStingRef)];
                if(![phoness isEqualToString:@""]){
                    if ([phoneJson length]) {
                        [phoneJson appendString:@","];
                    }
                    
                    if ([phoneXML length]) {
                        [phoneXML appendString:@","];
                    }
                    
                    if([label isEqualToString:@""]){
                        label = @"Other";
                    }
                    
                    phoness =[phoness stringByReplacingOccurrencesOfString:@"," withString:@""];
                    phoness = [phoness stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [phoneJson appendString:[NSString stringWithFormat:@"%@~%@",[[label lowercaseString]capitalizedString],phoness]];
                    
                    phoness = [phoness stringByReplacingOccurrencesOfString:@" " withString:@""];
                    phoness = [phoness stringByReplacingOccurrencesOfString:@"(" withString:@""];
                    phoness = [phoness stringByReplacingOccurrencesOfString:@")" withString:@""];
                    phoness = [phoness stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    phoness = [phoness stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    phoness = [phoness stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
                    [phoneXML appendString:[NSString stringWithFormat:@"%@",phoness]];
                }
                
            }
            
            [myDic removeAllObjects];
            if(![phone isEqualToString:@""]){
                
                NSString *unfilteredString = @"!@#$%^&*()_+|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
                NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:phone] invertedSet];
                NSString *resultString = [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
                resultString = [resultString stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSLog (@"Result: %@", resultString);
                
                [XMLString appendString:[NSString stringWithFormat:@"<ITEM1>"]];
                
                [XMLString appendString:[NSString stringWithFormat:@"<CONTACTID>%d</CONTACTID>",recordID]];
                
                 [XMLString appendString:[NSString stringWithFormat:@"<NAME>%@</NAME>",[strname stringByReplacingOccurrencesOfString:@"&" withString:@" "]]];
                
                NSString *strphone = phone;
                strphone = [strphone stringByReplacingOccurrencesOfString:@" " withString:@""];
                strphone = [strphone stringByReplacingOccurrencesOfString:@" " withString:@""];
                strphone = [strphone stringByReplacingOccurrencesOfString:@"(" withString:@""];
                strphone = [strphone stringByReplacingOccurrencesOfString:@")" withString:@""];
                strphone = [strphone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                strphone = [strphone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                strphone = [strphone stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
                
                [XMLString appendString:[NSString stringWithFormat:@"<PHONE>%@</PHONE>",[strphone stringByReplacingOccurrencesOfString:@"." withString:@""]]];
                [XMLString appendString:[NSString stringWithFormat:@"<PHONEJSON>%@</PHONEJSON>",phoneXML]];
                
                [XMLString appendString:[NSString stringWithFormat:@"</ITEM1>"]];
                
//                [newContext setValue:[dic valueForKey:@"contactid"] forKey:@"contactid"];
//                [newContext setValue:[dic valueForKey:@"chatapp_id"] forKey:@"chatappid"];
//                [newContext setValue:[dic valueForKey:@"status_message"] forKey:@"status_message"];
//                [newContext setValue:[dic valueForKey:@"nickname"] forKey:@"nickname"];
//                [newContext setValue:[dic valueForKey:@"name"] forKey:@"name"];
//                [newContext setValue:[NSString stringWithFormat:@"%d",ContactsTypePhones
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObject:[NSString stringWithFormat:@"%d",recordID] forKey:@"contactid"];
                [dict setObject:phoneXML forKey:@"phone"];
                [dict setObject:strname forKey:@"name"];
                [dict setObject:strname forKey:@"nickname"];
                [dict setObject:@"" forKey:@"chatappid"];
                [dict setObject:@"" forKey:@"status_message"];
                [dict setObject:[NSString stringWithFormat:@"%ld",(long)ContactsTypePhones] forKey:@"type"];
                
                if([[Utilities checkNil:strname] length]>=1){
                    if([[XMPPConnect sharedInstance] getSortingString:[strname substringToIndex:1]]){
                        [dict setObject:[strname substringToIndex:1].uppercaseString forKey:@"sorting"];
                    }
                    else{
                        [dict setObject:@"#" forKey:@"sorting"];

                    }
                }
                else{
                    [dict setObject:@"#" forKey:@"sorting"];

                }
                
                [arraycommon addObject:dict];
                
            }
        }
        current++;
    }
    
       // if(current==arrayPeopleCopy.count-1){
            [XMLString appendString:[NSString stringWithFormat:@"</ITEM>"]];
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Contacts.xml"];
            NSFileManager *fileManager= [NSFileManager defaultManager];
            BOOL check = [fileManager fileExistsAtPath:path];
            if(check==YES){
                [fileManager removeItemAtPath:path error:nil];
            }
            
            [[XMLString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically: YES];
           // dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"complete");
                [[ContactDb sharedInstance]saveContactsValueLocal:arraycommon  completionBlock:^(NSObject *responseObject, NSInteger errorCode){
                    NSLog(@"%@",responseObject);
                    if (errorCode == DBErrorSuccess )
                    {
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        [dic setObject:@"validatemobile" forKey:@"cmd"];
                        [dic setObject:[Utilities getSenderId] forKey:@"user_id"];
                        [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
                        
                        
                        
                        [WebService contactSyncApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
                            if(responseObject){
                                NSArray *array = [responseObject valueForKeyPath:@"mobile_list"];
                                if(array&&array.count>0){
                                    [[ContactDb sharedInstance] saveContactsValue:array  completionBlock:^(NSObject *responseObject, NSInteger errorCode){
                                        
                                    }];
                                }
                            }
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:@"ContactsSync"
                             object:self];
                            
                            NSLog(@"%@",responseObject);
                            
                        }];
                    }
                }];
}

- (void)succesLoop{
    
}

-(void)loadAddressbook1{
    people = nil;
    //addressBook = ABAddressBookCreate();
    addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    if([[UIDevice currentDevice].systemVersion integerValue]>=6){
        __block ABAddressBookRef addressBook1 = NULL; // create address book reference object
        __block BOOL accessGranted = NO;
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook1, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        
        if (accessGranted)
        {
            
            
            [self refresh:addressBook];
          ////  //people = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
        }
        else{
            
        }
    }
    else{
       // [self refresh:addressBook];
    }
    
    ABAddressBookUnregisterExternalChangeCallback(addressBook, MyAddressBookExternalChangeCallback, (__bridge void *)(self));
    
    
    ABAddressBookRegisterExternalChangeCallback (addressBook,
                                                 MyAddressBookExternalChangeCallback,
                                                 (__bridge void *)(self)
                                                 );
}



-(void)loadAddressbook{
    people = nil;
    //addressBook = ABAddressBookCreate();
    addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    if([[UIDevice currentDevice].systemVersion integerValue]>=6){
        __block ABAddressBookRef addressBook1 = NULL; // create address book reference object
        __block BOOL accessGranted = NO;
        if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook1, ^(bool granted, CFErrorRef error) {
                accessGranted = granted;
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        else { // we're on iOS 5 or older
            accessGranted = YES;
        }
        
        if (accessGranted)
        {
            [self refresh:addressBook];
            //people = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        }
        else{

        }
    }
    else{
        [self refresh:addressBook];
    }
    
    ABAddressBookUnregisterExternalChangeCallback(addressBook, MyAddressBookExternalChangeCallback, (__bridge void *)(self));

    
    ABAddressBookRegisterExternalChangeCallback (addressBook,
                                                 MyAddressBookExternalChangeCallback,
                                                 (__bridge void *)(self)
                                                 );
}

- (id)init
{
    if ((self = [super init]))
    {
        //sharedInstance = self;
        
        
    }
    return self;
}

@end
