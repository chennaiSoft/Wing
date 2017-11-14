//
//  DeleteAllViewController.m
//  ChatApp
//
//  Created by theen on 27/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "DeleteAllViewController.h"
#import "NBPhoneNumberUtil.h"
#import "ChatStorageDB.h"
#import "CountryViewController.h"

@interface DeleteAllViewController ()

@end

@implementation DeleteAllViewController

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
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Load_CountryCode) name:@"CountryCode" object:nil];
    
    [_textfld_PhoneNumber addTarget:self action:@selector(validateMobileNumber:) forControlEvents:UIControlEventEditingChanged];
    
    
    UITapGestureRecognizer *recogniser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tabView)];
    [scrollView addGestureRecognizer:recogniser];
    
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSData *data1 = [NSData dataWithContentsOfFile:filePath1];
    self.dictCountry = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:nil];

    // Do any additional setup after loading the view from its nib.
}
- (void)tabView{
    if(_textfld_PhoneNumber.isFirstResponder){
        [_textfld_PhoneNumber resignFirstResponder];
    }
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    //self.navigationController.navigationBarHidden  =YES;
    [scrollView setContentOffset:CGPointMake(0, 20) animated:YES];
}

- (IBAction)action_Country:(id)sender{
    
    //    [[AddressBookContacts sharedInstance] loadAddressbook];
    if(_textfld_PhoneNumber.isFirstResponder){
        [_textfld_PhoneNumber resignFirstResponder];
    }
    
    CountryViewController *cout = [[CountryViewController alloc] initWithNibName:@"CountryViewController" bundle:nil];
    [self.navigationController pushViewController:cout animated:YES];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if([string isEqualToString:@""]){
        return YES;
    }
    
    if ([@"1234567890" rangeOfString:string].location!=NSNotFound){
        
        if ([textField.text length]>=15){
            [Utilities alertViewFunction:@"" message:@"Only 15 Digits are allowed"];
            return NO;
        }
        return YES;
    }
    return NO;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(_textfld_PhoneNumber.isFirstResponder){
        [_textfld_PhoneNumber resignFirstResponder];
    }
    
    [scrollView setContentOffset:CGPointMake(0, -20) animated:YES];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




-(void)Load_CountryCode{
    
    _lbl_CountryName.text=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"countryname"]];
    _lbl_Code.text=[NSString stringWithFormat:@"+%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"mobilecode"]];
    
}
- (IBAction)action_Continue:(id)sender {
    
    if([[Utilities checkNil:_textfld_PhoneNumber.text] isEqualToString:@""]){
        [Utilities alertViewFunction:@"" message:@"Please enter mobile number."];
        return;
    }
    NSString *codee = [_lbl_Code.text stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    codee  =[NSString stringWithFormat:@"%@%@",codee,_textfld_PhoneNumber.text];
    if(![codee isEqualToString:[Utilities getSenderId]]){
        [Utilities alertViewFunction:@"" message:@"Please enter valid mobile number."];
        return;
    }
    
    [[ChatStorageDB sharedInstance] deleteAllDB:@"Message"];
    [[ChatStorageDB sharedInstance] deleteAllDB:@"ChatSession"];

    [[self navigationController]popViewControllerAnimated:YES];

    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [scrollView setContentOffset:CGPointMake(0, 100) animated:YES];
}
- (void)validateMobileNumber:(id)sender{
    
    UITextField *txt = (UITextField*)sender;
    if([[Utilities checkNil:txt.text] isEqualToString:@""]){
        
        return;
    }
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSString *stringKey =[Utilities checkNil:[self.dictCountry objectForKey:_lbl_CountryName.text]];
    
    if([stringKey isEqualToString:@""])
        return;
    
    NSError *aError = nil;
    
    NBPhoneNumber *myNumber = [phoneUtil parse:txt.text defaultRegion:stringKey error:&aError];
    if (aError == nil) {
        if([phoneUtil isValidNumber:myNumber]){
            [txt resignFirstResponder];
            [scrollView setContentOffset:CGPointMake(0, -20) animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
