//
//  RecordViewController.m
//  GrowingTextViewExample
//
//  Created by Theen on 11/02/15.
//
//

#import "RecordViewController.h"

@interface RecordViewController ()

@property (assign, nonatomic) BOOL isRecording;
@end

@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     self.voice = [[LCVoice alloc] init];
    
    [buttonRecord addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    
    self.voice.baseView = self.view;
    
    [self.voice showView];
    
    [self.view bringSubviewToFront:buttonRecord];
}

- (void) recordStart
{
    if (self.isRecording == NO) {
        self.isRecording = YES;
        [buttonRecord setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.voice startRecordWithPath:[NSString stringWithFormat:@"%@/Documents/MySound.caf", NSHomeDirectory()]];
    }
    else{
        self.isRecording = NO;
        [self recordEnd];
    }
}

-(void) recordEnd
{
    [self.voice stopRecordWithCompletionBlock:^{
        
        [buttonRecord setBackgroundImage:[UIImage imageNamed:@"mic_normal_358x358.png"] forState:UIControlStateNormal];

        if (self.voice.recordTime > 0.0f) {
            self.voice.recordTime = 0.0;
          //  [[NSNotificationCenter defaultCenter] postNotificationName:@"recordComplete" object:self];
        }
    }];
}

-(void) recordCancel
{
    [self.voice cancelled];
    
    [buttonRecord setBackgroundImage:[UIImage imageNamed:@"mic_normal_358x358.png"] forState:UIControlStateNormal];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"Cancelled" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
