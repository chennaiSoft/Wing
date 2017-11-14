//
//  WebService.m
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "WebService.h"
#import "ErrorConstant.h"
#import "ASIFormDataRequest.h"
#import "Constants.h"
#import "Utilities.h"

//#import "AFHTTPRequestOperationManager.h"


@implementation WebService

+ (ASIFormDataRequest*)createRequest:(NSString*)url{
    
    ASIFormDataRequest *requestMain = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [requestMain setUseHTTPVersionOne:YES];
    [requestMain setShouldContinueWhenAppEntersBackground:YES];
    [requestMain setTimeOutSeconds:120];
    requestMain.showAccurateProgress = YES;
	[requestMain setNumberOfTimesToRetryOnTimeout:30];
    [requestMain setRequestMethod:@"POST"];
    [requestMain setShouldAttemptPersistentConnection:YES];
    
    return requestMain;
}

+ (void)loginApi:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest * _request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        if(error){
           
                if (completionBlock)
                    completionBlock(responseObject,WebServiceErrorEmptyResponse);
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.error.localizedDescription);
    }];
    
    [request startAsynchronous];
}

+ (void)getYouTubeResult:(NSString*)url  completionBlock:(ServiceCompletionBlock)completionBlock{
    __block ASIFormDataRequest *_request = [self createRequest:url];
    __weak ASIFormDataRequest *request = _request;

    [request setRequestMethod:@"GET"];

    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];

}

+ (void)updateProfileVisibility:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
}

+ (void)updateVerification:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
}

+ (void)updateStatusMessage:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];

}

+ (void)updateNickname:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }

    UIImage *image1=[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"]];
    if(image1){
        
        UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:image1];
        
        UIImage *scaledImgHo = [Utilities resizedImageToFitInSize:CGSizeMake(600, 600) scaleIfSmaller:YES image:image1];
        
        
        [request setData:UIImagePNGRepresentation(scaledImgHo) withFileName:@"originalfile" andContentType:@"image/png" forKey:@"originalfile"];
        [request setData:UIImagePNGRepresentation(scaledImgH) withFileName:@"thumblfile" andContentType:@"image/png" forKey:@"thumblfile"];

    }

    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
 
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
 }


+ (void)updateFeedBack:(NSDictionary*)dictinput arrayInput:(NSMutableArray*)arrayInput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest * _request = [self createRequest:FTPURL];
    
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }

    for (int i=0; i<arrayInput.count; i++) {
        UIImage *image1=[arrayInput objectAtIndex:i];
        if(image1){
            [request setData:UIImagePNGRepresentation(image1) withFileName:[NSString stringWithFormat:@"%@%d",@"feedback",i] andContentType:@"image/png" forKey:[NSString stringWithFormat:@"%@%d",@"feedback",i]];
            
        }

    }

    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];

}

+ (void)contactSyncApi:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{

     ASIFormDataRequest * _request = [self createRequest:CONTACTSSYNC];
    //request.filetype = [dictinput objectForKey:@"cmd"];
    
    __weak ASIFormDataRequest *request = _request;
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Contacts.xml"];
    
    [request setData:[NSData dataWithContentsOfFile:path] withFileName:@"xmlfile" andContentType:@"text/xml" forKey:@"xmlfile"];
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.error.localizedDescription);
    }];
    
    [request startAsynchronous];
}

+ (void)socialContactSyncApi:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
 
    ASIFormDataRequest *_request = [self createRequest:SOCIALSYNC];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Social.json"];
    //[formData appendPartWithFileData:[NSData dataWithContentsOfFile:path] name:@"xmlfile" fileName:@"contacts.xml" mimeType:@"text/xml"];
    
    //[request addData:[NSData dataWithContentsOfFile:path] withFileName:@"xmlfile" andContentType:@"text/xml" forKey:@"xmlfile"];
    
    [request setData:[NSData dataWithContentsOfFile:path] withFileName:@"jsonfile" andContentType:@"text/json" forKey:@"jsonfile"];
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);

        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];

    
    
}

