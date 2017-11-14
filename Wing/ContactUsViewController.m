//
//  ContactUsViewController.m
//  ChatApp
//
//  Created by theen on 19/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "ContactUsViewController.h"
#import "SVProgressHUD.h"
#import "WebService.h"
#import "Utilities.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

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
    self.arrayInputs = [[NSMutableArray alloc]init];
    
    self.title = @"Contact Us";
    
    self.btnSend.enabled = NO;
    
    [self setImageButtons];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItem = self.btnSend;
    self.navigationItem.leftBarButtonItem = self.btnCancel;
}

- (void)setImageButtons{
    
    [self.btn1 setTitle:@"" forState:UIControlStateNormal];
    [self.btn2 setTitle:@"" forState:UIControlStateNormal];
    [self.btn3 setTitle:@"" forState:UIControlStateNormal];
    
    [self.btn3 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.btn1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.btn2 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];

    self.btn1.layer.borderWidth = 0;
    self.btn2.layer.borderWidth = 0;
    self.btn3.layer.borderWidth = 0;

    [self.btn1.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.btn2.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.btn3.layer setBorderColor:[UIColor clearColor].CGColor];


    self.btndelete1.hidden = YES;
    self.btndelete2.hidden = YES;
    self.btndelete3.hidden = YES;

    switch (self.arrayInputs.count) {
        case 0:{
            self.btn2.layer.borderWidth = 1;
            [self.btn2.layer setBorderColor:[UIColor blackColor].CGColor];

            [self.btn2 setTitle:@"+" forState:UIControlStateNormal];
            
            break;
        }
        case 1:{
            self.btndelete1.hidden = NO;

            [self.btn1 setBackgroundImage:[self.arrayInputs objectAtIndex:0] forState:UIControlStateNormal];
            self.btn2.layer.borderWidth = 1;

            [self.btn2 setTitle:@"+" forState:UIControlStateNormal];
            [self.btn2.layer setBorderColor:[UIColor blackColor].CGColor];

            break;
        }
        case 2:{
            self.btndelete1.hidden = NO;
            self.btndelete2.hidden = NO;

            [self.btn1 setBackgroundImage:[self.arrayInputs objectAtIndex:0] forState:UIControlStateNormal];
            [self.btn2 setBackgroundImage:[self.arrayInputs objectAtIndex:1] forState:UIControlStateNormal];
            self.btn3.layer.borderWidth = 1;
            [self.btn3.layer setBorderColor:[UIColor blackColor].CGColor];
            [self.btn3 setTitle:@"+" forState:UIControlStateNormal];
            
            break;
        }
        case 3:{
            self.btndelete1.hidden = NO;
            self.btndelete2.hidden = NO;
            self.btndelete3.hidden = NO;

            [self.btn1 setBackgroundImage:[self.arrayInputs objectAtIndex:0] forState:UIControlStateNormal];
            [self.btn2 setBackgroundImage:[self.arrayInputs objectAtIndex:1] forState:UIControlStateNormal];
            
            [self.btn3 setBackgroundImage:[self.arrayInputs objectAtIndex:2] forState:UIControlStateNormal];
            
            break;
        }
        default:
            break;
    }
}

- (IBAction)actionSend:(id)sender{
    
    if([self.textFeedBack.text isEqualToString:@""])
        return;
    
    [self.textFeedBack resignFirstResponder];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"sendfeedback" forKey:@"cmd"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"chatapp_id"] forKey:@"chatapp_id"];
    [dic setObject:[Utilities  encodingBase64:self.textFeedBack.text] forKey:@"feedback"];

    [WebService updateFeedBack:dic arrayInput:self.arrayInputs completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success:) withObject:[responseObject valueForKey:@"message"] waitUntilDone:YES];
            }
            else{
                [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
            }
        }
        else{
            [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
    }];
}

- (void)success:(NSString*)message{
    [Utilities alertViewFunction:@"" message:message];
    [[self navigationController]popViewControllerAnimated:YES];

}

- (IBAction)actionCanel:(id)sender{
    [[self navigationController]popViewControllerAnimated:YES];
}

- (IBAction)actionBtn1:(id)sender{
    [self.textFeedBack resignFirstResponder];

    if(self.arrayInputs.count==3)
        return;
    
    [self gallery:nil];
}
- (IBAction)actionBtn2:(id)sender{
    [self.textFeedBack resignFirstResponder];

    if(self.arrayInputs.count==3)
        return;
    [self gallery:nil];

}
- (IBAction)actionBtn3:(id)sender{
    [self.textFeedBack resignFirstResponder];
    if(self.arrayInputs.count==3)
        return;
    [self gallery:nil];

}

#pragma mark Image Picker
#pragma mark Image Picker

-(void)gallery:(id)sender
{
    UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
    imagepic.delegate=self;
    imagepic.allowsEditing=YES;
    imagepic.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepic animated:YES completion:nil];
    // [self presentViewController:imagepic animated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img=[Utilities fixOrientation:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    UIImage *scaledImage = [Utilities resizedImageToFitInSize:CGSizeMake(90, 180) scaleIfSmaller:YES image:img];

    
    switch (self.arrayInputs.count) {
        case 0:{
            [self.arrayInputs insertObject:scaledImage atIndex:0];
            break;
        }
        case 1:{

            [self.arrayInputs insertObject:scaledImage atIndex:1];
            break;
        }
        case 2:{
            [self.arrayInputs insertObject:scaledImage atIndex:2];
            break;
        }

        default:
            break;
    }
    
    [self setImageButtons];
    
}

- (void)textViewDidChange:(UITextView *)textView{

    if([[Utilities checkNil:textView.text] isEqualToString:@""]){
        [self.btnSend setEnabled:NO];
        return;
    }
    [self.btnSend setEnabled:YES];
    
}


-(UIImage*)scaleToSize:(CGSize)size sourceImage:(UIImage*)sourceImage
{
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [sourceImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    // Return our new scaled image
    return scaledImage;
}


- (IBAction)actionBtnDelete1:(id)sender{
    [self removeImage:0];
    
}
- (IBAction)actionBtnDelete2:(id)sender{
    [self removeImage:1];

}
- (IBAction)actionBtnDelete3:(id)sender{
    [self removeImage:2];

}

- (void)removeImage:(int)tag{
    [self.arrayInputs removeObjectAtIndex:tag];
    [self setImageButtons];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.textFeedBack.isFirstResponder){
        [self.textFeedBack resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
