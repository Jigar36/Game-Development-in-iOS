#import "UIColor+DTSColors.h"
#import "UIColor+Hex.h"

@implementation UIColor (DTSColors)

+ (UIColor *)dts_textColor
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHex:0x2C3E50];
    });

    return color;
}

+ (UIColor *)dts_neutralColor
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHex:0x2980B9];
    });

    return color;
}

+ (UIColor *)dts_player1Color
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHex:0x3498DB];
    });

    return color;
}

+ (UIColor *)dts_player2Color
{
    static UIColor *color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHex:0x2ECC71];
    });

    return color;
}

@end
