//
//  FileDetailsController.h
//  BoxContentSDKSampleApp
//
//  Created by Clement Rousselle on 1/7/15.
//  Copyright (c) 2015 Box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BoxContentSDK/BOXContentSDK.h>

@protocol BOXDownloadDelegate
- (void)BoxfileDownloaded:(NSString*)filePath withExtension:(NSString*)fileExtension;
@end

@interface BOXSampleFileDetailsController : UITableViewController

@property (nonatomic,strong)id<BOXDownloadDelegate> delegate;

- (instancetype)initWithClient:(BOXContentClient *)client itemID:(NSString *)itemID itemType:(BOXAPIItemType *)itemType;

@end
