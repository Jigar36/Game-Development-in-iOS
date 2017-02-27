#pragma mark Game Types
//! Represents a location on the game board.
typedef struct {
    NSUInteger x;
    NSUInteger y;
} DTSLocation;

//! Represents an edge on the game board.
typedef struct {
    DTSLocation location;
    BOOL horizontal;
} DTSEdge;
