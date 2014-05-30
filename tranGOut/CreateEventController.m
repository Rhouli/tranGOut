//
//  CreateEventController.m
//  tranGOut
//
//  Created by Ryan on 5/23/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "CreateEventController.h"
#import "AppDelegate.h"

@interface CreateEventController () 

@end

@implementation CreateEventController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)createAnEvent:(id)sender {
    PFObject *event = [PFObject objectWithClassName:@"Event"];
    event[@"title"] = [self.eventTitle text];
    event[@"location"] = [self.eventLocation text];
    event[@"info_plain"] = [self.eventInfo text];
    event[@"info_attributed"] = [AttributedStringCoderHelper encodeAttributedString:[self.eventInfo attributedText]];
    event[@"creator"] = [PFUser currentUser];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    event[@"startTime"] = [dateFormat dateFromString:[self.startTime titleForState:UIControlStateNormal]];
    event[@"endTime"] = [dateFormat dateFromString:[self.endTime titleForState:UIControlStateNormal]];
    
    [event saveInBackground];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
