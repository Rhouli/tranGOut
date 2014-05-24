//
//  WelcomePageController.m
//  tranGOut
//
//  Created by Ryan on 5/23/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Parse/Parse.h>
#import "WelcomePageController.h"

@implementation WelcomePageController
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"LoginBackground"]];;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self performSegueWithIdentifier:@"already_logged_in" sender:self];
    } else {
        // show the signup or login screen
    }
}

- (IBAction)pressedSignUpButton:(id)sender {
    [self performSegueWithIdentifier:@"sign_up" sender:self];
}

- (IBAction)pressedSignUpWithFacebookButton:(id)sender {
    //[self performSegueWithIdentifier:@"sign_up_with_facebook" sender:self];
    
}

- (IBAction)pressedLoginButton:(id)sender {
    [self performSegueWithIdentifier:@"login" sender:self];
}


@end
