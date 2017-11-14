//
//  Passcode.h
//  iVideo player
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class folderItem;
@class Passcode;

@protocol PasscodeDelegate <NSObject>

@optional

-(void)passcodeSucceded;
-(void)passcodeValidated:(NSString*)strjid isgroupchat:(NSString*)isgroupchat;

-(void)passcodeSucceded:(BOOL)isEditingPlaylist;

@end

@interface Passcode : UIViewController<UITextFieldDelegate>{
    IBOutlet UIButton *btnCancel;
    IBOutlet UIScrollView *scrollView;
}

@property(nonatomic, assign) id<PasscodeDelegate> delegate;

@property(nonatomic, retain) IBOutlet UIImageView *imageOne;
@property(nonatomic, retain) IBOutlet UIImageView *imageTwo;
@property(nonatomic, retain) IBOutlet UIImageView *imageThree;
@property(nonatomic, retain) IBOutlet UIImageView *imageFour;

@property(nonatomic, retain) IBOutlet UILabel     *lblHeading;
@property(nonatomic, retain) IBOutlet UILabel     *lblTitle;
@property(nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic, retain) UITextField *tmpTextField;
@property(nonatomic, copy) NSString    *strPassCode;
@property(nonatomic, retain) NSMutableString    *stringGetPassword;

@property(nonatomic) BOOL checkForPasscodeSetup;
@property(nonatomic) BOOL checkForPasscodeOff;
@property(nonatomic) BOOL checkForInitialLoad;
@property(nonatomic) BOOL checkForUnHide;



//variables for folder lock functionalities

@property(nonatomic,retain) NSString *fromWhichScreen;
@property(nonatomic) BOOL isEditing;
@property(nonatomic, copy) NSString *stringPasscode;
@property(nonatomic,retain) NSString *stringJid;
@property(nonatomic,retain) NSString *isgroupchat;




-(IBAction)actionCancel:(id)sender;
- (IBAction)actionZeroToNine:(id)sender;
- (IBAction)actionDelete:(id)sender;

@end
