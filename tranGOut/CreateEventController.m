//
//  CreateEventController.m
//  tranGOut
//
//  Created by Ryan on 5/23/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "CreateEventController.h"
#import "AppDelegate.h"
#import "addGuestsControllerTVC.h"

@interface CreateEventController () 

@end

@implementation CreateEventController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.submitButton setTitle:@"Create Event" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(createAnEvent:) forControlEvents: UIControlEventTouchUpInside];
    [self.addGuestButton addTarget:self action:@selector(addGuestAndSubmit:) forControlEvents: UIControlEventTouchUpInside];
}

- (IBAction)addGuestAndSubmit:(id)sender{
    PFObject *event= [PFObject objectWithClassName:@"Event"];
    event[@"title"] = [self.eventTitle text];
    event[@"location"] = [self.eventLocation text];
    event[@"info_plain"] = [self.eventInfo text];
    event[@"info_attributed"] = [AttributedStringCoderHelper encodeAttributedString:[self.eventInfo attributedText]];
    event[@"creator"] = [PFUser currentUser];
    event[@"acceptedGuests"] = [NSNumber numberWithInt:1];
    event[@"undecidedGuests"] = [NSNumber numberWithInt:0];
    event[@"maybeGuests"] = [NSNumber numberWithInt:0];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    event[@"startTime"] = [dateFormat dateFromString:[self.startTime titleForState:UIControlStateNormal]];
    event[@"endTime"] = [dateFormat dateFromString:[self.endTime titleForState:UIControlStateNormal]];
    
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error){
        if(!error){
            AddGuestsControllerTVC *inviteGuests = [[AddGuestsControllerTVC alloc] init];
            inviteGuests.eventTitle = [self.eventTitle text];
            inviteGuests.eventID = [event objectId];
            self.event = event;
            [self.navigationController pushViewController:inviteGuests animated:NO];
        }
    }];
}

- (IBAction)createAnEvent:(id)sender {
    if(!self.event){
        self.event = [PFObject objectWithClassName:@"Event"];
        self.event[@"acceptedGuests"] = [NSNumber numberWithInt:1];
        self.event[@"undecidedGuests"] = [NSNumber numberWithInt:0];
        self.event[@"maybeGuests"] = [NSNumber numberWithInt:0];
    }
    self.event[@"title"] = [self.eventTitle text];
    self.event[@"location"] = [self.eventLocation text];
    self.event[@"info_plain"] = [self.eventInfo text];
    self.event[@"info_attributed"] = [AttributedStringCoderHelper encodeAttributedString:[self.eventInfo attributedText]];
    self.event[@"creator"] = [PFUser currentUser];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterShortStyle];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    self.event[@"startTime"] = [dateFormat dateFromString:[self.startTime titleForState:UIControlStateNormal]];
    self.event[@"endTime"] = [dateFormat dateFromString:[self.endTime titleForState:UIControlStateNormal]];

    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error){
        [[[PFUser currentUser] relationForKey:@"Created"] addObject:self.event];
        [[[PFUser currentUser] relationForKey:@"Going"] addObject:self.event];
        [[PFUser currentUser] saveInBackground];
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
