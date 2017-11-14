//
//  MessgaeTypeConstant.h
//  ChatApp
//
//  Created by theen on 05/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MessageType : NSInteger
{
    MessageTypeText = 1,
    MessageTypeImage = 2,
    MessageTypeVideo = 3,
    MessageTypeLocation = 4,
    MessageTypeContact = 5,
    MessageTypeAudio = 6,
    MessageTypeFile = 7,
    MessageTypeYouTube = 8
}MessageType;