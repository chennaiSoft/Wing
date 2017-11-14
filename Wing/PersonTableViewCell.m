//
//  PersonTableViewCell.m
//  Wing
//
//  Created by CSCS on 2/19/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "PersonTableViewCell.h"

static const CGFloat userImageViewHeight = 43;

@implementation PersonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        
        self.selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16.5, 25, 25)];
        [self.contentView addSubview:self.selectImageView];
        
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(55, (60 - userImageViewHeight)/2, userImageViewHeight, userImageViewHeight)];
        self.iconImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + userImageViewHeight + 55, 10, self.frame.size.width - (15 + userImageViewHeight + 40 + 55), 25)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + userImageViewHeight + 55, 30, self.frame.size.width - (15 + userImageViewHeight + 40 + 55), 25)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:17.0];
        self.descriptionLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.descriptionLabel];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
