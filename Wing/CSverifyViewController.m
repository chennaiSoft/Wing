
#import "CSverifyViewController.h"
#import "AppDelegate.h"
#import "CSloginViewController.h"
#import "CSNicknameViewController.h"

#import "GUIDesign.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"


@interface CSverifyViewController ()<UITextFieldDelegate>{
    
    AppDelegate * appDelegate;
    UITextField * smscodeType;
    UIScrollView * scrollview;
}

@end

@implementation CSverifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBarHidden = YES;
    
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (screenHeight == 480) {
        scrollview.contentSize = CGSizeMake(screenWidth, screenHeight+100);
    }
    [self.view addSubview:scrollview];
    
    UIImageView* appbg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appbg.image = [UIImage imageNamed:@"appBg.png"];
    [scrollview addSubview:appbg];
    
    UIImageView* topLogo = [GUIDesign initWithImageView:CGRectMake((screenWidth - 99)/2, 50, 99, 99) img:@"login_logo.png"];
    [scrollview addSubview:topLogo];
    
    UIButton * btn1 = [GUIDesign initWithbutton:CGRectMake(((screenWidth-17)/2)-70 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"1" img:@" "];
    btn1.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn1.backgroundColor = [GUIDesign GrayColor];
    btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn1.layer.cornerRadius =0.5* btn1.bounds.size.width;
    [btn1 addTarget:self action:@selector(forstepOne) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:btn1];
    
    UIImageView* stepline1 = [GUIDesign initWithImageView:CGRectMake(btn1.frame.origin.x +17, topLogo.frame.origin.y +99 +30+ 8.5f, 50, 1) img:@"step_line.png"];
    [scrollview addSubview:stepline1];
    
    UIButton * btn2 = [GUIDesign initWithbutton:CGRectMake(stepline1.frame.origin.x+50 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"2" img:@" "];
    btn2.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn2.backgroundColor = [GUIDesign yellowColor];
    btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn2.layer.cornerRadius = 0.5 * btn2.bounds.size.width;
    [scrollview addSubview:btn2];
    
    UIImageView* stepline2 = [GUIDesign initWithImageView:CGRectMake(btn2.frame.origin.x +17, topLogo.frame.origin.y +99 +30+ 8.5f, 50, 1) img:@"step_line.png"];
    [scrollview addSubview:stepline2];
    
    UIButton * btn3 = [GUIDesign initWithbutton:CGRectMake(stepline2.frame.origin.x+50 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"3" img:@" "];
    btn3.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn3.backgroundColor = [GUIDesign GrayColor];
    btn3.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn3.layer.cornerRadius =0.5* btn3.bounds.size.width;
    [scrollview addSubview:btn3];
    
    UILabel* smsCode = [GUIDesign initWithLabel:CGRectMake((screenWidth-200)/2, btn2.frame.origin.y+ 28 + 10, 200, 50) title:@"Please enter the Code\n received by SMS" font:16 txtcolor:[UIColor blackColor]];
    smsCode.textAlignment = NSTextAlignmentCenter;
    smsCode.lineBreakMode = NSLineBreakByWordWrapping;
    smsCode.numberOfLines = 0;
    [scrollview addSubview:smsCode];
    
    smscodeType = [GUIDesign initWithtxtField:CGRectMake((screenWidth - 204)/2, smsCode.frame.origin.y+ 50 + 10, 204, 28) Placeholder:@"6 Digit code" delegate:self];
    smscodeType.textAlignment = NSTextAlignmentCenter;
    smscodeType.keyboardType = UIKeyboardTypeNumberPad;
    smscodeType.background = [UIImage imageNamed:@"code.png"];
    [scrollview addSubview:smscodeType];
    
    UIToolbar * numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [numberToolbar setBarTintColor:[UIColor whiteColor]];
    UIButton *doneButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 53, 29)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneWithNumberPad:)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc]initWithCustomView:doneButton];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],done,
                           nil];
    
    [smscodeType setInputAccessoryView:numberToolbar];

    //This section of label is already commented
    UILabel* nosmsCodeReceived = [GUIDesign initWithLabel:CGRectMake((screenWidth-250)/2, smscodeType.frame.origin.y+ 28 + 10, 250, 75) title:@"Not received code? Don't worry\n WING call you in a Minute" font:16 txtcolor:[UIColor blackColor]];
    nosmsCodeReceived.textAlignment = NSTextAlignmentCenter;
    nosmsCodeReceived.lineBreakMode = NSLineBreakByWordWrapping;
    nosmsCodeReceived.numberOfLines = 0;
    [scrollview addSubview:nosmsCodeReceived];
    
    UIButton * continueBtn = [GUIDesign initWithbutton:CGRectMake((screenWidth - (screenWidth - 150))/2, smscodeType.frame.origin.y + 75+ 35, screenWidth - 150, 40) title:@"Continue" img:nil];
    continueBtn.layer.borderWidth = 1.5;
    continueBtn.layer.borderColor = [UIColor grayColor].CGColor;
    continueBtn.layer.cornerRadius = 42/2;
    [continueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [continueBtn addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:continueBtn];
    
     if (screenHeight == 480) {
         continueBtn.frame =CGRectMake((screenWidth - (screenWidth - 150))/2, smscodeType.frame.origin.y + 75, screenWidth - 150, 40);
     }
    
    UILabel * copyrightlbl = [GUIDesign initWithLabel:CGRectMake(30,screenHeight - 40, screenWidth - 60,30) title:@"@2015 Wing. All Rights Reserved." font:16 txtcolor:[UIColor grayColor]];
    [scrollview addSubview:copyrightlbl];
    
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, - 100, screenWidth, screenHeight);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }];
    }
    return YES; // We do not want UITextField to insert line-breaks.
}

