//
//  LocationInStore.h
//  Grocery Dude
//
//  Created by Jens Reynders on 4/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"

@class Item;

@interface LocationInStore : Location

@property (nonatomic, retain) NSString *aisle;
@property (nonatomic, retain) NSSet *items;
@end

@interface LocationInStore (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
