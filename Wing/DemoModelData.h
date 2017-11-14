//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "JSQMessages.h"

/**
 *  This is for demo/testing purposes only. 
 *  This object sets up some fake model data.
 *  Do not actually do anything like this.
 */

@interface DemoModelData : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray * messages;

@property (strong, nonatomic) NSDictionary * avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) NSDictionary *users;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)addPhotoMediaMessage;

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;

- (void)addVideoMediaMessage;

@end
