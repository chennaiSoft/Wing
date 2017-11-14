//
//  CommonGroupsViewController.h
//  ChatApp
//
//  Created by Theen on 19/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonGroupsViewController : UIViewController{
    UIActionSheet *actionSheetMore;
    UIActionSheet *actionSheetMore1;
    NSIndexPath *indexPathCommon;
    UIActionSheet *actionSheetEmailChat;
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBarTop;
@property (nonatomic, strong) NSMutableArray *arraymessages;
@property(nonatomic, strong) IBOutlet UITableView *tableViewList;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editBtn;
@property (nonatomic, strong) NSMutableArray *arraytempmessages;

@property(nonatomic, strong) NSString *stringUserid;

@end
