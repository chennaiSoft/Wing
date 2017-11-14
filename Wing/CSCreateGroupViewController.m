//
//  CSCreateGroupViewController.m
//  Wing
//
//  Created by CSCS on 2/20/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSCreateGroupViewController.h"
#import "ChatStorageDB.h"

#import <QuartzCore/QuartzCore.h>
#import "MHGallery.h"
#import "UIImageView+AFNetworking.h"

#import "MessgaeTypeConstant.h"
#import "ContactDb.h"
#import "GUIDesign.h"
#import "WebService.h"
#import "Utilities.h"
#import "SVProgressHUD.h"

#define MAX_LENGTH_TEXT 25

@interface CSCreateGroupViewController ()
{
    UITextField * textGroupName;
    UIImageView * imageGroup;
    UILabel * countLabel;
    UIButton * btnAddPhoto;
    NSString * groupName;
}

@property (nonatomic, strong) UIBarButtonItem *nextButton;
@end

@implementation CSCreateGroupViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.arrayUsers = [[NSMutableArray alloc]init];

    self.title = @"New Group";
    
//    __weak CSCreateGroupViewController *weakSelf = self;
//    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)weakSelf;
//    }
    
    [self.view endEditing:YES];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    self.nextButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(createGroupAction:)];
    self.nextButton.tintColor = [UIColor blackColor];
    
    self.nextButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
    if(self.arrayUsers.count > 0)
        self.nextButton.title = @"Create";
    
    UIImageView * bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    bgImg.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:bgImg];
    
    imageGroup = [[UIImageView alloc]initWithFrame:CGRectMake(10, 80, 60, 60)];
    [self.view addSubview:imageGroup];
    
    imageGroup.layer.cornerRadius = imageGroup.frame.size.width/2;
    imageGroup.clipsToBounds = YES;
    imageGroup.layer.borderColor= [UIColor blackColor].CGColor;
    imageGroup.layer.borderWidth = 1;
    
    btnAddPhoto = [GUIDesign initWithbutton:imageGroup.frame title:@"Add Photo" img:nil];
    [btnAddPhoto setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnAddPhoto.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btnAddPhoto.titleLabel.numberOfLines = 2.0;
    btnAddPhoto.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnAddPhoto addTarget:self action:@selector(actionaddphoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnAddPhoto];

    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 155, screenWidth, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView];
    
    UIView * lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 205, screenWidth, 1)];
    lineView1.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView1];
    
    textGroupName = [GUIDesign initWithtxtField:CGRectMake(10, 156, screenWidth - 60, 48) Placeholder:@"Enter Group Name" delegate:self];
    [self.view addSubview:textGroupName];
    
    countLabel = [GUIDesign initWithLabel:CGRectMake(screenWidth - 60, 156, 60, 48) title:@"" font:18.0 txtcolor:[UIColor blackColor]];
    countLabel.text = [NSString stringWithFormat:@"%d",MAX_LENGTH_TEXT];
    [self.view addSubview:countLabel];
}

- (IBAction)actionaddphoto:(id)sender{
    
    [textGroupName resignFirstResponder];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose" message:nil preferredStyle:UIAlertControllerStyleActionSheet]; // 1
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Choose from Gallery"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self gallery:self];
                                                          }]; // 2
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Take from Camera"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self camera:self];
                                                          }]; // 2
    
    UIAlertAction * thirdAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                           }]; // 2


    [alert addAction:firstAction]; // 4
    [alert addAction:secondAction]; // 5
    [alert addAction:thirdAction]; // 6
    
    [self presentViewController:alert animated:YES completion:nil]; // 6
}

