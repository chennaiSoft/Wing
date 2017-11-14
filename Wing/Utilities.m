//
//  Utilities.m
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "Utilities.h"
#import "SSKeychain.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "M13ProgressViewRing.h"
#import "ChatStorageDB.h"

dispatch_queue_t backgroundQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.wing.backgroundQueue", 0);
    });
    return queue;
}

@implementation Utilities

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

+(NSString*)checkAlbhapet:(NSString*)string{
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];
    if([array containsObject:string]){
        return string;
    }
    else
        return @"#";
}

+(NSString *) dateInFormat:(NSString *)stringFormat {
	char buffer[80];
	const char *format = [stringFormat UTF8String];
	time_t rawtime;
	struct tm * timeinfo;
	time(&rawtime);
	timeinfo = localtime(&rawtime);
	strftime(buffer, 80, format, timeinfo);
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

+ (void)updateDefaultsValue:(NSString*)value key:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    //[defaults synchronize];
}

+ (NSString*)checkNil:(NSString*)string{
    
    if([string isKindOfClass:[NSNull class]])
        return @"";
    
    string = [self trimFunction:string];
    if(string == nil||[string isEqualToString:@""]||[string isEqualToString:@"(null)"]){
        return @"";
    }
    
    return string;
}

+ (NSString*)checkNil1:(NSString*)string{
    
    string = [self trimFunction:string];
    if(string==nil||[string isEqualToString:@""]||[string isEqualToString:@"(null)"]){
        return @"0";
    }
    
    return @"1";
}


+(NSString *)trimFunction:(NSString *)textvalue
{
	NSString *trimmed = [textvalue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	return trimmed;
}

+ (NSString *)urlEncode:(NSString *)url
{
	return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (void)alertViewFunction:(NSString *)title message:(NSString *)message
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prodName message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",@""),nil];
	[alert show];
    /*
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:prodName
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:NSLocalizedString(@"OK",@"")
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    */
}

+ (BOOL)setUserName:(NSString *)userName{
    BOOL deleted = [SSKeychain deletePasswordForService:@"c_nickname" account:@"chatapp_nickname"];
    if(userName){
        return [SSKeychain setPassword:userName forService:@"c_nickname" account:@"chatapp_nickname"];
    }
    return deleted;
}

+ (NSString*)getSenderStatus{
    // return @"Theen";
    if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"]] isEqualToString:@""]){
        return @"I'm using Wing";
    }
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"];
}

+ (NSString*)getExpiredDate{
    // return @"Theen";
    if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"expired_date"]] isEqualToString:@""]){
        return @"";
    }
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"expired_date"];
}

+ (NSDate*)getResetDate{
    NSDate *date = [[NSUserDefaults standardUserDefaults]objectForKey:@"reset_date"];
    return date;
}

+ (NSString*)getMediaDownload{
    // return @"Theen";
    if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"media_download"]] isEqualToString:@""]){
        return @"1";
    }
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"media_download"];
}

+ (NSString*)getAutoDownloadStatus:(NSString*)type{
    // return @"Theen";
    if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:type]] isEqualToString:@""]){
        return @"Wi-Fi and Cellular";
    }
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:type];
}

+ (NSString*)getPrivacySettings:(NSString*)type{
    // return @"Theen";
    if([[Utilities checkNil:[[NSUserDefaults standardUserDefaults]objectForKey:type]] isEqualToString:@""]){
        [Utilities saveDefaultsValues:@"Everyone" :type];
        return @"Everyone";
    }
    
    return [[NSUserDefaults standardUserDefaults]objectForKey:type];
}

+ (NSString*)getSenderNickname{
   // return @"Theen";
  return [[NSUserDefaults standardUserDefaults]objectForKey:@"nickname"];
}

+ (NSString*)getSenderId{
    //return @"919884318973";
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"chatapp_id"];
}

+ (NSString*)getSenderUserId{
    //return @"919884318973";

    return [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
}


+ (NSString*)getReceiverNickname{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_nick_name"];
}

+ (NSString*)getReceiverName{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_name"];
}

+ (NSString*)getFacebookName{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"fb_name"];
}


+ (NSString*)getFacebookID{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"fb_id"];
}



+ (NSString*)getReceiverId{
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"]);
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"receiver_id"];
}

+ (NSString*)getFilePath: (NSString*)fileId :(NSString*)fileType{
    
    NSString *strext = [[ChatStorageDB sharedInstance] getPathExtenstion:fileId];
    if([strext isEqualToString:@""]){
        strext = ([fileType isEqualToString:@"Image"] ? @"png" : @"mp4");
    }
    return [self documentsPath:[NSString stringWithFormat:@"%@.%@",fileId,strext]];
}

+ (NSString*)getFilePathNew: (NSString*)fileId :(NSString*)fileExt{
    return [self documentsPath:[NSString stringWithFormat:@"%@.%@",fileId,fileExt]];
}

