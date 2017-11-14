
#import "CSPersonChooseViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "AppDelegate.h"
#import "ContactDb.h"
#import "GUIDesign.h"
#import "WebService.h"
#import "Utilities.h"
#import "SVProgressHUD.h"
#import "Constants.h"

#import "PersonTableViewCell.h"
#import "CSCreateGroupViewController.h"

@interface CSPersonChooseViewController ()
{
    UITableView * tableViewList;
    NSMutableArray * arrayUsers;
    NSFetchedResultsController * fetchRequestController;
    AppDelegate * appDelegate;
}

@property (nonatomic,retain)NSFetchedResultsController *fetchRequestController;

@property (nonatomic, strong) UIBarButtonItem * addButton;
@property (nonatomic, strong) UIBarButtonItem * cancelBtn;
@property (nonatomic, strong) UISearchBar * searchBar;
@property (nonatomic, strong) NSMutableArray *alphabetsArray;
@property (nonatomic, strong)  NSString *searchString;
@property (nonatomic, strong) NSMutableDictionary *disctSelection;

@end

@implementation CSPersonChooseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.disctSelection = [[NSMutableDictionary alloc]init];
    
    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.title = @"Create Chat";
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    self.cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.cancelBtn.tintColor = [UIColor blackColor];
    
    self.addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
    self.addButton.tintColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 65,screenWidth, 44)];
    self.searchBar.placeholder = @"Search";
    self.searchBar.backgroundColor = [GUIDesign GrayColor];
    [self.view addSubview:self.searchBar];
    
    tableViewList = [GUIDesign initWithTabelview:self frmae:CGRectMake(0, self.searchBar.frame.size.height + 65, screenWidth, screenHeight - 65 - 44)];
    
    [tableViewList setBackgroundView:[GUIDesign initWithImageView:CGRectMake(0, 0, screenWidth, screenHeight) img:@"appBg"]];
    [self.view addSubview:tableViewList];
    
    tableViewList.allowsMultipleSelection = YES;
    
    [self getUsers];
}

- (IBAction)addButtonAction:(id)sender{
    
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    NSString * btnTitle = [NSString stringWithFormat:@"Create Group (%lu)",(unsigned long)selectedRows.count];
    
    if ([self.addButton.title isEqualToString:@"Done"]) {
        
        NSIndexPath * path = [selectedRows objectAtIndex:0];
        NSManagedObject * user = [self.fetchRequestController objectAtIndexPath:path];
        [[self navigationController]popViewControllerAnimated:NO];
        [self.deletgate selectPerson:user];
       // [[self navigationController]popViewControllerAnimated:NO];
        
    }else if ([self.addButton.title isEqualToString:btnTitle]) {
        [self actionCreateGroup:nil];
    }else{
        [self createNewPerson];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactNotification:)
                                                 name:@"UpdateContacts"
                                               object:nil];
}

- (void)updateGroupCount{
    
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    
    if (selectedRows.count == 0) {
        
        self.addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
        self.addButton.tintColor = [UIColor blackColor];
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.title = @"Create Chat";

    }else if (selectedRows.count == 1) {
        
        self.addButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonAction:)];
        self.addButton.tintColor = [UIColor blackColor];
        self.navigationItem.rightBarButtonItem = self.addButton;
        self.navigationItem.title = @"Create Chat";

    }else{
        self.navigationItem.title = @"";
        self.addButton.title = [NSString stringWithFormat:@"Create Group (%lu)",(unsigned long)selectedRows.count];
    }
    
}

