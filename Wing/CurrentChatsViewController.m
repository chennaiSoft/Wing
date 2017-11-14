//
//  CurrentChatsViewController.m
//  ChatApp
//
//  Created by Theen on 11/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "CurrentChatsViewController.h"
#import "MailTableCell.h"
#import "MGSwipeButton.h"
#import "Message.h"
#import "ChatStorageDB.h"

#import "DemoMessagesViewController.h"
#import "JSQMessagesTimestampFormatter.h"
#import "NSData+XMPP.h"
#import "Groups.h"
#import "ContactDb.h"
#import "UIImageView+AFNetworking.h"
#import "CSFriendsTableViewCell.h"
#import "MessgaeTypeConstant.h"

@interface CurrentChatsViewController ()
@property(nonatomic,retain) NSString *searchstring;
@end

@implementation CurrentChatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.arrayObjects = [[NSMutableArray alloc]init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    self.disctSelection = [[NSMutableDictionary alloc]init];
    
    self.searchstring = @"";

    self.title = @"Chats";
    
    self.tableViewList.scrollsToTop = YES;
    
    [self.tableViewList setEditing:YES animated:YES];
    
    [self.tableViewList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];


    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = self.addButton;
//    UITextField *textField = [searchBar valueForKey:@"_searchField"];
//    textField.clearButtonMode = UITextFieldViewModeNever;

    Message * messagess = [_arrayObjects objectAtIndex:0];

    if ([messagess.messagetype isEqualToString:@""]) {
        
    }
    selectType  = 2;
   
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    [self getUsers];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceivedNotification:)
                                                 name:@"messageReceived"
                                               object:nil];

   
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)actionCancel:(id)sender{
    [[self navigationController]popViewControllerAnimated:YES];
}

