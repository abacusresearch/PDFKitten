//
//  AFMFontParser.h
//  RMTXKit
//
//  Created by Roger Misteli on 11/06/14.
//  Copyright (c) 2014 ABACUS Research AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FontDescriptor.h"

@interface AFMFontCacheObject : NSObject
@property (nonatomic, strong) FontDescriptor* fontDescriptor;
@property (nonatomic, strong) NSDictionary* fontWidths;
@end



@interface AFMFontParser : NSObject
+(AFMFontCacheObject*) cacheForFontWithName:(NSString*) baseFont;
@end
