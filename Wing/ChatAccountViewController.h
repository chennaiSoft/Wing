//
//  ChatAccountViewController.h
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatAccountViewController : UIViewController
@property (nonatomic,retain) IBOutlet UITableView *tableList;
@property (nonatomic,retain) NSMutableArray *arrayValues;

@end