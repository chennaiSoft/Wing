//
//  AddToContactsViewController.h
//  TestProject
//
//  Created by Theen on 10/02/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddToContactsViewController : UIViewController{
    IBOutlet UITableView *tableList;
    IBOutlet UIImageView *imageUser;
    IBOutlet UILabel     *userName;

}

@property (nonatomic,retain) NSMutableArray *arrayJsonValues;
@property (nonatomic,retain) NSString *stringUsername;
@property (nonatomic,retain) UIImage *userImage;

- (IBAction)actionSaveContacts:(id)sender;

@end
