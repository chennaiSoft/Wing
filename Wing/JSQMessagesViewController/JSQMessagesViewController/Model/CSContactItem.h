//
//  CSContactItem.h
//  Wing
//
//  Created by CSCS on 30/06/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMediaItem.h"

@interface CSContactItem : JSQMediaItem<JSQMessageMediaData, NSCoding, NSCopying>

@property (copy, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *contactString;
@property (copy, nonatomic) NSString *phoneNumber;
@property (copy, nonatomic) UIColor * backgroundColor;
@property (copy, nonatomic) NSData * jsonData;
- (CGSize)mediaViewDisplaySize1;

- (instancetype)initWithContact:(NSString *)contactNumber andContactName:(NSString*)contactName withUserImage:(NSData *)imageData;

@end