- (IBAction)createGroupAction:(id)sender{
    
    if(self.arrayUsers.count > 0){
        [self createRoom];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSInteger currentlength = textGroupName.text.length;
    if (currentlength < MAX_LENGTH_TEXT + 1) {
        self.nextButton.enabled = YES;
        NSInteger total = MAX_LENGTH_TEXT - currentlength;
        countLabel.text = [NSString stringWithFormat:@"%ld",(long)total];
        groupName = textGroupName.text;
        
    }else{
        textGroupName.text = groupName;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)gallery:(id)sender
{
    UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
    imagepic.delegate=self;
    imagepic.allowsEditing=YES;
    imagepic.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepic animated:YES completion:nil];
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

    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img=[Utilities fixOrientation:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    
    imageGroup.image = img;
    
    [btnAddPhoto setTitle:@"" forState:UIControlStateNormal];
    
    
    [UIImagePNGRepresentation(img) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/groupchat.png"] atomically:YES];
}

- (void)createRoom{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createGroupChatSuccess:)
                                                 name:@"GroupChatCreateSuccess"
                                               object:nil];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait ..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"creategroup" forKey:@"cmd"];
    
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[NSString stringWithFormat:@"%@",[self.arrayUsers componentsJoinedByString:@","]] forKey:@"members_id"];
    
    [dic setObject:[Utilities  encodingBase64:textGroupName.text] forKey:@"group_subject"];
    
    [WebService createGroupChat:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        
        [SVProgressHUD dismiss];
        
        if(responseObject){
            
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                self.stringGroupID = [responseObject valueForKey:@"group_id"];
                [[XMPPConnect sharedInstance]createChatRoom:[responseObject valueForKey:@"group_id"]];
            }
            else{
                [[NSNotificationCenter defaultCenter]removeObserver:self];
                [self showAlert:[responseObject valueForKey:@"messsage"]];
            }
        }
        else{
            [[NSNotificationCenter defaultCenter]removeObserver:self];
            [self showAlert:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
        
    }];
}

- (void)createGroupChatSuccess:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [[ChatStorageDB sharedInstance]saveRoomsWhenCreate:self.stringGroupID subject:textGroupName.text];
    
    [[ChatStorageDB sharedInstance] saveAndInviteMembers:self.stringGroupID memeberid:[Utilities getSenderId] invite:YES group_subject:textGroupName.text member_name:@"You" member_nick_name:@"You"];
    
    for (NSString *string in self.arrayUsers) {
        [[XMPPConnect sharedInstance]addRoaster:string];
        
        XMPPRoom *room = [[XMPPConnect sharedInstance].dictRooms objectForKey:self.stringGroupID];
        if(room){
            [room inviteUser:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",string] domain:HOSTNAME1 resource:UNIQUERESOURCE] withMessage:textGroupName.text];
        }

        NSString *strname = [[ContactDb sharedInstance]validateUserName:string];
        
        //else{
        [[ChatStorageDB sharedInstance] saveAndInviteMembers:self.stringGroupID memeberid:string invite:YES group_subject:textGroupName.text member_name:strname member_nick_name:strname];
        
        [self invitetoGroup:[NSString stringWithFormat:@"%@",string]];
    }
    
    NSString *localid = [[XMPPConnect sharedInstance] getLocalId];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[Utilities getSenderId] forKey:@"fromjid"];
    [dict setObject:self.stringGroupID forKey:@"tojid"];
    [dict setObject:textGroupName.text forKey:@"displayname"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)MessageTypeText] forKey:@"messagetype"];
    [dict setObject:[NSDate date] forKey:@"sentdate"];
    [dict setObject:@"0" forKey:@"deliver"];
    [dict setObject:@"You Created a Group" forKey:@"text"];
    [dict setObject:localid forKey:@"localid"];
    [dict setObject:self.stringGroupID forKey:@"jid"];
    [dict setObject:@"yes" forKey:@"readstatus"];
    [dict setObject:[Utilities getDateForCommonString:nil] forKey:@"datestring"];
    [dict setObject:@"1" forKey:@"isgroupchat"];
  
    [[ChatStorageDB sharedInstance] saveIncomingAndOutgoingmessages:dict incoming:YES];
    [self showSuccessAlert:@"New chat created successfully"];

}

- (void)showSuccessAlert:(NSString *)message{
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Message"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self.navigationController popToRootViewControllerAnimated:YES];

                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)invitetoGroup:(NSString*)member_id{
    
    [[XMPPConnect sharedInstance]addRoaster:member_id];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"groupinvite" forKey:@"cmd"];
    [dict setObject:[Utilities getSenderId] forKey:@"owner_id"];
    [dict setObject:member_id forKey:@"tojid"];
    [dict setObject:self.stringGroupID forKey:@"group_id"];
    [dict setObject:textGroupName.text forKey:@"group_subject"];
    [[XMPPConnect sharedInstance]groupInviteSendToReciever:dict];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
