//
//  YouTubeParser.h
//  MusicDowloaderNew
//
//  Created by Wing on 4/26/15.
//  Copyright (c) 2015 Wing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    YouTubeThumbnailDefault,
    YouTubeThumbnailDefaultMedium,
    YouTubeThumbnailDefaultHighQuality,
    YouTubeThumbnailDefaultMaxQuality
} YouTubeThumbnail;


@interface YouTubeParser : NSObject{
    
}

/**
 Method for retrieving the youtube ID from a youtube URL
 
 @param youtubeURL the the complete youtube video url, either youtu.be or youtube.com
 @return string with desired youtube id
 */
+ (NSString *)youtubeIDFromYoutubeURL:(NSURL *)youtubeURL;

/**
 Method for retreiving a iOS supported video link
 
 @param youtubeURL the the complete youtube video url
 @return dictionary with the available formats for the selected video
 
 */
+ (NSDictionary *)h264videosWithYoutubeURL:(NSURL *)youtubeURL;

/**
 Method for retreiving an iOS supported video link
 
 @param youtubeID the id of the youtube video
 @return dictionary with the available formats for the selected video
 
 */
+ (NSDictionary *)h264videosWithYoutubeID:(NSString *)youtubeID;

/**
 Block based method for retreiving a iOS supported video link
 
 @param youtubeURL the the complete youtube video url
 @param completeBlock the block which is called on completion
 
 */
+ (void)h264videosWithYoutubeURL:(NSURL *)youtubeURL
                   completeBlock:(void(^)(NSDictionary *videoDictionary, NSError *error))completeBlock;
/**
 Method for retreiving a thumbnail for wanted youtube url
 
 @param youtubeURL the the complete youtube video url
 @param thumbnailSize the wanted size of the thumbnail
 @param completeBlock the block which is called on completion
 */
+ (void)thumbnailForYoutubeURL:(NSURL *)youtubeURL
                 thumbnailSize:(YouTubeThumbnail)thumbnailSize
                 completeBlock:(void(^)(UIImage *image, NSError *error))completeBlock;

/**
 Method for retreiving a thumbnail for wanted youtube id
 
 @param youtubeURL the complete youtube video id
 @param thumbnailSize the wanted size of the thumbnail
 @param completeBlock the block which is called on completion
 */
+ (void)thumbnailForYoutubeID:(NSString *)youtubeID
                thumbnailSize:(YouTubeThumbnail)thumbnailSize
                completeBlock:(void(^)(UIImage *image, NSError *error))completeBlock;


/**
 Method for retreiving all the details of a youtube video
 
 @param youtubeURL the the complete youtube video url
 @param completeBlock the block which is called on completion
 
 */
+ (void)detailsForYouTubeURL:(NSURL *)youtubeURL
               completeBlock:(void(^)(NSDictionary *details, NSError *error))completeBlock;

@end
