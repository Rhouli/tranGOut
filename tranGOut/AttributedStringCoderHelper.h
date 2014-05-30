//
//  AttributedStringCoderHelper.h
//  tranGOut
//
//  Created by Ryan on 5/30/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "FontUtility.h"

@interface AttributedStringCoderHelper : NSObject {
    
}

+(void)encodeAttributedStringAttributes:(NSDictionary*)attributes withKeyedArchiver:(NSKeyedArchiver*)archiver;
+(NSDictionary*)decodeAttributedStringAttriubtes:(NSKeyedUnarchiver*)decoder;
+(NSData*)encodeAttributedString:(NSAttributedString*)attributedString;
+(NSAttributedString*)decodeAttributedStringFromData:(NSData*)data;

@end
