//
//  BlockedViewController.h
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BlockedViewController : UIViewController{
    IBOutlet UITableView *tableViewList;
    
    UIActionSheet *actionSheetDelete;
    NSFetchedResultsController *fetchRequestController;
    
    UITapGestureRecognizer *gesture1;
    
    UITapGestureRecognizer *singleTap;
}

@property (nonatomic,retain)NSFetchedResultsController *fetchRequestController;
@property (nonatomic,retain) NSMutableArray *alphabetsArray;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleteBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelBtn;
@property (nonatomic,retain)  NSString *searchString;

- (IBAction)actionAdd;
- (IBAction)actionEdit;
- (IBAction)actionDelete;
- (IBAction)actionCancel;

@end
