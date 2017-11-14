//
//  StatusEditViewController.m
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "StatusEditViewController.h"
#import "StatusUpdateViewController.h"

@interface StatusEditViewController ()

@end

@implementation StatusEditViewController

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
    
    self.title = @"Tap status to edit text";
    self.arrayStatus = [[NSMutableArray alloc]init];
    
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationItem.rightBarButtonItem = self.btnDeleteAll;
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
    
    [self.tableList setEditing:YES];

}

- (void)saveStatusPlist{
    NSString *yourSoundPath = [self getPath];
    
    [self.arrayStatus writeToFile:yourSoundPath atomically:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self saveStatusPlist];
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

#pragma mark UITableView

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    id objectToMove = [self.arrayStatus objectAtIndex:sourceIndexPath.row];
    [self.arrayStatus removeObjectAtIndex:sourceIndexPath.row];
    [self.arrayStatus insertObject:objectToMove atIndex:destinationIndexPath.row];
    [self.tableList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.arrayStatus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    cell.textLabel.text  =[self.arrayStatus objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    StatusUpdateViewController *status = [[StatusUpdateViewController alloc]init];
    status.statusMessage = [self.arrayStatus objectAtIndex:indexPath.row];
    status.statusID  = indexPath.row;
    status.pageFromStatus = NO;
    status.deletgate  = (id<statusUpdateDelegate>)self;
    [[self navigationController]pushViewController:status animated:YES];
    
    NSLog(@"select");
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
      //  [self.tableList beginUpdates];
        
        if([[[self.arrayStatus objectAtIndex:indexPath.row] lowercaseString] isEqualToString:[[[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"] lowercaseString]]){
            [self resetStatusMessage];
        }
        
        [self.arrayStatus removeObjectAtIndex:indexPath.row];
        [self saveStatusPlist];
        [self.tableList deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
      //  [self.tableList reloadData];
    }
}

- (void)resetStatusMessage{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"status_message"];
    //[defaults synchronize];
}

- (IBAction)actionDeleteAll:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Delete all status messages?" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete All" otherButtonTitles:nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag==1){
        if(buttonIndex==0){
            [self resetStatusMessage];
            [self.arrayStatus removeAllObjects];
            [self saveStatusPlist];
        }
    }
    
    
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor blackColor];
        }
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.textColor = [UIColor blackColor];
            
        }
    }
}


- (void)statusUpdate:(NSString*)statusmessages :(NSInteger)statusidselected{
    [self.arrayStatus replaceObjectAtIndex:statusidselected withObject:statusmessages];
    [self saveStatusPlist];
    [self.tableList reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
