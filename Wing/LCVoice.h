
#import <Foundation/Foundation.h>
#import "LCVoiceHud.h"

@interface LCVoice : NSObject

@property(nonatomic,retain) NSString * recordPath;
@property(nonatomic) float recordTime;
@property (nonatomic,retain) UIView *baseView;

-(void) startRecordWithPath:(NSString *)path;
-(void) stopRecordWithCompletionBlock:(void (^)())completion;
-(void) cancelled;
- (void)showView;
@end
