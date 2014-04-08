//
//  Item.h
//  Grocery Dude
//
//  Created by Jens Reynders on 4/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocationAtHome, LocationInStore, Unit;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSNumber * collected;
@property (nonatomic, retain) NSNumber * listed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) LocationAtHome *locationAtHome;
@property (nonatomic, retain) Unit *unit;
@property (nonatomic, retain) LocationInStore *locationInStore;

@end
