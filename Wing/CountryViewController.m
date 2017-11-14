//
//  CountryViewController.m
//  ChatApp
//
//  Created by theen on 30/11/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "CountryViewController.h"
#import "AppDelegate.h"

@interface CountryViewController ()

@property (nonatomic,retain) NSMutableArray *alphabetsArray;
@property (nonatomic,retain) IBOutlet UISearchBar *searchBarTop;
@property(nonatomic,strong) NSString *searchString;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;

@property (nonatomic,retain) IBOutlet UIImageView *imageBg;

@end

@implementation CountryViewController
//@synthesize tableData;
@synthesize dictCountry;
@synthesize checkedIndexPath;
@synthesize arr_country;


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
    
    [[UITableViewCell appearance] setTintColor:[UIColor blackColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],UITextAttributeTextShadowOffset,nil] forState:UIControlStateNormal];
    
    self.checkedIndexPath = nil;
    
    UITextField *textField = [self.searchBarTop valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;

    self.searchString = @"";
    
    self.title  = @"Choose Country";
    
    count = 0;
    self.dictCountry=[NSMutableDictionary new];
    self.arr_country=[NSMutableArray new];
    
    self.alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];

    
    self.tableCountry.scrollsToTop  = YES;
    
    [self load_CountryList];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBarHidden  = YES;
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    [self.tableCountry setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_1.png"]]];
    
    [self.tableCountry setBackgroundColor:[UIColor clearColor]];

    [self.imageBg setFrame:CGRectMake(0, 64, screenWidth, screenHeight - 64)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(![self.searchString isEqualToString:@""])
        return 1;
    return [self.alphabetsArray count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(![self.searchString isEqualToString:@""])
        return nil;
    return self.alphabetsArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if(![self.searchString isEqualToString:@""])
        return nil;

    return [self.alphabetsArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{

    if(![self.searchString isEqualToString:@""]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",self.searchString];
        NSArray *filteredArr = [arr_country filteredArrayUsingPredicate:predicate];
        return [filteredArr count];
    }

    NSPredicate *pred =[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.alphabetsArray objectAtIndex:section]];
    
    NSArray *filteredArr = [arr_country filteredArrayUsingPredicate:pred];

    return [filteredArr count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    static NSString *simpleTableIdentifier = @"country";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    if(![self.searchString isEqualToString:@""]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",self.searchString];
        NSArray *filteredArr = [arr_country filteredArrayUsingPredicate:predicate];
        
        cell.textLabel.text = [filteredArr objectAtIndex:indexPath.row];

    }
    else{
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.alphabetsArray objectAtIndex:indexPath.section]];
        NSArray *filteredArr = [arr_country filteredArrayUsingPredicate:pred];
        NSLog(@"beginwithB = %@",filteredArr);
        cell.textLabel.text = [filteredArr objectAtIndex:indexPath.row];

    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSLog(@"%ld",(long)indexPath.row);
    if(self.checkedIndexPath)
    {
        if ((indexPath.row==self.checkedIndexPath.row)&&(indexPath.section==self.checkedIndexPath.section))
        {
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.checkedIndexPath = indexPath;
    count = 1;
    
    [self addCountryDetails];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CountryCode" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)load_CountryList{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];

       dictCountry = result;
    
       NSArray *arr = [result allObjects];
    
       NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(localizedCompare:)];
       NSArray* sortedArray = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
      [arr_country addObjectsFromArray:sortedArray];
      [_tableCountry reloadData];
    
}

- (IBAction)action_Back:(id)sender {
    
    if(count!=0){
        [self addCountryDetails];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CountryCode" object:nil];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

-(void)addCountryDetails{
    
    if(![self.searchString isEqualToString:@""]){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",self.searchString];
        NSArray *filteredArr = [arr_country filteredArrayUsingPredicate:predicate];
        
        NSArray *temp = [dictCountry allKeysForObject:[filteredArr objectAtIndex:checkedIndexPath.row]];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[filteredArr objectAtIndex:checkedIndexPath.row] forKey:@"countryname"];
        [[NSUserDefaults standardUserDefaults] setObject:[temp lastObject] forKey:@"countrycode"];
    }
    else{
        NSPredicate *pred =[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", [self.alphabetsArray objectAtIndex:checkedIndexPath.section]];
        NSArray *filteredArr = [arr_country filteredArrayUsingPredicate:pred];
        
        
        NSArray *temp = [dictCountry allKeysForObject:[filteredArr objectAtIndex:checkedIndexPath.row]];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[filteredArr objectAtIndex:checkedIndexPath.row] forKey:@"countryname"];
        [[NSUserDefaults standardUserDefaults] setObject:[temp lastObject] forKey:@"countrycode"];
        
        NSLog(@"beginwithB = %@",filteredArr);
        
    }

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mobilecode" ofType:@"plist"];
    NSDictionary *theDict = [NSDictionary dictionaryWithContentsOfFile:filePath];

    NSArray *arr=[theDict objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"countrycode"]];
    [[NSUserDefaults standardUserDefaults] setObject:[arr objectAtIndex:0] forKey:@"mobilecode"];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    count = 0;
    self.checkedIndexPath = nil;
    self.searchString = searchText;
    [self.tableCountry reloadData];
    NSLog(@"%@",searchText);
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

@end