+ (NSString*)getAudioFilePath: (NSString*)fileId{
     NSString *strext = @"caf";
    return [self documentsPath:[NSString stringWithFormat:@"%@.%@",fileId,strext]];
}

+ (NSString *)documentsPath:(NSString *)fileName {
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString*)downloadsPath
{
    return [Utilities documentsPath:@"downloads"];
}

+(NSString *)downloadsPathWithFileName:(NSString *)fileName {
    return [[Utilities downloadsPath] stringByAppendingPathComponent:fileName];
}

+ (void)saveFilesWithEncryption:(NSString*)filepath file:(NSData*)filedata{
    [filedata writeToFile:filepath atomically:YES];
}


+ (void)saveFilesInLocalPath:(NSString*)localid file:(NSData*)filedata tojid:(NSString*)tojid path_ext:(NSString*)path_ext filetype:(NSString*)filetype{
  //  NSString *cachepath = [Utilities getp]
    
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage *)fixOrientation: (UIImage *)imageOriginal {
    
    // No-op if the orientation is already correct
    if (imageOriginal.imageOrientation == UIImageOrientationUp){
        return imageOriginal;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (imageOriginal.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageOriginal.size.width, imageOriginal.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, imageOriginal.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, imageOriginal.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (imageOriginal.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, imageOriginal.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, imageOriginal.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, imageOriginal.size.width, imageOriginal.size.height,
                                             CGImageGetBitsPerComponent(imageOriginal.CGImage), 0,
                                             CGImageGetColorSpace(imageOriginal.CGImage),
                                             CGImageGetBitmapInfo(imageOriginal.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (imageOriginal.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,imageOriginal.size.height,imageOriginal.size.width), imageOriginal.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,imageOriginal.size.width,imageOriginal.size.height), imageOriginal.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(UINavigationController *)makeNavController:(UIViewController *)root delegate:(id)delegate
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:root];
        [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_gray_bg.png"] forBarMetrics:UIBarMetricsDefault];
    //    [nav.navigationBar setBackgroundImage:[Utilities navbarBackgroundImageL] forBarMetrics:UIBarMetricsLandscapePhone];
    
    // Custom button for left side menu activation
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.frame = CGRectMake(0, 0, 20, 16);
    [b setBackgroundImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
   // [b setBackgroundImage:[UIImage imageNamed:@"navbar_mainmenu_button_active2"] forState:UIControlStateHighlighted];
    //b.showsTouchWhenHighlighted = YES;
//   [b addTarget:delegate action:@selector(menuPressed:) forControlEvents:UIControlEventTouchUpInside];
    // [root.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:b] animated:NO];
    
//    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    b1.frame = CGRectMake(0, 0, 17, 18);ÏÏ
//    [b1 setBackgroundImage:[UIImage imageNamed:@"alert_icon.png"] forState:UIControlStateNormal];
//    // [b setBackgroundImage:[UIImage imageNamed:@"navbar_mainmenu_button_active2"] forState:UIControlStateHighlighted];
//    //b.showsTouchWhenHighlighted = YES;
//    // [b addTarget:delegate action:@selector(menuPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [root.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:b1] animated:NO];
    
    return nav;
}


+ (void)saveDefaultsValues :(NSString*)value :(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

#pragma mark Thumb Image Creation


+(UIImage*)resizedImageToSize:(CGSize)dstSize image:(UIImage*)inputImage
{
	CGImageRef imgRef = inputImage.CGImage;
	// the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
	CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!
	
    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return inputImage;
    }
    
	CGFloat scaleRatio = dstSize.width / srcSize.width;
	UIImageOrientation orient = inputImage.imageOrientation;
	CGAffineTransform transform = CGAffineTransformIdentity;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			dstSize = CGSizeMake(dstSize.height, dstSize.width);
			transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		default:
            break;
            
			//[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	/////////////////////////////////////////////////////////////////////////////
	// The actual resize: draw the image on a new context, applying a transform matrix
	UIGraphicsBeginImageContextWithOptions(dstSize, NO, inputImage.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return nil;
    }
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -srcSize.height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -srcSize.height);
	}
	
	CGContextConcatCTM(context, transform);
	
	// we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
	UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return resizedImage;
}



/////////////////////////////////////////////////////////////////////////////



+(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale image:(UIImage*)inputImage
{
	// get the image size (independant of imageOrientation)
	CGImageRef imgRef = inputImage.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which depends on the imageOrientation)!
    
	// adjust boundingSize to make it independant on imageOrientation too for farther computations
	UIImageOrientation orient = inputImage.imageOrientation;
	switch (orient) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
        default:
            // NOP
            break;
	}
    
	// Compute the target CGRect in order to keep aspect-ratio
	CGSize dstSize;
	
	if ( !scale && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		//NSLog(@"Image is smaller, and we asked not to scale it in this case (scaleIfSmaller:NO)");
		dstSize = srcSize; // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
	} else {
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
		
		if (wRatio < hRatio) {
			//NSLog(@"Width imposed, Height scaled ; ratio = %f",wRatio);
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		} else {
			//NSLog(@"Height imposed, Width scaled ; ratio = %f",hRatio);
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
		}
	}
    
	return [self resizedImageToSize:dstSize image:inputImage];
}

+ (UIImage *)imageRotatedByDegrees:(CGFloat)degrees image:(UIImage*)image
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

+ (double)getVideoFileSize:(NSString*)path{

    NSError *error = nil;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    NSNumber *size;
    
    if (!error) {
        size = [attributes objectForKey:NSFileSize];
        NSLog(@"file size = %ld", (long)[size integerValue]);
    }
    
    return [size doubleValue];
}


+(float) durationOfVideo:(NSString*)path{
    NSURL *videoFileUrl = [NSURL fileURLWithPath:path];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    
    float seconds = CMTimeGetSeconds(anAsset.duration);
    
    NSLog(@"seconds = %.f", seconds);
    
    return seconds;
}

+(float) bytePerSecond:(NSInteger)size :(float) seconds{
    
    return size/seconds;
}

+(void)deleteTmpFile:(NSString*)path{
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}


+(void)configureprogressview:(NSString*)stringlocalid{
    
    NSLog(@"LocalId : %@",stringlocalid);
    
    M13ProgressViewRing *progress = [[M13ProgressViewRing alloc]init];
    [progress setFrame:CGRectMake(0, 0, 60, 60)];
    progress.progressRingWidth = 5;
    progress.backgroundRingWidth = 2;
    progress.showPercentage = YES;
    [progress setProgress:0.0 animated:YES];
    [[XMPPConnect sharedInstance].dictLoading removeObjectForKey:stringlocalid];
    [[XMPPConnect sharedInstance].dictLoading setObject:progress forKey:stringlocalid];
    
}

+ (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return [[XMPPConnect sharedInstance]timeForDate:date];
    }
}

