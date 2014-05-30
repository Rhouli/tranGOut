//
//  ViewEventController.h
//  tranGOut
//
//  Created by Ryan on 5/29/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewEventController : UIViewController

@property (strong, nonatomic) NSString* eventTitle;
@property (strong, nonatomic) NSString* eventLocation;
@property (strong, nonatomic) NSAttributedString* eventInfo;
@property (strong, nonatomic) NSString* eventStartTime;
@property (strong, nonatomic) NSString* eventEndTime;
@property (strong, nonatomic) NSString* eventID;
@property BOOL hideEditor;

@end
