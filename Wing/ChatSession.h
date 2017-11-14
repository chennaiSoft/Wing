//
//  ChatSession.h
//  ChatApp
//
//  Created by theen on 01/05/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChatSession : NSManagedObject

@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * isgroupchat;
@property (nonatomic, retain) NSString * localid;
@property (nonatomic, retain) NSString * messagetype;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * fromjid;
@property (nonatomic, retain) NSDate * sentdate;
@property (nonatomic, retain) NSString * displayname;

@end
