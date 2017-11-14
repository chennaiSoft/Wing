//
//  ProfilePhotoViewController.h
//  ChatApp
//
//  Created by theen on 22/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePhotoViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    IBOutlet UIImageView *imageView;

}

@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *stringtitle;

@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *editBtn;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *actLoading;

- (IBAction)actionEdit:(id)sender;
- (IBAction)actionShare:(id)sender;

@end
