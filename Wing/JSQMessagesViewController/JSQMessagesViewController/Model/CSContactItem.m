//
//  CSContactItem.m
//  Wing
//
//  Created by CSCS on 30/06/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSContactItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"

@interface CSContactItem ()

@property (strong, nonatomic) UIView * cachedImageView;

@end

@implementation CSContactItem

- (instancetype)initWithContact:(NSString *)contactNumber andContactName:(NSString*)contactName withUserImage:(NSData *)imageData
{
    self = [super init];
    if (self) {
        self.contactString = contactName;
        [self returnContactView:contactNumber withUserImage:imageData];
    }
    return self;
}

- (void)returnContactView:(NSString*)contactStr withUserImage:(NSData*)data{
    self.phoneNumber = contactStr;

    if (data == nil) {
        self.image = [UIImage imageNamed:@"ment"];

    }else{
        self.image = [UIImage imageWithData:data];
    }
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
    _cachedImageView = nil;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = [image copy];
    _cachedImageView = nil;
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
    _cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

- (CGSize)mediaViewDisplaySize1
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(315.0f, 100);
    }
    
    return CGSizeMake(210.0f, 65.0f);
}

- (UIView *)mediaView
{
    if (self.image == nil) {
        return nil;
    }
    
    if (self.cachedImageView == nil) {
        
        CGSize size = [self mediaViewDisplaySize1];
        
        UIView * contactView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        contactView.backgroundColor = self.backgroundColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(10, (size.height - 45)/2, 45, 45);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        
        UILabel *contatcLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, size.width - 60, 30)];
        contatcLabel.text = self.contactString;
        
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, size.width - 60, 30)];
        phoneLabel.font = [UIFont systemFontOfSize:12.0];
        phoneLabel.text = self.phoneNumber;
        
        [contactView addSubview:imageView];
        [contactView addSubview:contatcLabel];
        [contactView addSubview:phoneLabel];

        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:contactView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        
       /* dispatch_async(dispatch_get_main_queue(), ^{
            if (_jsonData != nil) {
                NSString * number = @"";
                NSArray * arrayJsonValues = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:nil];
                if (arrayJsonValues.count > 0) {
                    NSDictionary * contactDic = [arrayJsonValues objectAtIndex:0];
                    if ([contactDic objectForKey:@"number"] != [NSNull null]) {
                        number = [contactDic objectForKey:@"number"] ;
                        phoneLabel.text = number;
                    }
                }
            }
        });*/
        
        self.cachedImageView = contactView;
    }
    
    return self.cachedImageView;
}

- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return super.hash ^ self.image.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: image=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.image, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    NSData *imageData = UIImagePNGRepresentation(self.image);

    CSContactItem *copy = [[CSContactItem allocWithZone:zone] initWithContact:self.phoneNumber andContactName:self.contactString withUserImage:imageData];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}

@end
