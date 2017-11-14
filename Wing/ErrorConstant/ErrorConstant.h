//
//  ErrorConstant.h
//  eMT
//
//  Created by Mani on 3/25/14.
//  Copyright (c) 2014 NPCompete. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum WebServiceError : NSInteger
{
    WebServiceErrorEmptyResponse,
    WebServiceErrorNetworkFailed,
    WebServiceErrorServerFailed,
    WebServiceErrorSuccess
}WebServiceError;


typedef enum DBServiceError : NSInteger
{
    DBErrorSuccess
}DBServiceError;