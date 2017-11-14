//
//  ImageGridViewController.m
//  TestApplication
//
//  Created by Theen on 28/04/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "ImageGridViewController.h"
#import "CollectionViewCellImages.h"
#import "CollectionReusableViewImages.h"
#import "ImageGridFullViewController.h"
#import "ChatStorageDB.h"
#import "Message.h"
#import "MessgaeTypeConstant.h"

@interface ImageGridViewController ()
{
    UIPanGestureRecognizer * _panRecognizer;
    CGPoint _panStartPoint;
    CGFloat _panStartOffset;
    CGFloat _targetOffset;

}
@end

@implementation ImageGridViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)swipeLeftToRight:(UISwipeGestureRecognizer*)sender{
    [self actionDone:nil];
}

- (void)viewDidLoad {
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeftToRight:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
   // [self.collectionViewImages addGestureRecognizer:swipe];
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self.view addGestureRecognizer:_panRecognizer];
    _panRecognizer.delegate = self;
    
    self.dictSelection = [[NSMutableDictionary alloc]init];
    
    [self.collectionViewImages registerNib:[UINib nibWithNibName:@"CollectionViewCellImages" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"Cell"];


    
    [self.collectionViewImages registerNib:[UINib nibWithNibName:@"CollectionReusableViewImages" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.toolBarForward setHidden:YES];
    
    
    
    self.collectionViewImages.allowsMultipleSelection = YES;


    //[self getRecords];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
   // self.navigationController.navigationBarHidden  =YES;

    self.navigationItem.rightBarButtonItem =self.btnSelect;
    self.navigationItem.leftBarButtonItem = self.btnDone;
    
    //self.viewTop.backgroundColor = [[UIApplication sharedApplication] keyWindow].
    
  //  self.editMode = YES;
    
    self.buttonCancel.hidden = YES;
    self.buttonDone.hidden = NO;
    self.buttonSelect.hidden = NO;

    
   // self.title = @"All Media";
}

#pragma mark CollectionView Methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [[self.fetchController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    CollectionViewCellImages *cell = (CollectionViewCellImages*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Message *messagess = [self.fetchController objectAtIndexPath:indexPath];

    
    if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
        cell.viewVideoMetadata.hidden = YES;
        [cell.imageThumb setImage:[UIImage imageWithData:messagess.image]];

    }
    else{
        cell.viewVideoMetadata.hidden = NO;
        if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){

            [cell.imageThumb setImage:[UIImage imageWithData:messagess.image]];
            
            [cell.imageIcon setBackgroundImage:[UIImage imageNamed:@"video_chat.png"] forState:UIControlStateNormal];

        }
        else{
            [cell.imageThumb setImage:[UIImage imageNamed:@"Audio_Sample.png"]];

            [cell.imageIcon setBackgroundImage:[UIImage imageNamed:@"speak_chat.png"] forState:UIControlStateNormal];

        }
        
        cell.labelTime.text = [Utilities durationOfVideoOrAudio:messagess.localid fileExt:messagess.file_ext];
        
    }
    

    
    
    
    cell.imageSelect.hidden = YES;
    
    if(self.editMode){
        if(cell.selected==YES){
            cell.imageSelect.hidden = NO;
        }
        
    }
    else{
        cell.selected = NO;
    }
    
    return cell;
    
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        static NSString *cellIdentifier = @"HeaderView";
        CollectionReusableViewImages *reusableview  = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
     
        
        reusableview.labelTitle.text = [[[self.fetchController sections] objectAtIndex:indexPath.section] name];
        
        if([reusableview.labelTitle.text isEqualToString:@""]){
            reusableview.labelTitle.text = @"";
        }
        else{
            reusableview.labelTitle.text = [[XMPPConnect sharedInstance]getDateFromat:reusableview.labelTitle.text];
        }
        
        return reusableview;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"select");
    if(self.editMode){
        
        
        
        if(self.toolBarForward.isHidden){
            [self viewUp:self.toolBarForward];
            [self.collectionViewImages setFrame:CGRectMake(0, self.collectionViewImages.frame.origin.y, self.collectionViewImages.frame.size.width, [UIScreen mainScreen].bounds.size.height-(self.toolBarForward.frame.size.height+64))];
        }
        
        [self.dictSelection setObject:@"yes" forKey:indexPath];
        
        CollectionViewCellImages *cell = (CollectionViewCellImages*)[self.collectionViewImages cellForItemAtIndexPath:indexPath];
        cell.selected = YES;
        cell.imageSelect.hidden = NO;
    }
    else{
        
        Message *messagess = [self.fetchController objectAtIndexPath:indexPath];

        
        NSMutableArray *arrayrecords = [[NSMutableArray alloc]init];
        
        if([self.isgroupchat isEqualToString:@"1"]){
            [arrayrecords addObjectsFromArray:[[ChatStorageDB sharedInstance] getMediaFilesForGroups:self.jid islocation:NO]];
        }
        else{
            [arrayrecords addObjectsFromArray:[[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:self.jid]];
            
        }
        
        int currentindex = 0;
        int presentindex = 0;

        for (NSManagedObject *s in arrayrecords) {
            if([[s valueForKey:@"localid"] isEqualToString:messagess.localid]){
                presentindex = currentindex;
                break;
            }
            
            currentindex++;
        }
        
        
        ImageGridFullViewController *imageFullView = [[ImageGridFullViewController alloc]init];
       // imageFullView.totalCount = 5;
        imageFullView.currentCount = presentindex;
        imageFullView.jid = self.jid;
        imageFullView.isgroupchat = self.isgroupchat;

        [[self navigationController]pushViewController:imageFullView animated:YES];
        
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"mullti select");
    if(self.editMode){
        [self.dictSelection removeObjectForKey:indexPath];
        CollectionViewCellImages *cell = (CollectionViewCellImages*)[self.collectionViewImages cellForItemAtIndexPath:indexPath];
        cell.selected = NO;
        cell.imageSelect.hidden = YES;
        
        if(self.collectionViewImages.indexPathsForSelectedItems.count==0){
            [self viewDone:self.toolBarForward];
             [self.collectionViewImages setFrame:CGRectMake(0, self.collectionViewImages.frame.origin.y, self.collectionViewImages.frame.size.width, [UIScreen mainScreen].bounds.size.height-64)];
        }
    }
}

