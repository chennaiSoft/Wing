//
//  AttachmentPreviewVC.m
//  ChatApp
//
//  Created by Jeeva on 4/21/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "AttachmentPreviewVC.h"
#import "AttachmentPreviewCell.h"
#import <QuickLook/QuickLook.h>

@interface AttachmentPreviewVC () <UITextFieldDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIView *viewBottomDescription;
@property (weak, nonatomic) IBOutlet UITextField *textFiledDescription;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPreview;
@property (strong, nonatomic) QLPreviewController *previewController;
@property (weak, nonatomic) IBOutlet UINavigationBar *topNavBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDescriptionConstraint;

- (IBAction)cancelPreview:(id)sender;
- (IBAction)deleteFile:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)previousItem:(id)sender;
- (IBAction)nextItem:(id)sender;
@end

@implementation AttachmentPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(closePage)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [_collectionViewPreview registerNib:[UINib nibWithNibName:@"AttachmentPreviewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    [self observeKeyboard];
    self.previewController = [[QLPreviewController alloc] init];
    self.previewController.view.frame = CGRectMake(0, 64, 320, 400);
    [self.previewController setCurrentPreviewItemIndex:0];
    _previewController.delegate = self;
    _previewController.dataSource = self;
    [self.view addSubview:self.previewController.view];
    [self.view bringSubviewToFront:_viewBottomDescription];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelPreview:(id)sender {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.delegate performSelector:@selector(willCloseAttachmentPreview:) withObject:self.arrayOfFiles];
}

- (IBAction)deleteFile:(id)sender {
    NSInteger currentIndex = self.previewController.currentPreviewItemIndex;
    if (currentIndex < self.arrayOfFiles.count) {
        [self.arrayOfFiles removeObjectAtIndex:currentIndex];
        [self.previewController reloadData];
    }
}

- (IBAction)send:(id)sender {
    
    __block NSMutableArray *arrayOfAttachments = [NSMutableArray array];
    NSString *text = (_textFiledDescription.text?_textFiledDescription.text : @"");
    [self.arrayOfFiles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *file = [NSMutableDictionary dictionaryWithCapacity:2];
        [file setObject:obj forKey:@"filePath"];
        if ([obj isEqual:[self.arrayOfFiles lastObject]]) {
            [file setObject:text forKey:@"message"];
        }
        [arrayOfAttachments addObject:file];
    }];
    
    [self.delegate performSelector:@selector(sendFiles:) withObject:arrayOfAttachments];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)previousItem:(id)sender {
    
    NSInteger currentIndex = self.previewController.currentPreviewItemIndex;
    if (currentIndex-1 >= 0) {
        self.previewController.currentPreviewItemIndex = currentIndex-1;
    }
}

- (IBAction)nextItem:(id)sender {
    NSInteger currentIndex = self.previewController.currentPreviewItemIndex;
    if (currentIndex+1 < self.arrayOfFiles.count) {
        self.previewController.currentPreviewItemIndex = currentIndex+1;
    }
}

#pragma mark -
#pragma mark QLPreviewController Data Source

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return self.arrayOfFiles.count;
}


- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSURL *url = nil;
    if (self.arrayOfFiles.count > index) {
        //[cell setCellData:[self.arrayOfFiles objectAtIndex:indexPath.row]];
        url = [[NSURL alloc] initFileURLWithPath:[self.arrayOfFiles objectAtIndex:index]];
    }
    
    _topNavBar.topItem.title = [NSString stringWithFormat:@"Attached(%ld)",(unsigned long)self.arrayOfFiles.count];
    return url;
    
}

- (void)closePage
{
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// The callback for frame-changing of keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    // Because the "space" is actually the difference between the bottom lines of the 2 views,
    // we need to set a negative constant value here.
    self.bottomDescriptionConstraint.constant = height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.bottomDescriptionConstraint.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
