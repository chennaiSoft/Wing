//
//  AddPeopleViewController.h
//  ChatApp
//
//  Created by theen on 08/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GridSelectViewController.h"

@protocol addPeopleDelegate <NSObject>

@optional

- (void)addUsers:(NSMutableArray*)array;

@end

@interface AddPeopleViewController : UIViewController<UIGestureRecognizerDelegate>{
    IBOutlet UITableView *tableViewList;
    
    NSMutableArray *arrayUsers;
    
    NSFetchedResultsController *fetchRequestController;
    
    //IBOutlet UISearchBar *searchBar;
    
    id<addPeopleDelegate> delegate;
    

    UITapGestureRecognizer *singleTap;
    
    GridSelectViewController *gridView;
}
@property (nonatomic,retain)GridSelectViewController *gridView;

@property (nonatomic,retain)NSFetchedResultsController *fetchRequestController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton1;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, weak)  id<addPeopleDelegate> delegate;
@property (nonatomic,retain) NSMutableArray *alphabetsArray;
@property (nonatomic,retain) NSMutableDictionary *disctSelection;

@property (nonatomic, strong) NSString *pageType;;


- (IBAction)actionCancel:(id)sender;
- (IBAction)actionDone:(id)sender;

@end
