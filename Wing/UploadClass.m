//
//  UploadClass.m
//  ChatApp
//
//  Created by theen on 17/01/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "UploadClass.h"
#import "ChatStorageDB.h"
#import "ErrorConstant.h"
#import "ASIFormDataRequest.h"
#import "AFHTTPSessionManager.h"
#import "XMPPConnect.h"
#import "Utilities.h"

#import "AFHTTPRequestOperationManager.h"

@implementation UploadClass
@synthesize delegate;
@synthesize dictInputs;
@synthesize fileDetails;
@synthesize requestMain;

-(void)getInputs{
    self.dictInputs = [[NSMutableDictionary alloc]init];
    self.fileDetails = [[NSMutableDictionary alloc]init];
}

-(void)animateProgress:(ASIFormDataRequest*)requestTemp{
//    M13ProgressViewRing *progress =[[XMPPConnect sharedInstance].dictLoading objectForKey:requestTemp.fileid];
//    if(progress){
//        //  NSLog(@"%f",requestTemp.progressvalue);
//        [progress setProgress:requestTemp.progressvalue animated:YES];
//        [progress setNeedsDisplay];
//    }
}


- (void)uploadToServer{
    
   NSString *type = @"text";
    
    switch ([[self.dictInputs valueForKey:@"messagetype"] intValue]) {
        case 2:
            type = @"Image";
            break;
        case 3:
            type = @"Video";
            break;
        case 4:
            type = @"Location";
            break;
        case 5:
            type = @"Contact";
            break;
        case 6:
            type = @"Audio";
            break;
        case 7:
            type = @"file";
            break;
        default:
            break;
    }
    
    if([type isEqualToString:@"text"]||[type isEqualToString:@"Location"]||[type isEqualToString:@"Contact"]){
        
        [self.dictInputs setValue:[Utilities checkNil:@""] forKey:@"fileurl"];
        [self.dictInputs setValue:[Utilities checkNil:@""] forKey:@"serverid"];
        
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"1" keyvalue:@"deliver"];

        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadcompleted" keyvalue:@"transferstatus"];
        
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:[Utilities checkNil:@""] keyvalue:@"serverid"];
        
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:[Utilities checkNil:@""] keyvalue:@"fileurl"];
    
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionaryWithDictionary:self.dictInputs];
   
        [self.delegate uploadSuccess:mutableDic responFromServer:nil];
        return;
    }
    
    NSLog(@"SucessUploadFileTesting:");
    
    NSURL *url = [NSURL URLWithString:UPLOADFILE];
    self.requestMain = [[ASIFormDataRequest alloc]initWithURL:url];
   // [self.requestMain setDelegate:self];
    [self.requestMain setShouldAttemptPersistentConnection:NO];
    
    self.requestMain.filetype = [self.dictInputs valueForKey:@"messagetype"];
    self.requestMain.fileid = [self.dictInputs valueForKey:@"localid"];
    
    //        [[ChatConnection sharedInstance].dictLoading setObject:self.requestMain forKey:self.requestMain.fileid];
    
    [self.requestMain addPostValue:[Utilities getSenderId] forKey:@"chatapp_id"];
    [self.requestMain addPostValue:[self.dictInputs objectForKey:@"tojid"] forKey:@"receiver"];
    [self.requestMain addPostValue:[self.dictInputs objectForKey:@"localid"] forKey:@"localid"];
    [self.requestMain addPostValue:type.lowercaseString forKey:@"type"];
    [self.requestMain addPostValue:[self.dictInputs objectForKey:@"text"] forKey:@"text_message"];
    [self.requestMain addPostValue:@"uploadfiles" forKey:@"cmd"];
    [self.requestMain addPostValue:[Utilities checkNil:[self.dictInputs objectForKey:@"file_ext"]]forKey:@"file_ext"];
    [self.requestMain addPostValue:[Utilities checkNil:[self.dictInputs objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [self.requestMain addPostValue:@"no" forKey:@"isuseronline"];
    
    [self.requestMain setShouldContinueWhenAppEntersBackground:YES];
    [self.requestMain setTimeOutSeconds:120];
    self.requestMain.showAccurateProgress = YES;
    [self.requestMain setNumberOfTimesToRetryOnTimeout:30];
    
    [self.requestMain setRequestMethod:@"POST"];
    
    if([type isEqualToString:@"Image"]||[type isEqualToString:@"Video"]||[type isEqualToString:@"Audio"]){
        
        NSData * fileData;
        
        if([type isEqualToString:@"Audio"]){
            
            NSString *filepath = [Utilities getAudioFilePath:[self.dictInputs valueForKey:@"localid"]];
            fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
            
            [self.requestMain setData:fileData withFileName:@"originalfile" andContentType:[NSString stringWithFormat:@"%@/%@",type.lowercaseString,@"caf"] forKey:@"originalfile"];
        }
        else{
            
            NSString *filepath = [Utilities getFilePath:[self.dictInputs valueForKey:@"localid"] :type];
            fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
            
            [self.requestMain setData:fileData withFileName:@"originalfile" andContentType:[NSString stringWithFormat:@"%@/%@",type.lowercaseString,([type.lowercaseString isEqualToString:@"image"] ? @"png" : @"mp4")] forKey:@"originalfile"];
        }
    }
    else if ([[type lowercaseString] isEqualToString:@"file"]){
        
        NSString *filepath = [Utilities getFilePath:[self.dictInputs valueForKey:@"localid"] :type];
        
        NSData *imagedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
        
        [self.requestMain setData:imagedata withFileName:@"originalfile" andContentType:[NSString stringWithFormat:@"%@/%@",type.lowercaseString,[Utilities checkNil:[self.dictInputs objectForKey:@"file_ext"]]] forKey:@"originalfile"];
    }
    
    UploadClass * upload = self;
    [self.requestMain setCompletionBlock:^{
        //[upload requestFinished:upload.requestMain];
        [upload performSelectorOnMainThread:@selector(requestFinished:) withObject:upload.requestMain waitUntilDone:YES];
       // NSLog(@"success : %@",upload.requestMain.responseData);
    }];
    
    [self.requestMain setBytesSentBlock:^(unsigned long long size, unsigned long long total){
        
        NSLog(@"Total Size Upload %llu",size/total);
        
        NSLog(@"Bandwidh %lu",[ASIHTTPRequest averageBandwidthUsedPerSecond]);
        
        [upload performSelectorOnMainThread:@selector(animateProgress:) withObject:upload.requestMain waitUntilDone:YES];
    }];
    
    [self.requestMain setUploadSizeIncrementedBlock:^(long long size){
        NSLog(@"Total Size Upload increment %llu",size);
    }];
    
    [self.requestMain setFailedBlock:^{
        [upload performSelectorOnMainThread:@selector(requestFailed:) withObject:upload.requestMain waitUntilDone:YES];
        NSLog(@"failure : %@",upload.requestMain.responseString);
    }];
    
    [self.requestMain startAsynchronous];
    
    [[XMPPConnect sharedInstance].dictUploadrequest setObject:self.requestMain forKey:[self.dictInputs valueForKey:@"localid"]];
    
    [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadprogress" keyvalue:@"transferstatus"];
}
/*
- (void)uploadPhoto{
    
    NSURL *url = [NSURL URLWithString:UPLOADFILE];

    NSMutableDictionary * dictionaryV = [[NSMutableDictionary alloc]init];
    [dictionaryV setObject:[self.dictInputs valueForKey:@"messagetype"] forKey:@"messagetype"];
    [dictionaryV setObject:[self.dictInputs valueForKey:@"tojid"] forKey:@"receiver"];
    [dictionaryV setObject:[self.dictInputs valueForKey:@"localid"] forKey:@"localid"];
    [dictionaryV setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dictionaryV setObject:@"image" forKey:@"type"];
    [dictionaryV setObject:[self.dictInputs valueForKey:@"text"] forKey:@"text_message"];
    [dictionaryV setObject:@"uploadfiles" forKey:@"cmd"];
    [dictionaryV setObject:[Utilities checkNil:[self.dictInputs objectForKey:@"file_ext"]] forKey:@"file_ext"];
    [dictionaryV setObject:[Utilities checkNil:[self.dictInputs objectForKey:@"isgroupchat"]] forKey:@"isgroupchat"];
    [dictionaryV setObject:@"no" forKey:@"isuseronline"];
    
    NSString *filepath = [Utilities getFilePath:[self.dictInputs valueForKey:@"localid"] :@"image"];
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:url];

    __weak UploadClass * upload = self;

    AFHTTPRequestOperation *op = [manager POST:@"rest.of.url" parameters:dictionaryV constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //do not put image inside parameters dictionary as I did, but append it!
        [formData appendPartWithFileData:imageData name:@"originalfile" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestFinished:operation];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    [op start];
}
*/

- (void)successUpload:(id)dict{
    @autoreleasepool {
        if(dict){
            if([[dict valueForKey:@"status"] isEqualToString:@"success"]){
                
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"1" keyvalue:@"deliver"];

                [self.dictInputs setValue:[Utilities checkNil:[dict valueForKey:@"file_url"]] forKey:@"fileurl"];
                
                [self.dictInputs setValue:[Utilities checkNil:[dict valueForKey:@"id"]] forKey:@"serverid"];
                
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadcompleted" keyvalue:@"transferstatus"];
                
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:[Utilities checkNil:[dict valueForKey:@"id"]] keyvalue:@"serverid"];
                
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:[Utilities checkNil:[dict valueForKey:@"file_url"]] keyvalue:@"fileurl"];
                
                [self.delegate uploadSuccess:[self.dictInputs mutableCopy] responFromServer:dict];
            }
            else{
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
                
                [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
            }
        }
        else{
            
            [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"3" keyvalue:@"deliver"];
            
            [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
            
            [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
        }
    }
}

- (void)failureUpload{
    
    @autoreleasepool {
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"3" keyvalue:@"deliver"];

        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
        [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
    }
}

- (void)requestFinished:(ASIFormDataRequest *)request{
    
    NSLog(@"SucessUploadFile:%@",request.responseString);
    NSLog(@"SucessUploadFile:%@",self.requestMain.responseString);
//
//    M13ProgressViewRing *progress =[[XMPPConnect sharedInstance].dictLoading objectForKey:request.fileid];
//    if(progress){
//        [progress removeFromSuperview];
//        [[XMPPConnect sharedInstance].dictLoading removeObjectForKey:request.fileid];
//    }
    
    ASIFormDataRequest *requestt = [[XMPPConnect sharedInstance].dictUploadrequest valueForKey:request.fileid];
    if(requestt){
        [[XMPPConnect sharedInstance].dictUploadrequest removeObjectForKey:request.fileid];
    }
    
    //  NSLog(@"%@",request.responseString);
    if(request.responseStatusCode == 200){
        
        NSLog(@"%@",request.responseString);
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableContainers error:nil];
        if(dict){
            
            if([[dict valueForKey:@"status"] isEqualToString:@"success"]){
                
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"1" keyvalue:@"deliver"];

                [self.dictInputs setValue:[Utilities checkNil:[dict valueForKey:@"file_url"]] forKey:@"fileurl"];
                [self.dictInputs setValue:[Utilities checkNil:[dict valueForKey:@"id"]] forKey:@"serverid"];
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadcompleted" keyvalue:@"transferstatus"];
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:[Utilities checkNil:[dict valueForKey:@"id"]] keyvalue:@"serverid"];
                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:[Utilities checkNil:[dict valueForKey:@"file_url"]] keyvalue:@"fileurl"];
                
                [self.delegate uploadSuccess:[self.dictInputs mutableCopy] responFromServer:dict];
            }
            else{
                
               [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"4" keyvalue:@"deliver"];

                [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
                
                [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
            }
            
        }
        else{
            [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"4" keyvalue:@"deliver"];
            
            [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
            [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
        }
    }
    else{
       [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"4" keyvalue:@"deliver"];
        
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
        [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
    }
}

- (void)requestFailed:(ASIFormDataRequest *)request{
#warning progress need to remove
    
    M13ProgressViewRing *progress =[[XMPPConnect sharedInstance].dictLoading objectForKey:request.fileid];
    if(progress){
        [progress removeFromSuperview];
        [[XMPPConnect sharedInstance].dictLoading removeObjectForKey:request.fileid];
    }
    
    ASIFormDataRequest *requestt = [[XMPPConnect sharedInstance].dictUploadrequest valueForKey:@"request.fileid"];
    if(requestt){
        [[XMPPConnect sharedInstance].dictUploadrequest removeObjectForKey:request.fileid];
    }
    
    [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"4" keyvalue:@"deliver"];

    NSLog(@"%@",request.responseString);
    NSLog(@"%@",@"failed");
    [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"uploadfailed" keyvalue:@"transferstatus"];
    [self.delegate uploadFailure:[self.dictInputs mutableCopy]];
}

- (void)updatesize:(ASIFormDataRequest *)request{
    NSLog(@"%@",request.downloadCache);
}

- (void)updatetotalsize:(ASIFormDataRequest *)request{
    NSLog(@"%@",request.downloadCache);
}

@end
