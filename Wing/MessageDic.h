//
//  MessageDic.h
//  Wing
//
//  Created by CSCS on 1/30/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MessageDic : NSObject

@property (nonatomic, copy) NSString * deliver;
@property (nonatomic, copy) NSString * jid;
@property (nonatomic, copy) NSString * messagetype;
@property (nonatomic, copy) NSDate * sentdate;
@property (nonatomic, copy) NSString * fromjid;
@property (nonatomic, copy) NSString * tojid;
@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * localid;
@property (nonatomic, copy) NSString * displayname;
@property (nonatomic, copy) NSString * fileurl;
@property (nonatomic, copy) NSData * image;
@property (nonatomic, copy) NSString * transferstatus;
@property (nonatomic, copy) NSString * readstatus;
@property (nonatomic, copy) NSData * jsonvalues;
@property (nonatomic, copy) NSString * datestring;
@property (nonatomic, copy) NSString * isgroupchat;
@property (nonatomic, copy) NSData * file;
@property (nonatomic, copy) NSString * fileName;
@property (nonatomic, copy) NSDate * scheduled_date;
@property (nonatomic, copy) NSString * file_ext;
@property (nonatomic, copy) UIImage * messageImg;
@property (nonatomic, copy) UIImage * userProfileImg;

+ (instancetype)messageDicWith:(NSDictionary *)dictionary;
@end
