//
//  YoutubeForwardViewController.m
//  ChatApp
//
//  Created by theen on 25/04/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "YoutubeForwardViewController.h"
#import "ChatStorageDB.h"
#import "ContactDb.h"
#import "MGSwipeButton.h"
#import "Groups.h"
#import "Message.h"
#import "MailTableCell.h"
#import "UIImageView+AFNetworking.h"
#import "CSFriendsTableViewCell.h"
#import "MessgaeTypeConstant.h"
#import "SVProgressHUD.h"

#import "AddressBookContacts.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "WebService.h"

@interface YoutubeForwardViewController ()

@end

@implementation YoutubeForwardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title  = @"Share";
        self.arrayInputs = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    self.disctSelection = [[NSMutableDictionary alloc]init];
    
    self.searchstring = @"";
    
    self.title = @"Share";
    
    self.tableViewForward.scrollsToTop = YES;
        
    [self.tableViewForward setEditing:YES animated:YES];
    
    [self.tableViewForward setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
    
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    selectType  = 2;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = (id<UISearchResultsUpdating>)self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.delegate = (id<UISearchBarDelegate>)self;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.tableViewForward.tableHeaderView = self.searchController.searchBar;

}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    [self getUsers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)actionCancel:(id)sender{
    [[self navigationController]popViewControllerAnimated:YES];
}

- (void)getUsers{
    
    if(self.fetchRequestController)
        self.fetchRequestController = nil;
    
    switch (selectType) {
        case 1:
            [self getFetchResultCurrentChats];
            break;
        case 2:
            [self getFetchResultContacts];
            break;
        case 3:
            [self getFetchResultGroupChats];
            break;
            
        default:
            break;
    }
}

- (void)getFetchResultCurrentChats{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message"
                                              inManagedObjectContext:[[ChatStorageDB sharedInstance] managedObjectContext]];
    
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    //    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sentdate"
                                                         ascending:NO];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    [fr setFetchBatchSize:1];
    
    NSPredicate *predicate;
    
    if(![[Utilities checkNil:self.searchstring] isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"displayname=%@",self.searchstring];
    }
    
    
    [fr setPredicate:predicate];
    
    
    self.fetchRequestController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                        managedObjectContext:[[ChatStorageDB sharedInstance] managedObjectContext]
                                          sectionNameKeyPath:@"jid"
                                                   cacheName:nil];
    
    if (![self.fetchRequestController performFetch:nil])
    {
        
        
    }
    
    [self.tableViewForward reloadData];
}


- (void)getFetchResultGroupChats{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Groups"
                                              inManagedObjectContext:[[ChatStorageDB sharedInstance] managedObjectContext]];
    
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    //    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"group_subject"
                                                         ascending:YES];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    // [fr setFetchBatchSize:1];
    
    NSPredicate *predicate;
    

    if(![[Utilities checkNil:self.searchstring] isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"group_subject contains[c] %@",self.searchstring];
    }
    else{
        //predicate = [NSPredicate predicateWithFormat:@"isgroupchat=%@",@"1"];
    }
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    
    
    if(predicate)
        [fr setPredicate:predicate];
    
    // [fr setPredicate:predicate];
    
    
    self.fetchRequestController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                        managedObjectContext:[[ChatStorageDB sharedInstance] managedObjectContext]
                                          sectionNameKeyPath:@"sorting"
                                                   cacheName:nil];
    
    if (![self.fetchRequestController performFetch:nil])
    {
        
        
    }
    
    [self.tableViewForward reloadData];
}


- (void)getFetchResultContacts{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phone"
                                              inManagedObjectContext:[[ContactDb sharedInstance] managedObjectContext]];
    
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    //    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sorting"
                                                         ascending:YES];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    
    NSPredicate *predicate;
    
    if([[Utilities checkNil:self.searchstring] isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"type=%d",ContactsTypeWINGS];
        
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"type=%d and name contains[c] %@",ContactsTypeWINGS,self.searchstring];
        
    }
    [fr setPredicate:predicate];
    
    
    self.fetchRequestController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                        managedObjectContext:[[ContactDb sharedInstance] managedObjectContext]
                                          sectionNameKeyPath:@"sorting"
                                                   cacheName:nil];
    
    if (![self.fetchRequestController performFetch:nil])
    {
        
        
    }
    
    [self.tableViewForward reloadData];
    
}

