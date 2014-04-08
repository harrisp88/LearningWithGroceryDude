//
//  JRAppDelegate.h
//  Grocery Dude
//
//  Created by Jens Reynders on 3/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface JRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;
- (CoreDataHelper*)cdh;

@end
