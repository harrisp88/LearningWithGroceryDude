//
//  PrepareTableViewController.h
//  Grocery Dude
//
//  Created by Jens Reynders on 4/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PrepareTableViewController : CoreDataTableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *clearConfirmActionSheet;

- (IBAction)clear:(id)sender;

@end
