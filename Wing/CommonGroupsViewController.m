//
//  CommonGroupsViewController.m
//  ChatApp
//
//  Created by Theen on 19/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "CommonGroupsViewController.h"
#import "MailTableCell.h"
#import "MGSwipeButton.h"
#import "Message.h"
#import "ChatStorageDB.h"
#import "Passcode.h"
#import "MessgaeTypeConstant.h"
#import "UIImageView+AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "ContactDb.h"
#import "SVProgressHUD.h"
#import "WebService.h"

@interface CommonGroupsViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic,retain)  NSString *searchString;

@end

@implementation CommonGroupsViewController
@synthesize stringUserid;

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
    self.arraymessages = [[NSMutableArray alloc]init];
    self.arraytempmessages =[[NSMutableArray alloc]init];
    self.title = @"Groups";

    self.searchString  = @"";
    
    [self.tableViewList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg.png"]]];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    app.currentRootView = self;

    self.navigationItem.rightBarButtonItem = self.editBtn;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageReceivedNotification:)
                                                 name:@"messageReceived"
                                               object:nil];
    

    
    [self getGroups];

}
- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)tabelViewTapped:(UIGestureRecognizer*)sender{
    [self.searchBarTop resignFirstResponder];
    
    NSIndexPath *indexPath = [self.tableViewList indexPathForRowAtPoint:[sender locationInView:self.tableViewList]];
    
    if(indexPath){
        [self.tableViewList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        // If you have custom logic in table view delegate method, also invoke this method too
        [self tableView:self.tableViewList didSelectRowAtIndexPath:indexPath];

    }
}

- (void)getGroups{
    [self.arraymessages removeAllObjects];
    [self.arraymessages addObjectsFromArray:[[ChatStorageDB sharedInstance] getCommonGroupsForUsers:self.stringUserid search:[Utilities checkNil:self.searchString]]];
    [self.tableViewList reloadData];
    return;

}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{              // Default is 1 if not implemented
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arraymessages.count;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    if(indexPath.section==0){
    //        return cellProfile;
    //    }
    
    static NSString * identifier = @"MailCell";
    MailTableCell * tempcell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!tempcell) {
        tempcell = [[MailTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
//    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabelViewTapped:)];
//    gesture1.cancelsTouchesInView = YES;
//    [tempcell addGestureRecognizer:gesture1];


    tempcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    tempcell.delegate = (id<MGSwipeTableCellDelegate>)self;

    [tempcell setBackgroundColor:[UIColor clearColor]];
    [tempcell.contentView setBackgroundColor:[UIColor clearColor]];
    
    NSDictionary *s1 = [self.arraymessages objectAtIndex:indexPath.row];
    [tempcell.imageUser setHidden:NO];
    [tempcell.lblStatus setHidden:NO];
    tempcell.labelIcon.hidden = YES;
    
    NSArray *array = [[ChatStorageDB sharedInstance] getChatHistoryBetweenGroups:[Utilities getSenderId] receiver:[s1 valueForKey:@"group_id"]];
    
    
    [tempcell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[s1 valueForKey:@"group_id"]]] placeholderImage:[UIImage imageNamed:@"ment"]];
    
    if(array.count==0){
          tempcell.lblName.text = [[ChatStorageDB sharedInstance]validateGroupName:[s1 valueForKey:@"group_id"]].capitalizedString;
        return tempcell;
    }
    
    
    Message *s = [array lastObject];
    
    //  Message *s = [self.fetchRequestController objectAtIndexPath:indexPath];
    
    tempcell.lblName.text = s.displayname;
    
    [tempcell setBackgroundColor:[UIColor clearColor]];

    [tempcell.lblTime setText:[Utilities relativeDateStringForDate:[s valueForKey:@"sentdate"]]];
    
    
    tempcell.btnBadge.hidden = YES;
    
    int count = [[ChatStorageDB sharedInstance]getReadStatusBetweenUsers:s.jid];
    
    if(count > 0){
        
        tempcell.btnBadge.hidden = NO;
        [tempcell.btnBadge setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];
    }
    
    
    if([s.isgroupchat isEqualToString:@"1"]){
        
        tempcell.lblName.text = [[ChatStorageDB sharedInstance]validateGroupName:s.jid].capitalizedString;
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
            [tempcell setFrame:CGRectMake(tempcell.labelIcon.frame.origin.x,tempcell.labelIcon.frame.origin.y, 18, 18)];
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
        default:
            break;
    }
    
    return tempcell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld:%ld",(long)indexPath.row,(long)indexPath.section);
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view class] == self.tableViewList.class){
        return NO;
    }
    return YES;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}


