//
//  GridSelectViewController.m
//  ChatApp
//
//  Created by theen on 01/03/15.
//  Copyright (c) 2015 theen. All rights reserved.
//

#import "GridSelectViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"

@interface GridSelectViewController ()

@end

@implementation GridSelectViewController

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
    self.arrayUsers = [[NSMutableArray alloc]init];
    
    UINib *cellNib = [UINib nibWithNibName:@"GridSelectCell" bundle:nil];
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:@"GridSelectCell"];
    
    [collectionView setBackgroundColor:[UIColor clearColor]];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayUsers.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"GridSelectCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageUser = (UIImageView *)[cell viewWithTag:1];
    imageUser.layer.cornerRadius = imageUser.frame.size.width / 2;
    imageUser.clipsToBounds = YES;

    [imageUser setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@thumb_%@.png",IMGURL,[[self.arrayUsers objectAtIndex:indexPath.row] lowercaseString]]] placeholderImage:[UIImage imageNamed:@"ment.png"]];

    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.delegate clickOnImage:[self.arrayUsers objectAtIndex:indexPath.row]];
}
- (void)reloadCollectionView:(NSString*)chatappid validate:(BOOL)isremove{

    if(isremove){
        [self.arrayUsers removeObject:chatappid];

    }
    else{
        [self.arrayUsers addObject:chatappid];
    }
    
    [collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
