//
//  GroupProfileViewController.m
//  TestProject
//
//  Created by Theen on 06/02/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "GroupProfileViewController.h"
#import "ChatStorageDB.h"
#import "ContactDb.h"
#import "AddPeopleViewController.h"
#import "UIImageView+AFNetworking.h"

#import "CSGroupTableViewCell.h"
#import "WebService.h"

#import "SVProgressHUD.h"
#import "Constants.h"
#import "MessgaeTypeConstant.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>

#import "ProfileViewController.h"
#import "SDWebImageManager.h"

#define MAX_LENGTH_TEXT 25

@interface GroupProfileViewController ()

@end

@implementation GroupProfileViewController

@synthesize arrayRecords;

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
    
    self.title = @"Group Info";
     self.stringOwnerId = @"";
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];

    [self.view endEditing:YES];

    [tableViewList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/YYYY  hh:mm a"];
    self.arrayRecords = [[NSMutableArray alloc]init];
    
    [self setInitalSetup];
    
    [self setCountLabel];


    [tableViewList setBackgroundColor:[UIColor clearColor]];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}



- (void)setInitalSetup{
    
    [self.arrayRecords removeAllObjects];
    
    self.getGroupStatus = [[ChatStorageDB sharedInstance] isGroupActive:self.stringGroupId];
    
    NSArray *arrayDetails = [[ChatStorageDB sharedInstance]getGroupDetails:self.stringGroupId];
    if(arrayDetails){
        NSManagedObject *object = [arrayDetails objectAtIndex:0];
        self.stringOwnerId      = [object valueForKey:@"owner_jid"];
        
        if ([self.stringOwnerId isEqualToString:[Utilities getSenderId]]) {
            labelCreatedBy.text = [NSString stringWithFormat:@"Created by %@",([[Utilities getSenderNickname] isEqualToString:@""] ? self.stringOwnerId : [Utilities getSenderNickname])];
            
        }
        else{
            labelCreatedBy.text = [NSString stringWithFormat:@"Created by %@",[[ContactDb sharedInstance]validateUserName:[object valueForKey:@"owner_jid"]].capitalizedString];
            
        }
       // created_date
        //Created 21/01/2015 at 23:15 pm.
        labelCreatedAt.text = [NSString stringWithFormat:@"Created %@",[dateFormatter stringFromDate:[object valueForKey:@"created_date"]]];
        
        
    }
    
    imageGroup.layer.cornerRadius = 30;
    imageGroup.clipsToBounds = YES;

    
    NSArray *array = [[ChatStorageDB sharedInstance]getGroupMembers:self.stringGroupId];
    
    [self.arrayRecords addObjectsFromArray:[[ChatStorageDB sharedInstance]getGroupMembers:self.stringGroupId]];
    
  
    
//    for (int i=0;i<2;i++) {
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        [dict setObject:[NSString stringWithFormat:@"Name_%d",i] forKey:@"Name"];
//        [dict setObject:[NSString stringWithFormat:@"Status_%d",i] forKey:@"Status"];
//        [self.arrayRecords addObject:dict];
//    }
//    [self.arrayRecords addObject:@""];
//    [self.arrayRecords addObject:@"Email Chat"];
//    [self.arrayRecords addObject:@""];
//    [self.arrayRecords addObject:@"Clear Chat"];
//    [self.arrayRecords addObject:@"Exit Group"];
    
    [imageGroup setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,self.stringGroupId]] placeholderImage:[UIImage imageNamed:@"ment"]];
    
    textGroupName.text = [Utilities checkNil:self.stringGroupName];
    
    participantsCount = [NSString stringWithFormat:@"Participants %lu of 50",(unsigned long)array.count];
    
    [tableViewList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    
    NSInteger count = 0;
    
    switch (section) {
        case 0:
            count = 2;
            break;
        case 1:{
            if([self.arrayRecords count]<50){
                
                if ([self.stringOwnerId isEqualToString:[Utilities getSenderId]]&&self.getGroupStatus==YES) {
                    count = self.arrayRecords.count+1;
                    break;
                }
            }
            count = self.arrayRecords.count;
            break;
        }
        case 2:
            count = 1;
            break;
        case 3:
            count = 2;
            break;

        default:
            break;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section!=1) {
        return 44;
    }
    
    if(indexPath.row == self.arrayRecords.count)
        return 44;
    
    return 56;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex==1) {
        return [NSString stringWithFormat:@"Participants %lu of %@",(unsigned long)self.arrayRecords.count,@"50"];
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"groupCell";
    
    // Similar to UITableViewCell, but
    CSGroupTableViewCell * cell = (CSGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CSGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
   // id object = [self.arrayRecords objectAtIndex:indexPath.row];
    
    if (indexPath.section != 1) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
       // cell.labelTitle.text = [self.arrayRecords objectAtIndex:indexPath.row];
        cell.descriptionLabel.hidden = YES;
        cell.iconImageView.hidden = YES;
        cell.btnWings.hidden = YES;
        
        [cell.titleLabel setFrame:CGRectMake(15, 0, cell.titleLabel.frame.size.width, 44)];
        
        cell.titleLabel.textAlignment = NSTextAlignmentLeft;
        cell.btnWings.titleLabel.textColor = [UIColor lightGrayColor];

        if (indexPath.section==3) {
            if (indexPath.row==0) {
                cell.titleLabel.text  = @"Clear Chat";

            }
            else{
                cell.titleLabel.text  = @"Exit Group";

            }
            [cell.titleLabel setFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 44)];
            cell.titleLabel.textAlignment = NSTextAlignmentCenter;
            cell.titleLabel.textColor  = [UIColor redColor];
        }
        else if (indexPath.section==2) {
            cell.titleLabel.text  = @"Email Chat";

             cell.titleLabel.textColor  = [UIColor blueColor];
        }
        else if (indexPath.section==0) {

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.btnWings.hidden = NO;
            
            if (indexPath.row==0) {
                cell.titleLabel.text  = @"View All Media";
                NSArray *array =[[ChatStorageDB sharedInstance] getMediaFilesForGroups:self.stringGroupId islocation:NO];
              
                NSString * countStr = (array.count ==0 ? @"None" : [NSString stringWithFormat:@"%lu",(unsigned long)array.count]);
                cell.btnWings.titleLabel.textColor = [UIColor lightGrayColor];
                [cell.btnWings setTitle:countStr forState:UIControlStateNormal];
            }
            else{
                cell.titleLabel.text  = @"Recent Locations";

                 NSArray *array =[[ChatStorageDB sharedInstance] getMediaFilesForGroups:self.stringGroupId islocation:YES];
                
                NSString * countStr = (array.count ==0 ? @"None" : [NSString stringWithFormat:@"%lu",(unsigned long)array.count]);
                cell.btnWings.titleLabel.textColor = [UIColor lightGrayColor];
                [cell.btnWings setTitle:countStr forState:UIControlStateNormal];
            }
        }
    }
    else {
        
//        Ameen Worked here.
        
        cell.descriptionLabel.hidden = NO;
        
        [cell.titleLabel setFrame:CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y+5, cell.titleLabel.frame.size.width, cell.contentView.frame.size.height - 30)];
        cell.iconImageView.hidden = NO;
        
        cell.iconImageView.layer.cornerRadius = 25;
        cell.iconImageView.clipsToBounds = YES;
        cell.btnWings.hidden = YES;
        
        if(indexPath.row==self.arrayRecords.count){
            cell.titleLabel.text = @"Add Participant";
            cell.descriptionLabel.text = @"";
            cell.iconImageView.hidden = YES;
            [cell.titleLabel setFrame:CGRectMake(imageGroup.frame.origin.x,0, cell.titleLabel.frame.size.width, 50)];
        }
        else{
            NSDictionary *dict = [self.arrayRecords objectAtIndex:indexPath.row];
            NSArray *array = [[ContactDb sharedInstance]getUserDetails:[dict valueForKey:@"member_jid"]];
            if (array) {
                NSManagedObject *object =[array objectAtIndex:0];
                
                if([[dict valueForKey:@"member_jid"] isEqualToString:[Utilities getSenderId]]){
                    cell.titleLabel.text = @"You";
                    
                }
                else{
                    cell.titleLabel.text = [Utilities checkNil:[object valueForKey:@"name"]];
                }
            
                cell.descriptionLabel.text = [Utilities checkNil:[object valueForKey:@"status_message"]];
                
                if([cell.descriptionLabel.text isEqualToString:@""]){
                    cell.descriptionLabel.text = @"I'm Using Wing";
                }
                
                if([self.stringOwnerId isEqualToString:[dict valueForKey:@"member_jid"]]){
                    cell.btnWings.hidden = NO;
                    [cell.btnWings setTitle:@"~admin" forState:UIControlStateNormal];
                    cell.btnWings.titleLabel.textColor = [UIColor redColor];
                }
                
            }
            else{
                if([[dict valueForKey:@"member_jid"] isEqualToString:[Utilities getSenderId]]){
                    cell.titleLabel.text = @"You";
                    cell.descriptionLabel.text = [Utilities getSenderStatus];
                }
                else{
                    cell.titleLabel.text = [dict valueForKey:@"member_jid"];
                    cell.descriptionLabel.text = @"";
                }
                
                if([self.stringOwnerId isEqualToString:[dict valueForKey:@"member_jid"]]){
                    cell.btnWings.hidden = NO;
                    [cell.btnWings setTitle:@"~admin" forState:UIControlStateNormal];
                    cell.btnWings.titleLabel.textColor = [UIColor redColor];
                }
            }
            
            [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[dict valueForKey:@"member_jid"]]] placeholderImage:[UIImage imageNamed:@"ment"]];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==1){
        if(indexPath.row==self.arrayRecords.count){
            [self addParticipants];
            return;
        }
        path = indexPath;
        NSDictionary *dict = [self.arrayRecords objectAtIndex:indexPath.row];
        NSString *strName = [dict valueForKey:@"member_jid"];
        
        if([strName isEqualToString:[Utilities getSenderId]])
            return;
        
        NSArray *array = [[ContactDb sharedInstance]getUserDetails:[dict valueForKey:@"member_jid"]];
        if (array) {
            NSManagedObject *object =[array objectAtIndex:0];
            strName = [Utilities checkNil:[object valueForKey:@"name"]];
        }

        NSString *strCall = [NSString stringWithFormat:@"Call %@",strName];
        NSString *strMessage = [NSString stringWithFormat:@"Message %@",strName];
        NSString *strRemove = [NSString stringWithFormat:@"Remove %@",strName];

        UIActionSheet *sheet;
        
        if ([self.stringOwnerId isEqualToString:[Utilities getSenderId]]&&self.getGroupStatus==YES) {
            
            sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",strCall,strMessage,strRemove, nil];

        }
        else{
            sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Info",strCall,strMessage, nil];

        }
        sheet.tag = 2;
        [sheet showInView:self.view];
    }
    else{
        
        if(indexPath.section==0){
            if(indexPath.row==0){
                [self viewMedia];
            }
            else{
                [self viewlocations];
            }
        }
        else if(indexPath.section==2){
            if(indexPath.row==0){
                [self emailChat];
            }

        }
        else if(indexPath.section==3){
            if(indexPath.row==0){
                [self clearChat];
            }
            else{
                [self exitChat];
            }

        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1){
        if ([self.stringOwnerId isEqualToString:[Utilities getSenderId]]&&self.getGroupStatus==YES) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 1)
        return YES;
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        path = indexPath;
        [self removeParticipant];
    }
}

