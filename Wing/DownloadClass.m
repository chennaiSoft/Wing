//
//  DownloadClass.m
//  ChatApp
//
//  Created by theen on 17/01/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "DownloadClass.h"
#import "ChatStorageDB.h"
#import "M13ProgressViewRing.h"
#import "ASIHTTPRequest.h"
#import "Utilities.h"
#import "XMPPConnect.h"

@implementation DownloadClass
@synthesize downloaddelegate;
@synthesize dictInputs;

-(id)init
{
    if(self =  [super init])
    {
        
    }
    return self;
}

-(void)animateProgress:(ASIHTTPRequest*)requestTemp{
    
    NSLog(@"uploading:%llu", requestTemp.totalBytesSent);

//    M13ProgressViewRing *progress = [[XMPPConnect sharedInstance].dictLoading objectForKey:requestTemp.downfilename];
//    if(progress){
//        NSLog(@"%f",requestTemp.progressvalue);
//        [progress setProgress:requestTemp.progressvalue animated:YES];
//        [progress setNeedsDisplay];
//    }
}

-(void)downloadStart:(NSManagedObject*)dictInput{
    self.dictInputs = dictInput;
    
       NSString *strUrl =[self.dictInputs valueForKey:@"fileurl"];
    
    if([[Utilities checkNil:strUrl] isEqualToString:@""]){
        [self.downloaddelegate downloadfailure:self.dictInputs];
        return;
    }
    

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:[self.dictInputs valueForKey:@"fileurl"]]];
    
    //_weak ASIHTTPRequest *request = _request;
    
    NSString *pathext =[Utilities checkNil:[self.dictInputs valueForKey:@"file_ext"]];
    
//    if ([[dictInput valueForKey:@"messagetype"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeFile]]) {
//        pathext = [[dictInput valueForKey:@"fileName"] pathExtension];
//    }
    
    
    NSString *strtemppathh = [self checkPath:[NSString stringWithFormat:@"%@.%@",[self.dictInputs valueForKey:@"localid"],pathext]];
    
    //  NSString *strtemppathh = [self checkPath:[NSString stringWithFormat:@"%@.%@",[self.dictInputs valueForKey:@"localid"],[[self.dictInputs valueForKey:@"serverurl"] pathExtension]]];
    
    //    NSString *strtemppathh = [self checkPath:[NSString stringWithFormat:@"%@.%@",[self.dictInputs valueForKey:@"localid"],[[self.dictInputs valueForKey:@"serverurl"] pathExtension]]];
    
	strtemppathh = [NSString stringWithFormat:@"%@-part",strtemppathh];
	NSString *orgpathh = [strtemppathh stringByReplacingOccurrencesOfString:@"-part" withString:@""];
//	request.downloadid = 0;
//	request.downfilename = [self.dictInputs valueForKey:@"localid"];
//	request.downfiletype = [self.dictInputs valueForKey:@"messagetype"];
//    request.downloadResponseId=[self.dictInputs valueForKey:@"serverid"];
//	request.lastdownloadsize = 0;
	// The full file will be moved here if and when the request completes successfully
	[request setDownloadDestinationPath:orgpathh];
	[request setTemporaryFileDownloadPath:strtemppathh];
	[request setAllowResumeForFileDownloads:YES];
	[request setShouldContinueWhenAppEntersBackground:YES];
    [request setTimeOutSeconds:120];
	[request setNumberOfTimesToRetryOnTimeout:30];
	[request setShowAccurateProgress:YES];
	//[request setDownloadProgressDelegate:self];
	//request.delegate = self;
    
    [request setCompletionBlock:^{
        [self performSelectorOnMainThread:@selector(requestFinished:) withObject:request waitUntilDone:YES];
        //NSLog(@"success : %@",request.responseString);
    }];
    
    [request setBytesReceivedBlock:^(unsigned long long size, unsigned long long total){
        
        [self performSelectorOnMainThread:@selector(animateProgress:) withObject:request waitUntilDone:YES];
        
    }];
    
    [request setFailedBlock:^{
        [self performSelectorOnMainThread:@selector(requestFailed:) withObject:request waitUntilDone:YES];
        NSLog(@"failure : %@",request.responseString);
    }];
    
	[request startAsynchronous];
    
    [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"downloadprogress" keyvalue:@"transferstatus"];

    [[XMPPConnect sharedInstance].dictDownloadrequest setObject:request forKey:[self.dictInputs valueForKey:@"localid"]];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
