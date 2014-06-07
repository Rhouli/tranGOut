//
//  EditEventController.m
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "EditEventController.h"
#import "addGuestsControllerTVC.h"

@interface EditEventController ()
@end

@implementation EditEventController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventTitle.text = self.eventTitleString;
    self.eventLocation.text = self.eventLocationString;
    [self.eventInfo setAttributedText:self.eventInfoString];
    [self.startTime setTitle:self.eventStartTimeDate forState:UIControlStateNormal];
    [self.endTime setTitle:self.eventEndTimeDate forState:UIControlStateNormal];

    [self.submitButton setTitle:@"Edit Event" forState:UIControlStateNormal];
    [self.submitButton addTarget:self action:@selector(editTheEvent:) forControlEvents: UIControlEventTouchUpInside];
    [self.addGuestButton addTarget:self action:@selector(addGuestAndSubmit:) forControlEvents: UIControlEventTouchUpInside];
}
- (IBAction)addGuestAndSubmit:(id)sender{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        
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
        
        AddGuestsControllerTVC *inviteGuests = [[AddGuestsControllerTVC alloc] init];
        inviteGuests.eventTitle = [self.eventTitle text];
        inviteGuests.eventID = [event objectId];
        self.event = event;
        [self.navigationController pushViewController:inviteGuests animated:NO];
    }];
}

- (IBAction)editTheEvent:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        
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
        
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end


