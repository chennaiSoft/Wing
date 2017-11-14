//
//  BackupCell.h
//  ChatApp
//
//  Created by Jeeva on 5/14/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelBackup;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *autobackUpSelecLabel;

@end
