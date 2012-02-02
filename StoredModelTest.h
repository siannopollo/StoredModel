//
//  StoredModelTest.h
//  StoredModel

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface StoredModelTest : SenTestCase {
  NSManagedObjectModel *model;
  NSPersistentStoreCoordinator *coordinator;
  NSManagedObjectContext *context;
}
@end
