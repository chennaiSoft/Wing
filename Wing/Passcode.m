//
//  Passcode.m
//  iVideo player
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Passcode.h"
#import "AppDelegate.h"
#import "ChatStorageDB.h"

@implementation Passcode

@synthesize imageOne;
@synthesize imageTwo;
@synthesize imageThree;
@synthesize imageFour;

@synthesize tmpTextField;
@synthesize strPassCode;
@synthesize checkForPasscodeSetup;
@synthesize checkForPasscodeOff;
@synthesize lblHeading;
@synthesize lblTitle;
@synthesize navBar;
@synthesize delegate;
@synthesize checkForUnHide;
//folder lock variables
@synthesize fromWhichScreen;
@synthesize isEditing;
@synthesize stringPasscode;
@synthesize stringGetPassword;
@synthesize checkForInitialLoad;
- (id)init
{
    self = [super initWithNibName:@"Passcode" bundle:nil];
    
	return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *passcode = [tmpTextField text];
    
    passcode = [passcode stringByReplacingCharactersInRange:range withString:string];
    
    switch ([passcode length])
    {
        case 0:
        {
            
            [self.imageOne setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];

            break;
        }  
        case 1:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            
            break;
        }  
        case 2:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            break;
        }  
        case 3:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            
;
            break;
        }  
        case 4:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"enter_dot.png"]];
            
          
            [self performSelector:@selector(checkForPasscode:) withObject:passcode afterDelay:0];
            
            return NO;
            break;
        }  

        default:
            break;
    }
    return YES;   
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)clearTextField
{
    [self.stringGetPassword setString:@""];
    
    [self.imageOne setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
    [self.imageTwo setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
    [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
    [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
    
}

#pragma mark -
#pragma mark Passcode
-(void)checkForPasscode:(NSString *)passcode
{
   // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Controller opened for pass code setup
    if(checkForPasscodeSetup)
    {
        if([self.strPassCode isEqualToString:@""])
        {
            self.strPassCode  = passcode;
            
            [self clearTextField];

            
            self.lblTitle.text = NSLocalizedString(@"Confirm the passcode",@"");
        }
        else
            
        {
            if([self.strPassCode isEqualToString:passcode])
            {
                
                [[ChatStorageDB sharedInstance] updatePasscode:passcode jid:self.stringJid];

                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else  
            {
                
                
                [Utilities alertViewFunction:@"" message:@"Passcode mismatches"];
                
//                UIAlertView *alertMismatch = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode mismatches",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                [alertMismatch show];
                [self clearTextField];
//                self.lblTitle.text = NSLocalizedString(@"Enter the passcode",@"");
                self.lblTitle.text =  NSLocalizedString(@"Confirm the passcode",@"");
                
                
            }
        }
        
    // Real ask for passcode
        
    }
    else
    {
        
        
        
        
        
        if([[[ChatStorageDB sharedInstance] getPassodeStatus:self.stringJid] isEqualToString:passcode])
        {
            if(self.checkForUnHide)
            {
                [[ChatStorageDB sharedInstance] removePasscode:@"" jid:self.stringJid];
            }
            else{
                [delegate passcodeValidated:self.stringJid isgroupchat:self.isgroupchat];
            }
            
           [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
             [Utilities alertViewFunction:@"" message:@"Passcode incorrect"];
            /*
            UIAlertView *alertFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode incorrect",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertFailed show];
             */
            [self clearTextField];
        }
    }
}


-(IBAction)actionCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)actionZeroToNine:(id)sender
{
    UIButton *buttonTag=(UIButton *)sender;
    
    if (self.stringGetPassword.length<=4)
    {
        [self.stringGetPassword appendFormat:@"%ld",(long)buttonTag.tag];
        [self updateFourButton];
    }
}

- (IBAction)actionDelete:(id)sender
{
    if (self.stringGetPassword.length>=1)
    {
        self.stringGetPassword=[NSMutableString stringWithFormat:@"%@",[self.stringGetPassword substringToIndex:[self.stringGetPassword length]-1]];
        
        [self updateFourButton];
    }
}

-(void)updateFourButton
{
    NSLog(@"string get password--->%@",self.stringGetPassword);
    
    switch ([self.stringGetPassword length])
    {
        case 0:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            
            break;
        }
        case 1:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            
            break;
        }
        case 2:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            break;
        }
        case 3:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"not_enter_dot.png"]];
            
            break;
        }
        case 4:
        {
            [self.imageOne setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageTwo setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageThree setImage:[UIImage imageNamed:@"enter_dot.png"]];
            [self.imageFour setImage:[UIImage imageNamed:@"enter_dot.png"]];
            
            if ([self.fromWhichScreen isEqualToString:@"playlist"])
            {
                if (self.isEditing)
                {
                    [self performSelector:@selector(PlaylistLock:) withObject:self.stringGetPassword afterDelay:0.5];
                    
                }
                else
                {
                    [self performSelector:@selector(WhileEditing:) withObject:self.stringGetPassword afterDelay:0.5];
                }
            }
            else if ([self.fromWhichScreen isEqualToString:@"fromMediaLibray"])
            {
                if (self.isEditing)
                {
                    [self performSelector:@selector(MediaLibrayLock:) withObject:self.stringGetPassword afterDelay:0.5];
                }
                else
                {
                    [self performSelector:@selector(whileEditingMediaLibray:) withObject:self.stringGetPassword afterDelay:0.5];
                }
            }
            else
            {
                [self performSelector:@selector(checkForPasscode:) withObject:self.stringGetPassword afterDelay:0.5];
            }
            
            break;
        }
            
        default:
            break;
    }
}
-(void)whileEditingMediaLibray:(NSString *)passcode
{
    /*
    if([self.folderItemObject.passcode isEqualToString:passcode])
    {
        [delegate passcodeSucceded:NO];
        
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alertFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode incorrect",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        
        [alertFailed show];
        
        [self clearTextField];
    }
     */
}

