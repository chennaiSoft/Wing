//
//  DropboxManager.h
//  ChatApp
//
//  Created by Jeeva on 5/14/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
// Check for Objective-C Modules
#if __has_feature(objc_modules)
// We recommend enabling Objective-C Modules in your project Build Settings for numerous benefits over regular #imports. Read more from the Modules documentation: http://clang.llvm.org/docs/Modules.html
@import Foundation;
@import UIKit;
@import QuartzCore;
#else
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#endif

#import <DropboxSDK/DropboxSDK.h>


@class DBRestClient;
@class DBMetadata;

@protocol DropboxManager 

- (void)uploadedChatHistory:(NSString *)status;
- (void)downloadedChatHistory:(NSString *)status;

@end

@interface DropboxManager : NSObject <DBRestClientDelegate>
{
    id <DropboxManager> delegate;
}
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) DBMetadata *selectedFile;
@property (retain) id delegate;

+ (instancetype)shared;
- (DBRestClient *)restClient;
- (void)backup:(void(^)(BOOL success))completion progress:(void(^)(CGFloat progress))progress;
- (void)restoreBackup:(void(^)(BOOL success))completion progress:(void(^)(CGFloat progress))progress;
- (void)autoBackup;
- (void)loginOfDropboxWithCompletionHandler:(void(^)(BOOL success))completion;
- (void)logoutOfDropboxWithCompletionHandler:(void(^)(BOOL success))completion;
- (BOOL)isDropboxLinked;
- (void)saveToDropBox:(void(^)(BOOL success))completion progress:(void(^)(CGFloat progress))progress fileURL:(NSString *)fileURL;
- (void)doSave:(NSString *)fileName;

@end
