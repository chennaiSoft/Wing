//
//  MessageInfoViewController.h
//  TestProject
//
//  Created by Theen on 06/02/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MessageInfoViewController : UIViewController{
    
    IBOutlet UILabel *labelLeftRead1;
    IBOutlet UILabel *labelLeftRead2;
    
    IBOutlet UILabel *labelLeftDelivered1;
    IBOutlet UILabel *labelLeftDelivered2;
    
    IBOutlet UIImageView *imageBubble;
    
    NSManagedObject *object;
    
    IBOutlet UILabel *labelDeliveryDate;
    
    IBOutlet UIView *viewInfo;
    


}

@property (nonatomic,retain)    NSManagedObject *object;
@property (nonatomic,retain)    UITableViewCell *cellCopy;


@end
