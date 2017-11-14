/*
 * MGSwipeTableCell is licensed under MIT license. See LICENSE.md file for more information.
 * Copyright (c) 2014 Imanol Fernandez @MortimerGoro
 */

#import "MailTableCell.h"



@implementation MailTableCell

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        
        self.imageUser = [[UIImageView alloc]init];
        [self.imageUser setFrame:CGRectMake(12, 9, 43, 43)];
        [self.imageUser setContentMode:UIViewContentModeScaleAspectFill];
        self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width / 2;
        self.imageUser.clipsToBounds = YES;
        [self.contentView addSubview:self.imageUser];

        
        // self.imageUser.layer.cornerRadius = 2.0;
        // self.imageUser.layer.borderWidth = 1.0;
        // self.imageUser.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageUser.layer.masksToBounds = YES;
        
        self.labelIcon = [[UIImageView alloc]init];
        [self.labelIcon setContentMode:UIViewContentModeScaleAspectFill];
        [self.labelIcon setFrame:CGRectMake(65, 36, 24, 18)];

        // self.imageUser.layer.cornerRadius = 2.0;
        // self.imageUser.layer.borderWidth = 1.0;
        // self.imageUser.layer.borderColor = [UIColor clearColor].CGColor;
        self.labelIcon.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.labelIcon];
        
        self.lblName = [[UILabel alloc]init];
        [self.lblName setFrame:CGRectMake(65, 9, 172, 21)];
        [self.lblName setTextColor:[UIColor blackColor]];
        [self.lblName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        [self.lblName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblName];
        
        self.lblStatus = [[UILabel alloc]init];
        [self.lblStatus setFrame:CGRectMake(self.lblName.frame.origin.x, 32, 150, 30)];
        [self.lblStatus setTextColor:[UIColor darkGrayColor]];
        [self.lblStatus setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [self.lblStatus setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblStatus];
        

        
        
        self.lblTime = [[UILabel alloc]init];
        [self.lblTime setFrame:CGRectMake(260, 10, 54, 21)];
        [self.lblTime setTextColor:[UIColor blackColor]];
        [self.lblTime setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [self.lblTime setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.contentView addSubview:self.lblTime];

        
//        self.btnTimeStamp = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.btnTimeStamp setFrame:CGRectMake(260, 10, 58, 21)];
//        [self.btnTimeStamp setUserInteractionEnabled:NO];
//        [self.btnTimeStamp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.btnTimeStamp.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
//        [self.btnTimeStamp setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
//        [self.contentView addSubview:self.btnTimeStamp];
        
        
        self.btnBadge = [UIButton buttonWithType:UIButtonTypeCustom];
        int x=36;
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

-(void) layoutSubviews
{
    [super layoutSubviews];
    

    /*
    CGFloat leftPadding = 25.0;
    CGFloat topPadding = 3.0;
    CGFloat textWidth = self.contentView.bounds.size.width - leftPadding * 2;
    CGFloat dateWidth = 40;
    
    _mailFrom.frame = CGRectMake(leftPadding, topPadding, textWidth, 20);
    _mailSubject.frame = CGRectMake(leftPadding, _mailFrom.frame.origin.y + _mailFrom.frame.size.height + topPadding, textWidth - dateWidth, 17);
    CGFloat messageHeight = self.contentView.bounds.size.height - (_mailSubject.frame.origin.y + _mailSubject.frame.size.height) - topPadding * 2;
    _mailMessage.frame = CGRectMake(leftPadding, _mailSubject.frame.origin.y + _mailSubject.frame.size.height + topPadding, textWidth, messageHeight);
    
    CGRect frame = _mailFrom.frame;
    frame.origin.x = self.contentView.frame.size.width - leftPadding - dateWidth;
    frame.size.width = dateWidth;
    _mailTime.frame = frame;*/
    

}

@end