+ (void)createGroupChat:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    
    
    
    UIImage *image1=[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/groupchat.png"]];
    if(image1){
        
        UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:image1];
        
        UIImage *scaledImgHo = [Utilities resizedImageToFitInSize:CGSizeMake(600, 600) scaleIfSmaller:YES image:image1];
        
        
        [request setData:UIImagePNGRepresentation(scaledImgHo) withFileName:@"originalfile" andContentType:@"image/png" forKey:@"originalfile"];
        [request setData:UIImagePNGRepresentation(scaledImgH) withFileName:@"thumblfile" andContentType:@"image/png" forKey:@"thumblfile"];
    }

    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}

+ (void)updateGroupChat:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }

    UIImage *image1=[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/groupchat.png"]];
    if(image1){
        
        UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:image1];
        
        UIImage *scaledImgHo = [Utilities resizedImageToFitInSize:CGSizeMake(600, 600) scaleIfSmaller:YES image:image1];
        
        
        [request setData:UIImagePNGRepresentation(scaledImgHo) withFileName:@"originalfile" andContentType:@"image/png" forKey:@"originalfile"];
        [request setData:UIImagePNGRepresentation(scaledImgH) withFileName:@"thumblfile" andContentType:@"image/png" forKey:@"thumblfile"];
    }
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
  
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}

+ (void)updatePrivacy:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }

    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}


+ (void)lastSeenApiCallNew:(NSString*)receiver_id completionBlock:(ServiceCompletionBlock)completionBlock{
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = @"getlastseen";
    [request addPostValue:request.filetype forKey:@"cmd"];
    [request addPostValue:[Utilities getSenderId] forKey:@"chatapp_id"];
    [request addPostValue:receiver_id forKey:@"receiver_id"];
    
    [request setCompletionBlock:^{
//        if (![[ChatConnection sharedInstance] isFailureSession:request isASI:YES])
//        {
            NSError *error;
            
            id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
            if(error){
                
                
                
                
                    if (completionBlock)
                        completionBlock(responseObject,WebServiceErrorEmptyResponse);
                
                
                
            }
            else{
                if (completionBlock)
                    completionBlock(responseObject,WebServiceErrorSuccess);
            }
            
       // }
        
        
        
        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}


+ (void)updateLastSeen:(NSString*)sender_id completionBlock:(ServiceCompletionBlock)completionBlock{
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = @"updatereadstatus";
    [request addPostValue:request.filetype forKey:@"cmd"];
    [request addPostValue:sender_id forKey:@"chatapp_id"];
    
    [request setCompletionBlock:^{
        //        if (![[ChatConnection sharedInstance] isFailureSession:request isASI:YES])
        //        {
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        if(error){

            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }

        NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}

+ (void)sendForPushNotification:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:UPLOADFILE];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }

    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }

    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}

+ (void)sendSchduledMessages:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{

    __block ASIFormDataRequest *_request = [self createRequest:UPLOADFILE];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}


+ (void)runCMD:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:UPLOADFILE];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}

+ (void)runCMDBackUp:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:BACKUPCHAT];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
    
    
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }
        
        
        // NSLog(@"success : %@",request.responseString);
    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
    
}

#pragma mark Groups Api


+ (void)groupChatUpdates:(NSDictionary*)dictinput  completionBlock:(ServiceCompletionBlock)completionBlock{
    
    __block ASIFormDataRequest *_request = [self createRequest:FTPURL];
    __weak ASIFormDataRequest *request = _request;

    request.filetype = [dictinput objectForKey:@"cmd"];
    
    for (NSString *str in [dictinput allKeys]) {
        [request addPostValue:[dictinput objectForKey:str] forKey:str];
    }
 
    [request setCompletionBlock:^{
        
        NSError *error;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@",responseObject);
        
        if(error){
            
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorEmptyResponse);
            
            
            
        }
        else{
            if (completionBlock)
                completionBlock(responseObject,WebServiceErrorSuccess);
        }

    }];
    [request setFailedBlock:^{
        if (completionBlock)
            completionBlock(request.responseString,WebServiceErrorNetworkFailed);
        NSLog(@"failure : %@",request.responseString);
    }];
    
    [request startAsynchronous];
}

@end
