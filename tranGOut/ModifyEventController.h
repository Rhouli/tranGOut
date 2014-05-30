//
//  ModifyEventController.h
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ModifyEventController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *eventTitle;
@property (weak, nonatomic) IBOutlet UITextField *eventLocation;
@property (weak, nonatomic) IBOutlet UIButton *startTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;
@property (weak, nonatomic) IBOutlet UITextView *eventInfo;
@property (weak, nonatomic) IBOutlet UIButton *boldFontButton;
@property (weak, nonatomic) IBOutlet UIButton *italicFontButton;
@property (weak, nonatomic) IBOutlet UIButton *greenColorButton;
@property (weak, nonatomic) IBOutlet UIButton *blueColorButton;
@property (weak, nonatomic) IBOutlet UIButton *redColorButton;
@end
