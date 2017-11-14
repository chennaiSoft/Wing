
#import "CSFavouritesViewController.h"
#import "GUIDesign.h"
#import "AppDelegate.h"
#import "AddPeopleViewController.h"
#import "ChatStorageDB.h"
#import "ContactDb.h"
#import "CSFavoriteTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface CSFavouritesViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    
    UITableView *tableViewList;
    UISearchBar *search;
}

@property (nonatomic, retain) UISearchBar *searchBarTop;
@property (nonatomic, retain) NSFetchedResultsController *fetchRequestController;
@property (nonatomic, retain) NSMutableArray *alphabetsArray;
@property (nonatomic, strong) UIBarButtonItem * addBtn;
@property (nonatomic, strong) UIBarButtonItem * editBtn;
@property (nonatomic, retain)  NSString *searchString;

@property (nonatomic, strong) NSString *receiver_id;
@property (nonatomic, strong) NSString *isgroupchat;
@property (nonatomic) BOOL checkPage;

@end

@implementation CSFavouritesViewController

- (id)init{
    
    self = [super init];
    if (self) {
        self.title = @"Favorites";
        UIImage *deselectedimage = [[UIImage imageNamed:@"favorites"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selectedimage = [[UIImage imageNamed:@"favoriteSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setImage:deselectedimage];
        [self.tabBarItem setSelectedImage:selectedimage];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Favourites";
    
    self.editBtn = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editSelection:)];
    self.editBtn.tintColor = [UIColor blackColor];
    
    self.addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSelection:)];
    self.addBtn.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = self.editBtn;
    self.navigationItem.rightBarButtonItem = self.addBtn;
    
    UIImageView* appbg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appbg.image = [UIImage imageNamed:@"appBg.png"];
    [self.view addSubview:appbg];
    
    search = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, screenWidth, 40)];
    search.delegate = self;
    search.placeholder = @"Search";
    search.backgroundColor = [GUIDesign GrayColor];
    [self.view addSubview:search];
    
    tableViewList = [GUIDesign initWithTabelview:self frmae:CGRectMake(0, 104, screenWidth, screenHeight - 65 - 104)];
    tableViewList.allowsMultipleSelection = YES;
    tableViewList.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:tableViewList];

    self.checkPage = NO;
    self.receiver_id = @"";
    self.isgroupchat = @"";
    
    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"",@"",@"",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    
    self.searchString = @"";

    tableViewList.backgroundColor = [UIColor clearColor];
    [tableViewList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];
    [tableViewList setScrollsToTop:YES];

}

- (void)reloadTable1{
    [tableViewList reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePresence:)
                                                 name:@"updatePresence"
                                               object:nil];

    [self  getUsers];

    
    if((self.checkPage==YES&&(![self.receiver_id isEqualToString:@""]))){
        self.checkPage = NO;
        //commented by thangarajan
//        NewChatViewController * chatViewController = [[NewChatViewController alloc]initWithNibName:@"NewChatViewController" bundle:nil];
//        [Utilities saveDefaultsValues:self.receiver_id :@"receiver_id"];
//        NSString *name;
//
//        if([self.isgroupchat isEqualToString:@"1"]){
//            name = [[ChatStorageDB sharedInstance]validateGroupName:self.receiver_id].capitalizedString;
//            [Utilities saveDefaultsValues:[Utilities checkNil:@"1"] :@"isgroupchat"];
//            
//        }
//        else{
//            [Utilities saveDefaultsValues:[Utilities checkNil:@"0"] :@"isgroupchat"];
//            
//            name = [[ContactDb sharedInstance]validateUserName:self.receiver_id];
//        }
//
//        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_name"];
//        [Utilities saveDefaultsValues:[Utilities checkNil:name] :@"receiver_nick_name"];
//        chatViewController.pageFromChat = NO;
//        chatViewController.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:chatViewController animated:NO];
        return;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.searchBarTop resignFirstResponder];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)getUsers{
    
    if(self.fetchRequestController)
        self.fetchRequestController = nil;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phone"
                                              inManagedObjectContext:[[ContactDb sharedInstance] managedObjectContext]];
    
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];
    //    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"Test"];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sorting"
                                                         ascending:YES];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    
    NSPredicate *predicate;
    
    if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"type=%d and isfavorite=%@",ContactsTypeWINGS,@"1"];
        
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"type=%d and name contains[c] %@ and isfavorite=%@",ContactsTypeWINGS,self.searchString,@"1"];
        
    }
    [fr setPredicate:predicate];
    
    
    self.fetchRequestController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                        managedObjectContext:[[ContactDb sharedInstance] managedObjectContext]
                                          sectionNameKeyPath:@"sorting"
                                                   cacheName:nil];
    
    if (![self.fetchRequestController performFetch:nil])
    {
    }
    
    [tableViewList reloadData];
}


