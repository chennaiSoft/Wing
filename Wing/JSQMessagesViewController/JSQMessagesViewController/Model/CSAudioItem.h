//
//  CSAudioItem.h
//  Wing
//
//  Created by CSCS on 07/07/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMediaItem.h"

@interface CSAudioItem : JSQMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

@property (copy, nonatomic) UIColor * backgroundColor;

- (CGSize)mediaViewDisplaySize1;

- (instancetype)initWithAudioiFile:(NSData *)audioData;

@end
