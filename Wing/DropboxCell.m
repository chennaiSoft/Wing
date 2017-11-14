//
//  DropboxCell.m
//  ChatApp
//
//  Created by Jeeva on 4/18/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "DropboxCell.h"
#import "DropboxBrowserViewController.h"
#import "NSDate+NVTimeAgo.h"

@interface DropboxCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDetails;

@end

@implementation DropboxCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellData:(DBMetadata*)file
{
    
    // Setup the cell file name
    _labelName.text = file.filename;
    
    // Display icon
    _imageViewThumbnail.image = [UIImage imageNamed:file.icon];
    if (file.thumbnailExists) {
        NSString *thumbnailPath = [DropboxBrowserViewController localThumbnailPathForFile:file.path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]) {
            _imageViewThumbnail.image = [UIImage imageWithContentsOfFile:thumbnailPath];
        }
        _imageViewThumbnail.layer.cornerRadius = 4.0;
    }
    else{
        _imageViewThumbnail.layer.cornerRadius = 0.0;
    }
    
    _imageViewThumbnail.clipsToBounds = YES;
    
    // Setup Last Modified Date
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"HH:mm:ss MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    // Get File Details and Display
    if ([file isDirectory]) {
        // Folder
        _labelDetails.text = @"";
    } else {
        // File
        _labelDetails.text = [NSString stringWithFormat:NSLocalizedString(@"%@, modified %@", @"DropboxBrowser: File detail label with the file size and modified date."), file.humanReadableSize, [file.lastModifiedDate formattedAsTimeAgo]];
    }

}

@end
