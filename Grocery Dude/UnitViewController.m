//
//  UnitViewController.m
//  Grocery Dude
//
//  Created by Jens Reynders on 9/04/14.
//  Copyright (c) 2014 JenssRey. All rights reserved.
//

#import "UnitViewController.h"
#import "Unit.h"
#import "JRAppDelegate.h"

#define debug YES

@interface UnitViewController ()

@end

@implementation UnitViewController

#pragma mark - VIEW
- (void)refreshInterface{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    if (_selectedObjectID){
        CoreDataHelper *cdh = [(JRAppDelegate*)[[UIApplication sharedApplication]delegate]cdh];
        Unit *unit = (Unit*)[cdh.context existingObjectWithID:_selectedObjectID error:nil];
        
        _nameTextField.text = unit.name;
    }
}

- (void)viewDidLoad{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    _nameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    [self refreshInterface];
    [_nameTextField becomeFirstResponder];
}

#pragma mark - TEXTFIELD
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(debug)
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));

    CoreDataHelper *cdh = [(JRAppDelegate*)[[UIApplication sharedApplication]delegate]cdh];
    Unit *unit = (Unit*)[cdh.context existingObjectWithID:_selectedObjectID error:nil];
    
    if (textField == _nameTextField){
        unit.name = _nameTextField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SomethingChanged" object:nil];
    }
}

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

@end
