//
//  ModifyEventController.h
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "colorAndFontUtility.h"

@interface ModifyEventController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *addGuestButton;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UITextField *eventTitle;
@property (strong, nonatomic) IBOutlet UITextField *eventLocation;
@property (strong, nonatomic) IBOutlet UIButton *startTime;
@property (strong, nonatomic) IBOutlet UIButton *endTime;
@property (strong, nonatomic) IBOutlet UITextView *eventInfo;
@property (strong, nonatomic) IBOutlet UIButton *boldFontButton;
@property (strong, nonatomic) IBOutlet UIButton *italicFontButton;
@property (strong, nonatomic) IBOutlet UIButton *greenColorButton;
@property (strong, nonatomic) IBOutlet UIButton *blueColorButton;
@property (strong, nonatomic) IBOutlet UIButton *redColorButton;
@property (strong, nonatomic) UIView *activeField;
@property (strong, nonatomic) PFObject *event;

-(IBAction)showDatePicker:(id)sender;
- (void)removeViews:(id)object;
@end
