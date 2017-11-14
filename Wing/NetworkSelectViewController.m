//
//  NetworkSelectViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "NetworkSelectViewController.h"
#import "Utilities.h"

@interface NetworkSelectViewController ()

@end

@implementation NetworkSelectViewController

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
    self.arrayValues  =[[NSMutableArray alloc]initWithObjects:@"Never",@"Wi-Fi",@"Wi-Fi and Cellular", nil];
    
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
    
    if([cell.textLabel.text isEqualToString:[Utilities getAutoDownloadStatus:self.stringType]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [Utilities saveDefaultsValues:[self.arrayValues objectAtIndex:indexPath.row] :self.stringType];
    
    [self.tableList reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
