@import UIKit;

@interface UIColor (DTSColors)

/*!
 Returns the default text color used in the app.
 */
+ (UIColor *)dts_textColor;

/*!
 Returns the color used for neutral backgrounds not associated with either
 player.
 */
+ (UIColor *)dts_neutralColor;

/*!
 Returns the color associated with player one.
 */
+ (UIColor *)dts_player1Color;

/*!
 Returns the color associated with player two.
 */
+ (UIColor *)dts_player2Color;

@end
