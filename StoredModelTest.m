//
//  StoredModelTest.m
//  StoredModel

#import "StoredModelTest.h"
#import "StoredModel.h"

@implementation StoredModelTest

- (void)setUp {
  model = [[NSManagedObjectModel mergedModelFromBundles:
            [NSArray arrayWithObject:[NSBundle bundleWithIdentifier:@"com.yourcompany.tests"]]] retain];
  coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
  context = [[NSManagedObjectContext alloc] init];
  [context setPersistentStoreCoordinator:coordinator];
  
  NSString *basePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                        stringByDeletingLastPathComponent];
  NSURL *storeUrl = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent: @"User/Documents/test.sqlite"]];
	
  NSError *error = nil;
  [[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error];
  if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
    NSLog(@"Error creating store: %@", error);
  }
  
  [StoredModel setContext:context];
}

@end
