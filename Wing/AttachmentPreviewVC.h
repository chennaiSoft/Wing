//
//  AttachmentPreviewVC.h
//  ChatApp
//
//  Created by Jeeva on 4/21/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttachmentPreviewVC : UIViewController

@property (nonatomic, strong) NSMutableArray *arrayOfFiles;

@property (weak, nonatomic) id delegate;
@end
