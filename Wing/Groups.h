//
//  Groups.h
//  ChatApp
//
//  Created by theen on 13/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Groups : NSManagedObject

@property (nonatomic, retain) NSDate * created_date;
@property (nonatomic, retain) NSString * group_id;
@property (nonatomic, retain) NSString * group_subject;
@property (nonatomic, retain) NSString * owner_jid;

@end
