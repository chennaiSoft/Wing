//
//  ProfileEditViewController.m
//  TestProject
//
//  Created by Theen on 06/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "StatusViewController.h"
#import "Utilities.h"
#import "UIImageView+AFNetworking.h"
#import "WebService.h"
#import "MHGallery.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "XMPPConnect.h"
#import "Constants.h"

@interface ProfileEditViewController ()

@end

@implementation ProfileEditViewController

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
    self.title = @"Profile";
    self.imageUser.layer.cornerRadius = self.imageUser.frame.size.width/2;
    self.imageUser.clipsToBounds = YES;

    // Ameen changed
    
//  [self.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[Utilities getSenderId] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
    
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[Utilities getSenderId]]];
    
    dispatch_queue_t postImageQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postImageQueue, ^{
        NSData *image = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image != nil) {
                
                self.imageUser.image = [UIImage imageWithData:image];
                
            }
        });
    });



    self.textName.text = [Utilities checkNil:[Utilities getSenderNickname]];
    
    [self.tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

  //  [self.tableList setContentOffset:CGPointMake(0, 44) animated:YES];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)tabImage:(UIGestureRecognizer*)sender{
    [self actionEdit:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableList reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{

    if (section==0) {
        return 2;
    }
    
    return 1;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0)
        return nil;
    
    return @"Status";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row==0&&indexPath.section==0)
        return 110;
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0:{
            if(indexPath.row==0){

                [cell.contentView addSubview:self.viewPicture];
            }
            else{
                [cell.contentView addSubview:self.viewName];
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1:
            cell.textLabel.text = [self chckNil:[[NSUserDefaults standardUserDefaults]objectForKey:@"status_message"]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];

 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            [self actionEdit:nil];
            break;
        }
        case 1:{
            StatusViewController *status = [[StatusViewController alloc]init];
            [[self navigationController]pushViewController:status animated:YES];
            break;
        }
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(![textField.text isEqualToString:@""]){
        [[NSFileManager defaultManager] removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] error:nil];
        
        [self uploadPhoto];
    }
    
    return YES;
}

#pragma mark Edit Image

- (IBAction)actionEdit:(id)sender{
    
    [self.textName resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"Choose" delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Goto Camera Roll",@"Take Photo",@"View", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag==1){
        if(buttonIndex==0){
            [self gallery:self];
        }
        else if(buttonIndex==1){
            [self camera:self];
        }
        else if (buttonIndex == 2){
            
            [self openImg];
        }
            
    }

    
    
}

-(void)openImg{
    
    
    MHGalleryItem * landschaft1;
    
    int presentationIndex = 0;
    
    NSMutableArray * galleryDataSource = [[NSMutableArray alloc]init];
    [galleryDataSource removeAllObjects];
    
    NSString * urlStr =[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[Utilities getSenderId]];
    
    
    
    NSURL * imageURL = [NSURL URLWithString:urlStr];
    
    NSData *image = [[NSData alloc] initWithContentsOfURL:imageURL];
    
    UIImage * usrImage = [UIImage imageWithData:image];
    
    //    NSURL * urlString = [[NSURL alloc]initWithString:urlStr];
    
    //    landschaft1 = [[MHGalleryItem alloc]initWithURL:urlStr galleryType:MHGalleryTypeImage];
    //
    landschaft1 = [[MHGalleryItem alloc]initWithImage:usrImage];
    
    [galleryDataSource addObject:landschaft1];
    
    
    MHGalleryController * gallery = [MHGalleryController galleryWithPresentationStyle:MHGalleryViewModeImageViewerNavigationBarHidden];
    gallery.galleryItems = galleryDataSource;
    gallery.presentingFromImageView = nil;
    gallery.UICustomization.showOverView =NO;
    gallery.UICustomization.barStyle = UIBarStyleBlackTranslucent;
    gallery.UICustomization.hideShare = YES;
    
    gallery.presentationIndex = presentationIndex;
    
    // gallery.UICustomization.hideShare = YES;
    //  gallery.galleryDelegate = self;
    //  gallery.dataSource = self;
    
    __weak MHGalleryController * blockGallery = gallery;
    
    gallery.finishedCallback = ^(NSInteger currentIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveTransition,MHGalleryViewMode viewMode){
        if (viewMode == MHGalleryViewModeOverView) {
            [blockGallery dismissViewControllerAnimated:YES completion:^{
                [self setNeedsStatusBarAppearanceUpdate];
            }];
        }else{
            // NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
            //  CGRect cellFrame  = [[self collectionViewLayout] layoutAttributesForItemAtIndexPath:newIndexPath].frame;
            //                 [collectionView scrollRectToVisible:cellFrame
            //                                            animated:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //   [collectionView reloadItemsAtIndexPaths:@[newIndexPath]];
                //  [collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                
                
                [blockGallery dismissViewControllerAnimated:YES dismissImageView:nil completion:^{
                    
                    [self setNeedsStatusBarAppearanceUpdate];
                    
                }];
            });
        }
    };
    [self presentMHGalleryController:gallery animated:YES completion:nil];
    
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


#pragma mark Image Picker

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
        
        imagepic.delegate=self;
        imagepic.allowsEditing=YES;
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
    self.imageUser.image = img;
    
    [UIImagePNGRepresentation(img) writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"] atomically:YES];

    [self uploadPhoto];

}

- (NSString*)chckNil:(NSString*)str{
    
    if(str==nil||[str isEqualToString:@""]||[str isEqualToString:@"(null)"]){
        return @"I'm using Wing";
    }
    
    return str;
}

- (void)uploadPhoto{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"Please wait..."];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"updatenickname" forKey:@"cmd"];
    [dic setObject:[Utilities getSenderId] forKey:@"chatapp_id"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"] forKey:@"user_id"];
    [dic setObject:[Utilities  encodingBase64:self.textName.text] forKey:@"nickname"];
   
    [WebService updateNickname:dic completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        [SVProgressHUD dismiss];
        if(responseObject){
            
            if([[responseObject valueForKey:@"status"] isEqualToString:@"success"]){
                [Utilities saveDefaultsValues:self.textName.text :@"nickname"];
                [self performSelectorOnMainThread:@selector(hideHUD:) withObject:@"success" waitUntilDone:YES];

            }
            else{
                [Utilities alertViewFunction:@"" message:[responseObject valueForKey:@"messsage"]];
            }
        }
        else{
            [self performSelectorOnMainThread:@selector(hideHUD:) withObject:@"failure" waitUntilDone:YES];
            
            [Utilities alertViewFunction:@"" message:@"Unknown error. Pleae try again"];
        }
        NSLog(@"%@",responseObject);
        
    }];
}

- (void)hideHUD:(NSString*)status{
    
    if([status isEqualToString:@"success"]){
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[Utilities getSenderId]]];
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:[NSString stringWithFormat:@"%@%@.png",IMGURL,[Utilities getSenderId]]];
        [[SDWebImageManager sharedManager].imageCache clearMemory];
        [[SDWebImageManager sharedManager].imageCache clearDisk];
        
        
        UIImage *image1=[UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/userimage.png"]];
        if(image1){
            
            UIImage* scaledImgH = [Utilities resizedImageToFitInSize:CGSizeMake(200, 200) scaleIfSmaller:YES image:image1];
            
            [[XMPPConnect sharedInstance]uploadImage:scaledImgH];
        }
    }
    else{
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
