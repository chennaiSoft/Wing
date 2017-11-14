//
//  ContactTableViewCell.h
//  Wing
//
//  Created by CSCS on 1/13/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsObj.h"

@interface ContactTableViewCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UILabel * name;
@property(nonatomic, strong) IBOutlet UILabel * phone;
@property(nonatomic, strong) ContactsObj * contactObj;
@end
