//
//  ImageGridFullViewController.h
//  TestApplication
//
//  Created by Theen on 29/04/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <CoreData/CoreData.h>

@interface ImageGridFullViewController : UIViewController
@property (nonatomic,strong) IBOutlet UICollectionView *collectionViewImages;

@property (nonatomic,weak) IBOutlet UIBarButtonItem *btnForward;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *btnPrev;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *btnNext;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *btnPlay;
@property (nonatomic,weak) IBOutlet UIBarButtonItem *btnTrash;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic,weak) IBOutlet UISlider *sliderMedia;
@property (nonatomic,weak) IBOutlet UILabel *labelCurrentTime;
@property (nonatomic,weak) IBOutlet UILabel *labelTotalTime;
@property (nonatomic) int totalCount;
@property (nonatomic) int currentCount;
@property (nonatomic,strong) NSString *jid;
@property (nonatomic,strong) NSString *isgroupchat;
@property (nonatomic,strong) NSMutableArray *arrayrecords;
@property (strong, nonatomic) NSFetchedResultsController *fetchController;
@property (strong, nonatomic) NSIndexPath *commonPath;


- (IBAction)actionForward:(id)sender;
- (IBAction)actionPrev:(id)sender;
- (IBAction)actionNext:(id)sender;
- (IBAction)actionPlayOrPause:(id)sender;
- (IBAction)actionDelete:(id)sender;


@end
