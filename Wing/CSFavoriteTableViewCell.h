//
//  CSFavoriteTableViewCell.h
//  Wing
//
//  Created by CSCS on 01/06/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSFavoriteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnWingsSelected;
@property (weak, nonatomic) IBOutlet UIButton *btnWings;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (weak, nonatomic) IBOutlet UIButton *btnBadge;

@end
