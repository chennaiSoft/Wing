//
//  YoutubeShare+CoreDataProperties.h
//  
//
//  Created by CSCS on 03/09/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YoutubeShare.h"

NS_ASSUME_NONNULL_BEGIN

@interface YoutubeShare (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *id;
@property (nullable, nonatomic, retain) NSString *imageurl;
@property (nullable, nonatomic, retain) NSString *published;
@property (nullable, nonatomic, retain) NSString *readstatus;
@property (nullable, nonatomic, retain) NSString *seconds;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *videoID;
@property (nullable, nonatomic, retain) NSString *viewCount;

@end

NS_ASSUME_NONNULL_END
