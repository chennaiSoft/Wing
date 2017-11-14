//
//  CSFriendsTableViewCell.h
//  Wing
//
//  Created by CSCS on 2/8/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSFriendsObjects.h"

@interface CSFriendsTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) CSFriendsObjects * friendsObj;
@property (nonatomic, strong) UIImageView * selectImageView;
@property (nonatomic, strong) UIButton * btnWings;
- (void)updateValues;
@end
