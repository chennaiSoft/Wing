
#import "CSSettingsViewController.h"
#import <Social/Social.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AppDelegate.h"
#import "GUIDesign.h"

#import "AboutViewController.h"
#import "DeleteAllViewController.h"
#import "XMPPConnect.h"

#import "ProfileEditViewController.h"
#import "ChatSettingsViewController.h"
#import "ChatAccountViewController.h"
#import "FHSTwitterEngine.h"
#import "SCFacebook.h"

#import "SVProgressHUD.h"

#define SYSTEMSTATUSURL @"http://www.csoftconsultancy.com"

//creating viewcontroller

@interface controllerContactUs : UIViewController
@property (nonatomic, strong) UIWebView * webLoad;
@end

@implementation controllerContactUs

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webLoad = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [self.webLoad loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:SYSTEMSTATUSURL]]];
    [self.view addSubview:self.webLoad];
}

@end



/************************/
@interface CSSettingsViewController ()<MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView * settingsTableView;
}

@property (nonatomic,retain) NSMutableArray *arrayOptions;

@property (nonatomic,retain) UIButton * btnFb;
@property (nonatomic,retain) UIButton * btnTwitter;
@property (nonatomic,retain) UIButton * btnMail;
@property (nonatomic,retain) UIButton * btnSms;

@property (nonatomic,retain) UIViewController * contactUs;

@property (nonatomic,retain) UIActivityIndicatorView *actLoading;


- (IBAction)actionselectshare:(id)sender;

@end

@implementation CSSettingsViewController

- (id)init{
    self = [super init];
    if (self) {
        
        self.title = @"Settings";
        UIImage *deselectedimage = [[UIImage imageNamed:@"settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedimage = [[UIImage imageNamed:@"settingsSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:deselectedimage];
        [self.tabBarItem setSelectedImage:selectedimage];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getConnectionStatus)
                                                     name:@"getConnectionStatus"
                                                   object:nil];

    }
    return self;
}

