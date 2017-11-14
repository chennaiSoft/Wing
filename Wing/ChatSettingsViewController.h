//
//  ChatSettingsViewController.h
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBRestClient;

@interface ChatSettingsViewController : UIViewController
@property (nonatomic,retain) IBOutlet UITableView *tableList;
@property (nonatomic,retain) IBOutlet UISwitch *switchMedia;
@property (nonatomic, strong) DBRestClient *restClient;
@property (strong, nonatomic) IBOutlet UIView *restoreView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
- (IBAction)actionchagestatus:(id)sender;
- (DBRestClient *)restClient;

@end
