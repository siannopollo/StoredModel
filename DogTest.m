//
//  DogTest.m
//  StoredModel

#import "DogTest.h"

@implementation DogTest
- (void)setUp {
  [super setUp];
  
  [Dog deleteAll];
  dog = [Dog new];
  dog.name = @"Wishbone";
}

- (void)testSaving {
  [dog save];
  STAssertTrue([[Dog all] count] == 1, @"");
  STAssertTrue([[Dog count] intValue] == 1, @"");
}

- (void)testSettingAttributes {
  [dog save];
  Dog *fetchedDog = [[Dog all] objectAtIndex:0];
  STAssertTrue([fetchedDog.name isEqualToString:@"Wishbone"], @"");
}

- (void)testFinding {
  [dog save];
  
  NSMutableArray *dogs;
  dogs = [Dog find:@"name = '%@'", @"Wishbone"];
  STAssertTrue([dogs count] == 1, @"");
  
  dogs = [Dog find:@"name = '%@'", @"Fido"];
  STAssertTrue([dogs count] == 0, @"");
  
  STAssertEqualObjects(dog, [Dog findFirst:@"name = 'Wishbone'"], @"");
  STAssertNil([Dog findFirst:@"name = 'Spot'"], @"");
}

- (void)testOrdering {
  [dog save];
  Dog *otherDog = [Dog new];
  otherDog.name = @"Scruff"; [otherDog save];
  
  NSMutableArray *dogs;
  dogs = [Dog findByOrder:@"name"];
  STAssertEqualObjects(otherDog, [dogs objectAtIndex:0], @"");
  STAssertEqualObjects(dog, [dogs objectAtIndex:1], @"");
  
  dogs = [Dog findByOrder:@"name desc"];
  STAssertEqualObjects(dog, [dogs objectAtIndex:0], @"");
  STAssertEqualObjects(otherDog, [dogs objectAtIndex:1], @"");
  
  STAssertEqualObjects(otherDog, [Dog findFirstByOrder:@"name"], @"");
  STAssertEqualObjects(dog, [Dog findFirstByOrder:@"name desc"], @"");
}

- (void)testCounting {
  [Dog deleteAll];
  STAssertEquals(0, [[Dog count] intValue], @"");
  dog = [Dog new];
  dog.name = @"Wishbone"; [dog save];
  STAssertEquals(1, [[Dog count] intValue], @"");
  Dog *otherDog = [Dog new];
  otherDog.name = @"Scruff"; [otherDog save];
  STAssertEquals(2, [[Dog count] intValue], @"");
  STAssertEquals(1, [[Dog count:@"name = 'Scruff'"] intValue], @"");
}

- (void)testDestroying {
  [dog save];
  STAssertEquals(1, [[Dog count] intValue], @"");
  [dog destroy];
  STAssertEquals(0, [[Dog count] intValue], @"");
}

- (void)testDateQuerying {
  NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:-86400];
  NSDate *twoDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-86400*2];
  
  [Dog deleteAll];
  dog = [Dog new];
  dog.name = @"Wishbone";
  dog.createdAt = oneDayAgo;
  Dog *otherDog = [Dog new];
  otherDog.name = @"Fluffy";
  otherDog.createdAt = twoDaysAgo;
  
  [dog save]; [otherDog save];
  
  NSMutableArray *dogs;
  dogs = [Dog find:@"createdAt > %@", [oneDayAgo queryFormat]];
  STAssertTrue([dogs count] == 0, @"");
  dogs = [Dog find:@"createdAt > %@", [twoDaysAgo queryFormat]];
  STAssertTrue(1 == [dogs count], @"");
}

- (void)testInitWithDictionary {
  [Dog deleteAll];
  
  dog = [Dog new:[NSDictionary dictionaryWithObjectsAndKeys:@"Fido", @"name", nil]];
  STAssertTrue([dog.name isEqualToString:@"Fido"], @"name is %@", dog.name);
}

- (void)testId {
  [dog save];
  NSString *path = [[[dog objectID] URIRepresentation] path];
  NSArray *components = [path componentsSeparatedByString:@"/"];
  STAssertTrue([[components objectAtIndex:[components count]-1] isEqualToString:@"p1"], @"");
  STAssertTrue([dog persistenceID] == 1, @"id is %i", [dog persistenceID]);
}

- (void)testKeyValueFinding {
  NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:-86400];
  NSDate *twoDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-86400*2];
  
  [Dog deleteAll];
  dog = [Dog new];
  dog.name = @"Wishbone";
  dog.createdAt = oneDayAgo;
  Dog *otherDog = [Dog new];
  otherDog.name = @"Scruff";
  otherDog.createdAt = twoDaysAgo;
  
  [dog save]; [otherDog save];
  
  dog = [[Dog findByKey:@"name" withValue:@"Wishbone"] objectAtIndex:0];
  STAssertTrue([dog.name isEqualToString:@"Wishbone"], @"");
  STAssertEqualObjects(dog.createdAt, oneDayAgo, @"");
  
  dog = [[Dog findByKey:@"createdAt" withValue:twoDaysAgo] objectAtIndex:0];
  STAssertTrue([dog.name isEqualToString:@"Scruff"], @"");
  STAssertEqualObjects(dog.createdAt, twoDaysAgo, @"");
  
  dog = [Dog findFirstByKey:@"createdAt" withValue:oneDayAgo];
  STAssertTrue([dog.name isEqualToString:@"Wishbone"], @"");
  STAssertEqualObjects(dog.createdAt, oneDayAgo, @"");
}
@end