#pragma mark Button Action

- (IBAction)actionSelect:(id)sender{
    [self.collectionViewImages reloadData];
    self.editMode = YES;
    self.navigationItem.rightBarButtonItem =self.btnCancel;
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    self.buttonDone.hidden = YES;
    self.buttonSelect.hidden = YES;
    self.buttonCancel.hidden = NO;


    
}
- (IBAction)actionCancel:(id)sender{
    [self.dictSelection removeAllObjects];

    self.editMode = NO;
    self.navigationItem.rightBarButtonItem =self.btnSelect;
    self.navigationItem.leftBarButtonItem = self.btnDone;
    [self.collectionViewImages reloadData];
    
    if(!self.toolBarForward.hidden){
        [self viewDone:self.toolBarForward];
        [self.collectionViewImages setFrame:CGRectMake(0, self.collectionViewImages.frame.origin.y, self.collectionViewImages.frame.size.width, [UIScreen mainScreen].bounds.size.height-64)];

    }
    
    self.buttonDone.hidden = NO;
    self.buttonSelect.hidden = NO;
    self.buttonCancel.hidden = YES;


}
- (IBAction)actionDone:(id)sender{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//    [app.mainMenuViewController hideMenuAnimated:YES];
//    return;
    
    CGRect frame = app.tabBarController.view.frame;
    frame.origin.x = 0;
    [app.tabBarController.view setFrame:frame];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromRight];
    [app.tabBarController.view.layer addAnimation:transition forKey:nil];
    
    [app.window bringSubviewToFront:app.tabBarController.view];

}
- (IBAction)actionForward:(id)sender{
    if(self.collectionViewImages.indexPathsForSelectedItems.count>0){
        actionSheetForward = [[UIActionSheet alloc]initWithTitle:@"Forward" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Forward (%lu)",(unsigned long)self.collectionViewImages.indexPathsForSelectedItems.count],@"Save",nil];
        [actionSheetForward showInView:self.view];
        
    }
}
- (IBAction)actionDelete:(id)sender{
    if(self.collectionViewImages.indexPathsForSelectedItems.count>0){
        actionSheetDelete = [[UIActionSheet alloc]initWithTitle:@"Delete" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Delete (%lu)",(unsigned long)self.collectionViewImages.indexPathsForSelectedItems.count],@"Delete All",nil];
        [actionSheetDelete showInView:self.view];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
//    if(actionSheet.cancelButtonIndex)
//        return;
    
    if(actionSheet==actionSheetForward){
        if(buttonIndex==0){
            [self forwardAction];
        }
        else if(buttonIndex==0){
            [self saveAction];
        }
    }
    else if(actionSheet==actionSheetDelete){
        if(buttonIndex==0){
            [self deleteSelectedAction];
        }
        else if(buttonIndex==0){
            [self deleteAllAction];
        }
    }
}

- (void)forwardAction{
 
    NSMutableArray *arrayobjects = [[NSMutableArray alloc]init];
        for (NSIndexPath *path in [self.dictSelection allKeys]) {
            Message *messagess = [self manageObject:path];
            [arrayobjects addObject:messagess];
        }

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [app.window sendSubviewToBack:self.view];

    CGRect frame = app.tabBarController.view.frame;
    frame.origin.x = 0;
    [app.tabBarController.view setFrame:frame];

    
    [self.dictSelection removeAllObjects];
    [self.collectionViewImages reloadData];
    [self viewDone:self.toolBarForward];
    
    self.editMode = NO;
    self.navigationItem.rightBarButtonItem =self.btnSelect;
    self.navigationItem.leftBarButtonItem = self.btnDone;
    
    self.buttonDone.hidden = NO;
    self.buttonSelect.hidden = NO;
    self.buttonCancel.hidden = YES;
    
    [self.collectionViewImages setFrame:CGRectMake(0, self.collectionViewImages.frame.origin.y, self.collectionViewImages.frame.size.width, self.collectionViewImages.frame.size.height+self.toolBarForward.frame.size.height+64)];


   // [app.thirdViewController forwardFromMedia:arrayobjects];
    
    //}
}

- (Message*)manageObject:(NSIndexPath *)indexPath{
    Message *messagess = [self.fetchController objectAtIndexPath:indexPath];
    
    return messagess;
}

- (void)saveAction{
    for (NSIndexPath *path in [self.dictSelection allKeys]) {
        Message *messagess = [self manageObject:path];
        if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
            [self saveImage:[Utilities getFilePathNew:messagess.localid :messagess.file_ext]];
        }
        else if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
            [self saveVideo:[Utilities getFilePathNew:messagess.localid :messagess.file_ext]];

            
        }
    }
}

- (void)saveImage:(NSString*)path{
   // if([[Utilities getMediaDownload] integerValue]==1){
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        UIImageWriteToSavedPhotosAlbum(image,
                                       self, // send the message to 'self' when calling the callback
                                       @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                       NULL);
   // }
    // [Utilities getFilePath:[s valueForKey:@"localid"] :type]
    
}

- (void)saveVideo:(NSString*)path{
   // if([[Utilities getMediaDownload] integerValue]==1){
        UISaveVideoAtPathToSavedPhotosAlbum(path,nil,nil,nil);
    //}
    
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
    }
}

