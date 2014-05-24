//
//  SignInPageController.m
//  tranGOut
//
//  Created by Ryan on 5/23/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SignInPageController.h"

@interface SignInPageController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@end

@implementation SignInPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer * Swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    Swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:Swiperight];
    
    UISwipeGestureRecognizer * Swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    Swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:Swipeleft];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackground"]];;
}

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer{
    [self performSegueWithIdentifier:@"welcome_screen" sender:self];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer{
    [self performSegueWithIdentifier:@"welcome_screen" sender:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}
- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}
- (IBAction)swipeBack:(id)sender {
    [self performSegueWithIdentifier:@"signed_in" sender:self];
}

- (IBAction)Login:(id)sender {
    if([[self.username text] isEqualToString:@""])
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else if ([[self.password text] isEqualToString:@""])
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Empty", nil) message:NSLocalizedString(@"Please Enter your password!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else {
        
        [PFUser logInWithUsernameInBackground:[self.username text] password:[self.password text]
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"Success, I exist so it's all good");
                                                [self performSegueWithIdentifier:@"signed_in" sender:self];
                                            } else {
                                                NSLog(@"This is the Error!: %@ %@", error, [error userInfo]);
                                                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid User", nil) message:NSLocalizedString(@"Invalid username and password combo! Please try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
                                                self.username.placeholder = @"Username";
                                                self.password.placeholder = @"Password";
                                            }
                                        }];
        
    }
}

@end
