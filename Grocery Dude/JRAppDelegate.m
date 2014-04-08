//
//  JRAppDelegate.m
//  Grocery Dude
//
//  Created by Jens Reynders on 3/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import "JRAppDelegate.h"
#import "Item.h"
#import "Unit.h"
#import "LocationAtHome.h"
#import "LocationInStore.h"

#define debug YES

@implementation JRAppDelegate
- (void)showUnitAndItemCount{
    //List how many items there are in the database
    NSFetchRequest *itemsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError *itemsError;
    NSArray *fetchedItems = [[[self cdh] context]executeFetchRequest:itemsRequest error:&itemsError];
    if(!fetchedItems)
        NSLog(@"%@", itemsError);
    else
        NSLog(@"Found %lu item(s)",(unsigned long)[fetchedItems count]);
    
    //List the number of Units in the database
    NSFetchRequest *unitsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError *unitsError;
    NSArray *fetchedUnits = [[[self cdh]context]executeFetchRequest:unitsRequest error:&unitsError];
    if(!fetchedUnits)
        NSLog(@"%@",unitsError);
    else
        NSLog(@"Found %lu item(s)",(unsigned long)[fetchedUnits count]);
}

//demo: Chapter 4
- (void)demo{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
//    CoreDataHelper *cdh = [self cdh];
//    NSArray *homeLocations = [NSArray arrayWithObjects: @"Fruit Bowl",@"Pantry",@"Nursery",@"Bathroom",@"Fridge",nil];
//    NSArray *shopLocations = [NSArray arrayWithObjects: @"Produce",@"Aisle 1",@"Aisle 2",@"Aisle 3", @"Deli",nil];
//    NSArray *unitNames = [NSArray arrayWithObjects: @"g",@"pkt",@"box",@"ml",@"kg",nil];
//    NSArray *itemNames = [NSArray arrayWithObjects: @"Grapes",@"Biscuits",@"Nappies",@"Shampoo",@"Sausages",nil];
//    
//    int i = 0;
//    for (NSString *itemName in itemNames){
//        LocationAtHome *locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
//        LocationInStore *locationInStore = [NSEntityDescription insertNewObjectForEntityForName:@"LocationInStore" inManagedObjectContext:cdh.context];
//        Unit *unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
//        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
//        
//        locationAtHome.storedIn = [homeLocations objectAtIndex:i];
//        locationInStore.aisle = [shopLocations objectAtIndex:i];
//        unit.name = [unitNames objectAtIndex:i];
//        item.name = [itemNames objectAtIndex:i];
//        item.locationAtHome = locationAtHome;
//        item.locationInStore = locationInStore;
//        item.unit = unit;
//        
//        i++;
//    }
//    [cdh saveContext];
}

- (CoreDataHelper *)cdh{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (!_coreDataHelper) {
        static dispatch_once_t predicate;
        dispatch_once(&predicate,^{
            _coreDataHelper = [CoreDataHelper new];
        });
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    [self cdh];
    [self demo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[self cdh]saveContext];
}

@end