- (void)removeParticipant{
    
    if([[XMPPConnect sharedInstance]getNetworkStatus]==NO){
        [Utilities alertViewFunction:@"" message:@"Unable to connect to remote server. Please try again"];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSDictionary *dict = [self.arrayRecords objectAtIndex:path.row];

    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"removepartcipant" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:self.stringGroupId forKey:@"group_id"];
    [dic setObject:[dict valueForKey:@"member_jid"] forKey:@"member_jid"];

    [WebService groupChatUpdates:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                
                
                [[ChatStorageDB sharedInstance]removeParticpant:self.stringGroupId member_id:[dict valueForKey:@"member_jid"]];
                
                [self setInitalSetup];
                
                [[XMPPConnect sharedInstance]sendGroupNotification:dic];


            }
        }
        
    }];
}


#pragma mark Add Participants

- (void)addParticipants{
    AddPeopleViewController *addPeople = [[AddPeopleViewController alloc]init];
    addPeople.delegate = (id<addPeopleDelegate>)self;
    addPeople.pageType = @"ADD";
    [[self navigationController]pushViewController:addPeople animated:YES];
}

- (void)addUsers:(NSMutableArray*)array{
    
    if(array.count>0){
        for (NSString *string in array) {
            [[XMPPConnect sharedInstance]addRoaster:string];
            
            XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms objectForKey:self.stringGroupId];
            if(room){
                [room inviteUser:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",string] domain:HOSTNAME1 resource:UNIQUERESOURCE] withMessage:textGroupName.text];
            }
            NSString *strname = [[ContactDb sharedInstance]validateUserName:string];
            
            //else{
            [[ChatStorageDB sharedInstance] saveAndInviteMembers:self.stringGroupId memeberid:string invite:YES group_subject:textGroupName.text member_name:strname member_nick_name:strname];
            
            [self invitetoGroup:[NSString stringWithFormat:@"%@",string]];

        }
        [self setInitalSetup];
        
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showWithStatus:@"Please wait..."];
        
       // NSDictionary *dict = [self.arrayRecords objectAtIndex:path.row];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:@"addpartcipant" forKey:@"cmd"];
        [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
        [dic setObject:self.stringGroupId forKey:@"group_id"];
        [dic setObject:[NSString stringWithFormat:@"%@",[array componentsJoinedByString:@","]] forKey:@"members_id"];
        [dic setObject:textGroupName.text forKey:@"group_subject"];

        [[XMPPConnect sharedInstance]sendGroupNotification:dic];
        
        [WebService groupChatUpdates:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
            
            [SVProgressHUD dismiss];
            
            if(responseObject){
                if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                    
                    
                  //  [[ChatStorageDB sharedInstance]removeParticpant:self.stringGroupId member_id:[dict valueForKey:@"member_jid"]];
                    
                    [self setInitalSetup];
                    
                }
            }
            
        }];
    }
    
}

