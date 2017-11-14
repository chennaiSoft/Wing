//
//  AddToContactsViewController.m
//  TestProject
//
//  Created by Theen on 10/02/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "AddToContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddToContactsViewController ()

@end

@implementation AddToContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.arrayJsonValues = [[NSMutableArray alloc]init];
        // Custom initialization
        self.title = @"Add To Contacts";
    }
    return self;
}

- (void)viewDidLoad
{
    
    userName.text  = self.stringUsername;
    
    imageUser.layer.cornerRadius = 30;
    imageUser.clipsToBounds = YES;
    imageUser.layer.borderColor= [UIColor grayColor].CGColor;
    imageUser.layer.borderWidth = 1;
    imageUser.image = self.userImage;
    
    
    [tableList setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"appBg"]]];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return self.arrayJsonValues.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    
    NSDictionary *dict = [self.arrayJsonValues objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict valueForKey:@"label"];
    cell.detailTextLabel.text = [dict valueForKey:@"number"];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (IBAction)actionSaveContacts:(id)sender{
    
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;

    
    NSString *strFName = @"";
    NSString *strLName = @"";

    NSArray *arrayname = [self.stringUsername componentsSeparatedByString:@" "];
    
    if(arrayname.count>0){
        
        if(arrayname.count==1){
            strFName = [arrayname objectAtIndex:0];
        }
        if(arrayname.count>=2){
            strFName = [arrayname objectAtIndex:0];
            strLName = [arrayname objectAtIndex:1];
        }
        
    }
    
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(imageUser.image)];
    
    
    CFDataRef imgDataRef = (__bridge CFDataRef)imageData;
    
    CFStringRef fNameCf = (__bridge CFStringRef)strFName;
    CFStringRef lNameCf = (__bridge CFStringRef)strLName;

    
    ABPersonSetImageData(newPerson, imgDataRef, &error);

    
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, fNameCf, &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, lNameCf, &error);
   // ABPersonSetImageData (()
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);

    for (NSDictionary *dict in self.arrayJsonValues) {
        
        if([[dict valueForKey:@"Type"] isEqualToString:@"Mobile"]){
            CFStringRef phonLabel = (__bridge CFStringRef)[dict valueForKey:@"label"];
            ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)([dict valueForKey:@"number"]), phonLabel, NULL);
        }
        else{
             CFStringRef emailLabel = (__bridge CFStringRef)[dict valueForKey:@"label"];
            ABMultiValueAddValueAndLabel(multiEmail,(__bridge CFTypeRef)([dict valueForKey:@"number"]), emailLabel, NULL);
        }
        
      
    }
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,&error);
    ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);

    
    
   


    
    ABNewPersonViewController* newPersonViewController = [[ABNewPersonViewController alloc] initWithNibName:nil bundle:nil];
    [newPersonViewController setDisplayedPerson:newPerson];
    [newPersonViewController setNewPersonViewDelegate:(id<ABNewPersonViewControllerDelegate>)self];
    
    // Wrap in a nav controller and display
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    [self presentViewController:navController animated:YES completion:nil];
    
    // Clean up everything
    CFRelease(newPerson);
    CFRelease(multiEmail);
    CFRelease(multiPhone);
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
