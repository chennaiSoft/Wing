//
//  AboutViewController.m
//  TestProject
//
//  Created by Theen on 02/03/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "AboutViewController.h"
#import "ContactUsViewController.h"
#import "AppDelegate.h"

#define FAQURL @"http://www.csoftconsultancy.com"

@interface AboutViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation AboutViewController

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

    self.title = @"About";
    
//     AMeen Coded
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    appBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    appBg.image = [UIImage imageNamed:@"appBg.png"];
    [self.view addSubview:appBg];
    
    imaegAppLogo = [[UIImageView alloc]init];
    imaegAppLogo.frame = CGRectMake((screenWidth - 100)/2, (87), 100, 100);
    imaegAppLogo.image = [UIImage imageNamed:@"login_logo.png"];
    [self.view addSubview:imaegAppLogo];
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *name = [infoDict objectForKey:@"CFBundleName"];

    labelAppName = [[UILabel alloc]init];
    labelAppName.frame = CGRectMake((screenWidth - 100)/2, CGRectGetMaxY(imaegAppLogo.frame)+ 15, 100, 21);
    labelAppName.textAlignment = NSTextAlignmentCenter;
    labelAppName.text = [NSString stringWithFormat:@"%@",name];
    [self.view addSubview:labelAppName];

    labelAppVersion = [[UILabel alloc]init];
    labelAppVersion.frame = CGRectMake(0, CGRectGetMaxY(labelAppName.frame)+ 15, screenWidth, 21);
    labelAppVersion.textAlignment = NSTextAlignmentCenter;
    labelAppVersion.text = [NSString stringWithFormat:@"Version %@",version];
    [self.view addSubview:labelAppVersion];
    
    tablView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(labelAppVersion.frame)+ 30, screenWidth, 88) style:UITableViewStylePlain];
    tablView.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
    tablView.dataSource = self;
    tablView.delegate = self;
    [self.view addSubview:tablView];

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSInteger year = [components year];
    
    labelCopyRight = [[UILabel alloc]initWithFrame:CGRectMake(0, (screenHeight-50), screenWidth, 50)];
    labelCopyRight.text = [NSString stringWithFormat:@"Copyright @ %ld Wing Inc. All rights reserved.",(long)year];
    if (screenHeight < 569) {
        
        labelCopyRight.font = [UIFont systemFontOfSize:14];
    }
    [labelCopyRight setBackgroundColor:[UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0]];
    labelCopyRight.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:labelCopyRight];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"cellIndentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];

    if(indexPath.row==0){
        cell.textLabel.text = @"Help/FAQ";
    }
    
    else if(indexPath.row==1){
        cell.textLabel.text = @"Contact Us";
    }
    [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==0) {
        [[self navigationController]pushViewController:controllerFaq animated:YES];
        [webFaq loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:FAQURL]]];
    }
    else if (indexPath.row==1) {
        
        ContactUsViewController *contact = [[ContactUsViewController alloc]init];
        [[self navigationController]pushViewController:contact animated:YES];
    }
}

#pragma mark Contact Us


- (IBAction)actionCancel:(id)sender{
    [[controllerFaq navigationController]popViewControllerAnimated:YES];
}
- (IBAction)actionSend:(id)sender{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
