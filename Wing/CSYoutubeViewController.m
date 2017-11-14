
#import "CSYoutubeViewController.h"
#import "LBYouTube.h"
#import "ChatStorageDB.h"
#import "GUIDesign.h"
#import "AppDelegate.h"
#import "CSYoutubeTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "WebService.h"
#import "YouTubeParser.h"
#import "YoutubeForwardViewController.h"
#import "YoutubeGridViewController.h"

#define YOUTUBEKEY @"AIzaSyBvWgIHegQX5iiWGJ-3FPdDK8XGxLP0RgQ"

@interface CSYoutubeViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,youTubeMenu,UIGestureRecognizerDelegate>
{
    UISearchBar * searchBar;
    UITableView * youtubeTableView;
    UITableView * menuTableView;
    NSDateFormatter * dateFormat;
    
    BOOL searchSelected;
    BOOL videocheck;
    
    UIButton * searchButton;
    UIButton * downloadButton;
    UIButton * uploadButton;
    UIButton * favButton;
    UIView * topView;
    NSInteger selectedRow;
    NSInteger seletedItem;
    UIBarButtonItem * leftBarButton;
    UIBarButtonItem * rightBarButton;
    
    UITapGestureRecognizer * taptoKeyboardHide;

}

@property (nonatomic, strong) NSMutableArray * arrayvideos;
@property (nonatomic, strong) NSMutableArray * arraytempvideos;
@property (nonatomic, strong) NSString * video_URL;
@property (nonatomic, strong) NSMutableArray * arrquality;
@property (nonatomic, strong) NSMutableDictionary * dictquality;

@property(strong,nonatomic) MPMoviePlayerController		* players;
@property(strong,nonatomic) MPMoviePlayerViewController	* tempPlayer;
@property (nonatomic, strong) YoutubeGridViewController * gridView;
@end

@implementation CSYoutubeViewController