- (void)deleteSelectedAction{
    if(self.dictSelection.count==0)
        return;
    
    for (NSIndexPath *path in self.dictSelection.allKeys) {
        NSManagedObject *s =[self.fetchController objectAtIndexPath:path];
        [[ChatStorageDB sharedInstance].managedObjectContext deleteObject:s];

    }
    [[ChatStorageDB sharedInstance].managedObjectContext save:nil];
    
    [self getRecords];
    [self.collectionViewImages reloadData];
    
    [[ChatStorageDB sharedInstance] updateChatSession:self.jid isgroupchat:[Utilities checkNil:self.isgroupchat]];


    
}
- (void)deleteAllAction{
    
    NSArray *array =[[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:self.jid];
    for (NSManagedObject *s in array) {
        [[ChatStorageDB sharedInstance].managedObjectContext deleteObject:s];
    }

    
//    NSArray *array = [self.fetchController fetchedObjects];
//    for (NSManagedObject *s in array) {
//        [[ChatStorageDB sharedInstance].managedObjectContext deleteObject:s];
//    }
    
    [[ChatStorageDB sharedInstance].managedObjectContext save:nil];
    
    [self getRecords];
    [self.collectionViewImages reloadData];
    
    [[ChatStorageDB sharedInstance] updateChatSession:self.jid isgroupchat:[Utilities checkNil:self.isgroupchat]];

}

#pragma mark View Up&Down Animation

- (void)viewUp:(UIToolbar*)toolBar{
    [toolBar setHidden:YES];

    [self.view addSubview:toolBar];
    [self.view bringSubviewToFront:toolBar];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [toolBar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-toolBar.frame.size.height, toolBar.frame.size.width, toolBar.frame.size.height)];
    [[toolBar layer] addAnimation:animation forKey:nil];
    [toolBar setHidden:NO];
}

- (void)viewDone:(UIToolbar*)toolBar{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [toolBar setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height+toolBar.frame.size.height, toolBar.frame.size.width, toolBar.frame.size.height)];
    [[toolBar layer] addAnimation:animation forKey:@"rightToLeftAnimation"];
    [self performSelector:@selector(hideBar) withObject:nil afterDelay:0.3];
}

