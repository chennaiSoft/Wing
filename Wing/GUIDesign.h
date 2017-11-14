//
//  GUIDesign.h
//  ModernTireNew
//
//  Created by Net4site LLC on 06/11/12.
//  Copyright (c) 2012 Net4site LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GUIDesign : NSObject

+(UILabel*)initWithLabel:(CGRect)Frame title:(NSString*)title font:(CGFloat)fontsize txtcolor:(UIColor*)textcolor;
+(UITextField*)initWithtxtField:(CGRect)Frame Placeholder:(NSString*)title delegate:(id)delegate;
+(BOOL)isIPad;
+(UIActivityIndicatorView*)ReturnLoadingAnimation:(CGRect)frame;
+(UIButton*)initWithbutton:(CGRect)Frame title:(NSString*)title img:(NSString*)image;
+(UITableView*)initWithTabelview:(id)delegate frmae:(CGRect)Frame;
+(UIImageView*)initWithImageView:(CGRect)Frame img:(NSString *)image;
+(UIView*)initWithView:(CGRect)Frame;
+(UIColor*)GrayColor;
+(UIColor*)yellowColor;
+(BOOL)isIOS7;
+(NSString *)CurentLocation;
@end
