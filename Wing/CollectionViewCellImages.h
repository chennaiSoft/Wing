//
//  CollectionViewCellImages.h
//  TestApplication
//
//  Created by Theen on 28/04/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCellImages : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imageThumb;
@property (nonatomic,weak) IBOutlet UIView *viewVideoMetadata;
@property (nonatomic,weak) IBOutlet UILabel *labelTime;
@property (nonatomic,weak) IBOutlet UIImageView *imageSelect;
@property (nonatomic,weak) IBOutlet UIButton *imageIcon;


@end
