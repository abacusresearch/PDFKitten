#import "Type1Font.h"
#import "AFMFontParser.h"

@interface Type1Font()
@property (nonatomic, assign) CGFontRef fontRef;
@end

@implementation Type1Font

-(CGFontRef) fontRefWithFont{
  NSString* fontName;
  if (NULL == _fontRef) {
    if ([self.baseFont hasPrefix:@"Helvetica"]) {
      fontName = @"Helvetica";
    }
    else if ([self.baseFont hasPrefix:@"Times"]) {
      fontName = @"Times New Roman";
    }
    else if ([self.baseFont hasPrefix:@"Courier"]) {
      fontName = @"Courier New";
    }
    else if ([self.baseFont hasPrefix:@"Zapf"]) {
      fontName = @"Zapfino";
    }
    else {
      fontName = @"Helvetica";
    }
    _fontRef = CGFontCreateWithFontName((CFStringRef) fontName);
  }
  return _fontRef;
}

-(id)initWithFontDictionary:(CGPDFDictionaryRef)dict {
	if (self = [super initWithFontDictionary:dict]) {
    if (nil == widths) {
      AFMFontCacheObject* cache = [AFMFontParser cacheForFontWithName:self.baseFont];
      self.widths = [cache.fontWidths mutableCopy];
      self.fontDescriptor = cache.fontDescriptor;
    }
	}
	return self;
}

-(CGFloat) maxY {
  if (self.fontDescriptor) {
    return [super maxY];
  }
  
  CGFloat height = CGFontGetXHeight([self fontRefWithFont]) - CGFontGetLeading([self fontRefWithFont]);
  return height;
}

-(CGFloat) minY {
  if (self.fontDescriptor) {
    return [super minY];
  }
  return 0;
}

@end
