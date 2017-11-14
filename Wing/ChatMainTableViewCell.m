//
//  ChatMainTableViewCell.m
//  Wing
//
//  Created by CSCS on 2/19/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "ChatMainTableViewCell.h"

@implementation ChatMainTableViewCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
 /*
  
     Thangarajan coded
  
        self.imageUser = [[UIImageView alloc]init];
        [self.imageUser setFrame:CGRectMake(12, 9, 43, 43)];
        [self.imageUser setContentMode:UIViewContentModeScaleAspectFill];
        self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
        self.imageUser.clipsToBounds = YES;
        [self.contentView addSubview:self.imageUser];

        self.imageUser.layer.masksToBounds = YES;
        
        self.labelIcon = [[UIImageView alloc]init];
        [self.labelIcon setContentMode:UIViewContentModeScaleAspectFill];
        [self.labelIcon setFrame:CGRectMake(65, 36, 24, 18)];
        
        self.labelIcon.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.labelIcon];
        
        self.lblName = [[UILabel alloc]init];
        [self.lblName setFrame:CGRectMake(CGRectGetMaxX(self.imageUser.frame) + 10, 9, self.frame.size.width - 60 - 65, 21)];
        [self.lblName setTextColor:[UIColor blackColor]];
        [self.lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [self.lblName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblName];
        
        self.lblStatus = [[UILabel alloc]init];
        [self.lblStatus setFrame:CGRectMake(CGRectGetMaxX(self.labelIcon.frame), 32, self.frame.size.width - 75, 30)];
        [self.lblStatus setTextColor:[UIColor darkGrayColor]];
        [self.lblStatus setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [self.lblStatus setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblStatus];

        self.lblTime = [[UILabel alloc]init];
        [self.lblTime setFrame:CGRectMake(self.frame.size.width - 66, 10, 60, 21)];
        [self.lblTime setTextColor:[UIColor blackColor]];
        [self.lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [self.lblTime setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblTime];
        
        self.btnBadge = [UIButton buttonWithType:UIButtonTypeCustom];
        
        int x = 36;
        
        [self.btnBadge setFrame:CGRectMake(x+8, 5, 12, 12)];
        [self.btnBadge setUserInteractionEnabled:NO];
        [self.btnBadge setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
        [self.btnBadge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnBadge.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [self.btnBadge setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.contentView addSubview:self.btnBadge];
        
        self.dotTypingView = [[DYDotsView alloc] initWithFrame:CGRectMake(self.imageUser.frame.origin.x,10, 43, 43)];
        [self.dotTypingView setNumberOfDots:@3];
        //    [dots setDuration:@0.4];
        [self.dotTypingView setAlpha:0.7];
        [self.dotTypingView setBackgroundColor:[UIColor lightGrayColor]];
        [self.dotTypingView setDotsColor:[UIColor redColor]];
        [self.dotTypingView stopAnimating];
        [self.contentView addSubview:self.dotTypingView];
        [self.contentView bringSubviewToFront:self.dotTypingView];
        self.dotTypingView.hidden = YES;
        
//        self.btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.btnClose setFrame:self.imageUser.frame];
//        [self.btnClose setUserInteractionEnabled:YES];
//        [self.btnClose setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
//        [self.btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [self.btnClose setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
//        [self.contentView addSubview:self.btnClose];
//        self.btnClose.hidden = YES;
//        [self.contentView bringSubviewToFront:self.btnClose];
        
    }
  */
        
//      Ameen Coded
        
        self.imageUser = [[UIImageView alloc]init];
        [self.imageUser setFrame:CGRectMake(12, 9, 43, 43)];
        [self.imageUser setContentMode:UIViewContentModeScaleAspectFill];
        self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
        self.imageUser.clipsToBounds = YES;
        [self.contentView addSubview:self.imageUser];
        
        self.imageUser.layer.masksToBounds = YES;
        
        self.labelIcon = [[UIImageView alloc]init];
