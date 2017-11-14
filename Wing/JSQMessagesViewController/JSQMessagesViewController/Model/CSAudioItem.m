//
//  CSAudioItem.m
//  Wing
//
//  Created by CSCS on 07/07/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSAudioItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"

@interface CSAudioItem ()

@property (strong, nonatomic) UIImageView *cachedImageView;

@end

@implementation CSAudioItem


- (instancetype)initWithAudioiFile:(NSData *)audioData
{
    self = [super init];
    if (self) {
        [self returnAudioView:audioData];
    }
    return self;
}

- (void)returnAudioView:(NSData*)audioData
{
    //Do with Audio Data
}

- (void)clearCachedMediaViews
{
    [super clearCachedMediaViews];
}

- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
{
    [super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
}

#pragma mark - JSQMessageMediaData protocol

- (CGSize)mediaViewDisplaySize1
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(100.f, 100.f);
    }
    
    return CGSizeMake(100.f, 100.0f);
}

- (UIView *)mediaView
{
    if (self.cachedImageView == nil) {
        
        CGSize size = [self mediaViewDisplaySize1];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Audio_Sample"]];
        imageView.frame = CGRectMake(0, 0, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;

        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = imageView;
    }
    
    return self.cachedImageView;
}

@end
