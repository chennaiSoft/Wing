//
//  CountryViewController.h
//  ChatApp
//
//  Created by theen on 30/11/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryViewController : UIViewController{
 
    NSMutableDictionary  *dictCountry;
    NSMutableArray *arr_country;
    
    id resultcountry;
    
    NSIndexPath *checkedIndexPath;
    
    int count;
}

@property(nonatomic,strong)NSMutableArray *arr_country;
@property(nonatomic,strong)NSMutableDictionary  *dictCountry;
@property(nonatomic,strong)NSIndexPath *checkedIndexPath;

@property (weak, nonatomic) IBOutlet UITableView *tableCountry;

- (IBAction)action_Back:(id)sender;

@end
