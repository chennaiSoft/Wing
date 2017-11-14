//
//  CSCreateGroupViewController.h
//  Wing
//
//  Created by CSCS on 2/20/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSBaseViewController.h"

@interface CSCreateGroupViewController : CSBaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSString *stringGroupID;
@property (nonatomic, strong) NSMutableArray *arrayUsers;

@end
