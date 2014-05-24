//
//  CreateEventController.h
//  tranGOut
//
//  Created by Ryan on 5/23/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEventController : UIViewController
@property (strong, nonatomic) UIDatePicker *datepicker;
@property (strong, nonatomic) UIPopoverController *popOverForDatePicker;
@end
