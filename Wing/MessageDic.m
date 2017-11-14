//
//  MessageDic.m
//  Wing
//
//  Created by CSCS on 1/30/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "MessageDic.h"
#import "MessgaeTypeConstant.h"

@implementation MessageDic

#pragma mark - Initialization

+ (instancetype)messageDicWith:(NSDictionary *)dictionary{
    
    return [[self alloc] initWithDic:dictionary];
}

- (instancetype)initWithDic:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        MessageDic * dic = [[MessageDic alloc]init];
        
        dic.deliver = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"deliver"]];
        dic.jid = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"jid"]];
        dic.messagetype = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"messagetype"]];
        dic.sentdate = [dictionary objectForKey:@"sentdate"];
        dic.fromjid = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"fromjid"]];
        dic.tojid = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"tojid"]];
        dic.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"text"]];
        dic.localid = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"localid"]];
        dic.displayname = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"displayname"]];
        dic.fileurl = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"fileurl"]];
        
        if ([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"messagetype"]] isEqualToString:@"2"] || [[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"messagetype"]] isEqualToString:@"3"]) {
            dic.image = [dictionary objectForKey:@"image"];
        }
        
        //dic.transferstatus = [dictionary objectForKey:@"displayname"];
        dic.readstatus = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"readstatus"]];
        
        if ([dictionary objectForKey:@"jsonvalues"] != [NSNull null]) {
            dic.jsonvalues = [dictionary objectForKey:@"jsonvalues"];
        }
        dic.datestring = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"datestring"]];
        dic.isgroupchat = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"isgroupchat"]];
        //receivedMessage.file = [dictionary objectForKey:@"fileName"];
        dic.fileName = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"fileName"]];
        //dic.scheduled_date = [dictionary objectForKey:@"displayname"];
        dic.file_ext = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"file_ext"]];
        // dic.messageImg = [dictionary objectForKey:@"displayname"];
        // dic.userProfileImg = [dictionary objectForKey:@"displayname"];
        self = dic;
    }
    return self;
}

@end
