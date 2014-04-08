//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by Jens Reynders on 3/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MigrationViewController.h"

@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;
@property (nonatomic, readonly) NSManagedObjectModel *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore *store;

@property (nonatomic, retain) MigrationViewController *migrationVC;

- (void)setupCoreData;
- (void)saveContext;

@end
