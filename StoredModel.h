//
//  StoredModel.h
//  memory

#import <CoreData/CoreData.h>

// This causes warnings, but nothing to worry about :-)
static NSManagedObjectContext *storedModelContext = nil;

@interface StoredModel : NSManagedObject

+ (void)setContext:(NSManagedObjectContext *)newContext;
+ (NSManagedObjectContext *)context;
- (NSManagedObjectContext *)context;

+ (NSString *)name;
+ (NSFetchRequest *)fetchRequestByOrder:(NSString *)orderString andQuery:(NSString* )queryString, ...;
+ (NSFetchRequest *)fetchRequestByOrder:(NSString *)orderString;
+ (NSFetchRequest *)fetchRequest:(NSString* )queryString, ...;
+ (NSFetchRequest *)defaultFetchRequest;

#pragma mark -
#pragma mark Querying methods
#pragma mark - Collection finding
+ (NSMutableArray *)findByOrder:(NSString *)orderString andQuery:(NSString *)queryString, ...;
+ (NSMutableArray *)findByOrder:(NSString *)orderString;
+ (NSMutableArray *)find:(NSString *)queryString, ...;
+ (NSMutableArray *)all;

#pragma mark - Single record finding
+ (id)findFirstByOrder:(NSString *)orderString andQuery:(NSString *)queryString, ...;
+ (id)findFirstByOrder:(NSString *)orderString;
+ (id)findFirst:(NSString *)queryString, ...;
+ (id)findFirst;
+ (id)findByID:(NSManagedObjectID *)objectID;

#pragma mark - Counting
+ (NSNumber *)count:(NSString *)queryString, ...;
+ (NSNumber *)count;

+ (void)deleteAll;

+ (NSMutableArray *)_findResults:(NSFetchRequest *)request;
+ (NSNumber *)_countResults:(NSFetchRequest *)request;
+ (NSArray *)_sortDescriptorsFromOrderString:(NSString *)orderString;

+ (id)new;

#pragma mark -
#pragma mark Instance methods
- (void)save;
- (void)destroy;
@end

// Doing this because NSPredicate does some munging of dates
// that [NSString stringWithFormat:] does not
@interface NSDate (QueryFormat)
- (NSString *)queryFormat;
@end

@implementation NSDate (QueryFormat)
- (NSString *)queryFormat {
  return [NSString stringWithFormat:@"CAST(%f, \"NSDate\")", [self timeIntervalSinceReferenceDate]];
}
@end
