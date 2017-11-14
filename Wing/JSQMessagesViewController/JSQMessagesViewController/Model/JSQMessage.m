//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessage.h"


@interface JSQMessage ()

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
                         message:(MessageDic *)message;

@end



@implementation JSQMessage

#pragma mark - Initialization

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                               text:(NSString *)text
                            message:(MessageDic *)message{
    NSDate * date = [NSDate date];
    if (message.sentdate == nil) {
        NSDateFormatter * formattor = [[NSDateFormatter alloc]init];
        [formattor setDateFormat:@"dd MMM yyyy hh:mm"];
        date = [formattor dateFromString:message.datestring];
    }else{
        date = message.sentdate;
    }
    
    return [[self alloc] initWithSenderId:senderId
                        senderDisplayName:displayName
                                     date:date
                                     text:text
                                  message:message];
}


- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                            text:(NSString *)text
                         message:(MessageDic *)message
{
    NSParameterAssert(text != nil);

    NSLog(@"%@",date);
    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date isMedia:NO message:message];
    if (self) {
        _text = [text copy];
    }
    return self;
}

+ (instancetype)messageWithSenderId:(NSString *)senderId
                        displayName:(NSString *)displayName
                              media:(id<JSQMessageMediaData>)media
                            message:(MessageDic *)message

{
    return [[self alloc] initWithSenderId:senderId
                        senderDisplayName:displayName
                                     date:[NSDate date]
                                    media:media message:message];
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                           media:(id<JSQMessageMediaData>)media
                         message:(MessageDic*)message
{
    NSParameterAssert(media != nil);

    self = [self initWithSenderId:senderId senderDisplayName:senderDisplayName date:date isMedia:YES message:message];
    if (self) {
        _media = media;
    }
    return self;
}

- (instancetype)initWithSenderId:(NSString *)senderId
               senderDisplayName:(NSString *)senderDisplayName
                            date:(NSDate *)date
                         isMedia:(BOOL)isMedia
                     message:(MessageDic*)message
{
    NSParameterAssert(senderId != nil);
    NSParameterAssert(senderDisplayName != nil);
    NSParameterAssert(date != nil);

    self = [super init];
    if (self) {
        _senderId = [senderId copy];
        _senderDisplayName = [senderDisplayName copy];
        _date = [date copy];
        _isMediaMessage = isMedia;
        _messageDic = message;
        _messageId = [message.localid copy];
        
        _isDeliverd = YES;
    }
    return self;
}

- (id)init
{
    NSAssert(NO, @"%s is not a valid initializer for %@.", __PRETTY_FUNCTION__, [self class]);
    return nil;
}

- (void)dealloc
{
    _senderId = nil;
    _senderDisplayName = nil;
    _date = nil;
    _text = nil;
    _media = nil;
}

- (NSUInteger)messageHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    JSQMessage *aMessage = (JSQMessage *)object;

    if (self.isMediaMessage != aMessage.isMediaMessage) {
        return NO;
    }

    BOOL hasEqualContent = self.isMediaMessage ? [self.media isEqual:aMessage.media] : [self.text isEqualToString:aMessage.text];

    return [self.senderId isEqualToString:aMessage.senderId]
    && [self.senderDisplayName isEqualToString:aMessage.senderDisplayName]
    && ([self.date compare:aMessage.date] == NSOrderedSame)
    && hasEqualContent;
}

- (NSUInteger)hash
{
    NSUInteger contentHash = self.isMediaMessage ? [self.media mediaHash] : self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: senderId=%@, senderDisplayName=%@, date=%@, isMediaMessage=%@, text=%@, media=%@>",
            [self class], self.senderId, self.senderDisplayName, self.date, @(self.isMediaMessage), self.text, self.media];
}

- (id)debugQuickLookObject
{
    return [self.media mediaView] ?: [self.media mediaPlaceholderView];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _senderId = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderId))];
        _senderDisplayName = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(senderDisplayName))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
        _isMediaMessage = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isMediaMessage))];
        _text = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(text))];
        _media = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(media))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.senderId forKey:NSStringFromSelector(@selector(senderId))];
    [aCoder encodeObject:self.senderDisplayName forKey:NSStringFromSelector(@selector(senderDisplayName))];
    [aCoder encodeObject:self.date forKey:NSStringFromSelector(@selector(date))];
    [aCoder encodeBool:self.isMediaMessage forKey:NSStringFromSelector(@selector(isMediaMessage))];
    [aCoder encodeObject:self.text forKey:NSStringFromSelector(@selector(text))];

    if ([self.media conformsToProtocol:@protocol(NSCoding)]) {
        [aCoder encodeObject:self.media forKey:NSStringFromSelector(@selector(media))];
    }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    if (self.isMediaMessage) {
        return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:self.date
                                                             media:self.media message:self.messageDic];
    }

    return [[[self class] allocWithZone:zone] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:self.date
                                                          text:self.text
                                                       message:self.messageDic];
}

@end
