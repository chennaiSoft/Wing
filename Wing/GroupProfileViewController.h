//
//  GroupProfileViewController.h
//  TestProject
//
//  Created by Theen on 06/02/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "MHGallery.h"

#import <MessageUI/MessageUI.h>

@interface GroupProfileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>{
    IBOutlet UITableView *tableViewList;
    
    IBOutlet UIImageView *imageGroup;
 //   IBOutlet UITextView *textGroupName;
    IBOutlet UITextField *textGroupName;

    IBOutlet UILabel *labelCount;
    
    IBOutlet UILabel *labelCreatedBy;
    IBOutlet UILabel *labelCreatedAt;

    NSIndexPath *path;
    
    NSString *participantsCount;
    
    NSDateFormatter *dateFormatter;
    
    UIActionSheet *actionSheetEmailChat;
    
}

@property (nonatomic,retain) NSMutableArray *arrayRecords;

@property (nonatomic) BOOL getGroupStatus;

@property (nonatomic,retain) NSString *participantsCount;

@property (nonatomic,retain) NSString *stringGroupId;
@property (nonatomic,retain) NSString *stringGroupName;
@property (nonatomic,retain) NSString *stringOwnerId;
@property (nonatomic,retain) NSString *stringUpdateType;
- (IBAction)textChange:(id)sender;


- (IBAction)actionEdit:(id)sender;

@end
