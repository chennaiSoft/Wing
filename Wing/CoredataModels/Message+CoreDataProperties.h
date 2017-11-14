//
//  Message+CoreDataProperties.h
//  
//
//  Created by CSCS on 03/09/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *datestring;
@property (nullable, nonatomic, retain) NSString *deliver;
@property (nullable, nonatomic, retain) NSDate *deliverydate;
@property (nullable, nonatomic, retain) NSString *displayname;
@property (nullable, nonatomic, retain) NSData *file;
@property (nullable, nonatomic, retain) NSString *file_ext;
@property (nullable, nonatomic, retain) NSString *fileName;
@property (nullable, nonatomic, retain) NSString *fileurl;
@property (nullable, nonatomic, retain) NSString *fromjid;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, retain) NSString *isgroupchat;
@property (nullable, nonatomic, retain) NSString *jid;
@property (nullable, nonatomic, retain) NSData *jsonvalues;
@property (nullable, nonatomic, retain) NSString *localid;
@property (nullable, nonatomic, retain) NSString *messagetype;
@property (nullable, nonatomic, retain) NSString *readstatus;
@property (nullable, nonatomic, retain) NSDate *scheduled_date;
@property (nullable, nonatomic, retain) NSDate *sentdate;
@property (nullable, nonatomic, retain) NSString *serverid;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *tojid;
@property (nullable, nonatomic, retain) NSString *transferstatus;

@end

NS_ASSUME_NONNULL_END
