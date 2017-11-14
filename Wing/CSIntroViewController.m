//
//  CSIntroViewController.m
//  Wing
//
//  Created by CSCS on 13/11/15.
//  Copyright © 2015 CSCS. All rights reserved.
//

#import "CSIntroViewController.h"
#import "AppDelegate.h"
#import "GUIDesign.h"
#import <QuartzCore/QuartzCore.h>
#import "CSGetStartViewController.h"

@interface CSIntroViewController ()<UIScrollViewDelegate>
{
    UIScrollView * introScrollView;
    AppDelegate * appDelegate;
    UIPageControl * pageControl;
    
    NSArray * infoArr;
    NSArray * slogArr;
    
    UILabel * sloglbl;
    UILabel * infolbl;
}

@end

@implementation CSIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    introScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, (screenHeight/2) + 40)];
    introScrollView.backgroundColor = [UIColor whiteColor];
    introScrollView.pagingEnabled = YES;
    introScrollView.delegate = self;
    introScrollView.showsHorizontalScrollIndicator = NO;
    [introScrollView setBounces:NO];
    [self.view addSubview:introScrollView];
    
    if (screenHeight == 480) {
        introScrollView.frame = CGRectMake(0, 0, screenWidth, 280);
    }

    slogArr = @[@"Follow a vision, not a path",@"Privacy is not for the passive",@"Erase your words",@"Share at the right place"];
    infoArr = @[@"A Revolutionary Chat App thoughtfully designed for \"You\"",@"Let your chat conversations be Visible to you and invisible to others",@"Cleanup your conversation at all ends",@"Experience fun, sharing your favorite music and videos with our in-app. YouTube player"];
    
    for (int i = 0; i < 4; i++) {
        
        UIImageView * bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(i * screenWidth, -30, screenWidth, (screenHeight/2) + 40)];
        [bgImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"banner%d.png",i+1]]];
        [bgImg setContentMode:UIViewContentModeScaleAspectFill];
        [introScrollView addSubview:bgImg];
        
        if (screenHeight == 480) {
            bgImg.frame = CGRectMake(i * screenWidth, - 30, screenWidth, 280);
        }
        
        if (i == 0) {
            UIImageView * logoImg = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth - 113)/2,(300 - 133)/2 ,113, 133)];
            [logoImg setImage:[UIImage imageNamed:@"intrologo.png"]];
            [logoImg setContentMode:UIViewContentModeCenter];
            [introScrollView addSubview:logoImg];
            
            if (screenHeight == 480) {
                logoImg.frame = CGRectMake((screenWidth - 113)/2,(280 - 133)/2 ,113, 133);
            }
        }
    }
    
    [introScrollView setContentSize:CGSizeMake(screenWidth * 4, 200)];
    
    UIImageView * graylogoImg = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth - 52)/2,((screenHeight/2) + 40 - 26) ,52, 52)];
    [graylogoImg setImage:[UIImage imageNamed:@"intrograylogo.png"]];
    [graylogoImg setContentMode:UIViewContentModeCenter];
    [self.view addSubview:graylogoImg];
    
    sloglbl = [GUIDesign initWithLabel:CGRectMake(0,(graylogoImg.frame.origin.y + 62), screenWidth,30) title:@"" font:18 txtcolor:[UIColor blackColor]];
    sloglbl.text = [[slogArr objectAtIndex:0] uppercaseString];
    [self.view addSubview:sloglbl];
    
    infolbl = [GUIDesign initWithLabel:CGRectMake(50,(sloglbl.frame.origin.y + 40), screenWidth - 100,75) title:@"" font:16 txtcolor:[UIColor grayColor]];
    infolbl.numberOfLines = 0;
    infolbl.text = [infoArr objectAtIndex:0];
    [self.view addSubview:infolbl];
    
    UIButton * skipBtn = [GUIDesign initWithbutton:CGRectMake(50, infolbl.frame.origin.y + 75, screenWidth - 100, 40) title:@"SKIP" img:nil];
    skipBtn.layer.borderWidth = 1.5;
    skipBtn.layer.borderColor = [UIColor grayColor].CGColor;
    skipBtn.layer.cornerRadius = 42/2;
    [skipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [skipBtn addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipBtn];
    
    if (screenHeight == 480) {
     //   graylogoImg.frame = CGRectMake((screenWidth - 52)/2,(280 - 26) ,52, 52);
        sloglbl.frame = CGRectMake(0,(graylogoImg.frame.origin.y + 50), screenWidth,30);
        infolbl.frame = CGRectMake(50,(sloglbl.frame.origin.y + 40), screenWidth - 100,60);
        skipBtn.frame = CGRectMake(50, infolbl.frame.origin.y + 55, screenWidth - 100, 42);
        sloglbl.font=[UIFont systemFontOfSize:16.0];
        infolbl.font=[UIFont systemFontOfSize:14.0];
    }
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake((screenWidth - 100)/2,screenHeight - 30,100,30);
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    pageControl.pageIndicatorTintColor = [GUIDesign GrayColor];
    pageControl.currentPageIndicatorTintColor = [GUIDesign yellowColor];
    [self.view addSubview:pageControl];
    
    
//    NSString *username = @"raj@54.254.222.76"; // OR [NSString stringWithFormat:@"%@@%@",username,XMPP_BASE_URL]]
//    NSString *password = @"149d81bcafbb2334f3eec50228e4791b";
//    
//    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    del.xmppStream.myJID = [XMPPJID jidWithString:username];
//    
//    NSLog(@"Attempting registration for username %@",del.xmppStream.myJID.bare);
//    
//    if (del.xmppStream.supportsInBandRegistration) {
//        NSError *error = nil;
//        if (![del.xmppStream registerWithPassword:password error:&error])
//        {
//            NSLog(@"Oops, I forgot something: %@", error);
//        }else{
//            NSLog(@"No Error");
//        }
//    }
    
}

- (void)skipAction{
    CSGetStartViewController * startView = [[CSGetStartViewController alloc]init];
    [self.navigationController pushViewController:startView animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    pageControl.currentPage = page;
    sloglbl.text = [[slogArr objectAtIndex:pageControl.currentPage] uppercaseString];
    infolbl.text = [infoArr objectAtIndex:pageControl.currentPage];
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