#pragma mark UITablevIew


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{              // Default is 1     
    
    return self.fetchRequestController.sections.count;
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if(selectType==1)
        return nil;
    
    if(![self.searchstring isEqualToString:@""])
        return nil;
    return self.alphabetsArray;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(selectType!=1){
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchRequestController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectType==2){
        return 56;
    }
    return 68;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if(selectType!=1){
        return [[[self.fetchRequestController sections] objectAtIndex:sectionIndex] name];
    }
    return nil;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (selectType) {
        case 1:{
            
            break;
        }
        case 3:{
            
            static NSString * identifier = @"MailCell";
            
            MailTableCell * tempcell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!tempcell) {
                tempcell = [[MailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            tempcell.labelIcon.hidden = YES;
            tempcell.btnBadge.hidden = YES;
            tempcell.lblTime.hidden = YES;
            
            Groups *s = [self.fetchRequestController objectAtIndexPath:indexPath];
            
            tempcell.lblName.text = [Utilities checkNil:s.group_subject];
            
            [tempcell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[s.group_id lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
            
            [tempcell.lblStatus setFrame:CGRectMake(tempcell.lblName.frame.origin.x, 32, 150, 30)];
            
            if([[self.disctSelection objectForKey:s.group_id] isEqualToString:@"yes"]){
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else{
                // [cell setSelected:NO animated:YES];
            }
            
            return tempcell;
            break;
        }
        case 2:{
            
            static NSString *cellIdentifier = @"friendsCell";
            
            // Similar to UITableViewCell, but
            CSFriendsTableViewCell * cell = (CSFriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[CSFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
//            customCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell_%ld_%ld",(long)indexPath.section,(long)indexPath.row]];
//            
//            if(cell==nil)
//            {
//                NSArray *nibArray= [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
//                cell = [nibArray objectAtIndex:4];
//                
//            }

            NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
            
            if([[self.disctSelection objectForKey:[user valueForKey:@"chatappid"]] isEqualToString:@"yes"]){
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else{
                // [cell setSelected:NO animated:YES];
                
            }
            
            
            cell.titleLabel.text = [user valueForKey:@"name"];
            
            [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"chatappid"] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
            
            cell.descriptionLabel.text = @"I'm using Wing";
            
            if(![[user valueForKey:@"status_message"] isEqualToString:@""]){
                cell.descriptionLabel.text = [user valueForKey:@"status_message"];
            }
            
            if([[self.disctSelection objectForKey:[user valueForKey:@"chatappid"]] isEqualToString:@"yes"]){
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else{
                // [cell setSelected:NO animated:YES];
                
            }

            cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.size.width / 2;
            cell.iconImageView.clipsToBounds = YES;
            
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
            break;
        }
        default:
            break;
    }
    
    
    static NSString * identifier = @"MailCell";
    
    MailTableCell * tempcell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!tempcell) {
        tempcell = [[MailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    tempcell.delegate = (id<MGSwipeTableCellDelegate>)self;
    
    
    Message *s = [self.fetchRequestController objectAtIndexPath:indexPath];
    
    tempcell.lblName.text = (s.displayname == nil)? @"" : s.displayname;
    
    [tempcell setBackgroundColor:[UIColor clearColor]];
    
    [tempcell.imageUser setHidden:NO];
    [tempcell.lblStatus setHidden:NO];
    
    [tempcell.btnBadge setHidden:NO];

    [tempcell.lblTime setText:[Utilities relativeDateStringForDate:[s valueForKey:@"sentdate"]]];
    
    
    if([[self.disctSelection objectForKey:s.jid] isEqualToString:@"yes"]){
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else{
        // [cell setSelected:NO animated:YES];
        
    }
    
    tempcell.lblTime.hidden = YES;
    
    tempcell.btnBadge.hidden = YES;
    
    int count = [[ChatStorageDB sharedInstance]getReadStatusBetweenUsers:s.jid];
    
    if(count > 0){
        
        tempcell.btnBadge.hidden = NO;
        [tempcell.btnBadge setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
    }
    
    if([s.isgroupchat isEqualToString:@"1"]){
        
        tempcell.lblName.text = [[ChatStorageDB sharedInstance]validateGroupName:s.jid].capitalizedString;
    }
    else{
        tempcell.lblName.text = [[ContactDb sharedInstance]validateUserName:s.jid].capitalizedString;
        
    }
    
    switch ([[s valueForKey:@"messagetype"] integerValue]) {
            
        case MessageTypeText:{
            [tempcell.lblStatus setFrame:CGRectMake(tempcell.lblName.frame.origin.x, 32, 150, 30)];
            
            [tempcell.lblStatus setText:[s valueForKey:@"text"]];
            break;
        }
        case MessageTypeImage:{
            tempcell.lblStatus.text = @"Image";
            tempcell.labelIcon.hidden = NO;
            [tempcell.labelIcon setImage:[UIImage imageNamed:@"image"]];
            [tempcell.lblStatus setFrame:CGRectMake(90, tempcell.lblStatus.frame.origin.y , tempcell.lblName.frame.size.width+20, tempcell.lblStatus.frame.size.height)];
            
        }
            break;
        case MessageTypeVideo:{
            tempcell.lblStatus.text = @"Video";
            tempcell.labelIcon.hidden = NO;
            [tempcell.labelIcon setImage:[UIImage imageNamed:@"video_audio.png"]];
            [tempcell.lblStatus setFrame:CGRectMake(90, tempcell.lblStatus.frame.origin.y , tempcell.lblName.frame.size.width+20, tempcell.lblStatus.frame.size.height)];
            
            
        }
            break;
        case MessageTypeLocation:
            tempcell.lblStatus.text = @"Location";
            break;
        case MessageTypeContact:
            tempcell.lblStatus.text = @"Contact";
            break;
        case MessageTypeAudio:
            tempcell.lblStatus.text = @"Audio";
            break;
        case MessageTypeFile:
            tempcell.lblStatus.text = @"File";
            break;

        default:
            break;
    }
    
    
    [tempcell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[s.jid lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
    
    return tempcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    indexPathCommon = indexPath;
    self.navigationItem.rightBarButtonItem = self.sendButton;

    switch (selectType) {
        case 1:{
            Message *s = [self.fetchRequestController objectAtIndexPath:indexPath];
            
            [self.disctSelection setValue:@"yes" forKey:s.jid];
            break;
        }
        case 2:{
            NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection setValue:@"yes" forKey:[user valueForKey:@"chatappid"]];
            break;
        }
        case 3:{
            Groups *s = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection setValue:@"yes" forKey:s.group_id];
            break;
        }
        default:
            break;
            
    }
    
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (selectType) {
        case 1:{
            Message *s = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection removeObjectForKey:s.jid];
            
            break;
        }
        case 3:{
            Groups *user = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection removeObjectForKey:user.group_id];
            
            break;
        }
            
        case 2:{
            NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection removeObjectForKey:[user valueForKey:@"chatappid"]];
            
            break;
        }
            
            
        default:
            break;
    }
    
    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    
    [self.disctSelection removeObjectForKey:[user valueForKey:@"chatappid"]];
    
    if(self.disctSelection.count==0){
        if(selectType==2){
            self.navigationItem.rightBarButtonItem = self.addButton;
            
        }
        else{
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet==sheetForward){
        switch (buttonIndex) {
            case 0:{
                
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showWithStatus:@"Please wait..."];
                
                [self performSelector:@selector(forwardMessages) withObject:nil afterDelay:0.5];
            }
                break;
                
            default:
                break;
        }
    }
    else if(actionSheet==sheetForward1){
        switch (buttonIndex) {
            case 0:{
                
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showWithStatus:@"Please wait..."];
                
                [self performSelector:@selector(forwardMessagesGroups) withObject:nil afterDelay:0.5];
            }
                break;
                
            default:
                break;
        }
    }
    else if(actionSheet==sheetForward2){
        switch (buttonIndex) {
            case 0:{
                
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD showWithStatus:@"Please wait..."];
                
                [self performSelector:@selector(forwardMessagesContacts) withObject:nil afterDelay:0.5];
            }
                break;
                
            default:
                break;
        }
    }
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return NO;
}


#pragma mark Search Bar

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableViewForward reloadData];
}

#pragma mark option select

- (IBAction)actionOptionSelect:(id)sender{
    
    [self.disctSelection removeAllObjects];
    
    [btnGroups setBackgroundImage:[UIImage imageNamed:@"group_wing_2.png"] forState:UIControlStateNormal];
    [btnContact setBackgroundImage:[UIImage imageNamed:@"wing_2.png"] forState:UIControlStateNormal];
    [btnChats setBackgroundImage:[UIImage imageNamed:@"contact_2.png"] forState:UIControlStateNormal];
    
    
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 1:{
            [btnChats setBackgroundImage:[UIImage imageNamed:@"contact_1.png"] forState:UIControlStateNormal];
            
            self.navigationItem.rightBarButtonItem = nil;
            selectType = 1;
            [self getUsers];
            break;
        }
        case 3:{
            [btnGroups setBackgroundImage:[UIImage imageNamed:@"group_wing_1.png"] forState:UIControlStateNormal];
            
            self.navigationItem.rightBarButtonItem = nil;
            selectType = 3;
            [self getUsers];
            break;
        }
        case 2:{
            [btnContact setBackgroundImage:[UIImage imageNamed:@"wing_1.png"] forState:UIControlStateNormal];
            
            self.navigationItem.rightBarButtonItem = self.addButton;
            selectType = 2;
            [self getUsers];
            break;
        }
        default:
            break;
    }
}
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.searchstring = searchController.searchBar.text;
    
    [self getUsers];

}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    
    
    
}// called when text changes (including clear)

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}//


#pragma mark Add

- (IBAction)actionAdd:(id)sender{
    [self createNewPerson];
}

- (void)createNewPerson
{
    // Create the pre-filled properties
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, CFSTR(""), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, CFSTR(""), &error);
    
    // Create and set-up the new person view controller
    ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] initWithNibName:nil bundle:nil];
    [newPersonViewController setDisplayedPerson:newPerson];
    [newPersonViewController setNewPersonViewDelegate:(id<ABNewPersonViewControllerDelegate>)self];
    
    // Wrap in a nav controller and display
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    [self presentViewController:navController animated:YES completion:nil];
    
    // Clean up everything
    CFRelease(newPerson);
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Send Action