#pragma mark Get  Chats

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
    
    if(self.pageFromProfile==YES){
        if(![[Utilities checkNil:self.searchstring] isEqualToString:@""]){
            predicate = [NSPredicate predicateWithFormat:@"displayname=%@ and isgroupchat=%@",self.searchstring,@"1"];
        }
        else{
            predicate = [NSPredicate predicateWithFormat:@"isgroupchat=%@",@"1"];
        }
    }
    else{
        if(![[Utilities checkNil:self.searchstring] isEqualToString:@""]){
            predicate = [NSPredicate predicateWithFormat:@"displayname=%@",self.searchstring];
            
        }
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
    
    [self.tableViewList reloadData];
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
    
    //    if(self.pageFromProfile==YES){
    //        if(![[Utilities checkNil:searchBar.text] isEqualToString:@""]){
    //            predicate = [NSPredicate predicateWithFormat:@"displayname=%@ and isgroupchat=%@",searchBar.text,@"1"];
    //        }
    //        else{
    //            predicate = [NSPredicate predicateWithFormat:@"isgroupchat=%@",@"1"];
    //        }
    //    }
    //    else{
    if(![[Utilities checkNil:self.searchstring] isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"group_subject contains[c] %@",self.searchstring];
    }
    else{
        //predicate = [NSPredicate predicateWithFormat:@"isgroupchat=%@",@"1"];
    }
    // }
    
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
    
    [self.tableViewList reloadData];
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
    
    [self.tableViewList reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{              // Default is 1 if not implemented
    
//    if(![self.searchString isEqualToString:@""])
//        return 1;

    
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
    if(selectType==3){
        return 56;
    }
    return 68.0;
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
            
            // tempcell.lblStatus.text = [[ChatStorageDB sharedInstance]getGroupChatMembers:s.group_id];
            
            [tempcell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[s.group_id lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
            
            [tempcell.lblStatus setFrame:CGRectMake(tempcell.lblName.frame.origin.x, 32, 150, 30)];
            
            if([[self.disctSelection objectForKey:s.group_id] isEqualToString:@"yes"]){
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else{
                // [cell setSelected:NO animated:YES];
                
            }

            
          //  tempcell.lblStatus.text = [[ChatStorageDB sharedInstance]getGroupChatMembers:s.group_id];
            return tempcell;
            break;
        }
        case 2:{
            
            static NSString *cellIdentifier = @"forwardCell";
            
            // Similar to UITableViewCell, but
            CSFriendsTableViewCell * cell = (CSFriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                cell = [[CSFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            
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
    
    tempcell.lblName.text = s.displayname;
    
    [tempcell setBackgroundColor:[UIColor clearColor]];
    
    [tempcell.imageUser setHidden:NO];
    [tempcell.lblStatus setHidden:NO];
    
    [tempcell.btnBadge setHidden:NO];
    
    // NSMutableArray *data = [[AddressBookContacts sharedInstance].people objectAtIndex:indexPath.section];
    
    //NSString *cellData = [data objectAtIndex:indexPath.row];
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
    
    if(count>0){
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
            [tempcell.labelIcon setImage:[UIImage imageNamed:@"video_audio"]];
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
    
   // [tableView deselectRowAtIndexPath:indexPath animated:YES];
    indexPathCommon = indexPath;
    self.navigationItem.rightBarButtonItem = self.sendButton;

    switch (selectType) {
        case 1:{
            Message *s = [self.fetchRequestController objectAtIndexPath:indexPath];
            
            [self.disctSelection setValue:@"yes" forKey:s.jid];
            
            break;
        }
        case 3:{
             Groups *s = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection setValue:@"yes" forKey:s.group_id];
            break;
        }
        case 2:{
            NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
            [self.disctSelection setValue:@"yes" forKey:[user valueForKey:@"chatappid"]];
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


-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

- (IBAction)actionOptionSelect:(id)sender{
    [self.disctSelection removeAllObjects];

    [btnGroups setBackgroundImage:[UIImage imageNamed:@"group_wing_2"] forState:UIControlStateNormal];
    [btnContact setBackgroundImage:[UIImage imageNamed:@"wing_2"] forState:UIControlStateNormal];
    [btnChats setBackgroundImage:[UIImage imageNamed:@"contact_2"] forState:UIControlStateNormal];
    
    
    UIButton *btn = (UIButton*)sender;
    switch (btn.tag) {
        case 1:{
            [btnChats setBackgroundImage:[UIImage imageNamed:@"contact_1"] forState:UIControlStateNormal];

            self.navigationItem.rightBarButtonItem = nil;
            selectType = 1;
            [self getUsers];
            break;
        }
        case 3:{
            [btnGroups setBackgroundImage:[UIImage imageNamed:@"group_wing_1"] forState:UIControlStateNormal];

            self.navigationItem.rightBarButtonItem = nil;
            selectType = 3;
            [self getUsers];
            break;
        }
        case 2:{
            [btnContact setBackgroundImage:[UIImage imageNamed:@"wing_1"] forState:UIControlStateNormal];

            self.navigationItem.rightBarButtonItem = self.addButton;
            selectType = 2;
            [self getUsers];
            break;
        }
        default:
            break;
    }
}
/*
- (IBAction)actionSegmentTouch:(id)sender{
    
    UISegmentedControl *seg = (UISegmentedControl*)sender;
    switch (seg.selectedSegmentIndex) {
        case 1:{
            seg.selected = YES;
            self.navigationItem.rightBarButtonItem = nil;
            selectType = 1;
            [self getUsers];
            break;
        }
        case 3:{
            self.navigationItem.rightBarButtonItem = nil;
            selectType = 3;
            seg.selected = YES;
            [self getUsers];
            break;
        }
        case 2:{
            seg.selected = YES;
            self.navigationItem.rightBarButtonItem = self.addButton;
            selectType = 2;
           [self getUsers];
            break;
        }
        default:
            break;
    }
}
*/

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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchstring = searchBar.text;
    
    [self getUsers];
    
}
// called when text changes (including clear)

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}//

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    tableView.sectionIndexColor = [UIColor blackColor];
    tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
    
    [tableView setAllowsMultipleSelection:YES];
    [tableView setAllowsMultipleSelectionDuringEditing:YES];
    [tableView setAllowsSelection:YES];
    [tableView setAllowsSelectionDuringEditing:YES];
    
    
    [tableView setEditing:YES];
    
    [tableView setBackgroundColor:[UIColor clearColor]];
    
    NSLog(@"show");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchstring =@"";
    
    [self getUsers];
}// called

#pragma mark Segment Actions

- (void)gotoGroupView{
  
  //  [app.menu groupListForwardRedirects:self.arrayObjects];
}

- (void)gotoContactView{
  //  [app.menu contactForwardRedirects:self.arrayObjects];

}


-(void)forwardMessages{
    
    for (NSIndexPath * path in  [self.tableViewList indexPathsForSelectedRows]) {
        
    
    Message *tempS = [self.fetchRequestController objectAtIndexPath:path];

    for (NSManagedObject *s in self.arrayObjects) {
        
        NSString *localId = [[XMPPConnect sharedInstance] getLocalId];
        
        NSArray *keys = [[[s entity] attributesByName] allKeys];
        
        NSDictionary *dict1 = [s dictionaryWithValuesForKeys:keys];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
        [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
        [dict setValue:tempS.jid forKeyPath:@"jid"];
        [dict setValue:tempS.jid forKeyPath:@"tojid"];
        [dict setValue:localId forKeyPath:@"localid"];
        [dict setValue:[NSDate date] forKey:@"sentdate"];
        [dict setValue:@"1" forKey:@"deliver"];
        [dict setValue:@"yes" forKey:@"readstatus"];
        [dict setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
        [dict setValue:[Utilities checkNil:tempS.isgroupchat] forKey:@"isgroupchat"];
        [dict setValue:[Utilities checkNil:tempS.fileName] forKey:@"fileName"];
        [dict removeObjectForKey:@"file"];
        
        NSString *file_ext = [Utilities checkNil:[dict valueForKey:@"file_ext"]];
        [dict setValue:file_ext forKey:@"file_ext"];

        NSString *strname = @"";
        if([tempS.isgroupchat isEqualToString:@"1"]){
            
            strname = [[ChatStorageDB sharedInstance]validateGroupName:tempS.jid].capitalizedString;
        }
        else{
            strname = [[ContactDb sharedInstance]validateUserName:tempS.jid].capitalizedString;
            
        }
        [dict setValue:[Utilities checkNil:strname] forKey:@"displayname"];

        
        if(![[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
            [dict removeObjectForKey:@"jsonvalues"];
        }

        
         if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
             [dict removeObjectForKey:@"image"];
         }
        
      
        
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
            [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Image"] toPath:[Utilities getFilePath:localId :@"Image"] error:nil];
            
        
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
              [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Video"] toPath:[Utilities getFilePath:localId :@"Video"] error:nil];
            
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
            [dict removeObjectForKey:@"image"];
            [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Audio"] toPath:[Utilities getFilePath:localId :@"Audio"] error:nil];
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
           
            NSData *dataimage = [s valueForKey:@"image"];
            
            if(dataimage){
                // [dict setValue:[NSString stringWithFormat:@"%@",[dataimage base64Encoded]] forKey:@"image"];
                
            }
            else{
                [dict removeObjectForKey:@"image"];
            }


        }
        [dict removeObjectForKey:@"deliverydate"];

        [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:dict incoming:YES];
        [dict removeObjectForKey:@"sentdate"];

        if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
            
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
                
                NSData *data = [s valueForKey:@"jsonvalues"];
                [dict setValue:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"jsonvalues"];
                
                NSData *dataimage = [s valueForKey:@"image"];
                
                if(dataimage){
                    [dict setValue:[NSString stringWithFormat:@"%@",[dataimage xmpp_base64Encoded]] forKey:@"image"];
                    
                }
                else{
                    [dict removeObjectForKey:@"image"];
                }
            }
            else{
                [dict setValue:[NSString stringWithFormat:@"%@",[[s valueForKey:@"image"] xmpp_base64Encoded]] forKey:@"image"];

            }
        
        }
        
        [[XMPPConnect sharedInstance]messageSendToReceiver:dict];
    }
    }
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:0.5];
}

- (void)hideAlert{
    
    [SVProgressHUD dismiss];
    [self.disctSelection removeAllObjects];
    [self.tableViewList reloadData];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)forwardMessagesGroups{
    
    for (NSIndexPath *path in  [self.tableViewList indexPathsForSelectedRows]) {

    Groups *group = [self.fetchRequestController objectAtIndexPath:path];
    
    for (NSManagedObject *s in self.arrayObjects) {
        NSArray *keys = [[[s entity] attributesByName] allKeys];
        NSDictionary *dict1 = [s dictionaryWithValuesForKeys:keys];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
        
        NSString *localId = [[XMPPConnect sharedInstance] getLocalId];
        [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
        [dict setValue:group.group_id forKeyPath:@"jid"];
        [dict setValue:group.group_id forKeyPath:@"tojid"];
        [dict setValue:localId forKeyPath:@"localid"];
        [dict setValue:[NSDate date] forKey:@"sentdate"];
        [dict setValue:@"1" forKey:@"deliver"];
        [dict setValue:@"yes" forKey:@"readstatus"];
        [dict setValue:[Utilities checkNil:group.group_subject] forKey:@"displayname"];

        [dict setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
        [dict setValue:@"1" forKey:@"isgroupchat"];
        [dict setValue:[Utilities checkNil:[s valueForKey:@"fileName"]] forKey:@"fileName"];
        [dict removeObjectForKey:@"file"];
        
        NSString *file_ext = [Utilities checkNil:[dict valueForKey:@"file_ext"]];
        [dict setValue:file_ext forKey:@"file_ext"];

        if(![[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
            [dict removeObjectForKey:@"jsonvalues"];
        }

        
        
        if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
            [dict removeObjectForKey:@"image"];
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
            [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Image"] toPath:[Utilities getFilePath:localId :@"Image"] error:nil];
            
            
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
            [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Video"] toPath:[Utilities getFilePath:localId :@"Video"] error:nil];
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
            [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Audio"] toPath:[Utilities getFilePath:localId :@"Audio"] error:nil];
        }
        else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
            
            
            NSData *dataimage = [s valueForKey:@"image"];
            
            if(dataimage){
               // [dict setValue:[NSString stringWithFormat:@"%@",[dataimage base64Encoded]] forKey:@"image"];
                
            }
            else{
                [dict removeObjectForKey:@"image"];
            }
        }
        
        [dict removeObjectForKey:@"deliverydate"];

        [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:dict incoming:YES];
        [dict removeObjectForKey:@"sentdate"];
        
        if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
            
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
                
                NSData *data = [s valueForKey:@"jsonvalues"];
                [dict setValue:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"jsonvalues"];
                
                NSData *dataimage = [s valueForKey:@"image"];
                
                if(dataimage){
                    [dict setValue:[NSString stringWithFormat:@"%@",[dataimage xmpp_base64Encoded]] forKey:@"image"];
                    
                }
                else{
                    [dict removeObjectForKey:@"image"];
                }
            }
            else{
                [dict setValue:[NSString stringWithFormat:@"%@",[[s valueForKey:@"image"] xmpp_base64Encoded]] forKey:@"image"];
            }
        }
        [[XMPPConnect sharedInstance]messageSendToReceiver:dict];
    }
    }
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:0.5];
}

-(void)forwardMessagesContacts{
    
    for (NSIndexPath *path in  [self.tableViewList indexPathsForSelectedRows]) {
        
        NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
        
        for (NSManagedObject *s in self.arrayObjects) {
            
            NSArray *keys = [[[s entity] attributesByName] allKeys];
            NSDictionary *dict1 = [s dictionaryWithValuesForKeys:keys];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dict1];
            NSString *localId = [[XMPPConnect sharedInstance] getLocalId];
            [dict setValue:[Utilities getSenderId] forKeyPath:@"fromjid"];
            [dict setValue:[user valueForKey:@"chatappid"] forKeyPath:@"jid"];
            [dict setValue:[user valueForKey:@"chatappid"] forKeyPath:@"tojid"];
            [dict setValue:localId forKeyPath:@"localid"];
            [dict setValue:[NSDate date] forKey:@"sentdate"];
            [dict setValue:@"1" forKey:@"deliver"];
            [dict setValue:@"yes" forKey:@"readstatus"];
            [dict setValue:[Utilities checkNil:[user valueForKey:@"name"]] forKey:@"displayname"];
            [dict setValue:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
            [dict setValue:@"0" forKey:@"isgroupchat"];
            [dict setValue:[Utilities checkNil:[s valueForKey:@"fileName"]] forKey:@"fileName"];
            [dict removeObjectForKey:@"file"];
            
            NSString *file_ext = [Utilities checkNil:[dict valueForKey:@"file_ext"]];
            [dict setValue:file_ext forKey:@"file_ext"];
            
            if(![[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
                [dict removeObjectForKey:@"jsonvalues"];
            }
            
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
                [dict removeObjectForKey:@"image"];
            }
            
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
                [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Image"] toPath:[Utilities getFilePath:localId :@"Image"] error:nil];
                
                
            }
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
                [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Video"] toPath:[Utilities getFilePath:localId :@"Video"] error:nil];
            }
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
                [[NSFileManager defaultManager] copyItemAtPath:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Audio"] toPath:[Utilities getFilePath:localId :@"Audio"] error:nil];
            }
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
                
                
                NSData *dataimage = [s valueForKey:@"image"];
                
                if(dataimage){
                    //  [dict setValue:[NSString stringWithFormat:@"%@",[dataimage base64Encoded]] forKey:@"image"];
                    
                }
                else{
                    [dict removeObjectForKey:@"image"];
                }
            }
            [dict removeObjectForKey:@"deliverydate"];
            
            [[ChatStorageDB sharedInstance]saveIncomingAndOutgoingmessages:dict incoming:YES];
            [dict removeObjectForKey:@"sentdate"];
            
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
                
                if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeContact]]){
                    
                    NSData *data = [s valueForKey:@"jsonvalues"];
                    [dict setValue:[NSString stringWithFormat:@"%@",[data xmpp_base64Encoded]] forKey:@"jsonvalues"];
                    
                    NSData *dataimage = [s valueForKey:@"image"];
                    
                    if(dataimage){
                        [dict setValue:[NSString stringWithFormat:@"%@",[dataimage xmpp_base64Encoded]] forKey:@"image"];
                        
                    }
                    else{
                        [dict removeObjectForKey:@"image"];
                    }
                }
                else{
                    [dict setValue:[NSString stringWithFormat:@"%@",[[s valueForKey:@"image"] xmpp_base64Encoded]] forKey:@"image"];
                }
            }
            
            [[XMPPConnect sharedInstance]messageSendToReceiver:dict];
        }
    }
    
    [self performSelector:@selector(hideAlert) withObject:nil afterDelay:0.5];
}

-(void)messageReceivedNotification:(NSNotification*)notification{
    
    [self getUsers];
}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