- (IBAction)doneWithNumberPad:(UITextField *)textField{
    
    [smscodeType resignFirstResponder];
    
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }];
    }

}

-(void)continueAction{
    //[self sucessCodeVerified];

    if (smscodeType.text.length == 0) {
        [self showAlert:@"Please enter verification code"];
    }else{
        [self verifyCodeService:smscodeType.text];
    }
}

- (void)verifyCodeService:(NSString *)code{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];

    [dic setObject:@"verifycode" forKey:@"cmd"];
    [dic setObject:[userDef objectForKey:@"chatapp_id"] forKey:@"chatapp_id"];
    [dic setObject:[userDef objectForKey:@"user_id"] forKey:@"user_id"];
    [dic setObject:code  forKey:@"activation_code"];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    [WebService loginApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
 
        [SVProgressHUD dismiss];
        
        if(responseObject){
            
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                NSUserDefaults * user = [NSUserDefaults standardUserDefaults];

                [user setObject:[Utilities checkNil:[responseObject valueForKey:@"nickname"]] forKey:@"nickname"];
                
                [Utilities saveDefaultsValues:[Utilities checkNil:[responseObject valueForKey:@"status_message"]] :@"status_message"];
                
                [Utilities saveDefaultsValues:[Utilities checkNil:[responseObject valueForKey:@"expired_date"]] :@"expired_date"];
                
                [Utilities saveDefaultsValues:[Utilities typeforprivacy:[Utilities checkNil:[responseObject valueForKey:@"hide_lastseen"]]] :@"Last Seen"];
                [Utilities saveDefaultsValues:[Utilities typeforprivacy:[Utilities checkNil:[responseObject valueForKey:@"hide_photo"]]] :@"Profile Photo"];
                [Utilities saveDefaultsValues:[Utilities typeforprivacy:[Utilities checkNil:[responseObject valueForKey:@"hide_status"]]] :@"Status"];
                
                [user synchronize];
                
                [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"userimage.png"] error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sucessCodeVerified];
                });
            }
            else{
//    Ameen
                UIAlertController * nextViewAlert = [UIAlertController alertControllerWithTitle:@"Message" message:[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"message"]] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction * okay = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
//                    [self sucessCodeVerified];
                }];
                
                [nextViewAlert addAction:okay];
                [self presentViewController:nextViewAlert animated:YES completion:nil];
                
//                [self showAlert:[responseObject valueForKey:@"message"]];
//                [self sucessCodeVerified];
            }
        }
        else{
            [self showAlert:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
    }];
}

- (void)sucessCodeVerified{
    
    CSNicknameViewController* gotoNick = [[CSNicknameViewController alloc]init];
    [self.navigationController pushViewController:gotoNick animated:YES];
}

- (void)forstepOne{
    [smscodeType resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
