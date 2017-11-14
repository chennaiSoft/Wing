//
//  DYDotsView.h
//  DYDotsViewDemo
//
//  Created by Dwarven on 15/1/10.
//  Copyright (c) 2015年 Dwarven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYDotsView : UIView

@property(nonatomic, strong) UIColor * dotsColor;
@property(nonatomic, strong) NSNumber * numberOfDots;
@property(nonatomic, strong) NSNumber * duration;

- (void)startAnimating;
- (void)stopAnimating;

@end
