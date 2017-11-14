
#import "LCVoice.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - <DEFINES>

#define WAVE_UPDATE_FREQUENCY   0.05

#pragma mark - <CLASS> LCVoice

@interface LCVoice () <AVAudioRecorderDelegate>
{
   NSTimer * timer_;
   LCVoiceHud * voiceHud_;
}

@property(nonatomic,retain) AVAudioRecorder * recorder;

@end

@implementation LCVoice

- (id)init{

    return self;
}

- (void)showView{
     [self showVoiceHudOrHide:YES];
}

#pragma mark - Publick Function

- (void)startRecordWithPath:(NSString *)path
{    
    NSError * err = nil;
    
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
	if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
	}
    
	[audioSession setActive:YES error:&err];
    
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
	}
	
	NSMutableDictionary * recordSetting = [NSMutableDictionary dictionary];
	
	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
	[recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
	[recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
	
/*
	[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
*/
     
	self.recordPath = path;
	NSURL * url = [NSURL fileURLWithPath:self.recordPath];
	
	err = nil;
	
	NSData * audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    
	if(audioData)
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:[url path] error:&err];
	}
	
	err = nil;
    
    if(self.recorder){
        [self.recorder stop];
        self.recorder = nil;
    }
    
	self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    
	if(!_recorder){
        
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [err localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        return;
	}
	
	[_recorder setDelegate:self];
	[_recorder prepareToRecord];
	_recorder.meteringEnabled = YES;
	
//	BOOL audioHWAvailable = audioSession.inputIsAvailable;
//	if (! audioHWAvailable) {
//        UIAlertView *cantRecordAlert =
//        [[UIAlertView alloc] initWithTitle: @"Warning"
//								   message: @"Audio input hardware not available"
//								  delegate: nil
//						 cancelButtonTitle:@"OK"
//						 otherButtonTitles:nil];
//        [cantRecordAlert show];
//        return;
//	}
	
	[_recorder recordForDuration:(NSTimeInterval) 60];
    
    self.recordTime = 0;
    [self resetTimer];
    
	timer_ = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) recorder  successfully:(BOOL)flag
{
    NSLog(@"DONE");
}

- (void) audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *) recorder error:(NSError *) error
{
    NSLog(@"ERROR");
}

- (void) stopRecordWithCompletionBlock:(void (^)())completion
{
    _recorder.delegate = nil;
    
    dispatch_async(dispatch_get_main_queue(),completion);

    [self resetTimer];
    [self showVoiceHudOrHide:NO];
}

#pragma mark - Timer Update

- (void)updateMeters {
    
    self.recordTime += WAVE_UPDATE_FREQUENCY;
    
    NSLog(@"%f",self.recordTime);
    
    if (voiceHud_)
    {
        int minutes = floor(_recorder.currentTime/60);
        int seconds = _recorder.currentTime - (minutes * 60);
        
        if (_recorder) {
            [_recorder updateMeters];
        }
    
        float peakPower = [_recorder averagePowerForChannel:0];
        double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
    
        [voiceHud_ setProgress:peakPowerForChannel];
        if(seconds>9){
            [voiceHud_ setLabelTime:[NSString stringWithFormat:@"0%d:%d",minutes,seconds]];
        }
        else{
            [voiceHud_ setLabelTime:[NSString stringWithFormat:@"0%d:0%d",minutes,seconds]];
        }
        
    }
}

#pragma mark - Helper Function

-(void) showVoiceHudOrHide:(BOOL)yesOrNo{
    
    if (voiceHud_) {
        [voiceHud_ hide];
       // voiceHud_ = nil;
    }
    
    if (yesOrNo) {
        
        voiceHud_ = [[LCVoiceHud alloc] init];
        voiceHud_.baseView = self.baseView;
        [voiceHud_ show];
        //[voiceHud_ release];
        
    }else{
        
    }
}

-(void) resetTimer
{    
    if (timer_) {
        [timer_ invalidate];
        timer_ = nil;
    }
    
     [voiceHud_ setLabelTime:@"00:00"];
}

-(void) cancelRecording
{
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    self.recorder = nil;    
}

- (void)cancelled {
    [voiceHud_ setLabelTime:@"00:00"];
    [self showVoiceHudOrHide:NO];
    [self resetTimer];
    [self cancelRecording];
}

#pragma mark - LCVoiceHud Delegate

-(void) LCVoiceHudCancelAction
{
    [self cancelled];
}

@end
