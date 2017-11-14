//
//  CustomQLPreviewController.m
//  ChatApp
//
//  Created by Jeeva on 4/23/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "CustomQLPreviewController.h"

@interface CustomQLPreviewController ()

@end

@implementation CustomQLPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)viewDidAppear:(BOOL)animated
{
    for(UIView *currentView in self.view.subviews)
    {
        currentView.userInteractionEnabled = NO;
    }
}

-(void)contentWasTappedInPreviewContentController:(id)item {}

@end
