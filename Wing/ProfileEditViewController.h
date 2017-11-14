//
//  ProfileEditViewController.h
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileEditViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{

}
@property (nonatomic,retain) IBOutlet UITableView *tableList;
@property (nonatomic,retain) IBOutlet UIView *viewPicture;
@property (nonatomic,retain) IBOutlet UIImageView *imageUser;

@property (nonatomic,retain) IBOutlet UIView *viewName;
@property (nonatomic,retain) IBOutlet UITextField *textName;

- (IBAction)actionEdit:(id)sender;

@end
