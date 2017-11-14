//
//  StatusUpdateViewController.m
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "StatusUpdateViewController.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "XMPPConnect.h"

#define MAXCHARFORSTATUS 130

@interface StatusUpdateViewController ()

@end

@implementation StatusUpdateViewController

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
    self.textViewStatus.text = self.statusMessage;
    
    self.title = [NSString stringWithFormat:@"Your Status (%u)",(MAXCHARFORSTATUS-self.statusMessage.length)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.leftBarButtonItem = self.btnCancel;
    self.navigationItem.rightBarButtonItem = self.btnDone;

}

- (IBAction)actionCancel:(id)sender{
    [[self navigationController]popViewControllerAnimated:YES];
}
- (IBAction)actionDone:(id)sender{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatestatus" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[Utilities  encodingBase64:self.textViewStatus.text]  forKey:@"status_message"];
    
    
    
    [WebService updateNickname:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success) withObject:nil waitUntilDone:YES];
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

- (void)success{
    [[XMPPConnect sharedInstance]goOnline];
    [self setStatusBsedOnSelection:self.textViewStatus.text];

}

- (void)setStatusBsedOnSelection:(NSString*)statusmessage{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:statusmessage forKey:@"status_message"];
    //[defaults synchronize];
}



- (void)setCountLabel{
    int currentlength = self.textViewStatus.text.length;
    int total = MAXCHARFORSTATUS - currentlength;
    self.title = [NSString stringWithFormat:@"Your Status (%d)",total];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@""]){
        return YES;
    }
    
    if([self.title isEqualToString:@"Your Status (0)"])
        return NO;
    
    [self setCountLabel];

    
    [self setCountLabel];

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if(textView.text==nil||[textView.text isEqualToString:@""]){
        self.title = [NSString stringWithFormat:@"Your Status (%d)",MAXCHARFORSTATUS];
        [self.btnDone setEnabled:NO];
        return;
    }
    [self.btnDone setEnabled:YES];

    [self setCountLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
