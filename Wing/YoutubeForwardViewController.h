//
//  YoutubeForwardViewController.h
//  ChatApp
//
//  Created by theen on 25/04/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface YoutubeForwardViewController : UIViewController{
    
    NSIndexPath *indexPathCommon;
    // IBOutlet UISearchBar *searchBar;
    
    
    UIActionSheet *sheetForward;
    UIActionSheet *sheetForward1;
    UIActionSheet *sheetForward2;
    
    
    int selectType;
    
    IBOutlet UIButton *btnChats;
    IBOutlet UIButton *btnContact;
    IBOutlet UIButton *btnGroups;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic,retain) IBOutlet UITableView *tableViewForward;
@property (strong, nonatomic) UISearchController *searchController;
@property(nonatomic,retain) NSFetchedResultsController *fetchRequestController;
@property (nonatomic, strong) NSMutableArray *alphabetsArray;
@property (nonatomic,retain) NSMutableDictionary *disctSelection;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,strong) NSString *searchstring;

@property(nonatomic,strong)id inputResult;
@property(nonatomic,strong)NSMutableArray *arrayInputs;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionSend;
- (IBAction)actionAdd:(id)sender;
- (IBAction)actionOptionSelect:(id)sender;

@end
