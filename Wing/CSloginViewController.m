
#import "CSloginViewController.h"
#import "CSverifyViewController.h"
#import "CSNicknameViewController.h"
#import "AppDelegate.h"

#import "GUIDesign.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"

#import "NBPhoneMetaData.h"
#import "NBPhoneNumberUtil.h"
#import "CountryViewController.h"

#import <DigitsKit/DigitsKit.h>


@interface CSloginViewController()<UITextFieldDelegate>{

    AppDelegate* appDelegate;
    UITextField* numberField;
    UILabel * countrylbl;
    UILabel * codeLbl;
    NSString * namesTrforCode;
    NSString * counrtycde;
}

@property (nonatomic, strong)NSDictionary * dictCountry;

@end

@implementation CSloginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
   
    
//     DGTAuthenticateButton *authButton;
//    authButton = [DGTAuthenticateButton buttonWithAuthenticationCompletion:^(DGTSession *session, NSError *error) {
//        if (session.userID) {
//            
//            namesTrforCode = session.phoneNumber;
//            
//            NSLog(@"%@",session.phoneNumber);
//            
////             [self loginService:namesTrforCode withCountryCode:codeLbl.text];
//
//            [self nextView];
//        }
//        else if (error) {
//            NSLog(@"Authentication error: %@", error.localizedDescription);
//        }
//    }];
//    authButton.center = self.view.center;
//    [self.view addSubview:authButton];
    
    
   /*
    
    Digits *digits = [Digits sharedInstance];
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
    configuration.phoneNumber = @"+91";
    counrtycde = configuration.phoneNumber;
    [digits authenticateWithViewController:nil configuration:configuration completion:^(DGTSession *newSession, NSError *error){
    
    
    if (newSession.userID) {
    
    namesTrforCode = [newSession.phoneNumber stringByReplacingOccurrencesOfString:@"+91" withString:@""];
    
    //                        namesTrforCode = newSession.phoneNumber;
    
    NSLog(@"%@",newSession.phoneNumber);
    
    //             [self loginService:namesTrforCode withCountryCode:codeLbl.text];
    
    [self nextView];
    }
    else if (error) {
    NSLog(@"Authentication error: %@", error.localizedDescription);
    }
    
    
    }];
    
    countrylbl = [[UILabel alloc]init];

    
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSData *data1 = [NSData dataWithContentsOfFile:filePath1];
    
    self.dictCountry = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:nil];
    
    */
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    [appDelegate setupViewControllers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Load_CountryCode) name:@"CountryCode" object:nil];
    
    codeLbl = [[UILabel alloc]init];
    
    /* Code Comented by Ameen from line 34 - 174 */


    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
     scrollview.contentSize = CGSizeMake(screenWidth, screenHeight);
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    if (screenHeight == 480) {
        scrollview.contentSize = CGSizeMake(screenWidth, screenHeight + 100);
    }
    [self.view addSubview:scrollview];
    
    UIImageView * appbg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appbg.image = [UIImage imageNamed:@"appBg.png"];
    [scrollview addSubview:appbg];
    
    UIImageView* topLogo = [GUIDesign initWithImageView:CGRectMake((screenWidth - 99)/2, 50, 99, 99) img:@"login_logo.png"];
    [scrollview addSubview:topLogo];
    
    UIButton * btn1 = [GUIDesign initWithbutton:CGRectMake(((screenWidth-17)/2)-70 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"1" img:@" "];
    btn1.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn1.backgroundColor = [GUIDesign yellowColor];
    btn1.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn1.layer.cornerRadius =0.5* btn1.bounds.size.width;
    [scrollview addSubview:btn1];
    
    UIImageView* stepline1 = [GUIDesign initWithImageView:CGRectMake(btn1.frame.origin.x +17, topLogo.frame.origin.y +99 +30+ 8.5f, 50, 1) img:@"step_line.png"];
    [scrollview addSubview:stepline1];
    
    UIButton * btn2 = [GUIDesign initWithbutton:CGRectMake(stepline1.frame.origin.x+50 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"2" img:@" "];
    btn2.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn2.backgroundColor = [GUIDesign GrayColor];
    btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn2.layer.cornerRadius =0.5* btn2.bounds.size.width;
    [scrollview addSubview:btn2];
    
    UIImageView* stepline2 = [GUIDesign initWithImageView:CGRectMake(btn2.frame.origin.x +17, topLogo.frame.origin.y +99 +30+ 8.5f, 50, 1) img:@"step_line.png"];
    [scrollview addSubview:stepline2];
    
    UIButton * btn3 = [GUIDesign initWithbutton:CGRectMake(stepline2.frame.origin.x+50 , topLogo.frame.origin.y + 99 + 30, 17, 17) title:@"3" img:@" "];
    btn3.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn3.backgroundColor = [GUIDesign GrayColor];
    btn3.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn3.layer.cornerRadius =0.5* btn3.bounds.size.width;
    [scrollview addSubview:btn3];
    
    // to do auto country select
    UIImageView * location = [GUIDesign initWithImageView:CGRectMake((screenWidth - 204)/2, btn3.frame.origin.y+ 17 + 50, 204, 28) img:@"location"];
    [scrollview addSubview:location];
    
    countrylbl = [GUIDesign initWithLabel:CGRectMake(location.frame.origin.x + 50, location.frame.origin.y + 4, location.frame.size.width - 80, 20) title:@"Country" font:18 txtcolor:[UIColor blackColor]];
    [scrollview addSubview:countrylbl];
    
    UIButton * countryBtn = [GUIDesign initWithbutton:location.frame title:nil img:nil];
    [countryBtn addTarget:self action:@selector(countryAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:countryBtn];
    
    /*
    
    UIImageView * phoneNumber = [GUIDesign initWithImageView:CGRectMake((screenWidth - 204)/2, location.frame.origin.y+ 28 + 30, 204, 28) img:@"phone.png"];
    [scrollview addSubview:phoneNumber];
    
    numberField = [GUIDesign initWithtxtField:CGRectMake((screenWidth - 130)/2+30, location.frame.origin.y+ 28 + 30, 130, 28) Placeholder:@"Mobile number" delegate:self];
    numberField.font = [UIFont systemFontOfSize:14 ];
    numberField.textAlignment = NSTextAlignmentLeft;
    numberField.keyboardType = UIKeyboardTypeNumberPad;
    [scrollview addSubview:numberField];

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
    
    [numberField setInputAccessoryView:numberToolbar];
    
    codeLbl = [GUIDesign initWithLabel:CGRectMake(location.frame.origin.x + 20, location.frame.origin.y+ 28 + 30, 50, 28) title:@"" font:14 txtcolor:[UIColor whiteColor]];
    codeLbl.textAlignment = NSTextAlignmentCenter;
    [scrollview addSubview:codeLbl];
    
    UILabel* typeNumberlbl = [GUIDesign initWithLabel:CGRectMake((screenWidth-250)/2, phoneNumber.frame.origin.y+ 28 + 10, 250, 28) title:@"Please type your mobile number" font:16 txtcolor:[UIColor blackColor]];
    typeNumberlbl.textAlignment = NSTextAlignmentCenter;
    [scrollview addSubview:typeNumberlbl];
     
     UIButton * continueBtn = [GUIDesign initWithbutton:CGRectMake((screenWidth - (screenWidth - 150))/2, countryBtn.frame.origin.y + 50, screenWidth - 150, 40) title:@"Continue" img:nil];
     continueBtn.layer.borderWidth = 1.5;
     continueBtn.layer.borderColor = [UIColor grayColor].CGColor;
     continueBtn.layer.cornerRadius = 42/2;
     [continueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [continueBtn addTarget:self action:@selector(continueAction) forControlEvents:UIControlEventTouchUpInside];
     [scrollview addSubview:continueBtn];
     
     */
    
    // AMeen did
    
    UIButton * continueBtn = [GUIDesign initWithbutton:CGRectMake((screenWidth - (screenWidth - 150))/2, countryBtn.frame.origin.y + 50, screenWidth - 150, 40) title:@"Continue" img:nil];
    continueBtn.layer.borderWidth = 1.5;
    continueBtn.layer.borderColor = [UIColor grayColor].CGColor;
    continueBtn.layer.cornerRadius = 42/2;
    [continueBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [continueBtn addTarget:self action:@selector(cntnueAction) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:continueBtn];
    

    
    UILabel * copyrightlbl = [GUIDesign initWithLabel:CGRectMake(30,screenHeight - 40, screenWidth - 60,30) title:@"@2015 Wing. All Rights Reserved." font:16 txtcolor:[UIColor grayColor]];
    [scrollview addSubview:copyrightlbl];
    
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSData *data1 = [NSData dataWithContentsOfFile:filePath1];
    
    self.dictCountry = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:nil];
    
}

-(void)cntnueAction{
    
    if ([countrylbl.text isEqualToString:@"Country"]) {
        
        [self showAlert:@"Please select the country code"];
    }else{
        
        [self verifyCodeAction];
    }
}

-(void)verifyCodeAction{
    
    
    
    Digits *digits = [Digits sharedInstance];
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
    configuration.phoneNumber = codeLbl.text;
    counrtycde = configuration.phoneNumber;
    [digits authenticateWithViewController:nil configuration:configuration completion:^(DGTSession *newSession, NSError *error){
        
        
        if (newSession.userID) {
            
            namesTrforCode = [newSession.phoneNumber stringByReplacingOccurrencesOfString:codeLbl.text withString:@""];
            
            //                        namesTrforCode = newSession.phoneNumber;
            
            NSLog(@"%@",newSession.phoneNumber);
            
            //             [self loginService:namesTrforCode withCountryCode:codeLbl.text];
            
            [self nextView];
        }
        else if (error) {
            NSLog(@"Authentication error: %@", error.localizedDescription);
        }
        
        
    }];

}


-(void)nextView{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:@"userlogin" forKey:@"cmd"];
    [dic setObject:@"ios" forKey:@"platform"];
    [dic setObject:namesTrforCode forKey:@"mobile_number"];
    
    [dic setObject:[counrtycde stringByReplacingOccurrencesOfString:@"+" withString:@""]  forKey:@"mobile_code"];
    
    NSString *stringKey = [Utilities checkNil:[self.dictCountry objectForKey:countrylbl.text]];
    [dic  setObject:stringKey forKey:@"country_code"];
    [dic setObject:[Utilities checkNil:app.strdevicetoken] forKey:@"device_id"];
    
    [WebService loginApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
                [user setObject:[responseObject valueForKey:@"user_type"] forKey:@"user_type"];
                
                [user setObject:[responseObject valueForKey:@"user_id"] forKey:@"user_id"];
                [user setObject:[Utilities checkNil:[responseObject valueForKey:@"code"]] forKey:@"code"];
                [user setObject:[responseObject valueForKey:@"chatapp_id"] forKey:@"chatapp_id"];
                
                [user setObject:[Utilities checkNil:[responseObject valueForKey:@"nickname"]] forKey:@"nickname"];
                
                [user synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sucesslogin];
                });
            }
            else{
                [self showAlert:[responseObject valueForKey:@"message"]];
            }
        }
        else{
            [self showAlert:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)countryAction{
    
    [numberField resignFirstResponder];
    
    CountryViewController *cout = [[CountryViewController alloc] initWithNibName:@"CountryViewController" bundle:nil];
    [self.navigationController pushViewController:cout animated:YES];
}

- (void)Load_CountryCode{
    
    countrylbl.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"countryname"]];
    codeLbl.text = [NSString stringWithFormat:@"+%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"mobilecode"]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            scrollview.frame = CGRectMake(0, - 150, screenWidth, screenHeight);
        }];
    }
    return YES;
}

