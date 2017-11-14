//
//  CommonPopUpView.m
//  ChataZap
//
//  Created by Rifluxyss on 5/2/14.
//  Copyright (c) 2014 Rifluxyss. All rights reserved.
//

#import "CommonPopUpView.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"

@implementation CommonPopUpView

@synthesize userImageView;
@synthesize strSenderName;
@synthesize stringMessage;
@synthesize btnClose;
@synthesize labelName;
@synthesize labelMessage;
@synthesize dictResponse;
@synthesize currentViewController;
@synthesize delegate;
static CommonPopUpView *shared = NULL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dictResponse = [[NSMutableDictionary alloc]init];
        [self setBackgroundColor:[UIColor colorWithRed:253.0/255.0 green:195.0/255.0 blue:12.0/255.0 alpha:1.0]];
        [self setAlpha:0.95];
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80);

        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        
        if(!self.userImageView){
            self.userImageView  = [[UIImageView alloc]init];
        }
        
        self.userImageView.layer.cornerRadius = 2.0;
        self.userImageView.layer.borderWidth = 1.0;
        self.userImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.userImageView.layer.masksToBounds = YES;
        self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.userImageView setFrame:CGRectMake(10, 20, 50, 50)];
        [self.userImageView setImage:[UIImage imageNamed:@"m_user_list_image.png"]];
        [self.userImageView setAlpha:1.0];
        [self addSubview:self.userImageView];
        
        if(!self.labelName){
            self.labelName  = [[UILabel alloc]init];
        }
        
        [self.labelName setFrame:CGRectMake(70, 15, 150, 30)];
        [self.labelName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
        [self.labelName setTextColor:[UIColor whiteColor]];
        [self.labelName setAlpha:1.0];
        [self addSubview:self.labelName];
        
        if(!self.labelMessage){
            self.labelMessage  = [[UILabel alloc]init];
        }
        
        [self.labelMessage setFrame:CGRectMake(70, 45, 150, 30)];
        [self.labelMessage setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [self.labelMessage setTextColor:[UIColor whiteColor]];
        [self.labelMessage setAlpha:1.0];
        [self addSubview:self.labelMessage];
        
        UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callclick:)];
        recog.numberOfTapsRequired =1;
        [self addGestureRecognizer:recog];
        
    }
    return self;
}

-(void)callclick:(UIGestureRecognizer*)recog{
    [self.delegate popupviewclick:self.dictResponse];
}

+ (CommonPopUpView*)sharedInstance
{
	if ( !shared || shared == NULL)
	{
		shared = [[CommonPopUpView alloc] init];
	}
	return shared;
}

-(void)show:(UIViewController*)viewControll{
    
    if(timerShow){
        [timerShow invalidate];
        timerShow = nil;
    }

    self.currentViewController = viewControll;
    
    if(self.hidden){
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.4;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        self.hidden = NO;
        [self.layer addAnimation:transition forKey:kCATransition];
    }
   
    NSLog(@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[labelName.text lowercaseString]]]);
    
    
    userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
    userImageView.clipsToBounds = YES;
    
    [userImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[self.dictResponse valueForKey:@"jid"]]] placeholderImage:[UIImage imageNamed:@"ment.png"]];
    
    [self.userImageView setNeedsDisplay];
    timerShow = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                 target:self
                                               selector:@selector(timerStop:)
                                               userInfo:nil
                                                repeats:NO];
    
    [viewControll.view addSubview:self];
    [viewControll.view bringSubviewToFront:self];
}

-(void)timerStop:(NSTimer*)timer{
    if(timerShow){
        [timerShow invalidate];
        timerShow = nil;
    }
    
    [self hide];
}

-(void)hide{
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    self.hidden = YES;
    [self.layer addAnimation:transition forKey:kCATransition];
}

@end
