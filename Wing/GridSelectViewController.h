//
//  GridSelectViewController.h
//  ChatApp
//
//  Created by theen on 01/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol gridDelegate <NSObject>

- (void)clickOnImage:(NSString*)chatappid;

@end

@interface GridSelectViewController : UIViewController
{
    IBOutlet UICollectionView *collectionView;
    
    id<gridDelegate> delegate;

}
- (void)reloadCollectionView:(NSString*)chatappid validate:(BOOL)isremove;
@property (nonatomic,retain) NSMutableArray *arrayUsers;
@property (nonatomic,weak)  id<gridDelegate> delegate;

@end
