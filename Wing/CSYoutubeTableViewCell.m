//
//  CSYoutubeTableViewCell.m
//  Wing
//
//  Created by CSCS on 20/05/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSYoutubeTableViewCell.h"
#import "AppDelegate.h"

@implementation CSYoutubeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // configure control(s)
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 120, 70)];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.image = [UIImage imageNamed:@"youtubeSelected"];
        [self.contentView addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 5, screenWidth - 140, 35)];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 45, screenWidth - 140, 25)];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14.0];
        self.descriptionLabel.textColor = [UIColor redColor];
        [self.contentView addSubview:self.descriptionLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
