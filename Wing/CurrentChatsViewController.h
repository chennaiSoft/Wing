//
//  CurrentChatsViewController.h
//  ChatApp
//
//  Created by Theen on 11/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"
#import <CoreData/CoreData.h>

@interface CurrentChatsViewController : UIViewController{
    NSIndexPath *indexPathCommon;
    
    IBOutlet UISegmentedControl *segmentControl;
    
    UIActionSheet *sheetForward;
    UIActionSheet *sheetForward1;
    UIActionSheet *sheetForward2;

    
    int selectType;
    
    IBOutlet UIButton *btnChats;
    IBOutlet UIButton *btnContact;
    IBOutlet UIButton *btnGroups;


}
@property (nonatomic, strong) NSMutableArray *arrayObjects;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sendBtn;
@property(nonatomic,retain) IBOutlet UITableView *tableViewList;
@property(nonatomic,retain) NSFetchedResultsController *fetchRequestController;
@property (nonatomic) BOOL pageFromProfile;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) NSMutableArray *alphabetsArray;
@property (nonatomic,retain) NSMutableDictionary *disctSelection;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sendButton;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionSegmentTouch:(id)sender;
- (IBAction)actionSend;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
- (IBAction)actionAdd:(id)sender;

- (IBAction)actionOptionSelect:(id)sender;
@end
