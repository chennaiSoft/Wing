//
//  CSBaseViewController.m
//  Wing
//
//  Created by CSCS on 1/30/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSBaseViewController.h"
#import "AppDelegate.h"

#import "GUIDesign.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"

@interface CSBaseViewController ()
{
    UIView * interNetView;
}
@end

@implementation CSBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showNoInternetView{
    
    interNetView = [[UIView alloc]initWithFrame:CGRectMake(0, - 80, screenWidth, 80)];
    interNetView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:interNetView];
    
    UILabel* internetlbl = [GUIDesign initWithLabel:CGRectMake(30, 35, screenWidth - 30, 30) title:@"No Internet Connectivity!" font:18 txtcolor:[UIColor blackColor]];
    [interNetView addSubview:internetlbl];
    
    [UIView animateWithDuration:1.0 animations:^{
        interNetView.frame = CGRectMake(0, 0, screenWidth, 80);
    } completion:^(BOOL finished) {
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideInterNetView) userInfo:nil repeats:NO];
}

- (void)hideInterNetView{
    
    [UIView animateWithDuration:1.0 animations:^{
        interNetView.frame = CGRectMake(0, -100, screenWidth, 80);
    } completion:^(BOOL finished) {
        [interNetView removeFromSuperview];
    }];
}

- (void)showAlert:(NSString *)message{
    
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
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
