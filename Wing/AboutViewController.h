//
//  AboutViewController.h
//  TestProject
//
//  Created by Theen on 02/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController{
    
    IBOutlet UILabel *labelAppName;
    IBOutlet UILabel *labelAppVersion;
    UIImageView * appBg;
    IBOutlet UIImageView *imaegAppLogo;
    IBOutlet UILabel *labelCopyRight;
    IBOutlet UIViewController *controllerFaq;
    IBOutlet UIWebView *webFaq;

    IBOutlet UIViewController *controllerContactUs;
    IBOutlet UITextView *textContactUs;
    IBOutlet UIBarButtonItem *btnCancel;
    IBOutlet UIBarButtonItem *btnSend;
    
    NSMutableArray *arrayAttachment;
    UITableView * tablView;

}

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionSend:(id)sender;

@end
