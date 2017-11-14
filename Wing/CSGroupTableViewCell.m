//
//  CSGroupTableViewCell.m
//  Wing
//
//  Created by CSCS on 27/07/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSGroupTableViewCell.h"

@implementation CSGroupTableViewCell

static const CGFloat imageViewCellHeight = 50;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16.5, 25, 25)];
        imageView.tag = 100;
        [self.contentView addSubview:imageView];
        
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, (60 - imageViewCellHeight)/2, imageViewCellHeight, imageViewCellHeight)];
        self.iconImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + imageViewCellHeight, 5, self.contentView.frame.size.width - (15 + imageViewCellHeight + 40), 25)];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + imageViewCellHeight, (imageViewCellHeight - 20) , self.frame.size.width - (15 + imageViewCellHeight + 40), 25)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14.0];
        self.descriptionLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.descriptionLabel];
        
        self.btnWings = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 90, (self.frame.size.height - 50)/2, 70, 50)];
        self.btnWings.titleLabel.textColor = [UIColor lightGrayColor];

        [self.contentView addSubview:self.btnWings];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
