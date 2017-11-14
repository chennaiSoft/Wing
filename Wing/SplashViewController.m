//
//  SplashViewController.m
//  ChatApp
//
//  Created by theen on 27/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import "SplashViewController.h"
#import "Utilities.h"
#import "CSGetStartViewController.h"
#import "Constants.h"

@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize scroll_instruction;

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
    
    labelmain1.text = labelmain1.text.uppercaseString;

    next=0;
    self.pageImages = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"banner_1.png"],
                       [UIImage imageNamed:@"banner_2.png"],
                       [UIImage imageNamed:@"banner_3.png"],
                       [UIImage imageNamed:@"banner_bg_5.png"],
                       nil];
    

    
//    [self showInstruction];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    int pageCount = (int)self.pageImages.count;
    
    self.pageViews = [[NSMutableArray alloc] init];
    float x=0;
    
    for (NSInteger i = 0; i < pageCount; ++i) {
        UIImageView *image = [[UIImageView alloc]init];
        [image setImage:[self.pageImages objectAtIndex:i]];
        [image setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        
        CGRect rect = CGRectMake(x,self.scroll_instruction.frame.origin.y, self.scroll_instruction.frame.size.width, (IS_IPHONE_4 ? 260 :351));
        
        [image setFrame:rect];
        [self.scroll_instruction addSubview:image];
        
        x = x+scroll_instruction.frame.size.width;
        
        //  [self.pageViews addObject:[NSNull null]];
    }
    
    self.scroll_instruction.contentSize = CGSizeMake(pageCount*[UIScreen mainScreen].bounds.size.width, 0);
    
    [self.scroll_instruction bringSubviewToFront:viewmain];
}
- (IBAction)actionskip:(id)sender{
    [Utilities saveDefaultsValues:@"YES" :@"isFirstInstall"];
    CSGetStartViewController *start = [[CSGetStartViewController alloc]init];
    [[self navigationController]pushViewController:start animated:YES];
}

- (void)showInstruction{
    CGSize pagesScrollViewSize = self.scroll_instruction.frame.size;
    self.scroll_instruction.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    
    // Load the initial set of pages that are on screen
    [self loadVisiblePages];
}

- (void)loadVisiblePages
{
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scroll_instruction.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scroll_instruction.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    next=(int) page;
    
    //img_nav.image=[UIImage imageNamed:[NSString stringWithFormat:@"navigation_%d.png",next+1]];
    
    // Update the page control
    
    // Work out which pages you want to load
        
    [self loadPage:0];
    
    // Purge anything before the first page
   /* for (NSInteger i=0; i<firstPage; i++)
    {
        [self purgePage:i];
    }
    
    for (NSInteger i=firstPage; i<=lastPage; i++)
    {
        [self loadPage:i];
    }
    
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++)
    {
        [self purgePage:i];
    }*/
}

- (void)loadPage:(NSInteger)page
{
    if (page < 0 || page >= self.pageImages.count)
    {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first checking if you've already loaded it
//    UIView *pageView = [self.pageViews objectAtIndex:page];
//    if ((NSNull*)pageView == [NSNull null])
//    {
        CGRect frame = self.scroll_instruction.bounds;
    
    
    
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        frame = CGRectInset(frame, 0.0f, 0.0f);
        frame.size.height = 356;
        
        imageMain.image = [self.pageImages objectAtIndex:page];

       // UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        //newPageView.contentMode = UIViewContentModeScaleAspectFit;
        // newPageView.contentMode = UIViewContentModeScaleToFill;
        //newPageView.backgroundColor=[UIColor clearColor];
        //newPageView.frame = frame;
        
       // UIImageView *newPageView_1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner_bg_4.png"]];
        //   newPageView_1.contentMode = UIViewContentModeScaleAspectFit;
        // newPageView_1.contentMode = UIViewContentModeScaleToFill;
        
        
        
        //frame.origin.y=50;
        
        
       // newPageView_1.frame = frame;
      //  [self.scroll_instruction addSubview:newPageView_1];
       // [self.scroll_instruction addSubview:newPageView];
       // [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
   // }
}

- (void)purgePage:(NSInteger)page
{
    if (page < 0 || page >= self.pageImages.count)
    {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null])
    {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    if (scrollView1==self.scroll_instruction)
    {
        //NSLog(@"%f",scroll_instruction.contentOffset.x);
        
       // [self loadVisiblePages];
    }
    // Load the pages that are now on screen
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
NSLog(@"%f",scroll_instruction.contentOffset.x);
    [self setDots:self.scroll_instruction.contentOffset.x];
}

-(void)setDots:(int)offsetvalues{
    
    image_dot1.image = [UIImage imageNamed:@"dot_normal.png"];
    image_dot2.image = [UIImage imageNamed:@"dot_normal.png"];
    image_dot3.image = [UIImage imageNamed:@"dot_normal.png"];
    image_dot4.image = [UIImage imageNamed:@"dot_normal.png"];

    offsetvalues = offsetvalues/scroll_instruction.frame.size.width;
    
    switch (offsetvalues) {
        case 0:{
            image_dot1.image = [UIImage imageNamed:@"1.png"];
            labelmain1.text = @"Follow a vision, not a path";
            labelmain2.text = @"A Revolutionary Chat App thoughtfully designed for \"You\"";
            break;
        }
        case 1:{
            image_dot2.image = [UIImage imageNamed:@"1.png"];
            labelmain1.text = @"Privacy is not for the passive";
            labelmain2.text = @"Let your chat conversations be Visible to you and invisible to others";

            break;
        }
        case 2:{
            image_dot3.image = [UIImage imageNamed:@"1.png"];
            labelmain1.text = @"Erase your words";
            labelmain2.text = @"Cleanup your conversation at all ends";
            break;
        }
        case 3:{
            image_dot4.image = [UIImage imageNamed:@"1.png"];
            labelmain1.text = @"Share at the right place";
            labelmain2.text = @"Experience fun, sharing your favorite music and videos with our in-app. YouTube player";
            
          //  [self performSelector:@selector(actionskip:) withObject:self afterDelay:0.2];
            
            break;
        }
   
        default:
            break;
    }
    
    labelmain1.text = labelmain1.text.uppercaseString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
