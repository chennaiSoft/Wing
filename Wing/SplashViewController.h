//
//  SplashViewController.h
//  ChatApp
//
//  Created by theen on 27/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplashViewController : UIViewController{
    int next;
    IBOutlet UIScrollView *scroll_instruction;
    
    IBOutlet UIImageView *imageMain;
    
    IBOutlet UIImageView *image_dot1;
    IBOutlet UIImageView *image_dot2;
    IBOutlet UIImageView *image_dot3;
    IBOutlet UIImageView *image_dot4;
    IBOutlet UILabel *labelmain1;

    IBOutlet UILabel *labelmain2;
    
    IBOutlet UIView   *viewmain;




}
@property (nonatomic, strong) NSMutableArray *pageViews;

@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) IBOutlet UIScrollView *scroll_instruction;


- (IBAction)actionskip:(id)sender;

@end
