//
//  ProfileViewController.m
//  ChatApp
//
//  Created by theen on 06/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "ProfileViewController.h"
#import "ChatStorageDB.h"
#import "CommonGroupsViewController.h"
#import "DemoMessagesViewController.h"
#import "ContactDb.h"
#import "UIImageView+AFNetworking.h"
#import "MessgaeTypeConstant.h"
#import "ProfilePhotoViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize pageFromChat,receiver_id;

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
    
    self.checkPage = NO;
    imageUser.layer.cornerRadius = imageUser.frame.size.width / 2;
    imageUser.clipsToBounds = YES;

    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapped:)];
    [imageUser addGestureRecognizer:gesture];
    
    [tableViewProfile setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg.png"]]];

    
    labelName.text  = [[ContactDb sharedInstance]validateUserName:self.receiver_id];
    
    [self imageLoad];
    
    labelMobile.text = self.receiver_id;
    
    tableViewProfile.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if(pageFromChat==NO)
        app.currentRootView = self;

    labelStatus.text = [[ContactDb sharedInstance]validateUserStatus:self.receiver_id];
    
    if([labelStatus.text isEqualToString:@""]){
        labelStatus.text = @"I'm using Wing";
    }
    
    self.title = @"Info";
    
    [self setupValues];
    
    if(self.checkPage==YES){
        self.checkPage = NO;
        [self pushTochat:YES];

    }
}

- (void)setupValues{
    
    NSArray *array =[[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:self.receiver_id];
    
    labelMediaCount.text = (array.count ==0 ? @"None" : [NSString stringWithFormat:@"%lu",(unsigned long)array.count]);
    
    labelGroupsCount.text = [NSString stringWithFormat:@"%d",[[ChatStorageDB sharedInstance]getCommonGroupsFromDB:@"GroupMembers" member_jid:self.receiver_id]];
    
    if([labelGroupsCount.text isEqualToString:@"0"]){
        labelGroupsCount.text = @"None";
    }
    
    
}

- (void)imageLoad{
    [imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[self.receiver_id lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
}


- (void)imageTapped:(UITapGestureRecognizer*)recogniser{
    
    if([imageUser.image isEqual:[UIImage imageNamed:@"ment"]])
        return;
    
    NSLog(@"Tapped avatar!");
    
    NSMutableArray *galleryDataSource = [[NSMutableArray alloc]init];
    
    NSURL *url;
    
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png",IMGURL,self.receiver_id]];
    
    
    MHGalleryItem *landschaft1 = [MHGalleryItem.alloc initWithURL:[NSString stringWithFormat:@"%@",url]
                                                      galleryType:MHGalleryTypeImage];
    [galleryDataSource addObject:landschaft1];
        
    MHGalleryController *gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarShown];
    gallery.galleryItems = galleryDataSource;
    gallery.presentingFromImageView = nil;
    gallery.presentationIndex = 0;

    __weak MHGalleryController *blockGallery = gallery;
    
    gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
        if (viewMode == MHGalleryViewModeOverView) {
            [blockGallery dismissViewControllerAnimated:YES completion:^{
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{

                [blockGallery dismissViewControllerAnimated:YES dismissImageView:nil completion:^{
                    
                    [self setNeedsStatusBarAppearanceUpdate];
                    
                }];
            });
        }
    };
    [self presentMHGalleryController:gallery animated:YES completion:nil];
}


- (IBAction)actionChat:(id)sender{
    
    if(self.pageFromChat==YES){
        [[self navigationController]popViewControllerAnimated:YES];
        return;
    }
    
    
    NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:self.receiver_id]];
    if(![str isEqualToString:@""])
    {
        //commented by thangarajan
//        AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//        [app actioHideOrShowPasscode:self.receiver_id viewcontrol:self isgroupchat:@"0" unhide:NO];
        return;
    }
    
    [self pushTochat:YES];
}