- (void)invitetoGroup:(NSString*)member_id{
    
    [[XMPPConnect sharedInstance]addRoaster:member_id];
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"groupinvite" forKey:@"cmd"];
    [dict setObject:[Utilities getSenderId] forKey:@"owner_id"];
    [dict setObject:member_id forKey:@"tojid"];
    [dict setObject:self.stringGroupId forKey:@"group_id"];
    [dict setObject:textGroupName.text forKey:@"group_subject"];
    [[XMPPConnect sharedInstance]groupInviteSendToReciever:dict];
    
}


#pragma mark View Media & Locations

- (void)viewMedia{
    
    NSArray *array =[[ChatStorageDB sharedInstance] getMediaFilesForGroups:self.stringGroupId islocation:NO];

    if(array.count > 0){
        
        int currentcount = 0;
        int presentationIndex = 0;
        NSMutableArray *galleryDataSource = [[NSMutableArray alloc]init];
        
        if(array.count > 0){
            
            for (NSManagedObject *s in array) {
                NSString *type = @"Video";
                int typee = MHGalleryTypeVideo;
                switch ([[s valueForKey:@"messagetype"] integerValue]) {
                    case MessageTypeImage:{
                        type = @"Image";
                        typee = MHGalleryTypeImage;
                        break;
                    }
                    default:
                        break;
                }
                
                NSLog(@"%@",[Utilities getFilePath:[s valueForKey:@"localid"] :type]);
                
                // [NSURL fileURLWithPath:[Utilities getFilePath:[s valueForKey:@"localid"] :type]];
                
                MHGalleryItem *landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:[Utilities getFilePath:[s valueForKey:@"localid"] :type]]]
                                                                  galleryType:typee];
                [galleryDataSource addObject:landschaft1];
                
                currentcount++;
                
            }
        }
        else{
            return;
        }
        
        MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeOverView];
        gallery.galleryItems = galleryDataSource;
        gallery.presentingFromImageView = nil;
        gallery.presentationIndex = presentationIndex;
        // gallery.UICustomization.hideShare = YES;
        //  gallery.galleryDelegate = self;
        //  gallery.dataSource = self;
        __weak MHGalleryController *blockGallery = gallery;
        
        gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
            if (viewMode == MHGalleryViewModeOverView) {
                [blockGallery dismissViewControllerAnimated:YES completion:^{
                    [self setNeedsStatusBarAppearanceUpdate];
                }];
            }else{
                //  CGRect cellFrame  = [[self collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
                //                 [collectionView scrollRectToVisible:cellFrame
                //                                            animated:NO];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //   [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
                    //  [collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                    
                    // MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[collectionView cellForItemAtIndexPath:newIndexPath];
                    
                    [blockGallery dismissViewControllerAnimated:YES dismissImageView:nil completion:^{
                        
                        [self setNeedsStatusBarAppearanceUpdate];
                        
                        //                    MPMoviePlayerController *player = interactiveTransition.moviePlayer;
                        //
                        //                    player.controlStyle = MPMovieControlStyleEmbedded;
                        //                    player.view.frame = cell.bounds;
                        //                    player.scalingMode = MPMovieScalingModeAspectFill;
                        //                    [cell.contentView addSubview:player.view];
                    }];
                });
            }
        };
        
        [self presentMHGalleryController:gallery animated:YES completion:nil];
        
    }
}