//    M13ProgressViewRing *progress =[[XMPPConnect sharedInstance].dictLoading objectForKey:request.downfilename];
//    if(progress){
//        [progress removeFromSuperview];
//        [[XMPPConnect sharedInstance].dictLoading removeObjectForKey:request.downfilename];
//    }
    
    
    ASIHTTPRequest *requesst = [[XMPPConnect sharedInstance].dictDownloadrequest objectForKey:[self.dictInputs valueForKey:@"localid"]];
    if(requesst){
        [[XMPPConnect sharedInstance].dictDownloadrequest removeObjectForKey:[self.dictInputs valueForKey:@"localid"]];
    }
    
    if(request.responseStatusCode == 200||request.responseStatusCode == 206){
        
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"downloadcompleted" keyvalue:@"transferstatus"];

        [self.downloaddelegate downloadsuccess:self.dictInputs];
        
//         if(![requesst.downfiletype isEqualToString:[NSString stringWithFormat:@"%ld",(long)MessageTypeImage]]){
//              [self saveVideo:[Utilities getFilePath:[self.dictInputs valueForKey:@"localid"] :@"video"]];
//          }
//          else{
//              [self saveImage:[Utilities getFilePath:[self.dictInputs valueForKey:@"localid"] :@"Image"]];
//          }
        
        
    }
    else{
        [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"downloadfailed" keyvalue:@"transferstatus"];
        [self.downloaddelegate downloadfailure:self.dictInputs];
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    
//    M13ProgressViewRing *progress =[[XMPPConnect sharedInstance].dictLoading objectForKey:request.downfilename];
//    if(progress){
//        [progress removeFromSuperview];
//        [[XMPPConnect sharedInstance].dictLoading removeObjectForKey:request.downfilename];
//    }
    
    [[ChatStorageDB sharedInstance]updateUploadDB:[self.dictInputs valueForKey:@"localid"] status:@"downloadfailed" keyvalue:@"transferstatus"];

    ASIHTTPRequest *requesst = [[XMPPConnect sharedInstance].dictDownloadrequest objectForKey:[self.dictInputs valueForKey:@"localid"]];
    if(requesst){
        [[XMPPConnect sharedInstance].dictDownloadrequest removeObjectForKey:[self.dictInputs valueForKey:@"localid"]];
    }

    
    [self.downloaddelegate downloadfailure:self.dictInputs];
}


-(NSString *)checkPath:(NSString*)strfilename
{
    if(![strfilename isEqualToString:@""]){
		NSArray *pathsd = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
		NSString	*document = [pathsd objectAtIndex:0];
		NSString *defaultDBPath1 = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",strfilename]];
        return defaultDBPath1;
		
        
    }
    
    return @"";
    
}

- (void)saveImage:(NSString*)path{
    if([[Utilities getMediaDownload] integerValue]==1){
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        UIImageWriteToSavedPhotosAlbum(image,
                                       self, // send the message to 'self' when calling the callback
                                       @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                       NULL);
    }
   // [Utilities getFilePath:[s valueForKey:@"localid"] :type]
  
}

- (void)saveVideo:(NSString*)path{
     if([[Utilities getMediaDownload] integerValue]==1){
            UISaveVideoAtPathToSavedPhotosAlbum(path,nil,nil,nil);
     }
    
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
    }
}



@end