- (void)pushTochat:(BOOL)anmated{
    
    [Utilities saveDefaultsValues:self.receiver_id :@"receiver_id"];
    [Utilities saveDefaultsValues:self.receiver_name :@"receiver_name"];
    [Utilities saveDefaultsValues:self.receiver_nick_name :@"receiver_nick_name"];
    [Utilities saveDefaultsValues:self.isgroupchat :@"isgroupchat"];
    
    
    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    self.title = @"Chat";
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)passcodeValidated:(NSString*)strjid isgroupchat:(NSString*)isgroupchat{
    self.checkPage = YES;
    
    
}
- (IBAction)actionCall:(id)sender{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",labelMobile.text]]];
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==2)
        return cellMobile.frame.size.height;
    if(indexPath.row==3)
        return cellStatus.frame.size.height;

    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0:
            cell = cellMedia;
            break;
        case 1:
            cell = cellGroups;
            break;
        case 2:
            cell = cellMobile;
            break;
        case 3:
            cell = cellStatus;
            break;
        case 4:
            cell = cellSendMessage;
            break;
        case 5:
            cell = cellEmailChat;
            break;
        case 6:
            cell = cellClearChat;
            break;

        default:
            break;
    }
    
    // static NSString *kCellID = @"cellID";
    
    cell.backgroundColor = [UIColor clearColor];
    
	return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self viewMedia];
            break;
        case 1:
            [self viewGroups];
            break;
        case 2:
            [self actionCall:self];
            break;
        case 3:
            break;
        case 4:
            [self actionChat:self];
            break;
        case 5:
            [self emailChat];
            break;
        case 6:
            [self clearChat];
            break;
            
        default:
            break;
    }

}

- (void)viewMedia{
    if(labelMediaCount.text.integerValue>0){
        int currentcount = 0;
        int presentationIndex = 0;
        NSMutableArray *galleryDataSource = [[NSMutableArray alloc]init];
        
        NSArray *array =[[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:self.receiver_id];
        if(array.count>0){
            
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
        else
            return;

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
                        
                    }];
                });
            }
        };
        [self presentMHGalleryController:gallery animated:YES completion:nil];

    }
}

- (void)viewGroups{
    
    CommonGroupsViewController *groups = [[CommonGroupsViewController alloc]init];
    groups.stringUserid = self.receiver_id;
    
    [self.navigationController pushViewController:groups animated:YES];
}


- (void)clearChat{
    
    NSString *title_str = [NSString stringWithFormat:@"Clear all conversations with %@?",labelName.text];
    
    actionSheetClearChat = [[UIActionSheet alloc]initWithTitle:title_str delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear Chat" otherButtonTitles:nil];
    [actionSheetClearChat showInView:self.view];

    
  
}

- (void)clearAllMessages{
    [[ChatStorageDB sharedInstance]deleteChatHistoryBetweenUsers:[Utilities getSenderId] receiver:self.receiver_id];
    [[ChatStorageDB sharedInstance] updateChatSession:self.receiver_id isgroupchat:@"0"];

    [self setupValues];
}

- (void)emailChat{

        actionSheetEmailChat = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Include Attachments",@"Without Attachements", nil];
        [actionSheetEmailChat showInView:self.view];

}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if(actionSheet==actionSheetEmailChat){
        if(buttonIndex==0){
            [self createEmailForChat:YES];
        }
        else if(buttonIndex==1){
            [self createEmailForChat:NO];
        }
    }
    else if(actionSheet==actionSheetClearChat){
        if(buttonIndex==0){
            [self clearAllMessages];
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
    
    NSMutableString *string = [[NSMutableString alloc]init];
    NSArray *array  =     [[ChatStorageDB sharedInstance]getChatHistoryBetweenUsers:[Utilities getSenderId] receiver:self.receiver_id];

    NSDateFormatter *dateforma = [[NSDateFormatter alloc]init];
    [dateforma setDateFormat:@"dd MMM YYYY hh:mm:ss a"];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    [picker setSubject:[NSString stringWithFormat:@"WING Chat with %@",labelName.text.capitalizedString]];

    
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
    [picker setMessageBody:[NSString stringWithFormat:@"WING Chat: %@.txt",labelName.text] isHTML:NO];
    //[self presentModalViewController:picker animated:YES];
    
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

- (IBAction)actionViewImage{
    
    if([[UIImage imageNamed:@"ment"] isEqual:imageUser.image]){
        return;
    }

    ProfilePhotoViewController *photo = [[ProfilePhotoViewController alloc]init];
    photo.stringtitle = @"Info";
    photo.jid = self.receiver_id;
    
    photo.hidesBottomBarWhenPushed = YES;
    [[self navigationController]pushViewController:photo animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
