#import "UIColor+Hex.h"

@implementation UIColor (Hex)

#pragma mark - Initialization
+ (UIColor *)colorWithHex:(NSUInteger)hex
{
    return [UIColor colorWithHex:hex alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha
{
    CGFloat red   = (CGFloat)(((hex >> 16) & 0xFF) / 255.0),
            green = (CGFloat)(((hex >>  8) & 0xFF) / 255.0),
            blue  = (CGFloat)(((hex >>  0) & 0xFF) / 255.0);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
