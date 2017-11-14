//
//  CSGroupTableViewCell.h
//  Wing
//
//  Created by CSCS on 27/07/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSGroupTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel * descriptionLabel;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * iconImageView;
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIButton * btnWings;

@end
