//
//  ChatAccountViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "ChatAccountViewController.h"

@interface ChatAccountViewController ()

@end

@implementation ChatAccountViewController

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

    self.title  = @"Account";
    self.arrayValues  =[[NSMutableArray alloc]initWithObjects:@"Privacy",/*@"Payment Info",*/@"Delete My Account", nil];
    
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
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
    

//    if(indexPath.section==1){
//        cell.textLabel.text = @"Network Usage";
//
//    }
//    else{
//    }
    
    cell.textLabel.text = [self.arrayValues objectAtIndex:indexPath.row];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *viewName = @"";
    
    if(indexPath.section == 0){
        
        viewName = [NSString stringWithFormat:@"%@ViewController",[self.arrayValues objectAtIndex:indexPath.row]];
    }
    else{
        viewName = [NSString stringWithFormat:@"%@ViewController",@"NetworkUsage"];

    }
    viewName = [viewName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    viewName = [viewName stringByReplacingOccurrencesOfString:@" " withString:@""];
    

    UIViewController *controller = [[NSClassFromString(viewName) alloc]init];
    [[self navigationController]pushViewController:controller animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
