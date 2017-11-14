//
//  CollectionViewCellImagesFull.h
//  TestApplication
//
//  Created by Theen on 29/04/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCellImagesFull : UICollectionViewCell
@property (nonatomic,weak) IBOutlet UIImageView *imageFullView;
@property (nonatomic,weak) IBOutlet UIView *mediaSliderView;
@property (nonatomic,weak) IBOutlet UISlider *sliderMedia;
@property (nonatomic,weak) IBOutlet UILabel *labelCurrentTime;
@property (nonatomic,weak) IBOutlet UILabel *labelTotalTime;

@end