+ (NSString*)getDateForCommonString:(NSDate*)datee{
    
    NSString *string = @"";
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"dd MMM YYYY hh:mm"];
    
    if(datee == nil){
        string = [format stringFromDate:[NSDate date]];
    }
    else{
        string = [format stringFromDate:datee];
    }
    
    return string;
}


+ (NSString*)getLocation{
    return [Utilities checkNil:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_location"]];
}

+ (NSString*)encodingBase64:(NSString*)string{
    NSData *plainData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    NSLog(@"%@", base64String); // Zm9v
    return base64String;
}

+ (NSString*)encodingBase64Data:(NSData*)inputdata{
    NSString *base64String = [inputdata base64EncodedStringWithOptions:0];
    NSLog(@"%@", base64String); // Zm9v
    return base64String;

    
}

+ (NSString*)decodebase64:(NSString*)inpustring{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:inpustring options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", decodedString); // foo
    return decodedString;

}

+ (void)setStatusBsedOnSelection:(NSString*)statusmessage{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:statusmessage forKey:@"status_message"];
    //[defaults synchronize];
}

+ (NSInteger)getYear{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger year = [components year];
    return year;
}

+ (NSString*)typeforprivacy:(NSString*)input{
    if([input isEqualToString:@"0"])
        return @"Nobody";
    if([input isEqualToString:@"1"])
        return @"Everyone";
    
    return @"My Contacts";
}

+ (NSString*)valueforprivacy:(NSString*)input{
    if([input isEqualToString:@"Nobody"])
        return @"0";
    if([input isEqualToString:@"Everyone"])
        return @"1";
    
    return @"2";
}


+ (NSString*) durationOfVideoOrAudio:(NSString*)fileId fileExt:(NSString*)fileExt{
    NSString *path = [self documentsPath:[NSString stringWithFormat:@"%@.%@",fileId,fileExt]];
    NSURL *videoFileUrl = [NSURL fileURLWithPath:path];
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    
    int totalSeconds = CMTimeGetSeconds(anAsset.duration);
    
    NSLog(@"seconds = %d", totalSeconds);
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    
}

+ (BOOL)isExistingUser{
    NSLog(@"user type--%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_type"]);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"user_type"] isEqualToString:@"existing"]) {
        return YES;
    }
    else
    {
        return NO;
    }
}
+ (NSString*)cachePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    return cachePath;
}


+ (void)saveUserImage:(NSString*)filename filedata:(NSData*)filedata{
    NSString *path = [[self cachePath] stringByAppendingPathComponent:filename];
    [filedata writeToFile:path atomically:YES];
}

+ (NSString*)getUserImageFile:(NSString*)filename{
    NSString *path = [[self cachePath] stringByAppendingPathComponent:filename];

    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL success = [manager fileExistsAtPath:path];
    if(success){
        return path;
    }
    return @"";
}

@end
