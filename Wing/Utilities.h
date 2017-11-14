//
//  Utilities.h
//  ChatApp
//
//  Created by theen on 01/12/14.
//  Copyright (c) 2014 theen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utilities : NSObject


+ (NSString *)urlEncode:(NSString *)url;
+ (void)alertViewFunction:(NSString *)title message:(NSString *)message;
+ (NSString*)checkNil:(NSString*)string;
+ (void)updateDefaultsValue:(NSString*)value key:(NSString*)key;
+ (NSString *) dateInFormat:(NSString *)stringFormat;
+ (NSString*)checkAlbhapet:(NSString*)string;
+ (NSString*)getSenderNickname;
+ (NSString*)getSenderId;
+ (NSString*)getReceiverId;
+ (void)saveFilesWithEncryption:(NSString*)filepath file:(NSData*)filedata;
+ (NSString*)getFilePath: (NSString*)fileId :(NSString*)fileType;
+ (NSString *)documentsPath:(NSString *)fileName;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
+ (UIImage *)fixOrientation: (UIImage *)imageOriginal;

+ (NSString*)getSenderUserId;
+ (void)saveDefaultsValues :(NSString*)value :(NSString*)key;
+(UINavigationController *)makeNavController:(UIViewController *)root delegate:(id)delegate;

+ (NSString*)getReceiverName;
+ (NSString*)getFacebookName;
+ (NSString*)getFacebookID;

+(UIImage*)resizedImageToSize:(CGSize)dstSize image:(UIImage*)inputImage;
+(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale image:(UIImage*)inputImage;

+ (UIImage *)imageRotatedByDegrees:(CGFloat)degrees image:(UIImage*)image;

+(double) getVideoFileSize:(NSString*) path;
+(void)deleteTmpFile:(NSString*)pat;
+(float) durationOfVideo:(NSString*)path;
+(float) bytePerSecond:(NSInteger)size :(float) seconds;
+(void)configureprogressview:(NSString*)stringlocalid;
+ (NSString *)relativeDateStringForDate:(NSDate *)date;
+(NSString*)checkNil1:(NSString*)string;
+(NSString*)getAudioFilePath: (NSString*)fileId;
+ (NSString*)getDateForCommonString:(NSDate*)datee;
+ (NSString*)getLocation;
+ (NSString*)getSenderStatus;
+ (NSString*)getMediaDownload;
+ (NSString*)getAutoDownloadStatus:(NSString*)type;
+ (NSString*)getPrivacySettings:(NSString*)type;
+ (NSString*)getExpiredDate;
+ (NSDate*)getResetDate;
+ (NSString*)encodingBase64:(NSString*)string;
+ (void)setStatusBsedOnSelection:(NSString*)statusmessage;
+ (NSInteger)getYear;
+ (NSString*)downloadsPath;
+(NSString *)downloadsPathWithFileName:(NSString *)fileName;
+ (NSString*)typeforprivacy:(NSString*)input;
+ (NSString*)valueforprivacy:(NSString*)input;
+ (NSString*)encodingBase64Data:(NSData*)inputdata;
+(NSString*)getFilePathNew: (NSString*)fileId :(NSString*)fileExt;

+(NSString*) durationOfVideoOrAudio:(NSString*)fileId fileExt:(NSString*)fileExt;
+(BOOL)isExistingUser;
+ (NSString*)cachePath;
+ (void)saveUserImage:(NSString*)filename filedata:(NSData*)filedata;
+ (NSString*)decodebase64:(NSString*)inpustring;
+ (NSString*)getUserImageFile:(NSString*)filename;
@end
