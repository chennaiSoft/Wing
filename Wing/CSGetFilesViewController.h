//
//  CSGetFilesViewController.h
//  Wing
//
//  Created by CSCS on 12/03/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol getFiles
- (void)getfilesFromGallery:(NSInteger)selectedId;
- (void)didselectedAssets:(NSArray*)assets;
- (void)removeShowFilesView;
@end

@interface CSGetFilesViewController : UIViewController
@property (nonatomic, strong) id <getFiles> delegate;
@end
