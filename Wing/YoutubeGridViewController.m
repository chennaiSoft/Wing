//
//  YoutubeGridViewController.m
//  ChatApp
//
//  Created by theen on 15/05/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "YoutubeGridViewController.h"
#import "Utilities.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface YoutubeGridViewController ()

@end

@implementation YoutubeGridViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)updateInputs{
    
    self.arrayItems = [[NSMutableArray alloc]init];
    self.arrayItemsSub = [[NSMutableArray alloc]init];
    
    NSArray *array= @[@"Film & Animation",@"Auto & Vehicles",@"Music",@"Pets & Animals",@"Sports",@"Travel & Events",@"Gaming",@"People & Blogs",@"Comedy",@"Entertainment",@"News & Politics",@"Howto & Style",@"Education",@"Science & Technology",@"Nonprofits & Activism",@"Movies",@"Action/Adventure",@"Classics",@"Shows",@"Trailers"];
    NSArray *array1= @[@"1",@"2",@"10",@"15",@"17",@"19",@"20",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"32",@"33",@"43",@"44"];
    
    [self.arrayItems addObjectsFromArray:array];
    [self.arrayItemsSub addObjectsFromArray:array1];

    imageUser.layer.cornerRadius = imageUser.frame.size.width / 2;
    imageUser.clipsToBounds = YES;
    
    [txt_location setText:[Utilities getLocation]];
    
    txt_name.text = [Utilities getSenderNickname];
    txt_status.text = [Utilities getSenderStatus];
    
    [self setImage];
    
    [self.tabelViewList reloadData];
}


- (void)setImage{
    [imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[Utilities getSenderId] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment"]];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayItems.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    cell.textLabel.text = [self.arrayItems objectAtIndex:indexPath.row];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.tintColor = [UIColor blackColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [delegate didSelectFromMenu:[self.arrayItemsSub objectAtIndex:indexPath.row]];
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

@end