#pragma mark navigation

- (IBAction)addSelection:(id)sender{
    
    AddPeopleViewController *addPeople = [[AddPeopleViewController alloc]init];
    addPeople.delegate = (id<addPeopleDelegate>)self;
    addPeople.pageType = @"ADD";
    addPeople.hidesBottomBarWhenPushed = YES;
    
    [[self navigationController]pushViewController:addPeople animated:YES];
    
}

- (void)addUsers:(NSMutableArray*)array{
    if(array.count>0){
        for (NSString *string in array) {
            [[ContactDb sharedInstance]validateFavorites:string];
        }
    }
    
    [self getUsers];
}


- (IBAction)editSelection:(id)sender{
    
    if(self.fetchRequestController.sections.count==0)
        return;
    
    self.searchBarTop.text = @"";
    [self getUsers];
    
    [tableViewList setEditing:YES animated:YES];
    
    self.editBtn = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    self.editBtn.tintColor = [UIColor blackColor];
    
    self.addBtn = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.editBtn.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = self.editBtn;
    self.navigationItem.rightBarButtonItem = self.addBtn;
}

- (IBAction)deleteAction:(id)sender{

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
                                  [self deleteAll];

                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Delete Selected"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [self deleteSelected];
                                  
                              }];
    
    
    [alert addAction:button0];
    [alert addAction:button2];
    [alert addAction:button1];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelAction:(id)sender{
    
    [tableViewList setEditing:NO animated:YES];
    
    self.editBtn = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editSelection:)];
    self.editBtn.tintColor = [UIColor blackColor];
    
    self.addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSelection:)];
    self.addBtn.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = self.editBtn;
    self.navigationItem.rightBarButtonItem = self.addBtn;
}


