//
//  CSFileItem.m
//  Wing
//
//  Created by CSCS on 13/07/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSFileItem.h"
#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"
#import "CustomQLPreviewController.h"

@interface CSFileItem ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate>

@property (strong, nonatomic) UIView *cachedImageView;
@property (strong, nonatomic) CustomQLPreviewController *previewController;
@property (nonatomic, copy) NSString * filePath;
@property (nonatomic, copy) NSURL * file_Url;


@end

@implementation CSFileItem

- (instancetype)initWithFilePath:(NSString *)filelocation
{
    self = [super init];
    if (self) {
        [self setFileUrl:filelocation];
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)fileurl{
    self = [super init];
    if (self) {
        _file_Url = fileurl;
    }
    return self;
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

- (UIView *)mediaView
{
    if (self.cachedImageView == nil) {
        
        CGSize size = [self mediaViewDisplaySize];
        
        UIView * fileView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        
        if (self.appliesMediaViewMaskAsOutgoing) {
            fileView.backgroundColor = [UIColor jsq_messageBubbleLightGrayColor];
        }else{
            fileView.backgroundColor = [UIColor jsq_messageBubbleGreenColor];
        }
        
        self.previewController = [[CustomQLPreviewController alloc] init];
        [self.previewController setCurrentPreviewItemIndex:0];
        _previewController.delegate = self;
        _previewController.dataSource = self;
        
        self.previewController.view.frame = CGRectMake(10, 10, fileView.frame.size.width - 30, fileView.frame.size.height - 20);
        
        [fileView addSubview:self.previewController.view];

        UIView * maskView = [[UIView alloc]initWithFrame:fileView.frame];
        maskView.backgroundColor = [UIColor lightGrayColor];
        maskView.alpha = 0.1;
        [fileView addSubview:maskView];
        
        [JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:fileView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
        self.cachedImageView = fileView;
    }
    
    return self.cachedImageView;
}


- (NSUInteger)mediaHash
{
    return self.hash;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    CSFileItem *videoItem = (CSFileItem *)object;
    
    return [self.filePath isEqual:videoItem.filePath];
}

- (NSUInteger)hash
{
    return super.hash ^ self.filePath.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: fileURL=%@, appliesMediaViewMaskAsOutgoing=%@>",
            [self class], self.filePath, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(fileURL))];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    CSFileItem *copy = [[[self class] allocWithZone:zone] initWithFilePath:self.filePath];
    copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
    return copy;
}


#pragma mark -
#pragma mark QLPreviewController Data Source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSURL *url = nil;
    if (_filePath) {
        //[cell setCellData:[self.arrayOfFiles objectAtIndex:indexPath.row]];
        url = [[NSURL alloc] initFileURLWithPath:_filePath];
    }else{
        return _file_Url;
    }
    
    return url;
    
}

- (void)setFileUrl:(NSString *)fileUrl
{
    _filePath = fileUrl;
    [self.previewController reloadData];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

@end
