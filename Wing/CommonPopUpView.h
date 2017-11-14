//
//  CommonPopUpView.h
//  ChataZap
//
//  Created by Rifluxyss on 5/2/14.
//  Copyright (c) 2014 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol popUpViewDelegate <NSObject>

@optional
-(void)popupviewclick:(NSMutableDictionary*)dictoutput;

@end

@interface CommonPopUpView : UIView{
    
    UIImageView *userImageView;
    NSString *strSenderName;
    NSString *stringMessage;
    UIButton *btnClose;
    NSMutableDictionary *dictResponse;
    
    UILabel *labelName;
    UILabel *labelMessage;
    
    NSTimer *timerShow;
    
    UIViewController *currentViewController;
    
    id<popUpViewDelegate> delegate;

}

@property(nonatomic,retain)NSMutableDictionary *dictResponse;
@property(nonatomic,retain)UIViewController *currentViewController;
@property(nonatomic,strong)id<popUpViewDelegate> delegate;

@property(nonatomic,retain)    UIImageView *userImageView;
@property(nonatomic,retain)    NSString *strSenderName;
@property(nonatomic,retain)    NSString *stringMessage;
@property(nonatomic,retain)    UIButton *btnClose;
@property(nonatomic,retain)    UILabel *labelName;
@property(nonatomic,retain)    UILabel *labelMessage;


-(void)show:(UIViewController*)viewControll;

+ (CommonPopUpView*)sharedInstance;


@end
