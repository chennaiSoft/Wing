//
//  RecordViewController.h
//  GrowingTextViewExample
//
//  Created by Theen on 11/02/15.
//
//

#import <UIKit/UIKit.h>

#import "LCVoice.h"

@interface RecordViewController : UIViewController{
    IBOutlet UIButton *buttonRecord;
    IBOutlet UILabel *labelTime;
}

@property(nonatomic,retain) LCVoice * voice;


@end
