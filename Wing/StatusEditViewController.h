//
//  StatusEditViewController.h
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusEditViewController : UIViewController{
    
}

@property (nonatomic,retain) IBOutlet UITableView *tableList;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnDeleteAll;
@property (nonatomic,retain) NSMutableArray *arrayStatus;


- (IBAction)actionDeleteAll:(id)sender;

@end
