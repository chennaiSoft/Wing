//
//  AutoDownloadViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "AutoDownloadViewController.h"
#import "Utilities.h"
#import "NetworkSelectViewController.h"

@interface AutoDownloadViewController ()

@end

@implementation AutoDownloadViewController

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
    self.title  =@"Auto Download";
    self.arrayValues  =[[NSMutableArray alloc]initWithObjects:@"Images",@"Audio",@"Videos", nil];
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableList reloadData];
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
    return @"Voice messages are always automatically downloaded for the best communication experience.";
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
    
    cell.detailTextLabel.text  = [Utilities getAutoDownloadStatus:[self.arrayValues objectAtIndex:indexPath.row]];
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NetworkSelectViewController *about = [[NetworkSelectViewController alloc]init];
    about.stringType = [self.arrayValues objectAtIndex:indexPath.row];
    [[self navigationController]pushViewController:about animated:YES];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
