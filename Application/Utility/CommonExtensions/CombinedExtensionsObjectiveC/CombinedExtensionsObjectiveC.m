#import "CombinedExtensionsObjectiveC.h"
#import <objc/runtime.h>

@implementation NSManagedObject (Serialization)

#define DATE_ATTR_PREFIX @"dAtEaTtr:"

#pragma mark -
#pragma mark Dictionary conversion methods

- (NSDictionary*) toDictionaryWithTraversalHistory:(NSMutableArray*)traversalHistory {
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];

    NSMutableArray *localTraversalHistory = nil;
    
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableArray arrayWithCapacity:[attributes count] + [relationships count] + 1];
    } else {
        localTraversalHistory = traversalHistory;
    }
    
    [localTraversalHistory addObject:self];
    
    [dict setObject:[[self class] description] forKey:@"class"];
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        
        if (value != nil) {
            if ([value isKindOfClass:[NSDate class]]) {
                NSTimeInterval date = [(NSDate*)value timeIntervalSinceReferenceDate];
                NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
                [dict setObject:[NSNumber numberWithDouble:date] forKey:dateAttr];
            } else {
                [dict setObject:value forKey:attr];
            }
        }
    }
    
    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];
        
        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            
            // Our set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            
            for (NSManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory]];
                }
            }
            
            [dict setObject:[NSArray arrayWithArray:dictSet] forKey:relationship];
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            
            NSManagedObject* relatedObject = (NSManagedObject*) value;
            
            if ([localTraversalHistory containsObject:relatedObject] == NO) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                [dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory] forKey:relationship];
            }
        }
    }
    if (traversalHistory == nil) {
        [localTraversalHistory removeAllObjects];
    }
    return dict;
}

- (NSDictionary*) toDictionary {
    return [self toDictionaryWithTraversalHistory:nil];
}

+ (id) decodedValueFrom:(id)codedValue forKey:(NSString*)key {
    if ([key hasPrefix:DATE_ATTR_PREFIX] == YES) {
        // This is a date attribute
        NSTimeInterval dateAttr = [(NSNumber*)codedValue doubleValue];
        return [NSDate dateWithTimeIntervalSinceReferenceDate:dateAttr];
    } else {
        // This is an attribute
        return codedValue;
    }
}

- (void) populateFromDictionary:(NSDictionary*)dict{
    NSManagedObjectContext* context = [self managedObjectContext];
    for (NSString* key in dict) {
        if ([key isEqualToString:@"class"]) {
            continue;
        }
        NSObject* value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject* relatedObject =
            [NSManagedObject createManagedObjectFromDictionary:(NSDictionary*)value
                                                           inContext:context];
            [self setValue:relatedObject forKey:key];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];
            for (NSDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject =
                [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                               inContext:context];
                [relatedObjects addObject:relatedObject];
            }
        }
        else if (value != nil) {
            [self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:key];
        }
    }
}

+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                                   inContext:(NSManagedObjectContext*)context{
    NSString* class = [dict objectForKey:@"class"];
    NSManagedObject* newObject =
    (NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:class
                                                          inManagedObjectContext:context];
    [newObject populateFromDictionary:dict];
    return newObject;
}

@end

@implementation NSObject (NSLog)

+ (void)logMessage:(NSString*)message{
    NSLog(@"%@",message);
}

@end

#define FULL_LOGGING 0
#define CHECK_DEALLOCATION 0
#define LOG_NAMES 0

@implementation UIViewController (Logging)

+ (void)load {
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
#if FULL_LOGGING
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewDidLoad));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewWillAppear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewWillAppear:));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewDidAppear:));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewWillDisappear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewWillDisappear));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        {
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidDisappear:));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledViewDidDisappear:));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
#endif
        {
            Method originalMethod = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
            Method extendedMethod = class_getInstanceMethod(self, @selector(loggedEnabledDealloc));
            method_exchangeImplementations(originalMethod, extendedMethod);
        }
        
    });
}

- (void) loggedEnabledViewDidLoad {
#if LOG_NAMES
    NSLog(@"viewDidLoad : %@", [self class]);
#endif
    [self loggedEnabledViewDidLoad];
    [[NSUserDefaults standardUserDefaults]setObject:@"exist" forKey:[[self class]description]];
}

- (void) loggedEnabledViewWillAppear:(BOOL)animated {
#if LOG_NAMES
    NSLog(@"ViewWillAppear : %@", [self class]);
#endif
    [self loggedEnabledViewWillAppear:animated];
}

- (void) loggedEnabledViewDidAppear:(BOOL)animated {
#if LOG_NAMES
    NSLog(@"viewDidAppear : %@", [self class]);
#endif
    [self loggedEnabledViewDidAppear:animated];
}

- (void) loggedEnabledViewWillDisappear {
#if LOG_NAMES
    NSLog(@"ViewWillDisappear : %@", [self class]);
#endif
    [self loggedEnabledViewWillDisappear];
#if CHECK_DEALLOCATION
    [self checkIfViewControllerDeallocatedWhenPopped];
#endif
}

- (void) loggedEnabledViewDidDisappear:(BOOL)animated {
#if LOG_NAMES
    NSLog(@"ViewDidDisappear : %@", [self class]);
#endif
    [self loggedEnabledViewDidDisappear:animated];
}

- (void) loggedEnabledDealloc {
#if CHECK_DEALLOCATION
    [self viewControllerDeallocatedWhenPopped];
#endif
#if LOG_NAMES
    NSLog(@"Dealloc : %@", [self class]);
#endif
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self loggedEnabledDealloc];
}

- (void)viewControllerDeallocatedWhenPopped{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:[[self class]description]];
}

#if CHECK_DEALLOCATION
- (void)checkIfViewControllerDeallocatedWhenPopped{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if ([viewControllers indexOfObject:self] == NSNotFound){
        __block __weak typeof(self) bself = self;
        NSLog(@"%@ just popped out and next within few seconds it should print its deallocation message", [[bself class]description]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((bself!=nil)&&[((NSString*)[[NSUserDefaults standardUserDefaults]objectForKey:[[bself class]description]])  isEqualToString:@"exist"]) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@ doesn't deallocated even it is popped out from navigation stack.. check for possibility of error", [[bself class]description]]);
            }
        });
    }
}
#endif


@end
