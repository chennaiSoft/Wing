//
//  ImageGridFullViewController.m
//  TestApplication
//
//  Created by Theen on 29/04/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "ImageGridFullViewController.h"
#import "CollectionViewCellImagesFull.h"
#import "ChatStorageDB.h"
#import "Message.h"
#import "MessgaeTypeConstant.h"

@interface ImageGridFullViewController ()

@end

@implementation ImageGridFullViewController

- (void)viewDidLoad {
    [self.collectionViewImages registerNib:[UINib nibWithNibName:@"CollectionViewCellImagesFull" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"CellFullView"];
    
    
    self.arrayrecords = [[NSMutableArray alloc]init];
    
    if([self.isgroupchat isEqualToString:@"1"]){
        [self.arrayrecords addObjectsFromArray:[[ChatStorageDB sharedInstance] getMediaFilesForGroups:self.jid islocation:NO]];
    }
    else{
        [self.arrayrecords addObjectsFromArray:[[ChatStorageDB sharedInstance]getMediaFiles:[Utilities getSenderId] receiver:self.jid]];

    }
    
    self.totalCount = self.arrayrecords.count;
    
    [self scrollToPosition:self.currentCount];
    
    if(self.totalCount==0){
        self.btnNext.enabled = NO;
        self.btnNext.enabled = NO;
    }
    
    if(self.currentCount<=0){
        [self.btnPrev setEnabled:NO];
    }
    if(self.currentCount>=self.totalCount-1){
        [self.btnNext setEnabled:NO];
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark CollectionView Methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arrayrecords.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellFullView";
    CollectionViewCellImagesFull *cell = (CollectionViewCellImagesFull*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
  
    Message *messagess = [self.arrayrecords objectAtIndex:indexPath.row];
    if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
        [cell.mediaSliderView setHidden:YES];
        [cell.imageFullView setImage:[UIImage imageWithContentsOfFile:[Utilities getFilePathNew:messagess.localid :messagess.file_ext]]];
    }
    else{
        [cell.mediaSliderView setHidden:NO];
        if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeVideo]]){
            [cell.imageFullView setImage:[UIImage imageWithData:messagess.image]];
        }
        else{
            [cell.imageFullView setImage:[UIImage imageNamed:@"Audio_Sample.png"]];
        }
        
        cell.labelTotalTime.text = [Utilities durationOfVideoOrAudio:messagess.localid fileExt:messagess.file_ext];
        
        cell.labelCurrentTime.text = @"00:00:00";
        cell.sliderMedia.value = 0.0f;

    }
    
   // cell.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-44);
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.x);
    self.currentCount = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width;
    [self scrollToPosition:self.currentCount];
    [self.btnPrev setEnabled:YES];
    [self.btnNext setEnabled:YES];

    if(self.currentCount<=0){
        [self.btnPrev setEnabled:NO];
    }
    if(self.currentCount>=self.totalCount-1){
        [self.btnNext setEnabled:NO];
    }
}


#pragma mark Button Actions

- (IBAction)actionForward:(id)sender{
    
}
- (IBAction)actionPrev:(id)sender{
    if(self.currentCount<=0){
        self.btnPrev.enabled = NO;
        return;
    }
    self.btnNext.enabled = YES;
    self.btnPrev.enabled = YES;
    self.currentCount --;
    [self scrollToPosition:self.currentCount];
    
    if(self.currentCount==0){
        self.btnPrev.enabled = NO;
    }
}
- (IBAction)actionNext:(id)sender{
    self.currentCount ++;
    if(self.currentCount>=self.totalCount){
        self.currentCount = self.totalCount-1;
        self.btnNext.enabled = NO;
        return;
    }
    self.btnNext.enabled = YES;
    self.btnPrev.enabled = YES;
    
    [self scrollToPosition:self.currentCount];
    
     if(self.currentCount==self.totalCount-1){
          self.btnNext.enabled = NO;
         
     }
}
- (IBAction)actionPlayOrPause:(id)sender{
    if(self.btnPlay.tag==0){
        
        Message *messages = [self.arrayrecords objectAtIndex:self.currentCount];
        
        self.btnPlay.style = UIBarButtonSystemItemPause;
        [self.btnPlay setTag:1];
        
        if(self.moviePlayer){
            if(self.moviePlayer.moviePlayer.playbackState==MPMoviePlaybackStatePlaying||self.moviePlayer.moviePlayer.playbackState==MPMoviePlaybackStatePaused){
                [self.moviePlayer.moviePlayer play];
                return;
            }
        }
        
        NSString *filepath   =   [Utilities getFilePathNew:messages.localid :messages.file_ext];
        NSURL    *fileURL    =   [NSURL fileURLWithPath:filepath];
        [self playAction:fileURL];
        
    }
    else{
        [self.btnPlay setTag:0];
        self.btnPlay.style = UIBarButtonSystemItemPlay;
        [self.moviePlayer.moviePlayer pause];
    }
}
- (IBAction)actionDelete:(id)sender{
    
}


- (void)scrollToPosition:(int)count{
    NSIndexPath *path = [NSIndexPath indexPathForItem:count inSection:0];
    [self.collectionViewImages scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    self.title = [NSString stringWithFormat:@"%d of %d",count+1,self.totalCount];
    
    Message *messagess = [self.arrayrecords objectAtIndex:path.row];
    if([messagess.messagetype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
        self.btnPlay.tintColor = [UIColor clearColor];

    }
    else{
        self.btnPlay.tintColor = [UIColor blackColor];
    }
}

- (void)playAction:(NSURL*)fileUrl{
    
    if(self.moviePlayer){
        self.moviePlayer = nil;
    }
    
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.currentCount inSection:0];
     CollectionViewCellImagesFull *cell = (CollectionViewCellImagesFull*)[self.collectionViewImages cellForItemAtIndexPath:path];
    
    self.sliderMedia = cell.sliderMedia;
    self.labelCurrentTime= cell.labelCurrentTime;
    self.labelTotalTime = cell.labelTotalTime;
    
    self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileUrl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackComplete:)
                                                 name:@"MPMoviePlayerPlaybackDidFinishNotification"
                                               object:self.moviePlayer.moviePlayer];
    
    [self.moviePlayer.view setFrame:cell.imageFullView.frame];
    [cell.contentView addSubview:self.moviePlayer.view];
    self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    self.sliderMedia.value = 0.0;
    self.labelCurrentTime.text=[NSString stringWithFormat:@"%f",self.sliderMedia.value];
    self.labelTotalTime.text=[NSString stringWithFormat:@"%f",self.moviePlayer.moviePlayer.playableDuration];
    
    [self.moviePlayer.moviePlayer play];
}

- (void)moviePlaybackComplete:(NSNotification*)info{
    [self.moviePlayer.moviePlayer stop];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