#pragma mark UITableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if(![self.searchString isEqualToString:@""])
        return nil;
    return self.alphabetsArray;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    return [[[self.fetchRequestController sections] objectAtIndex:sectionIndex] name];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchRequestController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchRequestController sections] objectAtIndex:section];
    NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"favoriteCell";
    
    CSFavoriteTableViewCell * cell = (CSFavoriteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CSFavoriteTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    cell.btnBadge.hidden = NO;
    
    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    [cell.btnBadge setBackgroundImage:[UIImage imageNamed:@"6.png"] forState:UIControlStateNormal];
    
    NSString *stringstatus = [[XMPPConnect sharedInstance].dictPresence objectForKey:[user valueForKey:@"chatappid"]];
    
    if(![[Utilities checkNil:stringstatus] isEqualToString:@""]){
        
       [cell.btnBadge setBackgroundImage:[UIImage imageNamed:@"green"] forState:UIControlStateNormal];
    }
    
    [cell.btnWingsSelected setTag:indexPath.row];
    
    [cell.btnWingsSelected setTitle:[NSString stringWithFormat:@"%ld",(long)indexPath.section] forState:UIControlStateNormal];
    [cell.btnWingsSelected addTarget:self action:@selector(goToInfo:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnWingsSelected setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    [cell.btnWings setTag:indexPath.row];
    
    [cell.btnWings setTitle:[NSString stringWithFormat:@"%ld",(long)indexPath.section] forState:UIControlStateNormal];
    [cell.btnWings addTarget:self action:@selector(removeFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnWings setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    
    cell.labelTitle.text = [user valueForKey:@"name"];
    
    cell.lblTime.text = [[ChatStorageDB sharedInstance] getDateSring:[user valueForKey:@"chatappid"]];
    
    [cell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"chatappid"] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment.png"]];
    
    cell.lblStatus.text = @"I'm using Wing";
    
    if(![[user valueForKey:@"status_message"] isEqualToString:@""]){
        cell.lblStatus.text = [user valueForKey:@"status_message"];
    }
    
    
    int count = [[ChatStorageDB sharedInstance]getReadStatusBetweenUsers:[user valueForKey:@"chatappid"]];
    
    //if(count>0){
    //  cell.btnBadge.hidden = NO;
    [cell.btnBadge setTitle:(count==0 ? @"": [NSString stringWithFormat:@"%d",count]) forState:UIControlStateNormal];
    // }
    
    
    cell.imageUser.layer.cornerRadius = cell.imageUser.frame.size.width / 2;
    cell.imageUser.clipsToBounds = YES;
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableViewList.editing){
        
    }
    else{
        NSManagedObject *object = [self.fetchRequestController objectAtIndexPath:indexPath];
        
        
        if([[object valueForKey:@"type"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]]){
            
            //commented by thangarajan
            
//            NSString *str = [Utilities checkNil:[[ChatStorageDB sharedInstance] getPassodeStatus:[object valueForKey:@"chatappid"]]];
//            if(![str isEqualToString:@""])
//            {
//                AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
//                [app actioHideOrShowPasscode:[object valueForKey:@"chatappid"] viewcontrol:self isgroupchat:@"0" unhide:NO];
//                return;
//            }
            
            
            [Utilities saveDefaultsValues:[object valueForKey:@"chatappid"] :@"receiver_id"];
            [Utilities saveDefaultsValues:[Utilities checkNil:[object valueForKey:@"name"] ]:@"receiver_name"];
            [Utilities saveDefaultsValues:[object valueForKey:@"name"] :@"receiver_nick_name"];
            [Utilities saveDefaultsValues:@"0" :@"isgroupchat"];
            
//            NewChatViewController * chatViewController = [[NewChatViewController alloc]initWithNibName:@"NewChatViewController" bundle:nil];
//            chatViewController.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:chatViewController animated:YES];
        }
        
    }
}

-(void)passcodeValidated:(NSString*)strjid isgroupchat:(NSString*)isgroupchat{
    
    self.receiver_id = strjid;
    self.isgroupchat = isgroupchat;
    self.checkPage = YES;
}

- (void)removeFavorite:(id)sender{
    UIButton *btn = (UIButton*)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:btn.tag inSection:btn.titleLabel.text.intValue];
    NSManagedObject *object = [self.fetchRequestController objectAtIndexPath:path];
    
    [object setValue:@"0" forKey:@"isfavorite"];
    [[ContactDb sharedInstance].managedObjectContext save:nil];
    
    [self getUsers];
    
}


- (void)goToInfo:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    NSIndexPath *path = [NSIndexPath indexPathForRow:btn.tag inSection:btn.titleLabel.text.intValue];
    NSManagedObject *object = [self.fetchRequestController objectAtIndexPath:path];
    
//    ProfileViewController *profile = [[ProfileViewController alloc]init];
//    profile.pageFromChat = NO;
//    
//    profile.receiver_id = [object valueForKey:@"chatappid"];
//    profile.receiver_name = [object valueForKey:@"name"];
//    profile.receiver_nick_name = [object valueForKey:@"name"];
//    profile.isgroupchat = @"0";
//    
//    [[self navigationController]pushViewController:profile animated:YES];
}

- (void)tabelViewTapped:(UIGestureRecognizer*)sender{
    
    if([self.searchBarTop isFirstResponder]){
        [self.searchBarTop resignFirstResponder];
        return;
    }
    
    NSIndexPath *indexPath = [tableViewList indexPathForRowAtPoint:[sender locationInView:tableViewList]];
    
    if(indexPath){
        [tableViewList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        // If you have custom logic in table view delegate method, also invoke this method too
        [self tableView:tableViewList didSelectRowAtIndexPath:indexPath];
        
    }
}

- (void)deleteSelected{
    
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    
    for (NSIndexPath *indexpath in selectedRows) {
        NSManagedObject *s = [self.fetchRequestController objectAtIndexPath:indexpath];
        [s setValue:@"0" forKey:@"isfavorite"];
        
    }
    [[ContactDb sharedInstance].managedObjectContext save:nil];
    [self reloadTable];
}

- (void)deleteAll{
    
    [[ContactDb sharedInstance]updateFavorites:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]];
    
    [self reloadTable];
}

- (void)reloadTable{
    [self cancelAction:nil];
    [self getUsers];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchString = searchBar.text;
    [self getUsers];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}// called when keyboard search button pressed

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch");
}

- (BOOL) scrollViewShouldScrollToTop:(UIScrollView*) scrollView {
    if (scrollView == tableViewList) {
        return YES;
    } else {
        return NO;
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];
    [tableView setBackgroundColor:[UIColor clearColor]];
    NSLog(@"show");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchString =@"";
    
    [self getUsers];
}

- (void)updatePresence:(NSNotification*)notification{
    [tableViewList reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
