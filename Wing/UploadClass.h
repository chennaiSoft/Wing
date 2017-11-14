//
//  UploadClass.h
//  ChatApp
//
//  Created by theen on 17/01/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "M13ProgressViewRing.h"
#import "Constants.h"

@class AFHTTPRequestOperation;
@class ASIHTTPRequest;
@class ASIFormDataRequest;


@protocol uploadDeleagtes <NSObject>


@optional
-(void)uploadSuccess:(NSMutableDictionary*)dictInput responFromServer:(NSDictionary*)dictResponse;
-(void)uploadFailure:(NSMutableDictionary*)dictInput;
-(void)uploadProgress:(NSMutableDictionary*)dictInput;

@end

@interface UploadClass : NSObject{
    id<uploadDeleagtes> delegate;
    NSDictionary *dictInputs;
    NSDictionary *fileDetails;
    ASIFormDataRequest * requestMain;

}
@property(nonatomic,strong)ASIFormDataRequest *requestMain;
@property(nonatomic,retain)NSDictionary *dictInputs;
@property(nonatomic,retain)NSDictionary *fileDetails;
@property(nonatomic,retain)id<uploadDeleagtes> delegate;
- (void)uploadToServer;
- (void)getInputs;
@end