- (void)viewlocations{
    
}

#pragma mark Clear Chat

- (void)clearChat{
    [[ChatStorageDB sharedInstance]deleteChatHistoryBetweenGroups:[Utilities getSenderId] receiver:self.stringGroupId];
    [[ChatStorageDB sharedInstance] updateChatSession:self.stringGroupId isgroupchat:@"1"];


}

#pragma mark Email Chat


- (void)emailChat{
    actionSheetEmailChat = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Include Attachments",@"Without Attachements", nil];
    actionSheetEmailChat.tag = 3;
    [actionSheetEmailChat showInView:self.view];

}

- (void)createEmailForChat:(BOOL)includeFiles{
    NSMutableString *string = [[NSMutableString alloc]init];
    NSArray *array  =     [[ChatStorageDB sharedInstance]getChatHistoryBetweenUsers:[Utilities getSenderId] receiver:self.stringGroupId];
    
    //    NSMutableArray *arrayVcard = [[NSMutableArray alloc]init];
    //    NSMutableArray *arrayImageFiles = [[NSMutableArray alloc]init];
    //    NSMutableArray *arrayVideoFiles = [[NSMutableArray alloc]init];
    
    
    NSDateFormatter *dateforma = [[NSDateFormatter alloc]init];
    [dateforma setDateFormat:@"dd MMM YYYY hh:mm:ss a"];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    [picker setSubject:[NSString stringWithFormat:@"WING Chat with %@",textGroupName.text.capitalizedString]];
    
    
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
        [string writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"] atomically:YES];
        [picker addAttachmentData:[NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatHistory.txt"]] mimeType:@"text/txt" fileName:@"ChatHistory.txt"];
    }
    [picker setMessageBody:[NSString stringWithFormat:@"WING Chat: %@.txt",textGroupName.text] isHTML:NO];
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

#pragma mark Exit Group Chat

- (void)exitGroupChat{
    if([[XMPPConnect sharedInstance]getNetworkStatus]==NO){
        [Utilities alertViewFunction:@"" message:@"Unable to connect to remote server. Please try again"];
        return;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"exitgroup" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:self.stringGroupId forKey:@"group_id"];
    
    [WebService groupChatUpdates:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms valueForKey:self.stringGroupId];
                if(room){
                    [room leaveRoom];
                }
                
                [[ChatStorageDB sharedInstance]leaveFromGroup:self.stringGroupId];
                
                [[XMPPConnect sharedInstance]sendGroupNotification:dic];

            }
        }
        
    }];
    
}


