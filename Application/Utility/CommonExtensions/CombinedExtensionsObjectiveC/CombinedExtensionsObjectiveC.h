#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (Serialization)

- (NSDictionary*) toDictionary;
- (void) populateFromDictionary:(NSDictionary*)dict;
+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context;
@end

@interface NSObject (NSLog)

+ (void)logMessage:(NSString*)message;

@end

@interface UIViewController (Logging)

+ (void)load;

@end