- (id)init{
    self = [super init];
    if (self) {
        self.title = @"Youtube";
        UIImage *deselectedimage = [[UIImage imageNamed:@"youtube"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedimage = [[UIImage imageNamed:@"youtubeSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:deselectedimage];
        [self.tabBarItem setSelectedImage:selectedimage];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.delegate = (id<UITabBarControllerDelegate>)self;

    dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-ddHH:mm:ss"];

    self.arrayvideos = [[NSMutableArray alloc]init];
    self.arraytempvideos = [[NSMutableArray alloc]init];
    self.dictquality = [[NSMutableDictionary alloc]init];
    self.arrquality = [[NSMutableArray alloc]init];
    
    /** creating topview*/
     
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    
    topView.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1.0];
    
    searchButton = [GUIDesign initWithbutton:CGRectMake(0, 0, screenWidth/4, 44) title:nil img:@""];
    [searchButton addTarget:self action:@selector(searcButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    searchButton.tag = 0;
    [topView addSubview:searchButton];
    
    downloadButton = [GUIDesign initWithbutton:CGRectMake(screenWidth/4, 0, screenWidth/4, 44) title:nil img:@""];
    [downloadButton addTarget:self action:@selector(searcButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    downloadButton.tag = 1;
    [topView addSubview:downloadButton];
    
    uploadButton = [GUIDesign initWithbutton:CGRectMake((screenWidth/4)*2, 0, screenWidth/4, 44) title:nil img:@""];
    [uploadButton addTarget:self action:@selector(searcButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    uploadButton.tag = 2;
    [topView addSubview:uploadButton];
    
    favButton = [GUIDesign initWithbutton:CGRectMake((screenWidth/4)*3, 0, screenWidth/4, 44) title:nil img:@""];
    [favButton addTarget:self action:@selector(searcButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    favButton.tag = 3;
    [topView addSubview:favButton];

    /**/
    youtubeTableView = [GUIDesign initWithTabelview:self frmae:CGRectMake(0, 0, screenWidth, screenHeight)];
    youtubeTableView.delegate = self;
    youtubeTableView.dataSource = self;
    youtubeTableView.delaysContentTouches = NO;
    youtubeTableView.allowsMultipleSelection = YES;
    youtubeTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:youtubeTableView];
    
    [youtubeTableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    searchBar.delegate = self;
    youtubeTableView.tableHeaderView = searchBar;
    [self searcButtonPressed:searchButton];
    
//    Ameen Code
    
    taptoKeyboardHide = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    taptoKeyboardHide.numberOfTouchesRequired = 1;
    taptoKeyboardHide.numberOfTapsRequired = 1;
    taptoKeyboardHide.delegate = self;
    [self.navigationController.view addGestureRecognizer:taptoKeyboardHide];
    [taptoKeyboardHide setCancelsTouchesInView:YES]
    ;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:youtubeTableView]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        if (self.arrayvideos.count == 0) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

-(IBAction)hideKeyboard:(id)sender{
    
    [self.view endEditing:YES];
    [searchBar resignFirstResponder];
}

- (IBAction)menuButtonAction:(id)sender{
    
    [self hideKeyboard:sender];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if(leftBarButton.tag == 0){
        
        leftBarButton.tag = 1;
        
        self.gridView = [[YoutubeGridViewController alloc]initWithNibName:@"YoutubeGridViewController" bundle:nil];
        [self.gridView.view setFrame:CGRectMake(0, 0, 250, [UIScreen mainScreen].bounds.size.height)];
        self.gridView.delegate = self;
        [self.gridView updateInputs];
        [app.window addSubview:self.gridView.view];
        [app.window sendSubviewToBack:self.gridView.view];
        
        [self viewUp:app.tabBarController.view];
    }
    else{
        leftBarButton.tag = 0;
        [self viewDone:app.tabBarController.view];
    }
}

- (void)viewUp:(UIView*)toolBar{
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [toolBar setFrame:CGRectMake(250, 0, toolBar.frame.size.width, toolBar.frame.size.height)];
    [[toolBar layer] addAnimation:animation forKey:nil];
}

- (void)viewDone:(UIView*)toolBar{
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [toolBar setFrame:CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height)];
    [[toolBar layer] addAnimation:animation forKey:@"rightToLeftAnimation"];
    [self performSelector:@selector(hideBar) withObject:nil afterDelay:0.3];
}

- (void)hideBar{
    
    if(self.gridView){
        [self.gridView.view removeFromSuperview];
        self.gridView = nil;
        [[[[UIApplication sharedApplication] delegate]window] setNeedsLayout];
    }
}

//Updating batch count in tabbaritem
- (void)unreadcount{
    
    int unread_count = [[ChatStorageDB sharedInstance]getUnreadCountForYoutube];
    if(unread_count > 0){
        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",unread_count];
    }
    else{
        [[self navigationController] tabBarItem].badgeValue = nil;
    }
}

- (IBAction)leftButtonAction:(id)sender{
    
    UIBarButtonItem * barButton = (UIBarButtonItem*)sender;
    
    if ([barButton.title containsString:@"Forward"]) {
        
        if([youtubeTableView indexPathsForSelectedRows].count > 0){
            
            YoutubeForwardViewController *share = [[YoutubeForwardViewController alloc]init];
            
            for (NSIndexPath *path in  [youtubeTableView indexPathsForSelectedRows]) {
                [share.arrayInputs addObject:[self.arrayvideos objectAtIndex:path.row]];
            }
            share.hidesBottomBarWhenPushed = YES;
            [[self navigationController]pushViewController:share animated:YES];
            
            [youtubeTableView setEditing:NO animated:YES];
            
            UIImage * listImg = [UIImage imageNamed:@"list_1"];
            [listImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            leftBarButton = [[UIBarButtonItem alloc]initWithImage:listImg style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction:)];
            
            self.navigationItem.leftBarButtonItem = leftBarButton;
            self.navigationItem.rightBarButtonItem = nil;
        }
    }else if([barButton.title containsString:@"Delete"]){
        [self showDeleteOptions];
    }
}

- (IBAction)rightButtonAction:(id)sender{
    
    UIBarButtonItem * barButton = (UIBarButtonItem*)sender;
    
    [youtubeTableView setEditing:NO animated:YES];

    if ([barButton.title isEqualToString:@"Cancel"]) {
        
        if (seletedItem == 0) {
            UIImage * listImg = [UIImage imageNamed:@"list_1"];
            [listImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            leftBarButton = [[UIBarButtonItem alloc]initWithImage:listImg style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction:)];
            
            self.navigationItem.leftBarButtonItem = leftBarButton;
            self.navigationItem.rightBarButtonItem = nil;
        }else{
            rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
            
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = rightBarButton;
        }
    }else{
        
        [youtubeTableView setEditing:YES animated:YES];
        
        leftBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonAction:)];
        rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
        
        self.navigationItem.rightBarButtonItem  = rightBarButton;
        self.navigationItem.leftBarButtonItem = leftBarButton;

        [leftBarButton setTitle:[NSString stringWithFormat:@"Delete(%lu)",[youtubeTableView indexPathsForSelectedRows].count]];
    }
}

- (void)showDeleteOptions{
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Delete All"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self deleteallfromdb];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Delete Selected"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self singledelete];
                                  
                              }];
    
    
    [alert addAction:button0];
    [alert addAction:button2];
    [alert addAction:button1];

    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)singledelete{
    
    switch (seletedItem) {
        case 1:{
            for (NSIndexPath *path in youtubeTableView.indexPathsForSelectedRows){
                NSDictionary *dict = [self.arrayvideos objectAtIndex:path.row];
                [[ChatStorageDB sharedInstance]validateYouTubeVideoShare:[dict valueForKey:@"id"] type:@"R" delete:YES];
            }
            [self.arrayvideos removeAllObjects];
            [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeShare:@"" type:@"R"]];
            [self resetItems];
            
            break;
        }
        case 2:{
            for (NSIndexPath *path in youtubeTableView.indexPathsForSelectedRows){
                NSDictionary *dict = [self.arrayvideos objectAtIndex:path.row];
                [[ChatStorageDB sharedInstance]validateYouTubeVideoShare:[dict valueForKey:@"id"] type:@"U" delete:YES];
            }
            [self.arrayvideos removeAllObjects];
            [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeShare:@"" type:@"U"]];
            [self resetItems];
            break;
        }
        case 3:{
            for (NSIndexPath *path in youtubeTableView.indexPathsForSelectedRows){
                NSDictionary *dict = [self.arrayvideos objectAtIndex:path.row];
                [[ChatStorageDB sharedInstance]validateYouTubeVideo:[dict valueForKey:@"id"] delete:YES];
            }
            
            [self.arrayvideos removeAllObjects];
            [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeFavorites:@""]];
            [self resetItems];
            break;
        }
            
        default:
            break;
    }
}

- (void)reloadTable{
    
    [self unreadcount];
    
    if(seletedItem == 2){
        [self.arrayvideos removeAllObjects];
        [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeShare:@"" type:@"R"]];
        [youtubeTableView reloadData];
        [[ChatStorageDB sharedInstance]updateUnreadCountForYoutube];
        [[self navigationController] tabBarItem].badgeValue = nil;
    }
    
}
- (void)deleteallfromdb{
    
    switch (seletedItem) {
        case 1:{
            [[ChatStorageDB sharedInstance]deleteAllYoutubeVideo:@"YoutubeShare" type:@"R"];
            break;
        }
        case 2:{
            [[ChatStorageDB sharedInstance]deleteAllYoutubeVideo:@"YoutubeShare" type:@"U"];
            
            break;
        }
        case 3:{
            [[ChatStorageDB sharedInstance]deleteAllYoutubeVideo:@"Youtube" type:@""];
            
            break;
        }
            
        default:
            break;
    }
    
    [self.arrayvideos removeAllObjects];
    [self resetItems];
    
}

- (void)resetItems{
    
    rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.leftBarButtonItem = nil;

    [youtubeTableView setEditing:NO animated:NO];
    [youtubeTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searcButtonPressed:(id)sender{
    
    NSInteger tagId = ((UIControl*)sender).tag;
    
    [searchButton setImage:[UIImage imageNamed:@"search_n"] forState:UIControlStateNormal];
    [downloadButton setImage:[UIImage imageNamed:@"inbox_n"] forState:UIControlStateNormal];
    [uploadButton setImage:[UIImage imageNamed:@"outbox_n"] forState:UIControlStateNormal];
    [favButton setImage:[UIImage imageNamed:@"fav_n"] forState:UIControlStateNormal];
    
    searchSelected = NO;
    [searchBar resignFirstResponder];
    
    rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButton;
    self.navigationItem.leftBarButtonItem = nil;

    seletedItem = tagId;
    
    if (tagId == 0) {
        
        [self.arrayvideos removeAllObjects];
        
        searchSelected = YES;
        [searchButton setImage:[UIImage imageNamed:@"search_s"] forState:UIControlStateNormal];
        
        UIImage * listImg = [UIImage imageNamed:@"list_1"];
        [listImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        leftBarButton = [[UIBarButtonItem alloc]initWithImage:listImg style:UIBarButtonItemStylePlain target:self action:@selector(menuButtonAction:)];
        
        self.navigationItem.leftBarButtonItem = leftBarButton;
        self.navigationItem.rightBarButtonItem = nil;
        
        if (self.arraytempvideos.count > 0) {
            [self.arrayvideos addObjectsFromArray:self.arraytempvideos];
            [youtubeTableView reloadData];
        }else{
            [searchBar becomeFirstResponder];
        }
        
    }else if (tagId == 1) {
        
        [self.arrayvideos removeAllObjects];
        [downloadButton setImage:[UIImage imageNamed:@"inbox_s"] forState:UIControlStateNormal];
        [[ChatStorageDB sharedInstance] updateUnreadCountForYoutube];
        [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeShare:@"" type:@"R"]];
        [youtubeTableView reloadData];
        [self unreadcount];

    }else if (tagId == 2) {
        [self.arrayvideos removeAllObjects];
        [uploadButton setImage:[UIImage imageNamed:@"outbox_s"] forState:UIControlStateNormal];
        [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeShare:@"" type:@"U"]];
        [youtubeTableView reloadData];
    }else{
        [self.arrayvideos removeAllObjects];
        [favButton setImage:[UIImage imageNamed:@"fav_s"] forState:UIControlStateNormal];
        [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeFavorites:@""]];
        [youtubeTableView reloadData];
    }
    
}

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return topView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.arrayvideos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"youtubeCell";
    
    CSYoutubeTableViewCell * cell = (CSYoutubeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[CSYoutubeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    id object = [self.arrayvideos objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [[object valueForKey:@"title"] capitalizedString];
    cell.descriptionLabel.text = [object valueForKey:@"published"];
    
    if(![[object valueForKey:@"imageurl"] isEqualToString:@""]){
        
        [cell.iconImageView setImageWithURL:[NSURL URLWithString:[object valueForKey:@"imageurl"]] placeholderImage:[UIImage imageNamed:@"youtubeSelected"]];
    }
    
    cell.backgroundColor = [UIColor clearColor];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBar resignFirstResponder];

    if(tableView.editing){
        [self updateEditAction];
    }else{
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        selectedRow = indexPath.row;
        [self selectRow];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateEditAction];
}

- (void)updateEditAction{
    
    
    switch (seletedItem) {
        case 0:{
            
            [leftBarButton setTitle:[NSString stringWithFormat:@"Forward(%lu)",[youtubeTableView indexPathsForSelectedRows].count]];
            break;
        }
            
        default:{
            
            [leftBarButton setTitle:[NSString stringWithFormat:@"Delete(%lu)",[youtubeTableView indexPathsForSelectedRows].count]];
//
//            if(editcheck){
//                [self.btndelete setTitle:[NSString stringWithFormat:@"Delete(%lu)",(unsigned long)[tableViewYoutube indexPathsForSelectedRows].count]];
//                
//                
//            }
//            else{
//                [self.btnforward setTitle:[NSString stringWithFormat:@"Forward(%lu)",(unsigned long)[tableViewYoutube indexPathsForSelectedRows].count]];
//            }
        
            break;
        }
    }
}

- (void)selectRow{
    
    NSString *string = @"Add to Favorite";
    
    id dict = [self.arrayvideos objectAtIndex:selectedRow];
    
    self.video_URL = [dict valueForKey:@"videoID"];
    
    if([[ChatStorageDB sharedInstance]validateYouTubeVideo:[dict valueForKey:@"id"] delete:NO]){
        string = @"Remove from Favorite";
    }
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil      //  Must be "nil", otherwise a blank title area will appear above our two buttons
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Play"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self play_YoutubeVideo:self.video_URL];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Share to Friends"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self shareToFriends];

                              }];
    UIAlertAction* addtoFav = [UIAlertAction
                              actionWithTitle:string
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                      id dict = [self.arrayvideos objectAtIndex:selectedRow];
                                      
                                      if([action.title isEqualToString:@"Remove from Favorite"]){
                                          [[ChatStorageDB sharedInstance]validateYouTubeVideo:[dict valueForKey:@"id"] delete:YES];
                                          
                                          [self getFavorites];
                                          
                                          if(seletedItem == 3||seletedItem == 0){
                                              [self getFavorites];
                                          }
                                          [youtubeTableView reloadData];
                                          
                                      }
                                      else{
                                          if([dict isKindOfClass:[NSManagedObject class]]){
                                              NSArray *keys = [[[dict entity] attributesByName] allKeys];
                                              dict = [dict dictionaryWithValuesForKeys:keys];
                                          }
                                          [[ChatStorageDB sharedInstance]saveYouTubeFavorites:dict];
                                      }
                              }];

    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [alert addAction:addtoFav];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)getFavorites{
    [self.arrayvideos removeAllObjects];
    [self.arrayvideos addObjectsFromArray:[[ChatStorageDB sharedInstance] getYouTubeFavorites:@""]];
}