-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
    NSLog(@"Swipe state: %@ ::: Gesture: %@", str, gestureIsActive ? @"Active" : @"Ended");
}


-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    
    //__weak ChatMainViewControllerNew * me = self;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
    }
    else {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage imageNamed:@"more"] backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            return YES;
        }];
        MGSwipeButton * flag = [MGSwipeButton buttonWithTitle:@""  icon:[UIImage imageNamed:@"hide"] backgroundColor:[UIColor colorWithRed:1.0 green:149/255.0 blue:0.05 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {

            [cell refreshContentView]; //needed to refresh cell contents while swipping
            return YES;
        }];
        
        return @[trash, flag];
    }
    
    return nil;
    
}


- (void)reloadTable{
    [self getGroups];
    [self.tableViewList reloadData];
}
-(void)messageReceivedNotification:(NSNotification*)notification{
    
    [self getGroups];
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion{
    
    
    switch (index) {
        case 0:
            [self actioMore:cell];
            
            break;
        case 1:
            [self actioHide:cell];
            
            break;
            
        default:
            break;
    }
    
    NSLog(@"%ld",(long)index);;
    
    return NO;
}



- (void)actioHide:(MGSwipeTableCell*)cell{
    __weak CommonGroupsViewController * me = self;
    NSIndexPath * indexPath = [me.tableViewList indexPathForCell:cell];
    
    indexPathCommon = indexPath;
    
    //  NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:indexPath.section-1];
    // Message *s = [self.fetchRequestController objectAtIndexPath:indexPath];
    
    NSDictionary *s1 = [self.arraymessages objectAtIndex:indexPath.row];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [app actioHideOrShow:[s1 valueForKey:@"group_id"] viewcontrol:self isgroupchat:[s1 valueForKey:@"isgroupchat"]];
    return;
}

- (void)passcodeSucceded{
    NSLog(@"success");
}


- (void)actioMore:(MGSwipeTableCell*)cell{
    __weak CommonGroupsViewController *me = self;
    NSIndexPath * indexPath = [me.tableViewList indexPathForCell:cell];

    indexPathCommon  = indexPath;

    actionSheetMore1 = [[UIActionSheet alloc]initWithTitle:@"More" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Group Info",@"Exit Group",@"Email Chat",@"Delete This Conversation",@"Clear All Conversation", nil];
    [actionSheetMore1 showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if(actionSheet==actionSheetMore1){
        if(buttonIndex==0){
            [self groupInfo];
        }
        else if(buttonIndex==1){
            [self exitGroupChat];
        }

        else if(buttonIndex==2){
            [self emailChat];
        }

        else if(buttonIndex==3){
            [self deleteSingleConversation];
        }
        else if(buttonIndex==4){
            [self deleteAllConevrsations];
        }
    }
    
    else if(actionSheet==actionSheetEmailChat){
        if(buttonIndex==0){
            [self createEmailForChat:YES];
        }
        else if(buttonIndex==1){
            [self createEmailForChat:NO];
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


- (void)createEmailForChat:(BOOL)includeFiles{
    
    
    NSDictionary *s1 = [self.arraymessages objectAtIndex:indexPathCommon.row];
    NSArray *array = [[ChatStorageDB sharedInstance] getChatHistoryBetweenGroups:[Utilities getSenderId] receiver:[s1 valueForKey:@"group_id"]];

    NSMutableString *string = [[NSMutableString alloc]init];
   NSString *strname = [Utilities checkNil:[[ChatStorageDB sharedInstance]validateGroupName:[s1 valueForKey:@"group_id"]]];

    NSDateFormatter *dateforma = [[NSDateFormatter alloc]init];
    [dateforma setDateFormat:@"dd MMM YYYY hh:mm:ss a"];
    
    MFMailComposeViewController * picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    [picker setSubject:[NSString stringWithFormat:@"WING Chat with %@",strname.capitalizedString]];
    
    
    for (NSManagedObject *s in array) {
        
        if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]||[[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeLocation]]){
            if([string isEqualToString:@""]){
                [string appendString:@"\n"];
            }
            
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeText]]){
                [string appendString:[NSString stringWithFormat:@"%@: %@: %@",[dateforma stringFromDate:[s valueForKey:@"sentdate"]],[[ContactDb sharedInstance]validateUserName:[s valueForKey:@"jid"]].capitalizedString,[s valueForKey:@"text"]]];
            }
            else{
                [string appendString:[NSString stringWithFormat:@"%@: %@: https://maps.google.com/?q=%@",[dateforma stringFromDate:[s valueForKey:@"sentdate"]],[[ContactDb sharedInstance]validateUserName:[s valueForKey:@"jid"]].capitalizedString,[s valueForKey:@"text"]]];
                
            }
            
            
            
        }
        
        if(includeFiles==YES){
            if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
                [picker addAttachmentData:[NSData dataWithContentsOfFile:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Image"]] mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",[s valueForKey:@"localid"]]];
            }
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
                [picker addAttachmentData:[NSData dataWithContentsOfFile:[Utilities getFilePath:[s valueForKey:@"localid"] :@"Video"]] mimeType:@"video/MOV" fileName:[NSString stringWithFormat:@"%@.MOV",[s valueForKey:@"localid"]]];
            }
            
            else if([[s valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio]]){
                [picker addAttachmentData:[NSData dataWithContentsOfFile:[Utilities getAudioFilePath:[s valueForKey:@"localid"]]] mimeType:@"audio/caf" fileName:[NSString stringWithFormat:@"%@.caf",[s valueForKey:@"localid"]]];
            }
        }

    }
    if(![string isEqualToString:@""]){
        [string writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"] atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];

       // [string writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"] atomically:YES];
        [picker addAttachmentData:[NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"]] mimeType:@"text/txt" fileName:@"ChatHistory.txt"];
    }
    [picker setMessageBody:[NSString stringWithFormat:@"WING Chat: %@.txt",strname] isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)groupInfo{
    
}

- (void)exitGroupChat{
    
    if([[XMPPConnect sharedInstance]getNetworkStatus]==NO){
        [Utilities alertViewFunction:@"" message:@"Unable to connect to remote server. Please try again"];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSDictionary *messagess1 = [self.arraymessages objectAtIndex:indexPathCommon.row];
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"exitgroup" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[messagess1 valueForKey:@"jid"] forKey:@"group_id"];
    
    [WebService groupChatUpdates:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms valueForKey:[messagess1 valueForKey:@"jid"]];
                if(room){
                    [room leaveRoom];
                }
                
                [[ChatStorageDB sharedInstance]leaveFromGroup:[messagess1 valueForKey:@"jid"]];
                
                [[XMPPConnect sharedInstance]sendGroupNotification:dic];

            }
        }
        
    }];

    
