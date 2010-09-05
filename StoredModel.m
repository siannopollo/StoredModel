//
//  StoredModel.m
//  memory

#import "StoredModel.h"

@implementation StoredModel

#pragma mark Context access methods
+ (void)setContext:(NSManagedObjectContext *)newContext {
  storedModelContext = newContext;
}
+ (NSManagedObjectContext *)context {
  return storedModelContext;
}
- (NSManagedObjectContext *)context {
  return [[self class] context];
}

#pragma mark -
#pragma mark Class methods for Core Data
+ (NSString *)name {
  return [NSString stringWithCString:object_getClassName(self) encoding:NSASCIIStringEncoding]; 
}

+ (id)new {
  return [NSEntityDescription insertNewObjectForEntityForName:[self name] inManagedObjectContext:[self context]];
}

+ (id)new:(NSDictionary *)dictionary {
  id instance = [self new];
  NSString *propertyName;
  for (propertyName in dictionary) {
    [instance setValue:[dictionary objectForKey:propertyName] forKey:propertyName];
  }
  return instance;
}

// Order can either be something like @"order" or @"order desc"
+ (NSFetchRequest *)fetchRequestByOrder:(NSString *)orderString andQuery:(NSString* )queryString, ... {
  NSFetchRequest *request = [self defaultFetchRequest];
  if ([orderString length] > 0) [request setSortDescriptors:[self _sortDescriptorsFromOrderString:orderString]];
  
  if ([queryString length] > 0) {
    va_list argumentList;
    va_start(argumentList, queryString);
    NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
    [request setPredicate:[NSPredicate predicateWithFormat:sqlString]];
  }
  
  return request;
}

+ (NSFetchRequest *)fetchRequestByOrder:(NSString *)orderString {
  return [self fetchRequestByOrder:orderString andQuery:@""];
}

+ (NSFetchRequest *)fetchRequest:(NSString* )queryString, ... {
  va_list argumentList;
  va_start(argumentList, queryString);
  NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
  return [self fetchRequestByOrder:@"" andQuery:sqlString];
}

+ (NSFetchRequest *)defaultFetchRequest {
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:[self name] inManagedObjectContext:[self context]];
  [request setEntity:entity];
  return request;
}

#pragma mark -
#pragma mark Querying methods
+ (NSMutableArray *)findByOrder:(NSString *)orderString andQuery:(NSString *)queryString, ... {
  va_list argumentList;
	va_start(argumentList, queryString);
	NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
  
  return [self _findResults:[self fetchRequestByOrder:orderString andQuery:sqlString]];
}

+ (NSMutableArray *)findByOrder:(NSString *)orderString {
  return [self _findResults:[self fetchRequestByOrder:orderString]];
}

+ (NSMutableArray *)find:(NSString *)queryString, ... {
  va_list argumentList;
	va_start(argumentList, queryString);
	NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
  
  return [self _findResults:[self fetchRequest:sqlString]];
}

+ (NSMutableArray *)all {
  return [self _findResults:[self defaultFetchRequest]];
}

+ (id)findFirstByOrder:(NSString *)orderString andQuery:(NSString *)queryString, ... {
  va_list argumentList;
	va_start(argumentList, queryString);
	NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
  
  NSMutableArray *objects = [self findByOrder:orderString andQuery:sqlString];
  if ([objects count] > 0) return [objects objectAtIndex:0];
	else return  nil;
}

+ (id)findFirstByOrder:(NSString *)orderString {
  return [self findFirstByOrder:orderString andQuery:@""];
}

+ (id)findFirst:(NSString *)queryString, ... {
  va_list argumentList;
	va_start(argumentList, queryString);
	NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
  
  NSMutableArray *objects = [self find:sqlString];
  if ([objects count] > 0) return [objects objectAtIndex:0];
	else return  nil;
}

+ (id)findFirst {
  NSMutableArray *objects = [self all];
  if ([objects count] > 0) return [objects objectAtIndex:0];
	else return  nil;
}

+ (id)findByID:(NSManagedObjectID *)objectID {
  return [[self context] objectRegisteredForID:objectID];
}

+ (NSNumber *)count:(NSString *)queryString, ... {
  va_list argumentList;
	va_start(argumentList, queryString);
	NSString *sqlString = [[NSString alloc] initWithFormat:queryString arguments:argumentList];
  return [self _countResults:[self fetchRequest:sqlString]];
}

+ (NSNumber *)count {
  return [self _countResults:[self defaultFetchRequest]];
}

+ (void)deleteAll {
  for (id object in [self all]) [[self context] deleteObject:object];
  
  NSError *error = nil;
  if (![[self context] save:&error]) {
    // Handle error
  }
}

#pragma mark -
#pragma mark Protected methods
+ (NSMutableArray *)_findResults:(NSFetchRequest *)request {
  NSError *error = nil;
  NSMutableArray *mutableFetchResults = [[[self context] executeFetchRequest:request error:&error] mutableCopy];
  if (mutableFetchResults == nil) {
    // Handle the error.
  }
  
  [request release];
  return mutableFetchResults;
}

+ (NSNumber *)_countResults:(NSFetchRequest *)request {
  NSError *error = nil;
  int number = [[self context] countForFetchRequest:request error:&error];
  return [NSNumber numberWithInt:number];
}

+ (NSArray *)_sortDescriptorsFromOrderString:(NSString *)orderString {
  NSArray *orderComponents = [orderString componentsSeparatedByString:@" "];
  NSString *order = [orderComponents objectAtIndex:0];
  
  BOOL ascending = YES;
  if ([orderComponents count] > 1) {
    NSString *direction = [orderComponents objectAtIndex:1];
    if ([direction isEqualToString:@"desc"]) ascending = NO;
  }
  
  NSArray *result = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:order ascending:ascending]];
  [order release];
  return result;
}

#pragma mark -
#pragma mark Instance Methods
// This ensures that after we save an object, it is up to date with data in the persistent store
- (void)save {
  NSError *error = nil;
  if (![[self context] save:&error]) {
    NSLog(@">>>>>> Error saving: %@", error);
  }
}

- (void)destroy {
  NSError *error = nil;
  NSManagedObjectContext *context = [self context];
  [context deleteObject:self];
  if (![context save:&error]) {
    NSLog(@">>>>>> Error destroying: %@", error);
  }
}

- (void)dealloc {
  [super dealloc];
}
@end
