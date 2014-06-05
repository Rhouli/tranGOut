//
//  colorUtility.m
//  tranGOut
//
//  Created by Ryan on 6/4/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#import "colorUtility.h"

@implementation colorUtility

+ (UIColor*)textFieldColor{
    return [UIColor colorWithRed:65.0/255.0 green:163.0/255.0 blue:137.0/255.0 alpha:0.6];
}
+ (UIColor*)backgroundColor{
    return [UIColor colorWithRed:243.0/255.0 green:239.0/255.0 blue:216.0/255.0 alpha:1];
}
+ (UIColor*)textMatchingBackgroundColor{
    return [UIColor colorWithRed:243.0/255.0 green:239.0/255.0 blue:216.0/255.0 alpha:1];
}
+ (UIColor*)textColor{
    return [UIColor colorWithRed:220.0/255.0 green:74.0/255.0 blue:72.0/255.0 alpha:1];
}
+ (UIColor*)buttonColor{
    return [UIColor colorWithRed:220.0/255.0 green:74.0/255.0 blue:72.0/255.0 alpha:0.8];
}
+ (UIColor*)darkLabelColor{
    return [UIColor colorWithRed:112.0/255.0 green:97.0/255.0 blue:94.0/255.0 alpha:1];
}
+ (UIColor*)opaqueLabelColor{
    return [UIColor colorWithRed:112.0/255.0 green:97.0/255.0 blue:94.0/255.0 alpha:0.7];
}
+ (UIColor*)darkTanColor{
    return [UIColor colorWithRed:242.0/255.0 green:220.0/255.0 blue:154.0/255.0 alpha:1];
}
+ (UIColor*)pastelGreenColor {
    return [UIColor colorWithRed:65.0/255.0 green:163.0/255.0 blue:137.0/255.0 alpha:1];
}
+ (UIColor*)opaqueWhiteColor {
    return [UIColor colorWithWhite:1 alpha:0.6];
}
@end