//        [self.labelIcon setContentMode:UIViewContentModeScaleAspectFill];
        [self.labelIcon setFrame:CGRectMake(67, (self.contentView.frame.size.height - 10.5), 16, 12)];
        
        self.labelIcon.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.labelIcon];
        
        self.lblName = [[UILabel alloc]init];
        
        [self.lblName setFrame:CGRectMake(CGRectGetMaxX(self.imageUser.frame) + 15, 5, self.frame.size.width - 60 - 65, 21)];
        [self.lblName setTextColor:[UIColor blackColor]];
        [self.lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        [self.lblName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblName];
        
        self.lblStatus = [[UILabel alloc]init];
        [self.lblStatus setFrame:CGRectMake(CGRectGetMaxX(self.labelIcon.frame) + 5, (self.contentView.frame.size.height - 20), self.frame.size.width - 75, 30)];
        [self.lblStatus setTextColor:[UIColor darkGrayColor]];
        [self.lblStatus setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        [self.lblStatus setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblStatus];
        
        self.lblTime = [[UILabel alloc]init];
        [self.lblTime setFrame:CGRectMake(self.frame.size.width -110 , 10, 90, 21)];
        [self.lblTime setTextColor:[UIColor blackColor]];
        self.lblTime.textAlignment = NSTextAlignmentRight;
        [self.lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [self.lblTime setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblTime];
        
        self.btnBadge = [UIButton buttonWithType:UIButtonTypeCustom];
        
        int x = 36;
        
        [self.btnBadge setFrame:CGRectMake(x+8, 5, 15, 15)];
        [self.btnBadge setUserInteractionEnabled:NO];
        
        [self.btnBadge setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
        [self.btnBadge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnBadge.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:9]];
        [self.btnBadge setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        [self.contentView addSubview:self.btnBadge];
        
        self.dotTypingView = [[DYDotsView alloc] initWithFrame:CGRectMake(self.imageUser.frame.origin.x,10, 43, 43)];
        [self.dotTypingView setNumberOfDots:@3];
        //    [dots setDuration:@0.4];
        [self.dotTypingView setAlpha:0.7];
        [self.dotTypingView setBackgroundColor:[UIColor lightGrayColor]];
        [self.dotTypingView setDotsColor:[UIColor redColor]];
        [self.dotTypingView stopAnimating];
        [self.contentView addSubview:self.dotTypingView];
        [self.contentView bringSubviewToFront:self.dotTypingView];
        self.dotTypingView.hidden = YES;
        
        //        self.btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [self.btnClose setFrame:self.imageUser.frame];
        //        [self.btnClose setUserInteractionEnabled:YES];
        //        [self.btnClose setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
        //        [self.btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [self.btnClose setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
        //        [self.contentView addSubview:self.btnClose];
        //        self.btnClose.hidden = YES;
        //        [self.contentView bringSubviewToFront:self.btnClose];
        
    }
    
    return self;
}

-(instancetype) initWithStyle1:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imageBig = [[UIImageView alloc]init];
        [self.imageBig setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 189)];
        [self.imageBig setContentMode:UIViewContentModeScaleAspectFill];
        self.imageBig.clipsToBounds = YES;        
        [self.contentView addSubview:self.imageBig];
        
        
        self.imageUser = [[UIImageView alloc]init];
        [self.imageUser setFrame:CGRectMake(46, 79, 69, 69)];
        [self.imageUser setContentMode:UIViewContentModeScaleAspectFill];
        self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
        self.imageUser.clipsToBounds = YES;
        [self.contentView addSubview:self.imageUser];
        
        self.btnImagEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnImagEdit setFrame:CGRectMake(46, 79, 69, 69)];
        
        [self.contentView addSubview:self.btnImagEdit];
        
        self.lblLocation = [[UILabel alloc]init];
        [self.lblLocation setFrame:CGRectMake(122, 99, 177, 30)];
        [self.lblLocation setTextColor:[UIColor colorWithRed:253.0/255.0 green:195.0/255.0 blue:12.0/255.0 alpha:1.0]];
        [self.lblLocation setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [self.lblLocation setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblLocation];
        
        self.txt_name = [[UITextField alloc]init];
        [self.txt_name setFrame:CGRectMake(123, 71, 177, 30)];
        [self.txt_name setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]];
        [self.txt_name setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.txt_name setTextColor:[UIColor whiteColor]];
        [self.txt_name setTintColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.txt_name];
        
        self.txt_status = [[UITextView alloc]init];
        [self.txt_status setFrame:CGRectMake(117, 123, 197, 51)];
        [self.txt_status setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [self.txt_status setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.txt_status setTextColor:[UIColor whiteColor]];
        [self.txt_status setBackgroundColor:[UIColor clearColor]];
        [self.txt_name setTintColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:self.txt_status];
    }
    
    return self;
}


- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
