//
//  AFMFontParser.m
//  RMTXKit
//
//  Created by Roger Misteli on 11/06/14.
//  Copyright (c) 2014 ABACUS Research AG. All rights reserved.
//

#import "AFMFontParser.h"
//#import "NSString+RMAdditions.h"

@implementation AFMFontParser

+(NSMutableDictionary*) fontCache {
  static NSMutableDictionary *sharedfontCache = nil;
  static dispatch_once_t sharedfontCache_pred;
  
  if (sharedfontCache)
    return sharedfontCache;
  
  dispatch_once(&sharedfontCache_pred, ^{
    sharedfontCache = [[NSMutableDictionary alloc] initWithCapacity:3];
  });
  
  return sharedfontCache;
}

+(NSDictionary<NSString*, NSString*>*) nameCache {
  static NSMutableDictionary *sharednameCache = nil;
  static dispatch_once_t sharednameCache_pred;
  
  if (sharednameCache)
    return sharednameCache;
  
  dispatch_once(&sharednameCache_pred, ^{
    sharednameCache = @{
      @"helvetica": @"Helvetica",
      @"helvetica-bold": @"Helvetica-Bold",
      @"helvetica-oblique": @"Helvetica-Oblique",
      @"helvetica-italics": @"Helvetica-Oblique",
      @"helveticaoblique": @"Helvetica-Oblique",
      @"helveticaitalics": @"Helvetica-Oblique",
      @"helvetica-boldoblique": @"Helvetica-BoldOblique",
      @"helvetica-bolditalics": @"Helvetica-BoldOblique",
      @"helvetica-boldoblique": @"Helvetica-BoldOblique",
      @"helveticabolditalics": @"Helvetica-BoldOblique",

      @"times": @"Times",
      @"times-bold": @"Times-Bold",
      @"times-oblique": @"Times-Oblique",
      @"times-italics": @"Times-Oblique",
      @"timesoblique": @"Times-Oblique",
      @"timesitalics": @"Times-Oblique",
      @"times-boldoblique": @"Times-BoldOblique",
      @"times-bolditalics": @"Times-BoldOblique",
      @"times-boldoblique": @"Times-BoldOblique",
      @"timesbolditalics": @"Times-BoldOblique",
      
      @"courier": @"Courier",
      @"courier-bold": @"Courier-Bold",
      @"courier-oblique": @"Courier-Oblique",
      @"courier-italics": @"Courier-Oblique",
      @"courieroblique": @"Courier-Oblique",
      @"courieritalics": @"Courier-Oblique",
      @"courier-boldoblique": @"Courier-BoldOblique",
      @"courier-bolditalics": @"Courier-BoldOblique",
      @"courier-boldoblique": @"Courier-BoldOblique",
      @"courierbolditalics": @"Courier-BoldOblique",
    };
  });
  
  return sharednameCache;
}

+(AFMFontCacheObject*) cacheForFontWithName:(NSString*) baseFont {
  NSMutableDictionary* dictionary = [AFMFontParser fontCache];
  @synchronized(dictionary) {
    NSString *fontName = [self nameCache][[baseFont lowercaseString]];
    if (nil == fontName) {
      if ([baseFont hasPrefix:@"Helvetica"])
        fontName = @"Helvetica";
      else if ([baseFont hasPrefix:@"Times"])
        fontName = @"Times-Roman";
      else if ([baseFont hasPrefix:@"Courier"])
        fontName = @"Courier";
      else if ([baseFont hasPrefix:@"Zapf"])
        fontName = @"ZapfDingbats";
      else if ([baseFont hasPrefix:@"Symbol"])
        fontName = @"Symbol";
      else
        fontName = @"Helvetica";
    }
    AFMFontCacheObject* cache = dictionary[fontName];
    if (nil == cache) {
      cache = [AFMFontCacheObject new];
      cache.fontWidths = [AFMFontParser widthsForFont:fontName];
      cache.fontDescriptor = [AFMFontParser fontDescriptorForFont:fontName];
      dictionary[fontName] = cache;
    }
    return cache;
  }
}

+(NSDictionary *)widthsForFont:(NSString *)fontName {
  NSString *afmContents = [AFMFontParser readAFMFileFromDiskByFontName:fontName];
  NSString *charData = [AFMFontParser getCharData:afmContents];
  return [AFMFontParser splitCharacterAndWidths:charData];
}

+(void) parseLine:(NSString*) header inLine:(NSString*) line needs:(NSUInteger) needsItems withBlock:(void (^) (NSArray* values)) block {
  if ([line hasPrefix:header]) {
    NSArray* array = [line componentsSeparatedByString:@" "];
    if ([array count] > needsItems) {
      array = [array subarrayWithRange:NSMakeRange(1, [array count] - 1)];
      if (NULL != block)
        block(array);
    }
  }
}

