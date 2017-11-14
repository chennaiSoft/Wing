//
//  CSGetFilesViewController.m
//  Wing
//
//  Created by CSCS on 12/03/16.
//  Copyright © 2016 CSCS. All rights reserved.
//

#import "CSGetFilesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>

@interface CSGetFilesViewController ()<CTAssetsPickerControllerDelegate>
{
    IBOutlet UIButton * closeBtn;
}
@end

@implementation CSGetFilesViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    closeBtn.layer.borderWidth = 1.0;
    closeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    closeBtn.layer.cornerRadius = 3.0;
}

- (IBAction)closeAction:(id)sender{
    [delegate removeShowFilesView];
}

- (IBAction)folderActions:(id)sender{
    
    [delegate getfilesFromGallery:[sender tag]];
//    [self openGallery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Image Picker at CTAssetsPickerController

- (void)openGallery
{
    // request authorization status
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // Optionally present picker as a form sheet on iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    [delegate didselectedAssets:assets];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