- (IBAction)actionSend{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    switch (selectType) {
        case 1:
            [self performSelector:@selector(forwardMessages) withObject:nil afterDelay:0.5];
            break;
        case 2:
            [self performSelector:@selector(forwardMessagesContacts) withObject:nil afterDelay:0.5];
            break;
        case 3:
            [self performSelector:@selector(forwardMessagesGroups) withObject:nil afterDelay:0.5];
            break;
        default:
            break;
    }
    
    
    
}

- (void)forwardMessages{
    for (id dict in  self.arrayInputs) {

    for (NSIndexPath *path in  [self.tableViewForward indexPathsForSelectedRows]) {
        NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
        
        
        if([[ChatStorageDB sharedInstance]validateYouTubeVideoShare:[dict valueForKey:@"id"] type:@"U" delete:NO]){
            
        }
        else{
            [[ChatStorageDB sharedInstance] saveYouTubeShare:dict type:@"U"];
        }
        
        NSArray *keys = [dict allKeys];
        NSDictionary *dict1 = [dict dictionaryWithValuesForKeys:keys];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
        [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
        [dict setObject:@"yes" forKeyedSubscript:@"readstatus"];
        [[XMPPConnect sharedInstance] sendYouTubeVideo:dict tojid:[Utilities checkNil:[user valueForKey:@"jid"]] isgroupchat:[user valueForKey:@"jid"]];
        
        [self sendPushNotification:@"youtube" localid:@"localid" text:@"" receiverid:[Utilities checkNil:[user valueForKey:@"jid"]] isgroupchat:@"isgroupchat"];
        
    }
    }
    
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:0.5];

}

