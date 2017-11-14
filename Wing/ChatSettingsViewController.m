//
//  ChatSettingsViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "ChatSettingsViewController.h"
#import "AutoDownloadViewController.h"
#import "DBBackUpViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "BackupVC.h"
#import "Utilities.h"

@interface ChatSettingsViewController ()
- (IBAction)restoreButton:(id)sender;

@end

@implementation ChatSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title  = @"Chat Settings";
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    if(![Utilities isExistingUser])
    {
        _restoreView.hidden = YES;
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"Automatically save images and video that you receive into the Camera Roll.";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
    
    if(indexPath.row==1){
        cell.textLabel.text = @"Save Incoming Media";
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.switchMedia.frame  = CGRectMake(cell.contentView.frame.size.width-(61), 7, 51, 31);
        [cell.contentView addSubview:self.switchMedia];
        
        self.switchMedia.on = [[Utilities getMediaDownload] integerValue];
    }
    else if(indexPath.row == 2){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Media Auto-Download";
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Chat Backup";
    }
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];

    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row==2){
        AutoDownloadViewController *about = [[AutoDownloadViewController alloc]init];
        [[self navigationController]pushViewController:about animated:YES];

        return;
    }
    else if(indexPath.row==0){
    
        [self movetoDBView];
       return;
    }

}

- (void)movetoDBView;
{

    UIStoryboard *backupStoryboard = [UIStoryboard storyboardWithName:@"BackupVC" bundle:nil];
    BackupVC *backup = [backupStoryboard instantiateViewControllerWithIdentifier:@"BackupVC"];
    [[self navigationController] pushViewController:backup animated:YES];
    NSLog(@"save into dropbox");
    
}

- (IBAction)actionchagestatus:(id)sender{
    
    [Utilities saveDefaultsValues:[NSString stringWithFormat:@"%d",self.switchMedia.on] :@"media_download"];
    NSLog(@"%d",self.switchMedia.on);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)restoreButton:(id)sender {
    
    [_loadingIndicator startAnimating];
    _loadingLabel.text = @"Loading";
    [[DropboxManager shared] restoreBackup:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success == YES) {
                [_loadingIndicator stopAnimating];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your chat history has been restored successfully." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Sorry, could not restore your backup." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        });
    } progress:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _loadingLabel.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
        });
    }];

}
@end
