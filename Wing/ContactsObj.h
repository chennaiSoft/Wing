//
//  ContactsObj.h
//  Wing
//
//  Created by CSCS on 1/13/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsObj : NSObject

@property (nonatomic, copy) NSString * jid;
@property (nonatomic, copy) NSString * isgroupchat;
@property (nonatomic, copy) NSString * localid;
@property (nonatomic, copy) NSString * messagetype;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * fromjid;
@property (nonatomic, copy) NSDate * sentdate;
@property (nonatomic, copy) NSString * displayname;
@end