- (void)forwardMessagesContacts{
    
    for (id dict in  self.arrayInputs) {
        
        for (NSIndexPath *path in  [self.tableViewForward indexPathsForSelectedRows]) {
            NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
            
            if([[ChatStorageDB sharedInstance]validateYouTubeVideoShare:[dict valueForKey:@"id"] type:@"U" delete:NO]){
                
            }
            else{
                [[ChatStorageDB sharedInstance] saveYouTubeShare:dict type:@"U"];
            }
            
            NSArray *keys = [dict allKeys];
            NSDictionary *dict1 = [dict dictionaryWithValuesForKeys:keys];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
            [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
            [dict setObject:@"yes" forKeyedSubscript:@"readstatus"];
            [[XMPPConnect sharedInstance] sendYouTubeVideo:dict tojid:[user valueForKey:@"chatappid"] isgroupchat:@"0"];
            [self sendPushNotification:@"youtube" localid:@"localid" text:@"" receiverid:[Utilities checkNil:[user valueForKey:@"chatappid"]] isgroupchat:@"0"];
        }
        
    }
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:0.5];


}

- (void)forwardMessagesGroups{
    
    for (id dict in  self.arrayInputs) {

    for (NSIndexPath *path in  [self.tableViewForward indexPathsForSelectedRows]) {
        NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
        
        
        if([[ChatStorageDB sharedInstance]validateYouTubeVideoShare:[dict valueForKey:@"id"] type:@"U" delete:NO]){
            
        }
        else{
            [[ChatStorageDB sharedInstance] saveYouTubeShare:dict type:@"U"];
        }
        
        NSArray *keys = [dict allKeys];
        NSDictionary *dict1 = [dict dictionaryWithValuesForKeys:keys];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
        [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
        [dict setObject:@"yes" forKeyedSubscript:@"readstatus"];
        [[XMPPConnect sharedInstance] sendYouTubeVideo:dict tojid:[Utilities checkNil:[user valueForKey:@"chatappid"]] isgroupchat:@"1"];
        [self sendPushNotification:@"youtube" localid:@"localid" text:@"" receiverid:[Utilities checkNil:[user valueForKey:@"chatappid"]] isgroupchat:@"1"];

        
    }
    }
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:0.5];
}

- (void)hideAlert{
    
    [SVProgressHUD dismiss];
    [self.disctSelection removeAllObjects];
    [self.tableViewForward reloadData];
    
    [[self navigationController] popViewControllerAnimated:YES];

}

- (void)sendPushNotification:(NSString*)type localid:(NSString*)localid text:(NSString*)textmessage receiverid:(NSString*)receiverid isgroupchat:(NSString*)isgroupchat{
    
    NSString *stringstatus = [[XMPPConnect sharedInstance].dictPresence objectForKeyedSubscript:[Utilities getReceiverId]];
    if([[Utilities checkNil:stringstatus] isEqualToString:@""]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
        [dict setObject:receiverid forKey:@"receiver"];
        [dict setObject:isgroupchat forKey:@"isgroupchat"];
        [dict setObject:textmessage forKey:@"text_message"];
        [dict setObject:type forKey:@"type"];
        [dict setObject:localid forKey:@"localid"];
        [dict setObject:@"sendpushnotification" forKey:@"cmd"];
        
        [WebService sendForPushNotification:dict completionBlock:^(NSObject *responseObject, NSInteger errorCode){
            
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