- (void)exitChat{
    [self exitGroupChat];
}

#pragma mark Image Update

- (IBAction)actionEdit:(id)sender{
    
    [textGroupName resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Choose" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from Gallery",@"Take from Camera", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if(actionSheet.tag==1){
        if(buttonIndex==0){
            [self gallery:self];
        }
        else if(buttonIndex==1){
            [self camera:self];
        }
    }
   else if(actionSheet.tag==2){
       switch (buttonIndex) {
           case 0:
               [self gotoInfo];
               break;
           case 1:
               [self gotoCall];
               break;
           case 2:
               [self gotoMessage];
               break;
           case 3:
               [self removeParticipant];
               break;
           default:
               break;
       }
    }
   else if(actionSheet.tag==3){
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


- (void)gotoInfo{
    NSDictionary *dict = [self.arrayRecords objectAtIndex:path.row];
    NSString *strId = [dict valueForKey:@"member_jid"];
    NSString *strName = [dict valueForKey:@"member_jid"];

    NSArray *array = [[ContactDb sharedInstance]getUserDetails:[dict valueForKey:@"member_jid"]];
    if (array) {
        NSManagedObject *object =[array objectAtIndex:0];
        strName= [Utilities checkNil:[object valueForKey:@"name"]];
    }

    ProfileViewController *profile = [[ProfileViewController alloc]init];
    profile.receiver_id = strId;
    profile.receiver_name = strName;
    profile.receiver_nick_name = strName;
    
    profile.pageFromChat = NO;
    [[self navigationController]pushViewController:profile animated:YES];

}

- (void)gotoCall{
    NSDictionary *dict = [self.arrayRecords objectAtIndex:path.row];
    NSString *strName = [dict valueForKey:@"member_jid"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",strName]]];

}

- (void)gotoMessage{
    
}

-(void)gallery:(id)sender
{
    UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
    imagepic.delegate=self;
    imagepic.allowsEditing=YES;
    imagepic.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepic animated:YES completion:nil];
    // [self presentViewController:imagepic animated:YES completion:nil];
    
}

-(void)camera:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
        
        imagepic.delegate=self;
        imagepic.allowsEditing=YES;
        imagepic.sourceType=UIImagePickerControllerSourceTypeCamera;
        
        CGRect overlayRect = imagepic.cameraOverlayView.frame;
        overlayRect.size.width=overlayRect.size.width-100.0f;
        overlayRect.size.height=overlayRect.size.height-100.0f;
        [imagepic.cameraOverlayView setFrame:overlayRect];
        [self presentViewController:imagepic animated:YES completion:nil];
        
    }
    else
    {
        //  [Utilities alertViewFunction:@"" message:@"This device is not supported by camera"];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *imgnew=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    imageGroup.image = imgnew;
    
    [UIImagePNGRepresentation(imgnew) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/groupchat.png"] atomically:YES];

    self.stringUpdateType = @"grouppicture";

    NSString *group_subject = textGroupName.text;
    if([[Utilities checkNil:group_subject] isEqualToString:@""]){
        group_subject = self.stringGroupName;
    }
    [self updateGroupInfo:group_subject];

    
}

- (IBAction)textChange:(id)sender{
    UITextField *txt = (UITextField*)sender;
    
    //    if([countLabel.text isEqualToString:@"0"])
    //        return;
    
    if(txt.text==nil||[txt.text isEqualToString:@""]){
        labelCount.text = @"25";
        return;
    }
    [self setCountLabel];
    //   int remaining = countLabel.text.intValue-
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([string isEqualToString:@""]){
      //  [self setCountLabel];

        return YES;
    }
    
    
    if([labelCount.text isEqualToString:@"0"])
        return NO;
    
    [self setCountLabel];
    
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if([textField.text isEqualToString:@""]){
        [Utilities alertViewFunction:@"" message:@"Please enter group name"];
        
        return NO;

    }
    
    self.stringUpdateType = @"groupname";
    
    [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] error:nil];

    
    [self updateGroupInfo:textField.text];

    
    [textField resignFirstResponder];
    return YES;
}

- (void)setCountLabel{
    int currentlength = textGroupName.text.length;
    int total = MAX_LENGTH_TEXT - currentlength;
    labelCount.text = [NSString stringWithFormat:@"%d",total];
}

#pragma mark Update Group Name

- (void)updateGroupInfo:(NSString*)group_chat{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updategroupname" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[Utilities getReceiverId] forKey:@"group_id"];
    [dic setObject:[Utilities  encodingBase64:textGroupName.text] forKey:@"group_subject"];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    
    [WebService createGroupChat:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [SVProgressHUD dismiss];
        
        if(responseObject){
            
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success:) withObject:group_chat waitUntilDone:YES];
                
                [[XMPPConnect sharedInstance]sendGroupNotification:dic];

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

- (void)success:(NSString*)group_subject{
    
    [[ChatStorageDB sharedInstance]updateGroupName:self.stringGroupId group_subject:group_subject];
    
    NSMutableDictionary *dictInput = [[NSMutableDictionary alloc]init];
    [dictInput setObject:group_subject forKey:@"updatename"];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"updateGroupName" object:nil userInfo:dictInput];
    
    if([self.stringUpdateType isEqualToString:@"grouppicture"]){
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,self.stringGroupId]];
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:[NSString stringWithFormat:@"%@%@.png",IMGURL,self.stringGroupId]];
        [[SDWebImageManager sharedManager].imageCache clearMemory];
        [[SDWebImageManager sharedManager].imageCache clearDisk];
    }
}

- (void)updateType{
    
    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:self.stringGroupId forKey:@"tojid"];
    [dict setObject:textGroupName.text forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeText] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    
    if([self.stringUpdateType isEqualToString:@"grouppicture"]){
        [dict setObject:@"changed this group'd icon" forKey:@"text"];
    }
    else if([self.stringUpdateType isEqualToString:@""]){
        [dict setObject:@"changed this group's subject" forKey:@"text"];
    }
    else if([self.stringUpdateType isEqualToString:@"membersremoved"]){
        [dict setObject:@"removed" forKey:@"text"];
    }
    else if([self.stringUpdateType isEqualToString:@"membersadded"]){
        [dict setObject:@"added" forKey:@"text"];
    }
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:self.stringGroupId forKey:@"jid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setObject:@"1" forKey:@"isgroupchat"];
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
