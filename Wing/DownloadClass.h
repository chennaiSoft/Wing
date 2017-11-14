//
//  DownloadClass.h
//  ChatApp
//
//  Created by theen on 17/01/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol downloaddelegate <NSObject>

@optional
-(void)downloadsuccess:(NSMutableDictionary*)dictInput;
-(void)downloadfailure:(NSMutableDictionary*)dictInput;

@end


@interface DownloadClass : NSObject{
    id<downloaddelegate> downloaddelegate;
    NSMutableDictionary *dictInputs;

}

@property(nonatomic,retain)id<downloaddelegate> downloaddelegate;
@property(nonatomic,retain)NSMutableDictionary *dictInputs;
-(void)downloadStart:(NSMutableDictionary*)dictInput;


@end
