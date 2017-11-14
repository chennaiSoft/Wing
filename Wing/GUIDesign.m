//
//  GUIDesign.m
//  ModernTireNew
//
//  Created by Net4site LLC on 06/11/12.
//  Copyright (c) 2012 Net4site LLC. All rights reserved.
//

#import "GUIDesign.h"
#import <QuartzCore/QuartzCore.h>

@implementation GUIDesign


+(UITextField*)initWithtxtField:(CGRect)Frame Placeholder:(NSString*)title delegate:(id)delegate{
    
    UITextField *txt=[[UITextField alloc]initWithFrame:Frame];
    txt.placeholder=title;
    txt.textColor = [UIColor blackColor];
    txt.font = [UIFont systemFontOfSize:16.0];
    txt.backgroundColor = [UIColor clearColor];
    txt.keyboardType = UIKeyboardTypeDefault;
    txt.keyboardAppearance = UIKeyboardAppearanceAlert;
    txt.returnKeyType = UIReturnKeyDone;
    txt.clearButtonMode = UITextFieldViewModeWhileEditing;
    txt.autocapitalizationType = UITextAutocapitalizationTypeNone;
    txt.delegate = delegate;
    txt.textAlignment = NSTextAlignmentLeft;
    return txt;
}

+(BOOL)isIPad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

+(UILabel*)initWithLabel:(CGRect)Frame title:(NSString*)title font:(CGFloat)fontsize txtcolor:(UIColor*)textcolor{
    UILabel *lbl=[[UILabel alloc]initWithFrame:Frame];
    lbl.text=title;
    lbl.backgroundColor=[UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font=[UIFont systemFontOfSize:fontsize];
    lbl.textColor =textcolor;
    return lbl;
}
+(BOOL)isIOS7{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >=7) {
        return YES;
    }else{
        return NO;
    }
}
+ (UIActivityIndicatorView*)ReturnLoadingAnimation:(CGRect)frame{
    UIActivityIndicatorView * activityindicator1 = [[UIActivityIndicatorView alloc]initWithFrame:frame];
    [activityindicator1 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityindicator1 setColor:[UIColor whiteColor]];
    return activityindicator1;
}

+ (UIButton *)initWithbutton:(CGRect)Frame title:(NSString*)title img:(NSString*)image{
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = Frame;
    return btn;
}

+ (UITableView *)initWithTabelview:(id)delegate frmae:(CGRect)Frame{
    UITableView *tbl=[[UITableView alloc]initWithFrame:Frame style:UITableViewStylePlain];
    tbl.backgroundColor = [UIColor clearColor];
    tbl.dataSource = delegate;
    tbl.delegate = delegate;
    return tbl;
}

+ (UIColor *)GrayColor{
    UIColor *colr=[UIColor colorWithRed:214/255.0 green:214/255.0 blue:214/255.0 alpha:1];
    return colr;
}

+(UIColor*)yellowColor{
    UIColor *colr = [UIColor colorWithRed:255/255.0 green:195/255.0 blue:12/255.0 alpha:1];
    return colr;
}
+(UIImageView*)initWithImageView:(CGRect)Frame img:(NSString *)image{
    UIImageView *img=[[UIImageView alloc]initWithFrame:Frame];
    [img setImage:[UIImage imageNamed:image]];
    return img;
}

+(UIView*)initWithView:(CGRect)Frame{
    UIView *view=[[UIView alloc]initWithFrame:Frame];
    return view;
}

+ (NSString *)CurentLocation {
    
    CLLocationManager * locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    NSLog(@"%@",[NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude]);
    
    return [NSString stringWithFormat:@"%f,%f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

@end
