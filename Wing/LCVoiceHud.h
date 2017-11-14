//
//  LCVoiceHud.h
//  LCVoiceHud
//
//  Created by 郭历成 on 13-6-21.
//  Contact titm@tom.com
//  Copyright (c) 2013年 Wuxiantai Developer Team.(http://www.wuxiantai.com) All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCVoiceHud : UIView

@property(nonatomic) float progress;
@property (nonatomic,retain) UIView *baseView;
-(void) setLabelTime:(NSString*)stringTime;
-(void) show;
-(void) hide;

@end
