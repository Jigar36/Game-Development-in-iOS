import UIKit

/**
 An extension to UIColor that allows for the convenience construction of color
 objects from hex strings.
 */
extension UIColor {
    /**
     The error returned when a valid hex integer cannot be parsed from the given
     string.
     */
    enum HexRepresentationError: ErrorType {
        case Empty
        case InvalidCharacters
        case InvalidStringLength
        case ParseError
    }

    /**
     Constructs a new color object from the given hex RGB/RGBA string.
     
     - parameter hexRepresentation: The string hex representation of the color.
                                    Must match the regular expression
                                    `/#?[[:xdigit:]]{6}([[:xdigit:]]{2})?/`.
     - throws:
        - `HexRepresentationError.Empty` if the given string is empty.
        - `HexRepresentationError.InvalidCharacters` if the given string
          contains characters which do not match the regular expression above.
        - `HexRepresentationError.InvalidStringLength` if the given string
          contains valid characters but is too short or too long.
        - `HexRepresentationError.ParseError` if there is an error in parsing a
          number out of the given representation.
     */
    public convenience init(hexRepresentation input: String) throws {
        // NOTE: self.init() is required before all throw statements. If
        // self.init() is not called, an `EXC_BAD_ACCESS` will occur because
        // Swift will try to destruct an object instance that was never
        // initialized.

        if input.characters.count == 0 {
            self.init()
            throw HexRepresentationError.Empty
        }

        let scanner = NSScanner(string: input)

        // Skip the initial '#' if it exists.
        if input.characters.first == "#" {
            scanner.scanLocation += 1
        }

        let validCharacters = NSCharacterSet(charactersInString: "0123456789abcdefABCDEF")
        var substring: NSString? = ""
        if !scanner.scanCharactersFromSet(validCharacters, intoString: &substring) || !scanner.atEnd {
            self.init()
            throw HexRepresentationError.InvalidCharacters
        }

        let length = substring!.length
        guard length == 6 || length == 8 else {
            self.init()
            throw HexRepresentationError.InvalidStringLength
        }

        let parser = NSScanner(string: substring! as String)
        var hex: UInt32 = 0
        if !parser.scanHexInt(&hex) {
            self.init()
            throw HexRepresentationError.ParseError
        }

        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 1

        if length == 6 {
            // RGB String
            red   = CGFloat(Double((hex >> 16) & 0xFF) / 255.0)
            green = CGFloat(Double((hex >>  8) & 0xFF) / 255.0)
            blue  = CGFloat(Double(hex         & 0xFF) / 255.0)
        } else {
            // RGBA String
            red   = CGFloat(Double((hex >> 24) & 0xFF) / 255.0)
            green = CGFloat(Double((hex >> 16) & 0xFF) / 255.0)
            blue  = CGFloat(Double((hex >>  8) & 0xFF) / 255.0)
            alpha = CGFloat(Double(hex         & 0xFF) / 255.0)
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
