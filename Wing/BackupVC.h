//
//  BackupVC.h
//  ChatApp
//
//  Created by Jeeva on 5/14/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxManager.h"

@interface BackupVC : UIViewController <DropboxManager,DBRestClientDelegate>
@property (weak, nonatomic) IBOutlet UILabel *autobackUpSelecLabel;

@end
