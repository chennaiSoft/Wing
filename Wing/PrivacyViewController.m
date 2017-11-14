//
//  PrivacyViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "PrivacyViewController.h"
#import "PrivacyUpdateViewController.h"
#import "BlockedViewController.h"
#import "Utilities.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

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

    self.title = @"Privacy";
    
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
    
    self.arrayValues  =[[NSMutableArray alloc]initWithObjects:@"Last Seen",@"Profile Photo",@"Status", nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableList reloadData];
}

#pragma mark UITableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
        return 1;
    
    return self.arrayValues.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if(section==0)
        return nil;
    
    return @"List of contacts you have been blocked";
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
    
    
    if(indexPath.section==1){
        cell.textLabel.text = @"Blocked";
        
    }
    else{
        cell.textLabel.text = [self.arrayValues objectAtIndex:indexPath.row];
        cell.detailTextLabel.text  = [Utilities getPrivacySettings:[self.arrayValues objectAtIndex:indexPath.row]];
        
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==0){
        PrivacyUpdateViewController *controller = [[PrivacyUpdateViewController alloc]init];
        controller.stringType = [self.arrayValues objectAtIndex:indexPath.row];
        [[self navigationController]pushViewController:controller animated:YES];

    }
    else{
        BlockedViewController *controller = [[BlockedViewController alloc]init];
        [[self navigationController]pushViewController:controller animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
