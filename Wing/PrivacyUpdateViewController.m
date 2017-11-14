//
//  PrivacyUpdateViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "PrivacyUpdateViewController.h"
#import "SVProgressHUD.h"
#import "Utilities.h"
#import "WebService.h"

@interface PrivacyUpdateViewController ()

@end

@implementation PrivacyUpdateViewController

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
    self.title  = self.stringType;
    self.arrayValues  =[[NSMutableArray alloc]initWithObjects:@"Everyone",@"My Contacts",@"Nobody", nil];
    
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.arrayValues.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if([self.stringType isEqualToString:@"Last Seen"]){
       return @"If you don't share your Last Seen, you won't be able to see other people's Last Seen ";
    }
    
    return nil;
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [self.arrayValues objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if([cell.textLabel.text isEqualToString:[Utilities getPrivacySettings:self.stringType]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updatePrivacy:[self.arrayValues objectAtIndex:indexPath.row]];
}

- (void)updatePrivacy:(NSString*)value{

    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updateprivacy" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    
    NSString *update_type = @"";
    if([self.stringType isEqualToString:@"Last Seen"]){
        update_type = @"hide_lastseen";
    }
    else if([self.stringType isEqualToString:@"Profile Photo"]){
        update_type = @"hide_photo";
    }
    else{
        update_type = @"hide_status";
    }
    
    [dic setObject:update_type  forKey:@"update_type"];
    [dic setObject:[Utilities  valueforprivacy:value]  forKey:@"update_value"];

    [WebService updatePrivacy:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success:) withObject:value waitUntilDone:YES];
            }
            else{
                [Utilities alertViewFunction:@"" message:[responseObject valueForKey:@"messsage"]];
            }
        }
        else{
            [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
        
    }];
}

- (void)success:(NSString*)value{
    [Utilities saveDefaultsValues:value :self.stringType];
    [self.tableList reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
