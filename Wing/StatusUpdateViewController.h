//
//  StatusUpdateViewController.h
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol statusUpdateDelegate <NSObject>

- (void)statusUpdate:(NSString*)statusmessages :(NSInteger)statusidselected;

@end

@interface StatusUpdateViewController : UIViewController{
}


@property (nonatomic,retain) id<statusUpdateDelegate> deletgate;
@property (nonatomic,retain) IBOutlet UITextView *textViewStatus;

@property (nonatomic) NSInteger *statusID;
@property (nonatomic,retain) NSString *statusMessage;
@property (nonatomic) BOOL pageFromStatus;

@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnCancel;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *btnDone;


- (IBAction)actionCancel:(id)sender;
- (IBAction)actionDone:(id)sender;


@end
