//
//  colorUtility.h
//  tranGOut
//
//  Created by Ryan on 6/4/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CORNERRADIUS 10.0
#define INPUTBOXWIDTHOFFSETPERCENT 0.025
#define SIDESPACING self.view.frame.size.width*INPUTBOXWIDTHOFFSETPERCENT
#define LABELSPACING SIDESPACING

@interface colorUtility : NSObject

+ (UIColor*)textFieldColor;
+ (UIColor*)backgroundColor;
+ (UIColor*)textMatchingBackgroundColor;
+ (UIColor*)textColor;
+ (UIColor*)darkLabelColor;
+ (UIColor*)opaqueLabelColor;
+ (UIColor*)darkTanColor;
+ (UIColor*)pastelGreenColor;
+ (UIColor*)buttonColor;
+ (UIColor*)opaqueWhiteColor;
@end