- (void)getConnectionStatus{
    [settingsTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Settings";
    
//    self.editBtn = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editSelection:)];
//    self.editBtn.tintColor = [UIColor blackColor];
//    
//    self.addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSelection:)];
//    self.addBtn.tintColor = [UIColor blackColor];
//    
//    self.navigationItem.leftBarButtonItem = self.editBtn;
//    self.navigationItem.rightBarButtonItem = self.addBtn;
    
    self.title  = @"Settings";
    
    UIImageView* appbg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appbg.image = [UIImage imageNamed:@"appBg"];
    [self.view addSubview:appbg];

    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"2cOW8TjXn5ed7NOcYzuaHGmK5" andSecret:@"pA7hcVISS6yeQGcMTaIDytbXM7IEobiDivqUSVDF3fpRKoMqME"];
    [[FHSTwitterEngine sharedEngine]setDelegate:(id<FHSTwitterEngineAccessTokenDelegate>)self];

    settingsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, screenWidth, screenHeight - 65) style:UITableViewStyleGrouped];
    settingsTableView.backgroundColor = [UIColor clearColor];
    settingsTableView.dataSource = self;
    settingsTableView.delegate = self;
    [self.view addSubview:settingsTableView];
    
    [settingsTableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
    
    self.arrayOptions = [[NSMutableArray alloc]initWithObjects:@"", nil];
    
    self.btnFb = [GUIDesign initWithbutton:CGRectMake(0, 0, 55, 55) title:nil img:nil];
    [self.btnFb setImage:[UIImage imageNamed:@"share_facebook"] forState:UIControlStateNormal];
    self.btnFb.tag = 1;
    [self.btnFb addTarget:self action:@selector(actionselectshare:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnTwitter = [GUIDesign initWithbutton:CGRectMake(0, 0, 55, 55) title:nil img:nil];
    [self.btnTwitter setImage:[UIImage imageNamed:@"share_twitter"] forState:UIControlStateNormal];
    self.btnTwitter.tag = 2;
    [self.btnTwitter addTarget:self action:@selector(actionselectshare:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnMail = [GUIDesign initWithbutton:CGRectMake(0, 0, 55, 55) title:nil img:nil];
    [self.btnMail setImage:[UIImage imageNamed:@"share_mail"] forState:UIControlStateNormal];
    self.btnMail.tag = 3;
    [self.btnMail addTarget:self action:@selector(actionselectshare:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnSms = [GUIDesign initWithbutton:CGRectMake(0, 0, 55, 55) title:nil img:nil];
    [self.btnSms setImage:[UIImage imageNamed:@"share_sms"] forState:UIControlStateNormal];
    self.btnSms.tag = 4;
    [self.btnSms addTarget:self action:@selector(actionselectshare:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setHidesBackButton:YES];
    
}

#pragma mark UITabelView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    
    int count = 2;
    
    switch (section) {
        case 0:
            count = 1;
            break;
        case 1:
            count = 3;
            break;
        case 2:
            count = 1;
            break;
        case 3:
            count = 1;
            break;
        case 4:
            count = 1;
            break;
            
        default:
            break;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 4)
        return 65;
    
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(section == 4)
        return @"Share WING with your friends";
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    if(indexPath.section==0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text  = @"About";
                break;
            case 1:
                cell.textLabel.text  = @"Tell a Friend";
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 1){
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text  = @"Profile";
                break;
            case 1:
                cell.textLabel.text  = @"Account";
                break;
            case 2:
                cell.textLabel.text  = @"Chat Settings";
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 2){
        
        switch (indexPath.row) {
            case 0:{
                cell.textLabel.text  = @"Network Status";
                [self.actLoading stopAnimating];
                [self.actLoading setHidden:YES];
                
                
                switch ([XMPPConnect sharedInstance].connectingStatus) {
                    case 1:
                        cell.detailTextLabel.text = @"Connecting...";
                        [self.actLoading setHidden:NO];
                        [self.actLoading startAnimating];
                        
                        break;
                    case 2:
                        cell.detailTextLabel.text = @"Connected";
                        cell.detailTextLabel.textColor = [UIColor grayColor];
                        
                        break;
                    case 3:
                        cell.detailTextLabel.text = @"Not Connected";
                        cell.detailTextLabel.textColor = [UIColor redColor];
                        break;
                        
                    default:
                        break;
                }
                
                break;
            }
//            case 1:
//                cell.textLabel.text  = @"System Status";
//                break;
                
            default:
                break;
        }
    }
    
    else if(indexPath.section == 3){
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text  = @"Clear All Chats";
                cell.textLabel.textColor = [UIColor redColor];
                break;
                
            default:
                break;
        }
    }
    else if(indexPath.section==4){
        
        self.btnTwitter.frame  =CGRectMake(10, 5, 55, 55);
        self.btnFb.frame  =CGRectMake(70, 5, 55, 55);
        self.btnSms.frame  =CGRectMake(130, 5, 55, 55);
        self.btnMail.frame  =CGRectMake(190, 5, 55, 55);
        
        [cell.contentView addSubview:self.btnFb];
        [cell.contentView addSubview:self.btnTwitter];
        [cell.contentView addSubview:self.btnMail];
        [cell.contentView addSubview:self.btnSms];
        
    }
    
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 0){
        
        switch (indexPath.row) {
            case 0:
                [self gotoAboutscreen];
                break;
            case 1:
                
                break;
            default:
                break;
        }
    }
    else if(indexPath.section == 1){
        
        switch (indexPath.row) {
            case 0:
                [self gotoProfileEditscreen];
                break;
            case 1:
                [self gotoAccountScreen];
                break;
            case 2:
                [self gotoChatSettingsView];
                break;
            default:
                break;
        }
        
    }
    else if(indexPath.section == 2){
        
        switch (indexPath.row) {
            case 1:
                _contactUs = [[controllerContactUs alloc]init];
                [[self navigationController]pushViewController:self.contactUs animated:YES];
                break;
                
            default:
                break;
        }
    }
    
    else if(indexPath.section == 3){
        
        DeleteAllViewController *deleteall  =[[DeleteAllViewController alloc]init];
        deleteall.hidesBottomBarWhenPushed = YES;
        
        [[self navigationController]pushViewController:deleteall animated:YES];
        
    }
}

- (void)gotoProfileEditscreen{
    
    ProfileEditViewController *about = [[ProfileEditViewController alloc]init];
    about.hidesBottomBarWhenPushed = YES;
    
    [[self navigationController]pushViewController:about animated:YES];
}

- (void)gotoChatSettingsView{
    ChatSettingsViewController *about = [[ChatSettingsViewController alloc]init];
    about.hidesBottomBarWhenPushed = YES;
    
    [[self navigationController]pushViewController:about animated:YES];
}

- (void)gotoAccountScreen{
    
    ChatAccountViewController *about = [[ChatAccountViewController alloc]init];
    about.hidesBottomBarWhenPushed = YES;
    [[self navigationController]pushViewController:about animated:YES];
    
}

#pragma mark Actions

- (void)gotoAboutscreen{
    AboutViewController *about = [[AboutViewController alloc]init];
    about.hidesBottomBarWhenPushed = YES;
    
    [[self navigationController]pushViewController:about animated:YES];
}

- (IBAction)actionselectshare:(id)sender{
    
    NSInteger tag = ((UIControl*)sender).tag;
    
    switch (tag) {
        case 1:
            [self shareViaFB];
            break;
        case 2:
            [self shareViaTwitter];
            
            break;
            
        case 3:
            [self openMailComposer];
            
            break;
            
        case 4:
            [self openSMSComposer];
            break;
            
        default:
            break;
            
    }
}

#pragma mark Twitter Share

-(void)shareViaTwitter{
    
    BOOL isAvailable = [SLComposeViewController isAvailableForServiceType: SLServiceTypeTwitter];
    
    if(isAvailable)
    {
        [self composeView:SLServiceTypeTwitter];
    }
    else{
        
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//        [SVProgressHUD showWithStatus:@"Please wait..."];

        BOOL isAuthorise =  [[FHSTwitterEngine sharedEngine]isAuthorized];
        
        if(isAuthorise){
            [self performSelectorOnMainThread:@selector(failuretwitterlogin) withObject:nil waitUntilDone:YES];
            return;
        }

        UIViewController * loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
            NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
            if(success){
                [self performSelectorOnMainThread:@selector(successtwitterlogin) withObject:nil waitUntilDone:YES];
                
            }
            else{
                [self performSelectorOnMainThread:@selector(failuretwitterlogin) withObject:nil waitUntilDone:YES];
            }
        }];
        
        [self presentViewController:loginController animated:YES completion:nil];
    }
}

- (void)twitterEngineControllerDidCancel{
    [SVProgressHUD dismiss];
}

- (void)failuretwitterlogin{
     [SVProgressHUD dismiss];
}

- (void)successtwitterlogin{
    
    id returned = [[FHSTwitterEngine sharedEngine]postTweet:INVITEMSG];
    
    NSString *title = nil;
    NSString *message = nil;
    
    if ([returned isKindOfClass:[NSError class]]) {
        NSError *error = (NSError *)returned;
        title = [NSString stringWithFormat:@"Error %ld",(long)error.code];
        message = error.localizedDescription;
    } else {
        NSLog(@"%@",returned);
        title = @"Tweet Posted";
    }
    
     //[SVProgressHUD dismiss];
    
    [Utilities alertViewFunction:@"" message:@"Tweet posted successfully"];
}

#pragma mark Fb Share

-(void)shareViaFB{
    
    BOOL isAvailable = [SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook];
    if(isAvailable)
    {
        [self composeView:SLServiceTypeFacebook];
    }
    else{
        [self fbShare];
    }
}

-(void)fbShare{
//commented by thangarajan
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:APPURL];
    content.contentDescription = INVITEMSG;
    
    content.imageURL = [NSURL URLWithString:SHAREIMGURL];
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
}

- (void)responseFacebook:(NSString*)message{
    [SVProgressHUD dismiss];
    [Utilities alertViewFunction:@"" message:message];
}


-(void)composeView:(id)type{
    
    SLComposeViewController * composeVC = [SLComposeViewController composeViewControllerForServiceType: type];
    if(composeVC)
    {
        BOOL success = YES;
        
        [composeVC setInitialText:[NSString stringWithFormat:@"%@ %@",INVITEMSG,APPURL]];
        [composeVC addURL:[NSURL URLWithString:APPURL]];
        [composeVC addImage:[UIImage imageNamed:@"App_icon.png"]];
        // [composeVC addImage:[UIImage imageNamed:@"76.png"]];
        
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                
                NSLog(@"Cancelled");
                // [Utilities alertViewFunction:@"" message:@"Fail to post in facebook"];
                
            } else
                
            {
                NSLog(@"Post");
                //  [self performSelectorOnMainThread:@selector(success:) withObject:type waitUntilDone:YES];
                
            }
            
            [composeVC dismissViewControllerAnimated:YES completion:Nil];
        };
        
        composeVC.completionHandler =myBlock;
        
        if(success)
        {
            [self presentViewController: composeVC animated: YES completion: nil];
        }
    }
    else{
        
    }
}

