//
//  ProfileViewController.h
//  ChatApp
//
//  Created by theen on 06/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface ProfileViewController : UIViewController{
    IBOutlet UITableView *tableViewProfile;
    
    IBOutlet UITableViewCell *cellMedia;
    IBOutlet UITableViewCell *cellGroups;
    IBOutlet UITableViewCell *cellMobile;
    IBOutlet UITableViewCell *cellStatus;
    IBOutlet UITableViewCell *cellSendMessage;
    IBOutlet UITableViewCell *cellEmailChat;
    IBOutlet UITableViewCell *cellClearChat;
    
    IBOutlet UIImageView *imageUser;
    IBOutlet UILabel     *labelName;
    IBOutlet UILabel     *labelMediaCount;
    IBOutlet UILabel     *labelGroupsCount;

    IBOutlet UILabel     *labelSendMessage;
    IBOutlet UILabel     *labelClearChat;
    IBOutlet UILabel     *labelEmailChat;

    IBOutlet UILabel     *labelMobile;
    IBOutlet UILabel     *labelStatus;


    BOOL pageFromChat;
    
    UIActionSheet *actionSheetEmailChat;
    UIActionSheet *actionSheetClearChat;
}
@property (nonatomic) BOOL checkPage;

@property (nonatomic) BOOL pageFromChat;

@property (nonatomic,retain) NSString *receiver_id;
@property (nonatomic,retain) NSString *isgroupchat;
@property (nonatomic,retain) NSString *receiver_name;
@property (nonatomic,retain) NSString *receiver_nick_name;

- (IBAction)actionViewImage;

- (IBAction)actionChat:(id)sender;
- (IBAction)actionCall:(id)sender;


@end
