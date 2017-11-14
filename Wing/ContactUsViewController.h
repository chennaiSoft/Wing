//
//  ContactUsViewController.h
//  ChatApp
//
//  Created by theen on 19/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactUsViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
}

@property (nonatomic,retain) NSMutableArray *arrayInputs;

@property (nonatomic,retain) IBOutlet UITextView *textFeedBack;
@property (nonatomic,retain) IBOutlet UIButton *btn1;
@property (nonatomic,retain) IBOutlet UIButton *btn2;
@property (nonatomic,retain) IBOutlet UIButton *btn3;

@property (nonatomic,retain) IBOutlet UIButton *btndelete1;
@property (nonatomic,retain) IBOutlet UIButton *btndelete2;
@property (nonatomic,retain) IBOutlet UIButton *btndelete3;


@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnSend;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnCancel;

- (IBAction)actionSend:(id)sender;
- (IBAction)actionCanel:(id)sender;

- (IBAction)actionBtn1:(id)sender;
- (IBAction)actionBtn2:(id)sender;
- (IBAction)actionBtn3:(id)sender;

- (IBAction)actionBtnDelete1:(id)sender;
- (IBAction)actionBtnDelete2:(id)sender;
- (IBAction)actionBtnDelete3:(id)sender;

@end
