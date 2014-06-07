//
//  GuestsControllerTVC.h
//  tranGOut
//
//  Created by Ryan on 6/6/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Parse/Parse.h>
#import "colorAndFontUtility.h"

@interface GuestsControllerTVC : PFQueryTableViewController
@property (strong, nonatomic) NSString *eventTitle;
@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) PFObject *event;
@end