//    NSDictionary *messagess1 = [self.arraymessages objectAtIndex:indexPathCommon.row];
//
//    XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms objectForKey:[messagess1 valueForKey:@"group_id"]];
//    if(room){
//        [room leaveRoom];
//    }
//
//    [[ChatStorageDB sharedInstance]leaveFromGroup:[messagess1 valueForKey:@"jid"]];
    

}


- (void)emailChat{
    actionSheetEmailChat = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Include Attachments",@"Without Attachements", nil];
    [actionSheetEmailChat showInView:self.view];

}


- (void)deleteSingleConversation{
    NSDictionary *messagess1 = [self.arraymessages objectAtIndex:indexPathCommon.row];
    
    NSArray *array = [[ChatStorageDB sharedInstance] getChatHistoryBetweenGroups:[Utilities getSenderId] receiver:[messagess1 valueForKey:@"group_id"]];
    Message *messagess = [array lastObject];
    
    [[ChatStorageDB sharedInstance]deleteChatHistoryBetweenGroups:[Utilities getSenderId] receiver:messagess.jid];

    [self getGroups];
}

- (void)deleteAllConevrsations{
    [[ChatStorageDB sharedInstance] deleteAllDB:@"Message"];
    [self getGroups];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.searchString = searchBar.text;
    [self getGroups];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}
// called when keyboard search button pressed

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
  
    [tableView setBackgroundColor:[UIColor whiteColor]];
    NSLog(@"show");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchString =@"";
    
    [self getGroups];
}// called

-(void)movePanel:(id)sender{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
