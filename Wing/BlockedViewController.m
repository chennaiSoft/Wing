//
//  BlockedViewController.m
//  ChatApp
//
//  Created by theen on 07/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "BlockedViewController.h"
#import "AddPeopleViewController.h"
#import "ContactDb.h"
#import "CSFriendsTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface BlockedViewController ()

@end

@implementation BlockedViewController

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

    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
    
    self.searchString = @"";
    self.title = @"Blocked";
    self.navigationItem.rightBarButtonItem = self.addBtn;
    //self.navigationItem.leftBarButtonItem = self.editBtn;

    tableViewList.scrollsToTop = YES;
    
    tableViewList.backgroundColor = [UIColor clearColor];
    [tableViewList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    // Do any additional setup after loading the view from its nib.
}

-(void) didTapNavView
{
    NSLog(@"doSomething");
    [tableViewList setContentOffset:CGPointMake(0, -64) animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated{

    [self  getUsers];
    
    [tableViewList setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated{
    
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
        predicate = [NSPredicate predicateWithFormat:@"type=%d and isblocked=%@",ContactsTypeWINGS,@"1"];
        
    }
    else{
        predicate = [NSPredicate predicateWithFormat:@"type=%d and name contains[c] %@ and isblocked=%@",ContactsTypeWINGS,self.searchString,@"1"];
        
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


- (IBAction)actionAdd{
    
    AddPeopleViewController *addPeople = [[AddPeopleViewController alloc]init];
    addPeople.delegate = (id<addPeopleDelegate>)self;
    addPeople.pageType = @"ADD";
    [[self navigationController]pushViewController:addPeople animated:YES];
    
}

- (void)addUsers:(NSMutableArray*)array{
    
    if(array.count>0){
        for (NSString *string in array) {
            [[ContactDb sharedInstance]validateBlocked:string];
        }
        
    }
    
    [self getUsers];
}


- (IBAction)actionEdit{

    if(self.fetchRequestController.sections.count==0)
        return;

    [tableViewList removeGestureRecognizer:gesture1];
    
    [self getUsers];
    
    self.navigationItem.leftBarButtonItem = self.deleteBtn;
    self.navigationItem.rightBarButtonItem = self.cancelBtn;
    [tableViewList setEditing:YES animated:YES];
}

- (IBAction)actionDelete{
    
    actionSheetDelete = [[UIActionSheet alloc]initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Unblock Selected", nil];
    [actionSheetDelete showInView:self.view];
}

- (IBAction)actionCancel{
    
    [tableViewList setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.addBtn;
    self.navigationItem.leftBarButtonItem = self.editBtn;
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
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendsCell";
    
    // Similar to UITableViewCell, but
    CSFriendsTableViewCell * cell = (CSFriendsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CSFriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSManagedObject *user = [self.fetchRequestController objectAtIndexPath:indexPath];
    
	cell.titleLabel.text = [user valueForKey:@"name"];
    
    [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[user valueForKey:@"chatappid"] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment.png"]];
    
    cell.descriptionLabel.text = @"I'm using Wing";
    
    if(![[user valueForKey:@"status_message"] isEqualToString:@""]){
        cell.descriptionLabel.text = [user valueForKey:@"status_message"];
    }
    
    cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.size.width / 2;
    cell.iconImageView.clipsToBounds = YES;
    
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
            [self actionDelete];
        }
    }
}

- (void)tabelViewTapped:(UIGestureRecognizer*)sender{

    NSIndexPath *indexPath = [tableViewList indexPathForRowAtPoint:[sender locationInView:tableViewList]];
    
    if(indexPath){
        [tableViewList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        // If you have custom logic in table view delegate method, also invoke this method too
        [self tableView:tableViewList didSelectRowAtIndexPath:indexPath];
        
    }
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if(buttonIndex==0){
        [self deleteSelected];
    }
    else if(buttonIndex==1){
        [self deleteAll];
    }
}

- (void)deleteSelected{
    
    NSArray *selectedRows = [tableViewList indexPathsForSelectedRows];
    
    for (NSIndexPath *indexpath in selectedRows) {
        NSManagedObject *s = [self.fetchRequestController objectAtIndexPath:indexpath];
        [s setValue:@"0" forKey:@"isblocked"];
        
    }
    [[ContactDb sharedInstance].managedObjectContext save:nil];
    //[self reloadTable];
    [self getUsers];
}

- (void)deleteAll{
    
    [[ContactDb sharedInstance]updateFavorites:[NSString stringWithFormat:@"%ld",(long)ContactsTypeWINGS]];
    
    [self reloadTable];
}

- (void)reloadTable{
    [tableViewList setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.addBtn;
    self.navigationItem.leftBarButtonItem = self.cancelBtn;
    
    [self getUsers];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchString = searchBar.text;
    [self getUsers];
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}


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
}// called when cancel button pressed


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
