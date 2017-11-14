//
//  MessageInfoViewController.m
//  TestProject
//
//  Created by Theen on 06/02/15.
//  Copyright (c) 2015 Rifluxyss. All rights reserved.
//

#import "MessageInfoViewController.h"
#import "JSQMessagesTimestampFormatter.h"

@interface MessageInfoViewController ()

@end

@implementation MessageInfoViewController
@synthesize object;

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
    
    self.title  = @"Info";
    
    labelLeftRead1.layer.cornerRadius = 5;
    labelLeftRead2.layer.cornerRadius = 5;
    labelLeftDelivered1.layer.cornerRadius = 5;
    labelLeftDelivered2.layer.cornerRadius = 5;

    labelLeftRead1.clipsToBounds = YES;
    labelLeftRead2.clipsToBounds = YES;
    labelLeftDelivered1.clipsToBounds = YES;
    labelLeftDelivered2.clipsToBounds = YES;
    
    
    labelLeftRead1.layer.backgroundColor = [UIColor orangeColor].CGColor;
    labelLeftRead2.layer.backgroundColor = [UIColor orangeColor].CGColor;

    labelLeftDelivered1.layer.backgroundColor = [UIColor grayColor].CGColor;
    labelLeftDelivered2.layer.backgroundColor = [UIColor grayColor].CGColor;
    
    labelDeliveryDate.text = @"Pending";
    
    if([self.object valueForKey:@"deliverydate"]){
        
        labelLeftDelivered1.layer.backgroundColor = [UIColor greenColor].CGColor;
        labelLeftDelivered2.layer.backgroundColor = [UIColor greenColor].CGColor;

        labelLeftRead1.layer.backgroundColor = [UIColor greenColor].CGColor;
        labelLeftRead2.layer.backgroundColor = [UIColor greenColor].CGColor;
        
        NSAttributedString  * string;
        
        if ([self.object valueForKey:@"deliverydate"]) {
            string = [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:[self.object valueForKey:@"deliverydate"]];
        }
//        
//        NSString *string = [NSString stringWithFormat:@"%@ at %@",[[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:[self.object valueForKey:@"deliverydate"]].string,[[JSQMessagesTimestampFormatter sharedFormatter] attributedTimeForDate:[self.object valueForKey:@"deliverydate"]].string];
//        
        
        labelDeliveryDate.attributedText = string;
    }
    
    imageBubble.image = [self imageFromCurrentView];
    
    [imageBubble.layer setBackgroundColor:[UIColor clearColor].CGColor];
    
    [imageBubble setFrame:CGRectMake(imageBubble.frame.origin.x, imageBubble.frame.origin.y, self.cellCopy.frame.size.width, self.cellCopy.frame.size.height)];
    
    [viewInfo setFrame:CGRectMake(viewInfo.frame.origin.x, imageBubble.frame.size.height+imageBubble.frame.origin.y+64, viewInfo.frame.size.width, viewInfo.frame.size.height)];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(UIImage *)imageFromCurrentView
{
    UIGraphicsBeginImageContextWithOptions(self.cellCopy.bounds.size, YES, 1);
    [self.cellCopy.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