+(FontDescriptor*) fontDescriptorForFont:(NSString*) fontName {
  NSString *afmContents = [AFMFontParser readAFMFileFromDiskByFontName:fontName];
  FontDescriptor* result = [FontDescriptor new];
  [afmContents enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
    [self parseLine:@"FontBBox" inLine:line needs:4 withBlock:^(NSArray *values) {
      result.bounds = (CGRect) { { [values[0] floatValue], [values[1] floatValue] }, { [values[2] floatValue], [values[3] floatValue] } };
    }];
    [self parseLine:@"Ascender" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.ascent = [values[0] floatValue];
    }];
    [self parseLine:@"Descender" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.descent = fabs([values[0] floatValue]);
    }];
    [self parseLine:@"CapHeight" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.capHeight = [values[0] floatValue];
    }];
    [self parseLine:@"XHeight" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.xHeight = [values[0] floatValue];
    }];
    [self parseLine:@"StdHW" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.horizontalStemWidth = [values[0] floatValue];
    }];
    [self parseLine:@"StdVW" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.verticalStemWidth = [values[0] floatValue];
    }];
    [self parseLine:@"ItalicAngle" inLine:line needs:1 withBlock:^(NSArray *values) {
      result.italicAngle = [values[0] floatValue];
    }];
    if ([line hasPrefix:@"StartCharMetrics"])
      *stop = YES;
  }];
  result.fontName = fontName;
  result.leading = result.ascent; // zwar technisch nicht wirklich korrekt, aber da AFM Files kein Leading enthalten müssen wir uns halt anders behelfen
  result.averageWidth = 1000;
  result.maxWidth = 1000;
  result.missingWidth = 1000;
  return result;
}

/*
 return only the string contained between StartCharMetrics and EndCharMetrics
 the collection of strings look like
 C 96 ; WX 600 ; N quoteleft ; B 178 277 428 562 ;
 C 97 ; WX 600 ; N a ; B 35 -15 570 454 ;
 */
+(NSString *)getCharData:(NSString *)string {
  NSError *error = nil;
  NSString *pattern = @"(?s)StartCharMetrics\\s\\d*(.*(?=EndCharMetrics))";
  
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:0
                                                                           error:&error];
  if (!regex) NSLog(@"Error with Char Metrics regex. Error:\n%@", error);
  
  NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
  if (match) return [string substringWithRange:[match rangeAtIndex:1]];
  else {
    NSLog(@"Could not find charMetrics");
    return nil;
  }
  return nil;
}

//Returns an NSDictionary with Character value as key and width as value;
+(NSDictionary *)splitCharacterAndWidths:(NSString *)charData {
  NSMutableDictionary *widths = [[NSMutableDictionary alloc] init];
  NSError *error = nil;
  NSString *pattern = @"C\\s(-?\\d{1,4})\\s;\\sWX\\s(-?\\d{1,4})";
  
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:0
                                                                           error:&error];
  if (!regex) NSLog(@"Error with Char/Widths regex. Error:\n%@", error);
  
  NSArray *matches = [regex matchesInString:charData
                                    options:0
                                      range:NSMakeRange(0, [charData length])];
  
  for (NSTextCheckingResult *match in matches) {
    NSInteger intKey = [[charData substringWithRange:[match rangeAtIndex:1]] integerValue];
    float floatValue = [[charData substringWithRange:[match rangeAtIndex:2]] floatValue];
    
    if (intKey >0 )
      widths[@(intKey)] = @(floatValue);
  }
  return widths;
}

+(NSBundle*) bundle {
  return [NSBundle bundleForClass:[self class]];
}

//Reads a specific AFM file from disk using the font name
+(NSString *)readAFMFileFromDiskByFontName:(NSString *)fontName {
  NSString *cleanFontName = [AFMFontParser cleanFontName:fontName];
  NSString *filePath = [[self bundle] pathForResource:cleanFontName ofType:@"afm"];
  if (filePath) {
    NSError *error = nil;
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (string) return string;
    else {
      NSLog(@"Could not load file from disk error:\n%@", error);
      return nil;
    }
  }
  return nil;
}

/*
 For a font subset, the PostScript name of the font—the value of the font’s BaseFont
 entry and the font descriptor’s FontName entry— shall begin with a tag followed by a
 plus sign (+). The tag shall consist of exactly six uppercase letters; the choice of
 letters is arbitrary, but different subsets in the same PDF file shall have different tags.
 EXAMPLE EOODIA+Poetica is the name of a subset of Poetica®, a Type 1 font.
 */
+(NSString *)cleanFontName:(NSString *)fontName {
  NSRange plusSign = [fontName rangeOfString:@"+"];
  if(plusSign.location != NSNotFound) {
    return [fontName substringFromIndex:plusSign.location+1];
  }
  return fontName;
}

@end









@implementation AFMFontCacheObject

@synthesize fontDescriptor, fontWidths;

@end
