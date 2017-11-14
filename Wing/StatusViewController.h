//
//  StatusViewController.h
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusViewController : UIViewController{
    UITapGestureRecognizer *singleTap;
}

@property (nonatomic,retain) IBOutlet UITableView *tableList;
@property (nonatomic,retain) NSMutableArray *arrayStatus;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnEdit;

- (IBAction)actionEdit:(id)sender;

@end
