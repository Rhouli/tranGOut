//
//  colorUtility.m
//  tranGOut
//
//  Created by Ryan on 6/4/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "colorAndFontUtility.h"

@implementation colorAndFontUtility

+ (UIColor*)textFieldColor{
    //return [UIColor colorWithRed:65.0/255.0 green:163.0/255.0 blue:137.0/255.0 alpha:0.6];
    return [UIColor colorWithRed:117.0/255.0 green:165.0/255.0 blue:162.0/255.0 alpha:0.6];
}
+ (UIColor*)backgroundColor{
    //return [UIColor colorWithRed:243.0/255.0 green:239.0/255.0 blue:216.0/255.0 alpha:1];
    return [UIColor colorWithRed:238.0/255.0 green:232.0/255.0 blue:210.0/255.0 alpha:1];
    //return [UIColor whiteColor];
}
+ (UIColor*)textMatchingBackgroundColor{
   // return [UIColor colorWithRed:243.0/255.0 green:239.0/255.0 blue:216.0/255.0 alpha:1];
    return [UIColor colorWithRed:238.0/255.0 green:232.0/255.0 blue:210.0/255.0 alpha:1];
}
+ (UIColor*)textColor{
    //return [UIColor colorWithRed:220.0/255.0 green:74.0/255.0 blue:72.0/255.0 alpha:1];
    return [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:142.0/255.0 alpha:1];
}
+ (UIColor*)buttonColor{
   // return [UIColor colorWithRed:220.0/255.0 green:74.0/255.0 blue:72.0/255.0 alpha:0.8];
   // return [UIColor colorWithRed:34.0/255.0 green:71.0/255.0 blue:94.0/255.0 alpha:0.8];
    return [UIColor colorWithRed:10.0/255.0 green:66.0/255.0 blue:92.0/255.0 alpha:0.8];
   // return [UIColor colorWithRed:240.0/255.0 green:231.0/255.0 blue:151.0/255.0 alpha:0.8];
}
+ (UIColor*)darkBlueColor{
    return [UIColor colorWithRed:10.0/255.0 green:28.0/255.0 blue:40.0/255.0 alpha:1];
}
+ (UIColor*)darkLabelColor{
    return [UIColor colorWithRed:112.0/255.0 green:97.0/255.0 blue:94.0/255.0 alpha:1];
    //return [UIColor colorWithRed:0.0/255.0 green:3.0/255.0 blue:36.0/255.0 alpha:1];
    //return [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:142.0/255.0 alpha:1];
}
+ (UIColor*)lightLabelColor{
    //return [UIColor colorWithRed:112.0/255.0 green:97.0/255.0 blue:94.0/255.0 alpha:1];
    //return [UIColor colorWithRed:0.0/255.0 green:3.0/255.0 blue:36.0/255.0 alpha:1];
    return [UIColor colorWithRed:201.0/255.0 green:218.0/255.0 blue:206.0/255.0 alpha:1];
}

+ (UIColor*)opaqueLabelColor{
   // return [UIColor colorWithRed:201.0/255.0 green:218.0/255.0 blue:206.0/255.0 alpha:0.7];
    return [UIColor colorWithWhite:1 alpha:0.6];
}
+ (UIColor*)darkTanColor{
    return [UIColor colorWithRed:242.0/255.0 green:220.0/255.0 blue:154.0/255.0 alpha:1];
}
+ (UIColor*)pastelGreenColor {
    return [UIColor colorWithRed:65.0/255.0 green:163.0/255.0 blue:137.0/255.0 alpha:1];
}
+ (UIColor*)opaqueWhiteColor {
    return [UIColor colorWithWhite:1 alpha:0.6];
    //return [UIColor colorWithRed:240.0/255.0 green:231.0/255.0 blue:151.0/255.0 alpha:1];
}
+ (UIColor*)redTextColor {
    return [UIColor colorWithRed:192.0/255.0 green:60.0/255.0 blue:68.0/255.0 alpha:1];
}

+ (void)setBorder:(UIView *)view withColor:(UIColor *)color{
  [[view layer] setBorderWidth:2.0f];
  [[view layer] setBorderColor:color.CGColor];
}
+ (void)setBorderWithRoundEdge:(UIView *)view withColor:(UIColor *)color{
    [[view layer] setBorderWidth:2.0f];
    [[view layer] setBorderColor:color.CGColor];
    view.layer.cornerRadius = CORNERRADIUS;
    view.clipsToBounds = YES;
}
+ (void)setRoundEdge:(UIView *)view  {
    view.layer.cornerRadius = CORNERRADIUS;
    view.clipsToBounds = YES;
}

+ (void)setButton:(UIButton *)view withBackgroundColor:(UIColor *)backgroundColor withTextColor:(UIColor *)textColor andFont:(UIFont *)font {
    [view setBackgroundColor:backgroundColor];
    [view setTitleColor:textColor forState:UIControlStateNormal];
    view.titleLabel.font = font;
}

