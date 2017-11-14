//
//  AddPeopleViewController.m
//  ChatApp
//
//  Created by theen on 08/02/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "AddPeopleViewController.h"
#import "ContactDb.h"
#import "AddPeopleTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface AddPeopleViewController ()
@property (nonatomic,retain)  NSString *searchString;

@end

@implementation AddPeopleViewController
@synthesize fetchRequestController;
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
    [super viewDidLoad];
    
    self.searchString = @"";
    self.disctSelection = [[NSMutableDictionary alloc]init];
    if([self.pageType isEqualToString:@"ADD"]){
        [tableViewList setEditing:YES animated:YES];

    }
    
    __weak AddPeopleViewController *weakSelf = self;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = weakSelf;
    }
    
    self.title = @"Select Contacts";
    
    tableViewList.scrollsToTop = YES;
//    UITextField *textField = [searchBar valueForKey:@"_searchField"];
//    textField.clearButtonMode = UITextFieldViewModeNever;

    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];

    [tableViewList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];

    
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    [tableViewList setContentOffset:CGPointMake(0, 0)];

    tableViewList.backgroundColor = [UIColor clearColor];
    tableViewList.scrollsToTop = YES;
    
    [self getUsers];

    self.gridView = [[GridSelectViewController alloc]init];
    [self.gridView.view setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(80), [UIScreen mainScreen].bounds.size.width, 80)];
    [self.view addSubview:self.gridView.view];
    [self.gridView setDelegate:(id<gridDelegate>)self];
    [self.view bringSubviewToFront:self.gridView.view];
    [self.gridView.view setHidden:YES];
    
    // Do any additional setup after loading the view from its nib.
}



-(void) didTapNavView
{
    

    
    NSLog(@"doSomething");
    [tableViewList setContentOffset:CGPointMake(0, -64) animated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactNotification:)
                                                 name:@"UpdateContacts"
                                               object:nil];
}

- (void)clickOnImage:(NSString*)chatappid{
    
   int count =  [[self.fetchRequestController sections] count];
    
    for (int i = 0; i < count; i++) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchRequestController sections] objectAtIndex:i];
        for (int j=0; j<[sectionInfo numberOfObjects]; j++) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:j inSection:i];
            if(path){
                NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
                if([chatappid isEqualToString:[user valueForKey:@"chatappid"]]){
                    [tableViewList scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                    return;
                }

            }
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[self.navigationController.navigationBar removeGestureRecognizer:singleTap];

}


- (IBAction)actionCancel:(id)sender{
    [[self navigationController]popViewControllerAnimated:YES];
    
}

- (IBAction)actionDone:(id)sender{
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for (NSIndexPath *path  in selectedRows){
        NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:path];
        [array addObject:[user valueForKey:@"chatappid"]];
        
    }
    
    [self.delegate addUsers:array];
    
    [[self navigationController]popViewControllerAnimated:YES];
    
    

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
        NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        if ([self.searchString rangeOfCharacterFromSet:notDigits].location == NSNotFound)
        {
            predicate = [NSPredicate predicateWithFormat:@"type=%d and chatappid contains[c] %@",ContactsTypeWINGS,self.searchString];

        }
        else{
            predicate = [NSPredicate predicateWithFormat:@"type=%d and name contains[c] %@",ContactsTypeWINGS,self.searchString];

        }
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
    if(![self.searchString isEqualToString:@""])
        return nil;

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
    
    return 56;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    return [[[self.fetchRequestController sections] objectAtIndex:sectionIndex] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"addCell";
    
    AddPeopleTableViewCell * cell = (AddPeopleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AddPeopleTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    
	cell.labelTitle.text = [user valueForKey:@"name"];
    
    [cell.imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"chatappid"] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment.png"]];
    
    cell.lblStatus.text = @"I'm using Wing";
    
    if(![[user valueForKey:@"status_message"] isEqualToString:@""]){
        cell.lblStatus.text = [user valueForKey:@"status_message"];
    }
    
    
    cell.imageUser.layer.cornerRadius = cell.imageUser.frame.size.width / 2;
    cell.imageUser.clipsToBounds = YES;
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    
    if([[self.disctSelection objectForKey:[user valueForKey:@"chatappid"]] isEqualToString:@"yes"]){
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else{
       // [cell setSelected:NO animated:YES];

    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    
    [self.disctSelection setValue:@"yes" forKey:[user valueForKey:@"chatappid"]];
    
   // [array addObject:[user valueForKey:@"chatappid"]];
    [self.gridView reloadCollectionView:[user valueForKey:@"chatappid"] validate:NO];
    
    
    if(self.gridView.view.isHidden){
        [self viewUp];

    }
    
    
    [tableView setFrame:CGRectMake(0, tableView.frame.origin.y, tableView.frame.size.width, [UIScreen mainScreen].bounds.size.height-80)];

    
   // [searchBar resignFirstResponder];
    // Update the delete button's title based on how many items are selected.
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];

    [self.disctSelection removeObjectForKey:[user valueForKey:@"chatappid"]];
    
    
    [self.gridView reloadCollectionView:[user valueForKey:@"chatappid"] validate:YES];
    
    
    if(self.disctSelection.count==0){
        [self viewDone];
        [tableView setFrame:CGRectMake(0, tableView.frame.origin.y, tableView.frame.size.width, [UIScreen mainScreen].bounds.size.height+80)];

    }
    

    
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];
    [tableView setAllowsMultipleSelection:YES];
    [tableView setAllowsMultipleSelectionDuringEditing:YES];
    [tableView setAllowsSelection:YES];
    [tableView setAllowsSelectionDuringEditing:YES];

    [tableView setEditing:YES];

    [tableView setBackgroundColor:[UIColor clearColor]];
    NSLog(@"show");

    [self.view bringSubviewToFront:self.gridView.view];

    
}

- (void)receiveContactNotification:(NSNotification *) notification
{
    
    [self getUsers];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    self.searchString = searchBar.text;

    [self getUsers];
    
//    if([searchBar.text isEqualToString:@""])
//        [searchBar resignFirstResponder];
}// called when text changes (including clear)

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    self.searchString =@"";

    [self getUsers];
}// called when cancel button pressed


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

}//

- (void)viewUp{
    
    [self.view bringSubviewToFront:self.gridView.view];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    [self.gridView.view setHidden:NO];
    [self.gridView.view.layer addAnimation:animation forKey:nil];
}

- (void)viewDone{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.gridView.view setHidden:YES];

    [[self.gridView.view layer] addAnimation:animation forKey:@"rightToLeftAnimation"];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