-(void)MediaLibrayLock:(NSString *)passcode
{
    /*
    if(self.folderItemObject.passcode==nil)
    {
        if([self.stringPasscode isEqualToString:@""])
        {
            self.stringPasscode=passcode;
            
            [self clearTextField];
            
            self.lblTitle.text = NSLocalizedString(@"Confirm the passcode",@"");
        }
        else
        {
            if([self.stringPasscode isEqualToString:passcode])
            {
                self.folderItemObject.passcode=self.stringPasscode;
                
                [self.folderModelObject updateItem:self.folderItemObject];
                
                NSString *path1=self.folderItemObject.folderPath;
                
                [self.folderModelObject save:[path1 lastPathComponent] folderPath:[path1 stringByDeletingLastPathComponent]];
                
                [delegate passcodeSucceded:YES];
                
                [self dismissModalViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alertMismatch = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode mismatches",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                
                [alertMismatch show];
                
                [self clearTextField];
                
                self.lblTitle.text = NSLocalizedString(@"Enter the passcode",@"");
            }
        }
    }
    else
    {
        if([self.folderItemObject.passcode isEqualToString:passcode])
        {
            self.folderItemObject.passcode=nil;
            
            [self.folderModelObject updateItem:self.folderItemObject];
            
            NSString *path1=self.folderItemObject.folderPath;
            
            [self.folderModelObject save:[path1 lastPathComponent] folderPath:[path1 stringByDeletingLastPathComponent]];
            
            
            [delegate passcodeSucceded:YES];
            
            [self dismissModalViewControllerAnimated:YES];
            
        }
        else
        {
            UIAlertView *alertFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode incorrect",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            [alertFailed show];
            
            [self clearTextField];
        }
    }
     */
}

-(void)WhileEditing:(NSString *)passcode
{
    /*
    if([self.playlistObject.playlistPasscode isEqualToString:passcode])
    {
        [delegate passcodeSucceded:NO];
        
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alertFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode incorrect",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertFailed show];
        [self clearTextField];
    }
     */
}

