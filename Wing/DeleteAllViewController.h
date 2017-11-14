//
//  DeleteAllViewController.h
//  ChatApp
//
//  Created by theen on 27/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeleteAllViewController : UIViewController{
    IBOutlet UILabel *labelMobileNumber;
    IBOutlet UIScrollView *scrollView;

}
@property (weak, nonatomic) IBOutlet UILabel *lbl_Code;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CountryName;
@property (weak, nonatomic) IBOutlet UITextField *textfld_PhoneNumber;
@property(nonatomic,retain)NSMutableDictionary *dictCountry;

- (IBAction)action_Country:(id)sender;
-(void)Load_CountryCode;
- (IBAction)action_Continue:(id)sender;

@end
