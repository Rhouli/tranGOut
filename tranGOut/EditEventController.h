//
//  EditEventController.h
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyEventController.h"
#import "AttributedStringCoderHelper.h"

@interface EditEventController : ModifyEventController

@property (strong, nonatomic) NSString* eventTitleString;
@property (strong, nonatomic) NSString* eventLocationString;
@property (strong, nonatomic) NSAttributedString* eventInfoString;
@property (strong, nonatomic) NSString* eventStartTimeDate;
@property (strong, nonatomic) NSString* eventEndTimeDate;
@property (strong, nonatomic) NSString* eventID;
@end