#pragma mark Mail Share

-(void)openMailComposer{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

-(void)displayComposerSheet
{
    NSMutableString *emailBody = [NSMutableString string];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    NSArray *toRecipients = nil;
    [picker setToRecipients:toRecipients];
    [picker setSubject:CAPTION];
    [emailBody appendFormat:@"<p>%@</p><br><p>%@</p><br><a href=\"%@\">%@</a>&nbsp;",INVITESMS,@"Chat - Share - Play",APPURL,APPURL];
    [picker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:picker animated:YES completion:nil];
    
}

-(void)launchMailAppOnDevice {
    NSString *recipients = @"mailto:?cc=&subject=ChataZap App";
    NSString *body = @"&body=";
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of           the operation.
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [Utilities alertViewFunction:@"" message:@"Mail cancelled"];
            break;
        case MFMailComposeResultSaved:
            [Utilities alertViewFunction:@"" message:@"Mail saved successfully"];
            break;
        case MFMailComposeResultSent:{
            
            
            
            [Utilities alertViewFunction:@"" message:@"Mail sent successfully"];
            break;
        }
        case MFMailComposeResultFailed:
            [Utilities alertViewFunction:@"" message:@"Sending failed"];
            break;
        default:
            [Utilities alertViewFunction:@"" message:@"Mail not send"];
            break;
    }
    
    
    //  [btnSend setTitle:[NSString stringWithFormat:@"Send(%d)",[self.dictSelect count]] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Sms Share

-(void)openSMSComposer{
    
    if([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
        [picker setSubject:CAPTION];
        [picker setBody:[NSString stringWithFormat:@"%@",INVITESMS]];
        //NSArray *toRecipients = nil;
        //[picker setRecipients:toRecipients];
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result)
    {
        case MessageComposeResultCancelled:
            // [Utilities alertViewFunction:@"" message:@"Message cancelled"];
            break;
        case MessageComposeResultSent:{
            break;
        }
        case MessageComposeResultFailed:
            // [Utilities alertViewFunction:@"" message:@"Sending failed"];
            return;
            break;
            
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
