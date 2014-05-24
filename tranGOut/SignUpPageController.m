//
//  ViewController.m
//  tranGOut
//
//  Created by Ryan on 5/22/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "SignUpPageController.h"


@interface SignUpPageController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *email;
@end

@implementation SignUpPageController

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

- (IBAction)createNewUserAndLogin:(id)sender {
    if(([[self.username text] isEqualToString:@""] && [[self.password text] isEqualToString:@""]) || ([[self.username text] isEqualToString:@""] && [[self.email text] isEqualToString:@""]) || ([[self.password text] isEqualToString:@""] && [[self.email text] isEqualToString:@""]))
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) message:NSLocalizedString(@"Make sure you fill out all of the information!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else if ([[self.username text] isEqualToString:@""] && ![[self.password text] isEqualToString:@""] && ![[self.email text] isEqualToString:@""])
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Username Empty", nil) message:NSLocalizedString(@"Please enter a username silly! ", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else if ([[self.password text] isEqualToString:@""] && ![[self.email text] isEqualToString:@""] && ![[self.username text] isEqualToString:@""])
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password Empty", nil) message:NSLocalizedString(@"Please enter a password you crazy guy you! ", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else if ([[self.email text] isEqualToString:@""] && ![[self.username text] isEqualToString:@""] && ![[self.password text] isEqualToString:@""])
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Email Empty", nil) message:NSLocalizedString(@"Please enter a email you goon! ", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    else {
        PFUser *user = [PFUser user];
        user.username = [self.username text];
        user.password = [self.password text];
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error){
                // Passed the test
                NSLog(@"Logged In");
                [self performSegueWithIdentifier:@"signed_up" sender:self];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"%@", errorString);
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil) message:NSLocalizedString(errorString, nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
            }
        }];
    }
}

@end
