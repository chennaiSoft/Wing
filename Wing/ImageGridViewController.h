//
//  ImageGridViewController.h
//  TestApplication
//
//  Created by Theen on 28/04/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ImageGridViewController : UIViewController{
    UIActionSheet *actionSheetForward;
    UIActionSheet *actionSheetDelete;

}

@property (nonatomic,strong) IBOutlet UICollectionView *collectionViewImages;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *btnDone;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *btnSelect;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *btnCancel;
@property (nonatomic,strong) IBOutlet UIToolbar *toolBarForward;
@property (nonatomic,strong) NSString *jid;
@property (nonatomic,strong) NSString *isgroupchat;

@property (nonatomic,strong) IBOutlet UIButton *buttonCancel;
@property (nonatomic,strong) IBOutlet UIButton *buttonDone;
@property (nonatomic,strong) IBOutlet UIButton *buttonSelect;



@property (nonatomic,retain) IBOutlet UIView *viewTop;

@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) NSMutableDictionary *dictSelection;

- (void)reloadTable:(NSString*)jidten isgrouchattemp:(NSString*)isgrouchattemp;

@property (nonatomic) BOOL editMode;
@property (weak, nonatomic) id delegate;
@property (nonatomic, assign) CGPoint paneStartLocation;
@property (nonatomic, assign) CGPoint paneStartLocationInSuperview;
@property (nonatomic, assign) CGFloat paneVelocity;


- (IBAction)actionSelect:(id)sender;
- (IBAction)actionCancel:(id)sender;
- (IBAction)actionDone:(id)sender;
- (IBAction)actionForward:(id)sender;
- (IBAction)actionDelete:(id)sender;

@end
