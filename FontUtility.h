//
//  FontUtility.h
//  tranGOut
//
//  Created by Ryan on 5/30/14.
//  Copyright (c) 2014 Ryan Houlihan. All rights reserved.
//

#ifndef tranGOut_FontUtility_h
#define tranGOut_FontUtility_h

#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>

CTFontDescriptorRef CreateFontDescriptorFromName(CFStringRef iPostScriptName, CGFloat iSize);
CTFontDescriptorRef CreateFontDescriptorFromFamilyAndTraits(CFStringRef iFamilyName, CTFontSymbolicTraits iTraits, CGFloat iSize);
CTFontRef CreateFont(CTFontDescriptorRef iFontDescriptor, CGFloat iSize);
CTFontRef CreateBoldFont(CTFontRef iFont, Boolean iMakeBold);
CFDataRef CreateFlattenedFontData(CTFontRef iFont);
CTFontRef CreateFontFromFlattenedFontData(CFDataRef iData);

#endif
