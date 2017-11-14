//
//  CSFileItem.h
//  Wing
//
//  Created by CSCS on 13/07/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMediaItem.h"

@interface CSFileItem : JSQMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

@property (copy, nonatomic) UIColor * backgroundColor;

- (instancetype)initWithFilePath:(NSString *)filelocation;
- (instancetype)initWithUrl:(NSURL *)fileurl;

@end