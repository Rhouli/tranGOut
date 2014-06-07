//
//  ViewEventController.h
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewEventController : UIViewController

@property (strong, nonatomic) NSString* eventTitle;
@property (strong, nonatomic) NSString* eventLocation;
@property (strong, nonatomic) NSAttributedString* eventInfo;
@property (strong, nonatomic) NSString* eventStartTime;
@property (strong, nonatomic) NSString* eventEndTime;
@property (strong, nonatomic) NSString* eventID;
@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UIButton *attendingButton;
@property (strong, nonatomic) UIButton *postButton;
@property (strong, nonatomic) UIButton *inviteButton;
@property (strong, nonatomic) NSNumber *acceptedGuests;
@property (strong, nonatomic) NSNumber *maybeGuests;
@property (strong, nonatomic) NSNumber *undecidedGuests;
@property (strong, nonatomic) PFUser *eventCreator;
@property (strong, nonatomic) PFObject *event;
@property BOOL hideEditor;
@property BOOL blockInvite;

@end
