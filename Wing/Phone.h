//
//  Phone.h
//  ChatApp
//
//  Created by theen on 26/04/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Phone : NSManagedObject

@property (nonatomic, retain) NSString * chatappid;
@property (nonatomic, retain) NSString * contactid;
@property (nonatomic, retain) NSString * hide_lastseen;
@property (nonatomic, retain) NSString * hide_photo;
@property (nonatomic, retain) NSString * hide_status;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * isblocked;
@property (nonatomic, retain) NSString * isfavorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * sorting;
@property (nonatomic, retain) NSString * status_message;
@property (nonatomic, retain) NSString * type;

@end
