//
//  ChatMainTableViewCell.h
//  Wing
//
//  Created by CSCS on 2/19/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "DYDotsView.h"

@interface ChatMainTableViewCell : MGSwipeTableCell

@property (nonatomic, strong) UILabel * mailFrom;
@property (nonatomic, strong) UILabel * mailSubject;
@property (nonatomic, strong) UITextView * mailMessage;
@property (nonatomic, strong) UILabel * mailTime;

@property (retain, nonatomic) IBOutlet UILabel * lblName;
@property (retain, nonatomic) IBOutlet UILabel * lblStatus;
@property (retain, nonatomic) IBOutlet UIImageView * imageUser;
@property (retain, nonatomic) IBOutlet UIImageView * labelIcon;
@property (retain, nonatomic) IBOutlet UIButton * btnBadge;
@property (retain, nonatomic) IBOutlet UILabel * lblTime;
@property (retain, nonatomic) IBOutlet UILabel * labelNickName;

@property (retain, nonatomic) IBOutlet UIImageView * imageBig;
@property (retain, nonatomic) IBOutlet UILabel * lblLocation;
@property (retain, nonatomic) IBOutlet UITextField * txt_name;
@property (retain, nonatomic) IBOutlet UITextView * txt_status;
@property (retain, nonatomic) IBOutlet UIButton * btnImagEdit;

@property (retain, nonatomic) DYDotsView * dotTypingView;

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(instancetype) initWithStyle1:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
