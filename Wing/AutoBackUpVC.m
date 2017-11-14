//
//  AutoBackUpVC.m
//  ChatApp
//
//  Created by jeeva on 14/05/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoBackUpVC.h"
#import "DropboxManager.h"
#import "Constants.h"

@interface AutoBackUpVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;
@property (weak, nonatomic) IBOutlet UILabel *labelStatusUpdate;
@property(retain) NSIndexPath* lastIndexPath;
@end

@implementation AutoBackUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"chatBackupSelectionArray"] count])
    {
        [self chatBackupSelectionArray];
    }
        
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}


- (void)chatBackupSelectionArray
{
    NSMutableArray *dateSelection = [[NSMutableArray alloc] init];
    for (int i = 0; i<4 ; i++ ) {
        NSMutableDictionary *dateDic = [[NSMutableDictionary alloc] init];
        NSString *dateStr = @"";
        NSString *selectionStr = @"";
        AutoBackup autoBackup;
        switch (i) {
            case 0:
                dateStr = @"Daily";
                selectionStr = @"0";
                autoBackup = AutoBackupDaily;
                break;
            case 1:
                dateStr = @"Weekly";
                selectionStr = @"0";
                autoBackup = AutoBackupWeekly;
                break;
            case 2:
                dateStr = @"Monthly";
                selectionStr = @"0";
                autoBackup = AutoBackupMothly;
                break;
            case 3:
                dateStr = @"Off";
                selectionStr = @"1";
                autoBackup = AutoBackupOff;
                break;
                
            default:
                break;
        }
        [dateDic setObject:dateStr forKey:@"name"];
        [dateDic setObject:selectionStr forKey:@"selection"];
        [dateDic setObject:[NSNumber numberWithInt:autoBackup] forKey:@"autoBackup"];
        [dateSelection addObject:dateDic];
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:dateSelection forKey:@"chatBackupSelectionArray"];
   // [[NSUserDefaults standardUserDefaults] synchronize];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    
    static NSString *CellIdentifier = @"Cell";
    NSArray *menuArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatBackupSelectionArray"];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    tableView.separatorColor= [UIColor blackColor];
    if(cell == nil )
    {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.text = [[menuArray objectAtIndex:indexPath.row] valueForKey:@"name"];

    }
    if ([[[menuArray objectAtIndex:indexPath.row] valueForKey:@"selection"] isEqualToString:@"1"])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    self.lastIndexPath = indexPath;
    NSMutableArray *selectedArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"chatBackupSelectionArray"] mutableCopy];
    for (int i = 0; i<4; i++) {
        
        NSMutableDictionary *dic = [[selectedArray objectAtIndex:i] mutableCopy];

        if (i == indexPath.row) {
            [dic setObject:@"1" forKey:@"selection"];
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"chatBackupType"];
            AutoBackup backupType = [[dic objectForKey:@"autoBackup"] integerValue];
            if ([[DropboxManager shared] isDropboxLinked] == NO && backupType != AutoBackupOff) {
                [[DropboxManager shared] loginOfDropboxWithCompletionHandler:^(BOOL success) {
                    [[DropboxManager shared] autoBackup];
                }];
            }
        }
        else
        {
            [dic setObject:@"0" forKey:@"selection"];
        }
        [selectedArray removeObjectAtIndex:i];
        [selectedArray insertObject:dic atIndex:i];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedArray forKey:@"chatBackupSelectionArray"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    [tableView reloadData];
    [[DropboxManager shared] autoBackup];
}

- (void)uploadedChatHistory:(NSString *)status
{
    
}

@end