+ (void)setLabel:(UILabel *)view withBackgroundColor:(UIColor *)backgroundColor withTextColor:(UIColor *)textColor andFont:(UIFont *)font {
    [view setBackgroundColor:backgroundColor];
    [view setTextColor:textColor];
    [view setFont:font];
    view.textAlignment = NSTextAlignmentCenter;
}

+ (void)setTextView:(UITextView *)view withBackgroundColor:(UIColor *)backgroundColor withTextColor:(UIColor *)textColor andFont:(UIFont *)font {
    [view setBackgroundColor:backgroundColor];
    [view setTextColor:textColor];
    [view setFont:font];
    view.textAlignment = NSTextAlignmentCenter;
}

+ (void)setTextField:(UITextField *)view withBackgroundColor:(UIColor *)backgroundColor withTextColor:(UIColor *)textColor andFont:(UIFont *)font {
    [view setBackgroundColor:backgroundColor];
    [view setTextColor:textColor];
    [view setFont:font];
    view.textAlignment = NSTextAlignmentCenter;
    view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
}

+ (void)buttonStyleOne:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self buttonColor];
    UIColor *fontColor = [self lightLabelColor];
    UIColor *backgroundColor = [self buttonColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}

+ (void)buttonStyleOneSolid:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self buttonColor];
    UIColor *fontColor = [self lightLabelColor];
    UIColor *backgroundColor = [self textColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}


+ (void)buttonStyleTwo:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self buttonColor];
    UIColor *fontColor =  [self darkLabelColor];
    UIColor *backgroundColor = [self opaqueLabelColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];
    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}

+ (void)buttonStyleTwoSolid:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self buttonColor];
    UIColor *fontColor = [self darkLabelColor];
    UIColor *backgroundColor = [UIColor whiteColor];
    if(round)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else
        [self setBorder:view withColor:borderColor];
    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}

+ (void)buttonStyleThree:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self buttonColor];
    UIColor *fontColor = [self darkLabelColor];
    UIColor *backgroundColor = [self opaqueLabelColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UILabel class]]){
        [self setLabel:(UILabel*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UITextView class]]){
        [self setTextView:(UITextView *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UITextField class]]){
        [self setTextField:(UITextField *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}

+ (void)buttonStyleThreeSolid:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self buttonColor];
    UIColor *fontColor = [self darkLabelColor];
    UIColor *backgroundColor = [UIColor whiteColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UILabel class]]){
        [self setLabel:(UILabel*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UITextView class]]){
        [self setTextView:(UITextView *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}

+ (void)buttonStyleFour:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [UIColor clearColor];
    UIColor *fontColor = [self textColor];
    UIColor *backgroundColor = [self textFieldColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UILabel class]]){
        [self setLabel:(UILabel*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UITextView class]]){
        [self setTextView:(UITextView *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    } else if([view isKindOfClass:[UITextField class]]){
        [self setTextField:(UITextField *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}

+ (void)buttonStyleFive:(UIView *)view withRoundEdges:(BOOL)round{
    UIColor *borderColor = [self lightLabelColor];
    UIColor *fontColor =  [self buttonColor];
    UIColor *backgroundColor = [self lightLabelColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];
    if([view isKindOfClass:[UIButton class]]){
        [self setButton:(UIButton*)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_MEDIUM_FONT];
    }
}
+ (void)textInputBox:(UIView *)view withRoundEdges:(BOOL)round {
    UIColor *borderColor = [UIColor clearColor];
    UIColor *fontColor = [self textColor];
    UIColor *backgroundColor = [self textFieldColor];
    bool border = NO;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];
    
    if([view isKindOfClass:[UITextView class]]){
        [self setTextView:(UITextView *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:nil];
        UITextView *textView = (UITextView *)view;
        textView.textAlignment = NSTextAlignmentLeft;
        view = textView;
    }
}

+ (void)postStyleSenderMe:(UIView *)view{
    UIColor *borderColor = [self darkBlueColor];
    UIColor *fontColor = [self textColor];
    UIColor *backgroundColor = [self lightLabelColor];
    bool border = YES;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UITextView class]]){
        [self setTextView:(UITextView *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_SMALL_FONT];
    }
}

+ (void)postStyleSenderOther:(UIView *)view{
    UIColor *borderColor = [self darkBlueColor];
    UIColor *fontColor = [self textColor];
    UIColor *backgroundColor = [self opaqueWhiteColor];
    bool border = YES;
    if(round && border)
        [self setBorderWithRoundEdge:view withColor:borderColor];
    else if(border)
        [self setBorder:view withColor:borderColor];
    else if(round)
        [self setRoundEdge:view];

    if([view isKindOfClass:[UITextView class]]){
        [self setTextView:(UITextView *)view withBackgroundColor:backgroundColor withTextColor:fontColor andFont:FUTURA_SMALL_FONT];
    }
}

@end
