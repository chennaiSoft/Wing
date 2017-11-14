//
//  DropboxCell.h
//  ChatApp
//
//  Created by Jeeva on 4/18/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DBMetadata.h>

@interface DropboxCell : UITableViewCell

- (void)setCellData:(DBMetadata*)file;


@end