- (void)shareToFriends{
    
    [youtubeTableView setEditing:YES animated:YES];
    
    leftBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Forward" style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonAction:)];
    rightBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
    
    self.navigationItem.rightBarButtonItem  = rightBarButton;
    self.navigationItem.leftBarButtonItem = leftBarButton;

    NSIndexPath *path = [NSIndexPath indexPathForRow:selectedRow inSection:0];
    [youtubeTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [leftBarButton setTitle:[NSString stringWithFormat:@"Forward(%lu)",[youtubeTableView indexPathsForSelectedRows].count]];
}

- (void)play_YoutubeVideo:(NSString *)videoID{
    
    if(videocheck){
        return;
    }

    NSString *str_ID=[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",videoID];
    videocheck = YES;
    
    NSURL *youTbURL=[NSURL URLWithString:str_ID];
    
    [YouTubeParser h264videosWithYoutubeURL:youTbURL completeBlock:^(NSDictionary *dictionart, NSError *error){
        // NSLog(@"success %@",dictionart);
        [self performSelectorOnMainThread:@selector(callOutput:) withObject:dictionart waitUntilDone:YES];
    }];
}

-(void)callOutput:(NSDictionary*)dicttemp{
    videocheck = NO;
    
    [self.dictquality removeAllObjects];
    [self.dictquality addEntriesFromDictionary:dicttemp];
    [self.arrquality removeAllObjects];
    
    NSArray *array  = [[self.dictquality allKeys]  sortedArrayUsingSelector:
                       @selector(localizedStandardCompare:)];
    
    [self.arrquality addObjectsFromArray:array];
    
    if([self.arrquality count] == 0){
        
        NSString *str_ID=[NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",self.video_URL];
        
        NSURL *youTbURL=[NSURL URLWithString:str_ID];
        
        LBYouTubeExtractor *extractor2;
        extractor2 = [[LBYouTubeExtractor alloc] initWithURL:youTbURL quality:LBYouTubeVideoQualitySmall];
        
        [extractor2 extractVideoURLWithCompletionBlock:^(NSURL *videoURL, NSError *error) {
            if(!error) {
                
                [self performSelectorOnMainThread:@selector(callnew:) withObject:videoURL waitUntilDone:YES];
                return;
                
            } else {
                [self performSelectorOnMainThread:@selector(callerror) withObject:nil waitUntilDone:YES];
            }
        }];
    }
    else{
        
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"Choose Quality"
                                    message:nil
                                    preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (NSInteger i = [self.arrquality count] - 1; i < [self.arrquality count]; i--) {
            
            UIAlertAction* button1 = [UIAlertAction
                                      actionWithTitle:[self.arrquality objectAtIndex:i]
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action)
                                      {
                                          NSString *str = action.title;
                                          NSURL *videoUrl = [NSURL URLWithString:[self.dictquality objectForKey:str]];
                                          [self startPlaying:videoUrl];
                                      }];
            [alert addAction:button1];
        }

        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)startPlaying:(NSURL*)video_url{
    
    self.tempPlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:video_url];
    self.players = [self.tempPlayer moviePlayer];
    
    NSNotificationCenter *notificationCenter = [ NSNotificationCenter defaultCenter ];
    
    [notificationCenter addObserver: self selector:@selector(moviePlayerPlaybackDidFinish:) name: MPMoviePlayerPlaybackDidFinishNotification object: [self.tempPlayer moviePlayer] ];
    [notificationCenter addObserver: self selector:@selector(moviePlayerPlaybackDidclose:) name: MPMoviePlayerDidExitFullscreenNotification object: [self.tempPlayer moviePlayer] ];
    [self presentMoviePlayerViewControllerAnimated:self.tempPlayer];
    self.players.controlStyle = MPMovieControlStyleFullscreen;
    [self.players play];
    
}

-(void)moviePlayerPlaybackDidclose:(NSNotification*)notification
{
    
}

-(void)moviePlayerPlaybackDidFinish:(NSNotification*)notification
{
    //AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self.players stop];
    [self dismissMoviePlayerViewControllerAnimated];
}

-(void)callnew:(NSURL*)videoURL{
    @autoreleasepool {
        [self startPlaying:videoURL];
    }
}

-(void)callerror{
    @autoreleasepool {
        [self showAlert:@"he content owner has not made this video download available on mobile"];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1{
    [searchBar resignFirstResponder];
    
    if(searchSelected){
        [self startYouTubeSearch:searchBar.text];
    }
}

- (void)startYouTubeSearch:(NSString*)text{

    NSString *url;
    
    if([text isEqualToString:@""])
    {
        url  = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/standardfeeds/most_popular?v=2&alt=json"];
    }
    else
    {
        url  = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&order=viewCount&q=%@&type=video&key=%@&maxResults=50",text,YOUTUBEKEY];
    }
    
    
    [WebService getYouTubeResult:url completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        if(responseObject){
            NSLog(@"%@",responseObject);
            [self performSelectorOnMainThread:@selector(loadYoutubeList:) withObject:responseObject waitUntilDone:YES];
        }
        
    }];
}

- (void)didSelectFromMenu:(NSString*)stringInput{
    
    [self menuButtonAction:leftBarButton];
    [self hideBar];
    
    NSString *url;
    
    if([stringInput isEqualToString:@"mostpopular"]){
        url  = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=%@&key=%@&maxResults=50",stringInput,YOUTUBEAPIKEY];
        
    }
    else{
        url  = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&videoCategoryId=%@&key=%@&maxResults=50",stringInput,YOUTUBEAPIKEY];
    }
    
    [WebService getYouTubeResult:url completionBlock:^(NSObject *responseObject, NSInteger errorCode){
        if(responseObject){
            NSLog(@"%@",responseObject);
            [self performSelectorOnMainThread:@selector(loadYoutubeList:) withObject:responseObject waitUntilDone:YES];
        }
        
    }];
}

- (void)loadYoutubeList:(id)responseobject{
    
    @autoreleasepool {
        
        [self.arrayvideos removeAllObjects];
        [self.arraytempvideos removeAllObjects];
    
        NSArray *arr = [responseobject objectForKey:@"items"];
        
        for(NSDictionary *dicresults in arr){
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:[Utilities checkNil:@""] forKey:@"imageurl"];
            
            NSString *videoId = [Utilities checkNil:[[dicresults objectForKey:@"id"] valueForKey:@"videoId"]];
            NSString *videoTitle = [Utilities checkNil:[[dicresults objectForKey:@"snippet"] valueForKey:@"title"]];
            
            [dict setObject:videoId forKey:@"videoID"];
            [dict setObject:videoTitle forKey:@"title"];
            
            [dict setObject:@"" forKey:@"seconds"];
            [dict setObject:@"" forKey:@"viewCount"];
            
            NSString *formatted = [Utilities checkNil:[[dicresults objectForKey:@"snippet"] valueForKey:@"publishedAt"]];
            formatted = [formatted stringByReplacingOccurrencesOfString:@"T" withString:@""];
            formatted = [formatted stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            formatted = [formatted stringByReplacingCharactersInRange:NSMakeRange(18, 5) withString:@""];
            
            [dict setObject:[self relativeDateStringForDate:[dateFormat dateFromString:formatted]] forKey:@"published"];
            
            //  int j=0;
            NSDictionary *arrarythumbnail = [[dicresults objectForKey:@"snippet"] valueForKey:@"thumbnails"];
            if(arrarythumbnail.count>0){
                
                NSString *imageurl = [[arrarythumbnail objectForKey:@"medium"] valueForKey:@"url"];
                
                [dict setObject:[Utilities checkNil:imageurl] forKey:@"imageurl"];
            }
            
            [self.arrayvideos addObject:dict];
        }
    }
    [self.arraytempvideos addObjectsFromArray:self.arrayvideos];
    [youtubeTableView reloadData];
}

- (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekOfYear;

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
        return @"Today";
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if(app.tabBarController.view.frame.origin.x > 10){
        [self menuButtonAction:leftBarButton];
        [self hideBar];
    }
}

@end
