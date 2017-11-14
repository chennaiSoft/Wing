//
//  YoutubeGridViewController.h
//  ChatApp
//
//  Created by theen on 15/05/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol youTubeMenu
- (void)didSelectFromMenu:(NSString*)stringInput;
@end

@interface YoutubeGridViewController : UIViewController{
    IBOutlet UITextField *txt_name;
    IBOutlet UITextView *txt_status;
    IBOutlet UITextField *txt_location;
    
    IBOutlet UIImageView *imageUser;

}

- (void)updateInputs;

@property (nonatomic,weak) IBOutlet UITableView *tabelViewList;

@property (nonatomic,strong) NSMutableArray *arrayItems;
@property (nonatomic,strong) NSMutableArray *arrayItemsSub;
@property (nonatomic, strong) id<youTubeMenu> delegate;
@end
