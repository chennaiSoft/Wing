//
//  ScheduledMessageVC.m
//  ChatApp
//
//  Created by Jeeva on 5/7/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "ScheduledMessageVC.h"

@interface ScheduledMessageVC () <UITableViewDataSource, UITableViewDelegate>
{
    CGFloat screenWidth;
    CGFloat screenHeight;
    IBOutlet UIToolbar * navigationBar;
    IBOutlet UIDatePicker * datePickerSchedule;
    UIView *viewScheduleDatePicker;
    IBOutlet UITextView *textViewMessage;
    IBOutlet UITableView *tableViewList;
    IBOutlet UIButton * buttonSchedule;
}

@property (strong, nonatomic) NSDate *scheduledDate;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomDescriptionConstraint;
@property (strong, nonatomic) NSArray *arrayOfItems;

- (IBAction)cancelDatePicker:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * doneDatePicker;
- (IBAction)doneDatePicker:(id)sender;
- (IBAction)openScheduling;
@end

@implementation ScheduledMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [self observeKeyboard];
    self.arrayOfItems = @[
                          @{@"title":@"Birthday",
                            @"message":@"May your birthday and every day be filled with the warmth of sunshine, the happiness of smiles, the sounds of laughter, the feeling of love and the sharing of good cheer."},
                          @{@"title":@"Anniversary",
                            @"message":@"The wrinkles on your faces are not signs of how much you have aged, but how beautifully your marriage has survived the test of time. Happy anniversary."},
                          @{@"title":@"Well Wishes",
                            @"message":@"If I had a flower for every time I thought of you,  I would walk forever in my garden."},
                          @{@"title":@"Wishes for a New Baby",
                            @"message":@"A baby is God's opinion that the world should go on."},
                          @{@"title":@"Happy Graduation",
                            @"message":@"Do not go where the path may lead; go instead where there is no path and leave a trail."},
                          @{@"title":@"Best Wishes",
                            @"message":@"May you get all your wishes but one, so you always have something to strive for."},
                          @{@"title":@"Custom3",
                            @"message":@""},
                          @{@"title":@"Custom4",
                            @"message":@""},
                          ];
    [tableViewList reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableViewList selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:tableViewList didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    });
    [self setDefaultNavBarButtons];
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

- (IBAction)openScheduling
{
    [textViewMessage resignFirstResponder];
    
    if (self.scheduledDate) {
        datePickerSchedule.date = self.scheduledDate;
    }
    
    datePickerSchedule.minimumDate = [NSDate date];
    
    viewScheduleDatePicker = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight, screenWidth, screenHeight)];
    viewScheduleDatePicker.backgroundColor = [UIColor lightGrayColor];
    viewScheduleDatePicker.alpha = 0.65;
    [self.navigationController.view addSubview:viewScheduleDatePicker];
    
    navigationBar.frame = CGRectMake(0, screenHeight, screenWidth, 44);
    [self.navigationController.view addSubview:navigationBar];
    
    datePickerSchedule.frame = CGRectMake(0, screenHeight, screenWidth, 162);
    datePickerSchedule.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:datePickerSchedule];
    
    [UIView animateWithDuration:0.5 animations:^{
        navigationBar.frame = CGRectMake(0, screenHeight - 162 - 44, screenWidth, 44);
        viewScheduleDatePicker.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        datePickerSchedule.frame = CGRectMake(0, screenHeight - 162, screenWidth, 162);
    }];
}

- (IBAction)cancelDatePicker:(id)sender {
    [self closeDatePickerWithAnimation:NO];
}

- (IBAction)doneDatePicker:(id)sender {
    
    self.scheduledDate = datePickerSchedule.date;
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    [datePickerSchedule setDatePickerMode:UIDatePickerModeDateAndTime];
    [dateFomatter setDateFormat:@"yyyy-mm-dd hh:mm"];
    NSString *titleStr = [NSString stringWithFormat:@"Scheduled at %@",[dateFomatter stringFromDate:self.scheduledDate]];
    
    [buttonSchedule setTitle:titleStr forState:UIControlStateNormal];
    [self closeDatePickerWithAnimation:NO];
}

- (void)closeDatePickerWithAnimation:(BOOL)animation
{
    [UIView animateWithDuration:0.5 animations:^{
        viewScheduleDatePicker.frame = CGRectMake(0, screenHeight, screenWidth, screenHeight);
        navigationBar.frame = CGRectMake(0, screenHeight, screenWidth, 44);
        datePickerSchedule.frame = CGRectMake(0, screenHeight, screenWidth, 162);
    } completion:^(BOOL finished) {
        [viewScheduleDatePicker removeFromSuperview];
        [navigationBar removeFromSuperview];
        [datePickerSchedule removeFromSuperview];
    }];
}

- (void)observeKeyboard {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// The callback for frame-changing of keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    
    [self setTextViewNavBarButtons];
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
    [self setDefaultNavBarButtons];
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.bottomDescriptionConstraint.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma Mark -
#pragma UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfItems.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (self.arrayOfItems.count > indexPath.row) {
        NSDictionary *item = [self.arrayOfItems objectAtIndex:indexPath.row];
        cell.textLabel.text = [item objectForKey:@"title"];
    }
    
    return cell;
}

#pragma UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [textViewMessage resignFirstResponder];
    if (self.arrayOfItems.count > indexPath.row) {
        NSDictionary *item = [self.arrayOfItems objectAtIndex:indexPath.row];
        textViewMessage.text = [item objectForKey:@"message"];
    }
}

- (void)sendMessage:(id)sender
{
    if (self.scheduledDate == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please choose your scheduled time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else{
        if (self.delegate) {
            [self.delegate performSelector:@selector(sendScheduledText:date:) withObject:textViewMessage.text withObject:self.scheduledDate];
        }
        [self cancelMessage:nil];
    }
}

- (void)cancelMessage:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDefaultNavBarButtons
{
    self.title = @"Schedule Message";
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendMessage:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelMessage:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

}

- (void)setTextViewNavBarButtons
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(editDone:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = nil;
    self.title = @"";
}

- (void)editDone:(id)sender
{
    [textViewMessage resignFirstResponder];
}

@end