-(void)PlaylistLock:(NSString *)passcode
{
    /*
    if(self.playlistObject.playlistPasscode==nil)
    {
        if([self.stringPasscode isEqualToString:@""])
        {
            self.stringPasscode=passcode;
            
            [self clearTextField];
            
            self.lblTitle.text = NSLocalizedString(@"Confirm the passcode",@"");
        }
        else
        {
            if([self.stringPasscode isEqualToString:passcode])
            {
                self.playlistObject.playlistPasscode=self.stringPasscode;
                
                [[PlaylistModel sharedInstance] save];
                
                
                [delegate passcodeSucceded:YES];
                
                [self dismissModalViewControllerAnimated:YES];
            }
            else
            {
                UIAlertView *alertMismatch = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode mismatches",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                
                [alertMismatch show];
                
                [self clearTextField];
                
                self.lblTitle.text = NSLocalizedString(@"Enter the passcode",@"");
            }
        }
    }
    else
    {
        if([self.playlistObject.playlistPasscode isEqualToString:passcode])
        {
            self.playlistObject.playlistPasscode=nil;
            
            [[PlaylistModel sharedInstance] save];
            
            [delegate passcodeSucceded:YES];

            [self dismissModalViewControllerAnimated:YES];

        }
        else
        {
            UIAlertView *alertFailed = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed!",@"") message:NSLocalizedString(@"Passcode incorrect",@"") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            
            [alertFailed show];
            
            [self clearTextField];
        }
    }
    
    */
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    tmpTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    tmpTextField.keyboardType = UIKeyboardTypeNumberPad;
    tmpTextField.delegate = self;
    [self.view addSubview:tmpTextField];
//    [tmpTextField becomeFirstResponder];
    self.strPassCode = @"";
    
    self.stringPasscode=@"";
    self.stringGetPassword=[[NSMutableString alloc]init];

   // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    if(appDelegate.passcodeLock)
//    {
//        if(!self.checkForPasscodeOff)
//        {
//            // Hide "Cancel" button
//            self.navBar.topItem.rightBarButtonItem = nil;
//        }
//    }
    
    
    self.lblHeading.text = NSLocalizedString(@"Set Passcode",@"");
    
    self.lblTitle.text = NSLocalizedString(@"Enter the passcode",@"");
    
    if(checkForInitialLoad==YES){
        [btnCancel setHidden:YES];
    }

    
//    
//    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height+200)];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tmpTextField = nil;
    self.strPassCode  = nil;
    self.lblHeading   = nil;
    self.lblTitle     = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
//   [self scrollContentSize];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"test");
    
//   [self scrollContentSize];
   
}

-(void)scrollContentSize{
    
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation))
    {
        scrollView.contentSize = CGSizeMake(320, [UIScreen mainScreen].bounds.size.width+300);
    }
    else{
        scrollView.contentSize = CGSizeMake(320, [UIScreen mainScreen].bounds.size.height);
    }
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	if(!appDelegate.landscapeLocked)
	{
		if(interfaceOrientation==UIInterfaceOrientationPortrait)
		{
			[[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
			return (interfaceOrientation==UIInterfaceOrientationPortrait);
		}
		else if(interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown)
		{
			[[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortraitUpsideDown];
			return (interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown);
			
		}
		else if(interfaceOrientation==UIInterfaceOrientationLandscapeLeft)
		{	
			[[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
			return (interfaceOrientation==UIInterfaceOrientationLandscapeLeft);
			
		}
		else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight)
		{
			[[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
			return (interfaceOrientation==UIInterfaceOrientationLandscapeRight);
			
		}
		return YES;
		
		
	}
	else
		
	{
		if([[appDelegate side_rotate] isEqualToString:@"1"])
		{
			//[loadingView setOrientation:UIInterfaceOrientationPortrait];
			return (interfaceOrientation==UIInterfaceOrientationPortrait);
            
		}
		else if([[appDelegate side_rotate] isEqualToString:@"2"])
		{
			//[loadingView setOrientation:UIInterfaceOrientationPortraitUpsideDown];
            
			return (interfaceOrientation==UIInterfaceOrientationPortraitUpsideDown);
            
		}
		else if([[appDelegate side_rotate] isEqualToString:@"3"])
		{
			//[loadingView setOrientation:UIInterfaceOrientationLandscapeLeft];
            
			return (interfaceOrientation==UIInterfaceOrientationLandscapeLeft);
            
		}
		else if([[appDelegate side_rotate] isEqualToString:@"4"])
		{
			//[loadingView setOrientation:UIInterfaceOrientationLandscapeRight];
            
			return (interfaceOrientation==UIInterfaceOrientationLandscapeRight);
            
		}
		
		return NO;
		
	}	
	
	
	return NO;
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    return YES;
}


@end
