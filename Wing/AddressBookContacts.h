//
//  AddressBookContacts.h
//  ChataZap
//
//  Created by Rifluxyss on 3/4/14.
//  Copyright (c) 2014 Rifluxyss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@protocol contacdelegate <NSObject>


@optional
-(void)success;
-(void)failure;


@end

@interface AddressBookContacts : NSObject{
    ABAddressBookRef addressBook;
    NSArray *people;
    
    id<contacdelegate> delegate;
}

@property(nonatomic,retain)id<contacdelegate> delegate;
@property(nonatomic,retain) NSArray *people;

+ (AddressBookContacts*)sharedInstance;
- (void)refresh:(ABAddressBookRef)add;

void MyAddressBookExternalChangeCallback (
                                          ABAddressBookRef addressBook,
                                          CFDictionaryRef info,
                                          void *context
                                          );
-(void)loadAddressbook;
-(void)loadAddressbook1;
@end