- (IBAction)doneWithNumberPad:(id)sender{
    
    if (screenHeight < 569) {
        [UIView animateWithDuration:0.5 animations:^{
            scrollview.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }];
    }
    [numberField resignFirstResponder];
}

-(void)continueAction{

    if (numberField.text.length < 10) {
        
        [self showAlert:@"Please enter valid mobile number"];
    
    }else{
        
        NSString * stringKey =[Utilities checkNil:[self.dictCountry objectForKey:countrylbl.text]];
        
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;
        NBPhoneNumber *myNumber = [phoneUtil parse:numberField.text
                                     defaultRegion:stringKey error:&anError];
        if (anError == nil) {
            
            if ([phoneUtil isValidNumber:myNumber]) {
                
//                NSString * phoneNumber = [phoneUtil format:myNumber
//                                              numberFormat:NBEPhoneNumberFormatINTERNATIONAL
//                                                     error:&anError];
                [self loginService:numberField.text withCountryCode:codeLbl.text];

            }else{
                [self showAlert:@"Not a valid Mobile Number"];
            }
        } else {
            [self showAlert:[anError localizedDescription]];
            NSLog(@"Error : %@", [anError localizedDescription]);
        }
    }
}

- (void)loginService:(NSString*)mobile withCountryCode:(NSString *)code{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:@"userlogin" forKey:@"cmd"];
    [dic setObject:@"ios" forKey:@"platform"];
    [dic setObject:mobile forKey:@"mobile_number"];
    
    [dic setObject:[code stringByReplacingOccurrencesOfString:@"+" withString:@""]  forKey:@"mobile_code"];
    
    NSString *stringKey = [Utilities checkNil:[self.dictCountry objectForKey:countrylbl.text]];
    [dic  setObject:stringKey forKey:@"country_code"];
    [dic setObject:[Utilities checkNil:app.strdevicetoken] forKey:@"device_id"];
    
    [WebService loginApi:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
                [user setObject:[responseObject valueForKey:@"user_type"] forKey:@"user_type"];
                
                [user setObject:[responseObject valueForKey:@"user_id"] forKey:@"user_id"];
                [user setObject:[Utilities checkNil:[responseObject valueForKey:@"code"]] forKey:@"code"];
                [user setObject:[responseObject valueForKey:@"chatapp_id"] forKey:@"chatapp_id"];
                [user synchronize];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sucesslogin];
                });
            }
            else{
                [self showAlert:[responseObject valueForKey:@"message"]];
            }
        }
        else{
            [self showAlert:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
    }];
}

- (void)sucesslogin{
    
    CSNicknameViewController * verifylogin = [[CSNicknameViewController alloc]init];
    [self.navigationController pushViewController:verifylogin animated:YES];

    
//    Ameen
    
//    CSverifyViewController * verifylogin = [[CSverifyViewController alloc]init];
//    [self.navigationController pushViewController:verifylogin animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    
    [[Digits sharedInstance] logOut];

    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
