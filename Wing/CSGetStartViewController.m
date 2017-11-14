//
//  CSGetStartViewController.m
//  Wing
//
//  Created by CSCS on 13/11/15.
//  Copyright © 2015 CSCS. All rights reserved.
//

#import "CSGetStartViewController.h"
#import "AppDelegate.h"
#import "GUIDesign.h"
#import "CSloginViewController.h"

@interface CSGetStartViewController ()
{
    AppDelegate * appDelegate;
}
@end

@implementation CSGetStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.navigationController.navigationBarHidden = YES;
    
    UIImageView * mainBgImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [mainBgImg setImage:[UIImage imageNamed:@"appBg.png"]];
    [self.view addSubview:mainBgImg];
    
    UIImageView * bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,screenWidth, 350)];
    [bgImg setImage:[UIImage imageNamed:@"top_bg"]];
    [bgImg setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:bgImg];
    
    UIImageView * logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth - 113)/2,(350 - 133)/2 ,113, 133)];
    [logoImg setImage:[UIImage imageNamed:@"intrologoBlack.png"]];
    [logoImg setContentMode:UIViewContentModeCenter];
    [self.view addSubview:logoImg];
    
    UIImageView * graylogoImg = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth - 52)/2,(350 - 26) ,52, 52)];
    [graylogoImg setImage:[UIImage imageNamed:@"intrograylogo.png"]];
    [graylogoImg setContentMode:UIViewContentModeCenter];
    [self.view addSubview:graylogoImg];
    
    UIButton * startBtn = [GUIDesign initWithbutton:CGRectMake(50, graylogoImg.frame.origin.y + 80 + 30, screenWidth - 100, 42) title:@"Get Started" img:nil];
    startBtn.layer.cornerRadius = 42/2;
    [startBtn setBackgroundColor:[GUIDesign yellowColor]];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    
    if(screenHeight == 480){
        
        startBtn.frame = CGRectMake(50, graylogoImg.frame.origin.y + 30 + 30, screenWidth - 100, 42);
    }
    
    UILabel * copyrightlbl = [GUIDesign initWithLabel:CGRectMake(30,screenHeight - 40, screenWidth - 60,30) title:@"@2015 Wing. All Rights Reserved." font:16 txtcolor:[UIColor grayColor]];
    [self.view addSubview:copyrightlbl];
}

- (void)startAction{
    CSloginViewController* loginView = [[CSloginViewController alloc]init];
    [self.navigationController pushViewController:loginView animated:YES];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
