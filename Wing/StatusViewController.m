//
//  StatusViewController.m
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "StatusViewController.h"
#import "StatusEditViewController.h"
#import "StatusUpdateViewController.h"
#import "SVProgressHUD.h"
#import "Utilities.h"
#import "Constants.h"
#import "WebService.h"
#import "XMPPConnect.h"

@interface StatusViewController ()

@end

@implementation StatusViewController

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
    
    self.title = @"Status";
    
    self.arrayStatus = [[NSMutableArray alloc]init];
    
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem = self.btnEdit;
    [self.arrayStatus removeAllObjects];

    NSString *yourSoundPath = [self getPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:yourSoundPath])
    {
       // NSArray *array = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:yourSoundPath] options:NSJSONReadingMutableContainers error:nil];
        NSString *strerrorDesc = nil;
        NSPropertyListFormat plistFormat;
        NSArray *array = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:yourSoundPath] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&plistFormat errorDescription:&strerrorDesc];

        [self.arrayStatus addObjectsFromArray:array];
    }
    else{
        [self setStatusMessages];
        
        [self.arrayStatus writeToFile:yourSoundPath atomically:YES];
       
    }

    [self.tableList reloadData];
}

-(void) didTapNavView
{
    NSLog(@"doSomething");
    [self.tableList setContentOffset:CGPointMake(0, -64) animated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
   // [self.navigationController.navigationBar removeGestureRecognizer:singleTap];
}


- (NSString*)getPath{
    
    NSString *filename = @"StatusMessages.plist";
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    NSString *yourSoundPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return yourSoundPath;
}

- (void)setStatusMessages{
    [self.arrayStatus addObject:@"Available"];
    [self.arrayStatus addObject:@"At school"];
    [self.arrayStatus addObject:@"At the movies"];
    [self.arrayStatus addObject:@"At the gym"];
    [self.arrayStatus addObject:@"At work"];
    [self.arrayStatus addObject:@"Battery about to die"];
    [self.arrayStatus addObject:@"Can't talk, WING only"];
    [self.arrayStatus addObject:@"In a meeting"];
    [self.arrayStatus addObject:@"Sleeping"];
    [self.arrayStatus addObject:@"Urgent calls only"];
}

- (NSString*)chckNil:(NSString*)str{
    
    if(str==nil||[str isEqualToString:@""]||[str isEqualToString:@"(null)"]){
        return @"I'm using Wing";
    }
    
    return str;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    
    if (section==1) {
        return self.arrayStatus.count;
    }
    
    return 1;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0)
        return @"Your current status is";
    if (section==1)
        return @"Select your new status";
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor  =[UIColor blackColor];
    [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text = [self chckNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:{
            cell.textLabel.text = [self.arrayStatus objectAtIndex:indexPath.row];
            
            if([cell.textLabel.text.lowercaseString isEqualToString:[[[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"] lowercaseString]]){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            break;
        }
        case 2:{
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
             cell.textLabel.textColor  =[UIColor redColor];
            cell.textLabel.text = @"Clear Status";
            break;
        }
            
        default:
            break;
    }
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            [self statusEditView];
            break;
        }
        case 1:{
            [self updateStatus:[self.arrayStatus objectAtIndex:indexPath.row]];
            break;
        }
        case 2:{
            [self clearStatus];
            break;
        }
        default:
            break;
    }
    
    [self.tableList reloadData];
}

- (void)statusEditView{
    
    StatusUpdateViewController *status = [[StatusUpdateViewController alloc]init];
    status.statusMessage = [self chckNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"]];
    status.statusID  = 0;
    status.pageFromStatus = YES;
    status.deletgate  = (id<statusUpdateDelegate>)self;
    [[self navigationController]pushViewController:status animated:YES];
}

- (void)statusUpdate:(NSString*)statusmessages :(NSInteger)statusidselected{
    [self.arrayStatus addObject:statusmessages];
    NSString *yourSoundPath = [self getPath];
    [self.arrayStatus writeToFile:yourSoundPath atomically:YES];
}

- (void)setStatusBsedOnSelection:(NSString*)statusmessage{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:statusmessage forKey:@"status_message"];
   // [defaults synchronize];
}

- (void)clearStatus{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"status_message"];
   // [defaults synchronize];
    [self.arrayStatus removeAllObjects];
    [self setStatusMessages];
    NSString *yourSoundPath = [self getPath];
    [self.arrayStatus writeToFile:yourSoundPath atomically:YES];

    [self.tableList reloadData];
}


- (IBAction)actionEdit:(id)sender{
    StatusEditViewController *edit = [[StatusEditViewController alloc]init];
    [[self navigationController]pushViewController:edit animated:YES];
}

- (void)updateStatus:(NSString*)stringtatus{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatestatus" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[Utilities  encodingBase64:stringtatus]  forKey:@"status_message"];
    
    
    
    [WebService updateNickname:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success:) withObject:stringtatus waitUntilDone:YES];
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

- (void)success:(NSString*)status_message{
    
    [self setStatusBsedOnSelection:status_message];
    [self.tableList reloadData];
    
    [[XMPPConnect sharedInstance]goOnline];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
