//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Jens Reynders on 3/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import "CoreDataHelper.h"

#define debug YES

@interface CoreDataHelper (){
}

@end

@implementation CoreDataHelper

#pragma mark - FILES
NSString *storeFilename = @"Grocery-Dude.sqlite";

#pragma mark - PATHS
- (NSString *)applicationDocumentsDirectory{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)applicationStoresDirectory{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]]URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[storesDirectory path]]){
        NSError *error;
        if ([fileManager createDirectoryAtURL:storesDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            if(debug)
                NSLog(@"Successfully created Stores directory");
            
        } else {
            NSLog(@"FAILED to create Stores directory: %@", error);
        }
    }
    return storesDirectory;
}

- (NSURL *)storeURL{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    return [[self applicationStoresDirectory]URLByAppendingPathComponent:storeFilename];
}

#pragma mark - SETUP
- (id)init{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:_coordinator];
    
    return self;
}

- (void)loadStore {
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (_store)
        return;
    
    BOOL useMigrationManager = NO;
    if(useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]){
        [self performBackgroundManagedMigrationForStore:[self storeURL]];
    } else {
    
        NSError *error;
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                                  NSInferMappingModelAutomaticallyOption:@YES,
                                  NSSQLitePragmasOption: @{@"journal_mode":@"DELETE"}};
        _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:options error:&error];
        if(!_store){
            NSLog(@"Failed to add store. Error: %@",error);
            abort();
        } else {
            if(debug)
                NSLog(@"Successfully added store: %@", _store);
        }
    }
}

- (void)setupCoreData{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    [self loadStore];
}

#pragma mark - SAVING
- (void)saveContext{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if([_context hasChanges]){
        NSError *error;
        if([_context save:&error]){
            NSLog(@"_context saved changes to persistent store");
        } else {
            NSLog(@"Failed to save _context: %@", error);
            [self showValidationError:error];
        }
    }else{
        NSLog(@"SKIPPED _context save, there are no changes!");
    }
}

#pragma mark - MIGRATION MANAGER
- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeURL{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:[self storeURL].path]) {
        if(debug)
            NSLog(@"SKIPPED MIGRATION: Source database missing");
        return NO;
    }
    NSError *error;
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
    NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
    if([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]){
        if(debug)
            NSLog(@"SKIPPED MIGRATION: Source is already compatible.");
        return NO;
    }
    return YES;
}

- (BOOL)migrateStore:(NSURL*)sourceStore{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    BOOL succes = NO;
    NSError *error;
    
    // STEP 1 - Gather the Source, Destination and Mapping Model
    NSDictionary *sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:sourceStore error:&error];
    NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetaData];
    
    NSManagedObjectModel *destinModel = _model;
    
    NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
    
    // STEP 2 - Perform migration, assuming the mapping model isn't null
    if (mappingModel) {
        NSError *error;
        NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self forKeyPath:@"migrationProgress" options:NSKeyValueObservingOptionNew context:NULL];
        
        NSURL *destinStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"Temp.sqlite"];
        
        succes = [migrationManager migrateStoreFromURL:sourceStore type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:destinStore destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
        
        if(succes){
            // STEP 3 - Replace the old store with the new migrated store
            if([self replaceStore:sourceStore withStore:destinStore]){
                if(debug)
                    NSLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",sourceStore.path);
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
        } else {
            if(debug)
                NSLog(@"FAILED MIGRATION: %@",error);
        }
    } else {
        if(debug)
            NSLog(@"FAILED MIGRATION: Mapping Model is null");
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress *100;
            NSString *string = [NSString stringWithFormat:@"Migration Progress: %i%%",percentage];
            NSLog(@"%@",string);
            self.migrationVC.label.text = string;
        });
    }
}

- (BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new{
    BOOL succes = NO;
    NSError *error;
    
    if ([[NSFileManager defaultManager]removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&error] ) {
            succes = YES;
        } else {
            if(debug)
                NSLog(@"FAILED to re-home new store: %@",error);
        }
    }else{
        if(debug)
            NSLog(@"FAILED to remove old store %@: Error: %@",old,error);
    }
    return succes;
}

- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    
    //Show migration progress view preventing the user from using the app
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication *sa = [UIApplication sharedApplication];
    UINavigationController *nc = (UINavigationController*)sa.keyWindow.rootViewController;
    [nc presentViewController:self.migrationVC animated:NO completion:nil];
    
    //Perform migration in the background, so it doesn't freeze the UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateStore:storeURL];
        if(done){
            //Migration is finished, add new store
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:&error];
                
                if(!_store){
                    NSLog(@"Failed to add a migrated store: %@",error);
                    abort();
                }else{
                    NSLog(@"Successfully added a migrated store: %@",_store);
                }
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
        }
    });
}

#pragma mark - VALIDATION ERROR HANDLING
- (void)showValidationError:(NSError*)anError{
    if(anError && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]){
        NSArray *errors = nil;
        NSString *txt = @"";
        
        //Populate array with errors
        if(anError.code == NSValidationMultipleErrorsError){
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }else{
            errors = [NSArray arrayWithObject:anError];
        }
        //Display the error(s)
        if(errors && errors.count >0){
            for (NSError *error in errors){
                NSString *entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"]entity]name];
                NSString *property = [error.userInfo objectForKey:@"NSValidationErrorKey"];
                
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:@"%@ delete was denied because there are associated %@\n(Error Code %li)\n\n", entity,property,(long)error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError: txt = [txt stringByAppendingFormat:
                                                                                @"the '%@' relationship count is too small (Code %li)." , property, (long)error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' relationship count is too large (Code %li)."
                               , property, (long)error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' property is missing (Code %li).", property, (long)error.code]; break;
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too small (Code %li).", property, (long)error.code]; break;
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' number is too large (Code %li).", property, (long)error.code]; break;
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too soon (Code %li).", property, (long)error.code]; break;
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is too late (Code %li).", property, (long)error.code]; break;
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' date is invalid (Code %li).", property, (long)error.code]; break;
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too long (Code %li).", property, (long)error.code]; break;
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text is too short (Code %li).", property, (long)error.code]; break;
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:
                               @"the '%@' text doesn't match the specified pattern (Code %li)." , property, (long)error.code];
                        break;
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:
                               @"generated validation error (Code %li)", (long)error.code]; break;
                    default:
                        txt = [txt stringByAppendingFormat:@"Unhandled error code %li in showValidationError method",(long)error.code];
                        break;
                }
            }
            //display error message txt message
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Validation error" message:[NSString stringWithFormat:@"%@Please double-tap the home button and close this application by swiping the application screenshot upwards",txt] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alertView show];
        }
    }
}
@end
