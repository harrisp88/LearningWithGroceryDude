//
//  ItemViewController.m
//  Grocery Dude
//
//  Created by Jens Reynders on 5/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import "ItemViewController.h"
#import "JRAppDelegate.h"
#import "Item.h"

#define debug YES

@interface ItemViewController ()

@end

@implementation ItemViewController

#pragma mark - INTERACTION
- (IBAction)done:(id)sender{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideKeyboardWhenBackgroundIsTapped{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)hideKeyboard{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [self.view endEditing:YES];
}

#pragma mark - DELEGATE: UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if(textField == self.nameTextField){
        if([_nameTextField.text isEqualToString:@"New Item"]){
            _nameTextField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    CoreDataHelper *cdh = [(JRAppDelegate*)[[UIApplication sharedApplication]delegate]cdh];
    Item *item = (Item*)[cdh.context existingObjectWithID:_selectedItemID error:nil];
    
    if(textField == _nameTextField){
        if ([textField.text isEqualToString:@""]) {
            self.nameTextField.text = @"New Item";
        }
        item.name = _nameTextField.text;
    } else if (textField == _quantityTextField){
        item.quantity = [NSNumber numberWithFloat:_quantityTextField.text.floatValue];
    }
}

#pragma mark - VIEW
- (void)refreshInterface{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if(_selectedItemID){
        CoreDataHelper *cdh = [(JRAppDelegate*)[[UIApplication sharedApplication]delegate]cdh];
        Item *item = (Item*)[cdh.context existingObjectWithID:_selectedItemID error:nil];
        _nameTextField.text = item.name;
        _quantityTextField.text = [item.quantity stringValue];
    }
}

- (void)viewDidLoad{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    _nameTextField.delegate = self;
    _quantityTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [self refreshInterface];
    if([_nameTextField.text isEqualToString:@"New Item"]){
        self.nameTextField.text = @"";
        [_nameTextField becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    CoreDataHelper *cdh = [(JRAppDelegate*)[[UIApplication sharedApplication]delegate]cdh];
    [cdh saveContext];
}
@end
