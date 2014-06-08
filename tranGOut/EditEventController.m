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
@property (strong, nonatomic) UIButton *deleteButton;
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
    
    [self addDeleteButton];
}

-(void) addDeleteButton {
    // add submit button
    CGPoint deleteButtonPoint = CGPointMake(self.submitButton.frame.origin.x, self.submitButton.frame.origin.y+self.submitButton.frame.size.height+LABELSPACING);
    CGSize deleteButtonSize = self.submitButton.frame.size;
    CGRect deleteButtonRect = {deleteButtonPoint, deleteButtonSize};
    
    self.deleteButton = [[UIButton alloc] initWithFrame:deleteButtonRect];
    [colorAndFontUtility buttonStyleFive:self.deleteButton withRoundEdges:YES];
    [self.deleteButton setTitle:@"Delete Event" forState:UIControlStateNormal];
    [colorAndFontUtility  setBorder:self.deleteButton withColor:[colorAndFontUtility redTextColor]];
    [self.deleteButton addTarget:self action:@selector(deleteEvent:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:self.deleteButton];
}

-(IBAction) deleteEvent:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {

        [event deleteInBackground];
    }];
     [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)showDatePicker:(id)sender{
    self.deleteButton.hidden = YES;
    [super showDatePicker:sender];
}

- (void)removeViews:(id)object {
    [super removeViews:object];
    self.deleteButton.hidden = NO;
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


