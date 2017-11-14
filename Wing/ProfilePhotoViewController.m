//
//  ProfilePhotoViewController.m
//  ChatApp
//
//  Created by theen on 22/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "ProfilePhotoViewController.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "Utilities.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "SDWebImageCompat.h"
#import "Constants.h"
#import "XMPPConnect.h"
#import "SDWebImageManager.h"

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@interface ProfilePhotoViewController ()
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;
@property (assign, nonatomic) NSInteger maxCacheAge;
@property (assign, nonatomic) NSUInteger maxCacheSize;

@end

@implementation ProfilePhotoViewController
@synthesize stringtitle,jid;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.title = self.stringtitle;
    
    [self setImage];
    
    if([self.jid isEqualToString:[Utilities getSenderId]]||[self.title isEqualToString:@"Group Icon"]){
        self.navigationItem.rightBarButtonItem  = self.editBtn;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)setImage{
    
    [self.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png",IMGURL,self.jid]] placeholderImage:[UIImage imageNamed:@"ment.png"]];
}

- (IBAction)actionEdit:(id)sender{
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Choose" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Goto Camera Roll",@"Take Photo", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.textColor = [UIColor blackColor];
        }
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            label.textColor = [UIColor blackColor];
            
        }
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag==1){
        if(buttonIndex==0){
            [self gallery:self];
        }
        else if(buttonIndex==1){
            [self camera:self];
        }
    }
    else if(actionSheet.tag==2){
        if(buttonIndex==0){
            [self saveImage];
        }
        else if(buttonIndex==1){
            [self copyImage];
        }
    }
}



- (void)saveImage{
    if([self.imageView.image isEqual:[UIImage imageNamed:@"ment.png"]])
        return;
    

    UIImageWriteToSavedPhotosAlbum(imageView.image,
                                   self, // send the message to 'self' when calling the callback
                                   @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), // the selector to tell the method to call on completion
                                   NULL);
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
    }
}


- (void)copyImage{
    
    if([self.imageView.image isEqual:[UIImage imageNamed:@"ment.png"]])
        return;
    
    [[UIPasteboard generalPasteboard] setImage:self.imageView.image];

}


-(void)gallery:(id)sender
{
    UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
    imagepic.delegate=self;
    imagepic.allowsEditing=YES;
    imagepic.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagepic animated:YES completion:nil];
    // [self presentViewController:imagepic animated:YES completion:nil];
    
}

-(void)camera:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagepic=[[UIImagePickerController alloc]init];
        
        imagepic.delegate = self;
        imagepic.allowsEditing = YES;
        imagepic.sourceType=UIImagePickerControllerSourceTypeCamera;
        
        CGRect overlayRect = imagepic.cameraOverlayView.frame;
        overlayRect.size.width=overlayRect.size.width-100.0f;
        overlayRect.size.height=overlayRect.size.height-100.0f;
        [imagepic.cameraOverlayView setFrame:overlayRect];
        [self presentViewController:imagepic animated:YES completion:nil];
        
    }
    else
    {
        //  [Utilities alertViewFunction:@"" message:@"This device is not supported by camera"];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img=[Utilities fixOrientation:[info objectForKey:@"UIImagePickerControllerEditedImage"]];
    NSLog(@"%@",[NSHomeDirectory() stringByAppendingPathComponent:@"userimage.png"]);
    [UIImagePNGRepresentation(img) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] atomically:YES];
    
    self.imageView.image = img;
    
    [self uploadPhoto];
    
}


- (IBAction)actionShare:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Choose" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Image",@"Copy", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];

}


- (void)uploadPhoto{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatenickname" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [dic setObject:[Utilities  encodingBase64:[Utilities getSenderNickname]] forKey:@"nickname"];

    [WebService updateNickname:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        
        if(responseObject){

            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [self performSelectorOnMainThread:@selector(success) withObject:nil waitUntilDone:YES];

            }
            else{
                [Utilities alertViewFunction:@"" message:[responseObject valueForKey:@"messsage"]];
            }
        }
        else{

            [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
        
    }];
    
}

- (void)success{
    
    [[SDWebImageManager sharedManager].imageCache removeImageForKey:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,self.jid]];
    [[SDWebImageManager sharedManager].imageCache removeImageForKey:[NSString stringWithFormat:@"%@%@.png",IMGURL,self.jid]];
    [[SDImageCache sharedImageCache] clearMemory];
    
    UIImage *image1=[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"]];
    if(image1){
        
        UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:image1];

        [[XMPPConnect sharedInstance]uploadImage:scaledImgH];
    }

   // [self.imageView clearImageCacheForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png",IMGURL,self.jid]]];
}

- (void)cleanDisk {
    _ioQueue = dispatch_queue_create("com.hackemist.SDWebImageCache", DISPATCH_QUEUE_SERIAL);
    NSString *fullNamespace = [@"com.hackemist.SDWebImageCache." stringByAppendingString:@"default"];
    self.maxCacheAge = kDefaultCacheMaxCacheAge;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];

    dispatch_async(self.ioQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *diskCacheURL = [NSURL fileURLWithPath:diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                                  includingPropertiesForKeys:resourceKeys
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        for (NSURL *fileURL in fileEnumerator) {
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            // Skip directories.
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            // Remove files that are older than the expiration date;
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [fileManager removeItemAtURL:fileURL error:nil];
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            
            // Delete files until we fall below our desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
