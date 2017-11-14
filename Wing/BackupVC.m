//
//  BackupVC.m
//  ChatApp
//
//  Created by Jeeva on 5/14/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "BackupVC.h"
#import "Constants.h"
#import "DropboxManager.h"
#import "BackupCell.h"
#import "AutoBackUpVC.h"
#import "NSDate+NVTimeAgo.h"
#import "DropboxManager.h"

@interface BackupVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusUpdate;
@property (strong, nonatomic) BackupCell *backupCell;
@property (strong, nonatomic) BackupCell *restoreCell;
@property (strong, nonatomic) BackupCell *dropboxCell;

@property (assign) BOOL isBackingUp,isRestoring;
@end

@implementation BackupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self updateLastBackupDateDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [_tableViewMenu reloadData];
    [self updateLastBackupDateDisplay];
    [super viewWillAppear:YES];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId;
    if (indexPath.row == 0) {
        cellId = @"cell1";
    }
    else{
        cellId = @"cell2";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (indexPath.row == 1) {
        self.backupCell = (BackupCell*)cell;
    }
    else if(indexPath.row == 2){
        self.restoreCell = (BackupCell*)cell;
        self.restoreCell.labelBackup.text = @"Restore";
    }
    else if(indexPath.row == 3){
        self.dropboxCell = (BackupCell*)cell;
        if ([[DropboxManager shared] isDropboxLinked]) {
            self.dropboxCell.labelBackup.text = @"Dropbox: Logout";
        }
        else{
            self.dropboxCell.labelBackup.text = @"Dropbox: Login";
        }
        
    }
    else
    {
        self.backupCell = (BackupCell*)cell;
        NSArray *menuArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatBackupSelectionArray"];
        if (menuArray.count) {
            for (int  i = 0 ; i< [menuArray count]; i++) {
                if ([[[menuArray objectAtIndex:i] valueForKey:@"selection"] isEqualToString:@"1"])
                {
                    self.backupCell.autobackUpSelecLabel.text = [[menuArray objectAtIndex:i] valueForKey:@"name"];
                }
            }
        }
        else
        {
            self.backupCell.autobackUpSelecLabel.text = @"Off";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        self.backupCell.labelBackup.text = @"Backing up...";
        [self.backupCell.loadingIndicator startAnimating];
        self.backupCell.loadingIndicator.hidden = NO;
        [DropboxManager shared].delegate = self;
        __weak BackupVC *weakSelf = self;
        if (self.isBackingUp == NO) {
            self.isBackingUp = YES;
            [[DropboxManager shared] backup:^(BOOL success) {
                weakSelf.isBackingUp = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.backupCell.labelBackup.text = @"Backup";
                    [weakSelf.backupCell.loadingIndicator stopAnimating];
                    NSString *alertCopy;
                    if (success == YES) {
                        alertCopy = @"Your chat history has been saved successfully to Dropbox.";
                    }
                    else{
                        alertCopy = @"Sorry, could not backup your history. Please try again.";
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertCopy delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [self updateLastBackupDateDisplay];
                });
            } progress:^(CGFloat progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.backupCell.labelBackup.text = [NSString stringWithFormat:@"Backing up %.0f%%",progress*100];
                });
            }];
        }
    }
    else if (indexPath.row == 2){
        [self restore];
    }
    else if(indexPath.row == 3){
        __weak BackupVC *weakSelf = self;
        
        if ([[DropboxManager shared] isDropboxLinked]) {
            [[DropboxManager shared] logoutOfDropboxWithCompletionHandler:^(BOOL success) {
                [weakSelf.tableViewMenu reloadData];
            }];
        }
        else{
            [[DropboxManager shared] loginOfDropboxWithCompletionHandler:^(BOOL success) {
                [weakSelf.tableViewMenu reloadData];
            }];
        }
    }
    
    else {
        
        [self performSelectorOnMainThread:@selector(moveView) withObject:nil waitUntilDone:NO];
    }
}

-(void) moveView
{
    AutoBackUpVC *view = [[AutoBackUpVC alloc] initWithNibName:@"AutoBackUpVC" bundle:nil] ;
    [self.navigationController pushViewController:view animated:YES];
}
- (void)uploadedChatHistory:(NSString *)status
{
    [self.backupCell.loadingIndicator stopAnimating];
    self.backupCell.loadingIndicator.hidden = YES;
    NSLog(@"cal back");
}

- (void)restore{
    
    self.restoreCell.labelBackup.text = @"Restoring...";
        [self.restoreCell.loadingIndicator startAnimating];
        self.restoreCell.loadingIndicator.hidden = NO;
     [DropboxManager shared].delegate = self;
    __weak BackupVC *weakSelf = self;
    [[DropboxManager shared] restoreBackup:^(BOOL success) {
        
        weakSelf.isRestoring = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.restoreCell.labelBackup.text = @"Restore";
                            [weakSelf.restoreCell.loadingIndicator stopAnimating];

            if (success == YES) {
            
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
                        weakSelf.restoreCell.labelBackup.text = [NSString stringWithFormat:@"Restoring %.0f%%",progress*100];
                    });
                }];

    
//    self.restoreCell.labelBackup.text = @"Restoring...";
//    [self.restoreCell.loadingIndicator startAnimating];
//    self.restoreCell.loadingIndicator.hidden = NO;
//    [DropboxManager shared].delegate = self;
//    __weak BackupVC *weakSelf = self;
//    if (self.isRestoring == NO) {
//        self.isRestoring = YES;
//        [[DropboxManager shared] backup:^(BOOL success) {
//            weakSelf.isRestoring = NO;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.restoreCell.labelBackup.text = @"Restore";
//                [weakSelf.restoreCell.loadingIndicator stopAnimating];
//                NSString *alertCopy;
//                if (success == YES) {
//                    alertCopy = @"Your chat history has been restored successfully.";
//                }
//                else{
//                    alertCopy = @"Sorry, could not restore your backup.";
//                }
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:alertCopy delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//            });
//        } progress:^(CGFloat progress) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                weakSelf.restoreCell.labelBackup.text = [NSString stringWithFormat:@"Restoring %.0f%%",progress*100];
//            });
//        }];
//    }
}

- (void)updateLastBackupDateDisplay
{
    NSDate *backedupDate = [[NSUserDefaults standardUserDefaults] objectForKey:Dropbox_Last_Back_Date];
    if (backedupDate) {
        _labelStatusUpdate.text = [NSString stringWithFormat:@"Last Backup: %@",[backedupDate formattedAsTimeAgo]];
    }
}

@end