- (void) didTapNavView
{
    NSLog(@"doSomething");
    [tableViewList setContentOffset:CGPointMake(0, -64) animated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //  [self.navigationController.navigationBar removeGestureRecognizer:singleTap];
    
}

- (IBAction)cancelAction:(id)sender{
    [[self navigationController]popViewControllerAnimated:YES];
}

- (IBAction)actionCreateGroup:(id)sender{
    
    [[NSFileManager defaultManager]  removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/groupchat.png"] error:nil];
    
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (NSIndexPath *path  in selectedRows){
        NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
        [array addObject:[user valueForKey:@"chatappid"]];
        
    }

    CSCreateGroupViewController *group = [[CSCreateGroupViewController alloc]init];
    group.arrayUsers = array;
    [[self navigationController]pushViewController:group animated:YES];
}


- (void)getUsers{
    
    if(self.fetchRequestController)
        self.fetchRequestController = nil;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Phone"
                                              inManagedObjectContext:[[ContactDb sharedInstance] managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:entity];

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"sorting"
                                                         ascending:YES];
    [fr setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fr setReturnsDistinctResults:YES];
    
    NSPredicate *predicate;
    
    if([[Utilities checkNil:self.searchString] isEqualToString:@""]){
        predicate = [NSPredicate predicateWithFormat:@"type=%d",ContactsTypeWINGS];
        
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"type=%d and name contains[c] %@",ContactsTypeWINGS,self.searchString];
        
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

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.alphabetsArray;
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
    return 58;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    return [[[self.fetchRequestController sections] objectAtIndex:sectionIndex] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"contactCell";
    
    PersonTableViewCell * cell = (PersonTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PersonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSManagedObject * user = [self.fetchRequestController objectAtIndexPath:indexPath];
    cell.selectImageView.tintColor = [UIColor lightGrayColor];
    
    cell.titleLabel.text = [user valueForKey:@"name"];
    cell.descriptionLabel.text = @"I'm using Wing";
    
    if(![[user valueForKey:@"status_message"] isEqualToString:@""]){
        cell.descriptionLabel.text = [user valueForKey:@"status_message"];
    }
    
//    friendsDetails.imageUrl = [NSString stringWithFormat:@"%@",[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"chatappid"] lowercaseString]]]];

    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    if([[self.disctSelection objectForKey:[user valueForKey:@"chatappid"]] isEqualToString:@"yes"]){
        
        UIImage * userImg = [UIImage imageNamed:@"EditControlSelected"];
        [userImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectImageView.image = userImg;
    }
    else{
        UIImage * userImg = [UIImage imageNamed:@"EditControl"];
        [userImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.selectImageView.image = userImg;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    [self.disctSelection setValue:@"yes" forKey:[user valueForKey:@"chatappid"]];
    cell.selectImageView.image = [UIImage imageNamed:@"EditControlSelected"];
    
    // Update the delete button's title based on how many items are selected.
    [self updateGroupCount];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];

    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    cell.selectImageView.image = [UIImage imageNamed:@"EditControl"];
    [self.disctSelection removeObjectForKey:[user valueForKey:@"chatappid"]];
    
    [self updateGroupCount];
    
    /*
     if(selectedRows.count==0){
     self.navigationItem.rightBarButtonItem = self.clearButton;
     self.navigationItem.leftBarButtonItem = self.createGroup;
     
     self.createGroup.title=[NSString stringWithFormat:@"Create Group (%d)",selectedRows.count];
     }
     else{
     self.navigationItem.rightBarButtonItem = self.addButton;
     self.navigationItem.leftBarButtonItem = self.cancelButton;
     }
     */
}

/*
- (void)updateTopButtons{
    
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    
    if(selectedRows.count==0){
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = self.addButton;
    }else if(selectedRows.count==1){
        
        self.navigationItem.rightBarButtonItem = self.clearButton;
        self.navigationItem.leftBarButtonItem = self.cancelButton1;
        
    }else{
        self.navigationItem.rightBarButtonItem = self.doneButton;
        self.navigationItem.leftBarButtonItem = self.createGroup;
        self.createGroup.title=[NSString stringWithFormat:@"Create Group (%lu)",(unsigned long)selectedRows.count];
    }
}
*/

- (void)createNewPerson
{
    // Create the pre-filled properties
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, CFSTR(""), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, CFSTR(""), &error);
    
    // Create and set-up the new person view controller
    ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] initWithNibName:nil bundle:nil];
    [newPersonViewController setDisplayedPerson:newPerson];
    [newPersonViewController setNewPersonViewDelegate:(id<ABNewPersonViewControllerDelegate>)self];
    
    // Wrap in a nav controller and display
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    [self presentViewController:navController animated:YES completion:nil];
    
    // Clean up everything
    CFRelease(newPerson);
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveContactNotification:(NSNotification *) notification
{
    [self getUsers];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchString = searchBar.text;
    [self getUsers];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

// called when keyboard search button pressed
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];
    
    [tableView setAllowsMultipleSelection:YES];
    [tableView setAllowsMultipleSelectionDuringEditing:YES];
    [tableView setAllowsSelection:YES];
    [tableView setAllowsSelectionDuringEditing:YES];
    [tableView setEditing:YES];
    [tableView setBackgroundColor:[UIColor clearColor]];
    NSLog(@"show");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchString = @"";
    [self getUsers];
}



@end
