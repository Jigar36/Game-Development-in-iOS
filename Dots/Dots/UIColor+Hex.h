@import UIKit;

@interface UIColor (Hex)

#pragma mark - Initialization
/*!
 Creates a new \c UIColor object with the given hex representation
 (e.g. \c 0xAABBCC).
 
 \param hex The hex value to create the color with.
 \returns A new \c UIColor instance.
 */
+ (UIColor *)colorWithHex:(NSUInteger)hex;

/*!
 Creates a new \c UIColor object with the given hex representation
 (e.g. \c 0xAABBCC) and an alpha value.

 \param hex The hex value to create the color with.
 \param alpha The alpha value to give the color.
 \returns A new \c UIColor instance.
 */
+ (UIColor *)colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha;

@end
