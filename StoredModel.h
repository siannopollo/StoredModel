//
//  StoredModel.h
//  memory

#import <CoreData/CoreData.h>

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
+ (NSMutableArray *)findByKey:(NSString *)key withValue:(id)value;
+ (NSMutableArray *)all;

#pragma mark - Single record finding
+ (id)findFirstByOrder:(NSString *)orderString andQuery:(NSString *)queryString, ...;
+ (id)findFirstByOrder:(NSString *)orderString;
+ (id)findFirst:(NSString *)queryString, ...;
+ (id)findFirstByKey:(NSString *)key withValue:(id)value;
+ (id)findFirst;
+ (id)findByID:(NSManagedObjectID *)objectID;

#pragma mark - Counting
+ (NSNumber *)count:(NSString *)queryString, ...;
+ (NSNumber *)count;

+ (void)deleteAll;

+ (id)new;
+(id)new:(NSDictionary *)dictionary;

#pragma mark -
#pragma mark Instance methods
- (BOOL)save;
- (BOOL)destroy;
- (int)persistenceID;
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