- (void)hideBar{
    [self.toolBarForward setHidden:YES];
    [self.toolBarForward removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)animation{
    
    ImageGridFullViewController *imageFullView = [[ImageGridFullViewController alloc]init];
    imageFullView.totalCount = 5;
    imageFullView.currentCount = 1;

    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:imageFullView animated:NO];
}



- (void)getRecords{
    
    if(self.fetchController)
        self.fetchController = nil;
    
    
    NSManagedObjectContext *moc = [[ChatStorageDB sharedInstance] managedObjectContext];
    
    /*NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tbl_message"
     inManagedObjectContext:moc];*/
    
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc];
    
    NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sentdate" ascending:YES];
    //NSPredicate *predicate=[NSPredicate predicateWithFormat:@"NOT (status CONTAINS %@)",@"unavailable"];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    NSPredicate *predicate;
    predicate=[NSPredicate predicateWithFormat:@"(jid=%@ AND  (messagetype=%@ OR messagetype=%@ OR  messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@)) OR (jid=%@ AND  (messagetype=%@ OR messagetype=%@  OR messagetype=%@) AND (transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@ OR transferstatus=%@))",self.jid,[NSString stringWithFormat:@"%ld",(long)MessageTypeImage],[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo],[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed",self.jid,[NSString stringWithFormat:@"%ld",(long)MessageTypeImage],[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo],[NSString stringWithFormat:@"%ld",(long)MessageTypeAudio],[NSString stringWithFormat:@"%ld",(long)MessageTypeFile], @"downloadcompleted",@"uploadcompleted",@"uploadstart",@"uploadprogress",@"uploadfailed"];

    
    
    
    
    
    [fetchRequest setReturnsDistinctResults:YES];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //    [fetchRequest setFetchBatchSize:10];
    [fetchRequest setPredicate:predicate];
    
    
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:moc
                            
                                                                 sectionNameKeyPath:@"datestring"
                                                                          cacheName:nil];
    // [self.fetchController setDelegate:self];
    
    
    
    
    
    
    NSError *error = nil;
    if (![self.fetchController performFetch:&error])
    {
        
        NSLog(@"Error performing fetch: %@", error);
        
    }
}

- (void)reloadTable:(NSString*)jidten isgrouchattemp:(NSString*)isgrouchattemp{
    self.jid = jidten;
    self.isgroupchat = isgrouchattemp;
    [self getRecords];
    [self.collectionViewImages reloadData];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) panHandler: (UIPanGestureRecognizer *)gesture
{
    CGPoint current = [gesture translationInView:self.view];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    //CGPoint current = [sender translationInView:app.tabBarController.view];
    NSLog(@"swipe left to right %f",current.x);
    
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan: {
            self.paneStartLocation = [gesture locationInView:app.tabBarController.view];
            self.paneVelocity = 0.0;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint panLocationInPaneView = [gesture locationInView:app.tabBarController.view];
            // Pane Sliding
            CGRect newFrame = app.tabBarController.view.frame;
            
            newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
            if (newFrame.origin.x < 0.0) {
                newFrame.origin.x = 0;
            } else if (newFrame.origin.x > 250) {
                //newFrame.origin.x = (320 + nearbyintf(sqrtf((newFrame.origin.x - 320) * 2.0)));
                newFrame.origin.x = SCREEN_WIDTH;
            }
            
            if(newFrame.origin.x<=0){
                newFrame.origin.x = 0;
            }
            
            //if(newFrame!=NAN){
            app.tabBarController.view.frame = newFrame;
            
            //}
            
            CGFloat velocity;
            velocity = -(self.paneStartLocation.x - panLocationInPaneView.x);
            if (velocity != 0) {
                self.paneVelocity = velocity;
                
            }
            break;
            
        }
            
        case UIGestureRecognizerStateCancelled: {
            
            
            break;
        }
            
        case UIGestureRecognizerStateFailed: {
            
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGPoint panLocationInPaneView = [gesture locationInView:app.tabBarController.view];
            // Pane Sliding
            CGRect newFrame = app.tabBarController.view.frame;
            
            newFrame.origin.x += (panLocationInPaneView.x - self.paneStartLocation.x);
            if (newFrame.origin.x < 0.0) {
                newFrame.origin.x = 0;
            } else if (newFrame.origin.x > 250) {
                //newFrame.origin.x = (320 + nearbyintf(sqrtf((newFrame.origin.x - 320) * 2.0)));
                newFrame.origin.x = SCREEN_WIDTH;
            }
            else{
                newFrame.origin.x = 0;
            }
            
            if(newFrame.origin.x<=0){
                newFrame.origin.x = 0;
            }
            
            //if(newFrame!=NAN){
            app.tabBarController.view.frame = newFrame;
            
        }
            break;
            
    }
}


@end
