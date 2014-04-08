//
//  ItemViewController.h
//  Grocery Dude
//
//  Created by Jens Reynders on 5/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface ItemViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) NSManagedObjectID *selectedItemID;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *quantityTextField;
@end
