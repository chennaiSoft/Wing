//
//  CSFriendsTableViewCell.m
//  Wing
//
//  Created by CSCS on 2/8/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSFriendsTableViewCell.h"

static const CGFloat imageViewHeight = 43;

@implementation CSFriendsTableViewCell
@synthesize friendsObj;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16.5, 25, 25)];
        imageView.tag = 100;
        [self.contentView addSubview:imageView];
        
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, (60 - imageViewHeight)/2, imageViewHeight, imageViewHeight)];
        self.iconImageView.image = [UIImage imageNamed:@"contactPlaceholder"];
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + imageViewHeight, 5, self.frame.size.width - (15 + imageViewHeight + 40), 25)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + imageViewHeight, 35, self.frame.size.width - (15 + imageViewHeight + 40), 25)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:17.0];
        self.descriptionLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.descriptionLabel];
        
        self.btnWings = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, (self.frame.size.height - 50)/2, 50, 50)];
        [self.contentView addSubview:self.btnWings];
    }
    
    return self;
}

- (void)updateValues{
    
    self.titleLabel.text = friendsObj.title;
    self.descriptionLabel.text = friendsObj.desc;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
