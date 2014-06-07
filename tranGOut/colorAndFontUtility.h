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
#define FUTURA_EXTRA_SMALL_FONT [UIFont fontWithName:@"Futura" size:8]
#define FUTURA_SMALL_FONT [UIFont fontWithName:@"Futura" size:12]
#define FUTURA_MEDIUM_FONT [UIFont fontWithName:@"Futura" size:16]
#define FUTURA_LARGE_FONT [UIFont fontWithName:@"Futura" size:20]

@interface colorAndFontUtility : NSObject

+ (UIColor*)textFieldColor;
+ (UIColor*)backgroundColor;
+ (UIColor*)textMatchingBackgroundColor;
+ (UIColor*)textColor;
+ (UIColor*)darkLabelColor;
+ (UIColor*)darkBlueColor;
+ (UIColor*)lightLabelColor;
+ (UIColor*)opaqueLabelColor;
+ (UIColor*)darkTanColor;
+ (UIColor*)pastelGreenColor;
+ (UIColor*)buttonColor;
+ (UIColor*)opaqueWhiteColor;
+ (void)setBorder:(UIView *)view withColor:(UIColor *)color;
+ (void)setBorderWithRoundEdge:(UIView *)view withColor:(UIColor *)color;
+ (void)setRoundEdge:(UIView *)view;
+ (void)setButton:(UIButton *)view withBackgroundColor:(UIColor *)color withTextColor:(UIColor *)color andFont:(UIFont *)font;
+ (void)setLabel:(UILabel *)view withBackgroundColor:(UIColor *)color withTextColor:(UIColor *)color andFont:(UIFont *)font;
+ (void)setTextView:(UITextView *)view withBackgroundColor:(UIColor *)backgroundColor withTextColor:(UIColor *)textColor andFont:(UIFont *)font;
+ (void)setTextField:(UITextField *)view withBackgroundColor:(UIColor *)backgroundColor withTextColor:(UIColor *)textColor andFont:(UIFont *)font;
+ (void)buttonStyleOne:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)buttonStyleOneSolid:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)buttonStyleTwo:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)buttonStyleTwoSolid:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)buttonStyleThree:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)buttonStyleThreeSolid:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)buttonStyleFour:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)textInputBox:(UIView *)view withRoundEdges:(BOOL)round;
+ (void)postStyleSenderMe:(UIView *)view;
+ (void)postStyleSenderOther:(UIView *)view;
@end
