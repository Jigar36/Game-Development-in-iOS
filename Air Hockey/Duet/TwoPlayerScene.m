//
//  TwoPlayerScene.m
//  Duet
//
//  Created by Jigar Panchal on 5/14/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

#import "TwoPlayerScene.h"
#import "MainViewController.h"
#define kPaddle1Radius 25.0
#define kPaddle2Radius 25.0

#define kBallRadius 15.0 //radius of the moving ball
#define kStartingVelocityX 250.0 //starting velocity x value for moving the ball
#define kStartingVelocityY -250.0
#define kPaddleMoveMult 1.5
#define kVelocityMultFactor 1.05 //multiply factor for speeding up the ball after some time
#define kSpeedupInterval 5.0 //interval after which the speedUpTheBall method is called
#define kScoreFontSize 30.0
#define kRestartGameWidthHeight 50.0 //width and height of restart node
#define kPaddleMoveMult 1.5

@interface TwoPlayerScene()
@property(nonatomic) BOOL isPlayingGame;
//ball node
@property(nonatomic) SKSpriteNode *ballNode;
//paddle nodes
@property(nonatomic) SKSpriteNode *playerOnePaddleNode;
@property(nonatomic) SKSpriteNode *playerTwoPaddleNode;

@property(nonatomic) SKSpriteNode *centerImage;

//goal Node
@property(nonatomic) SKSpriteNode *goal1Node;
@property(nonatomic) SKSpriteNode *goal2Node;

@property(nonatomic) UITouch *playerOnePaddleControlTouch;
@property(nonatomic) UITouch *playerTwoPaddleControlTouch;
//timer for speed-up
@property(nonatomic) NSTimer *speedupTimer;
//score label nodes
@property(nonatomic) SKLabelNode *playerOneScoreNode;
@property(nonatomic) SKLabelNode *playerTwoScoreNode;

//score
@property(nonatomic) NSInteger playerOneScore;
@property(nonatomic) NSInteger playerTwoScore;

@property(nonatomic) SKSpriteNode *restartGameNode;
@property(nonatomic) SKSpriteNode *homeGameNode;
//start game info node
@property(nonatomic) SKLabelNode *startGameInfoNode;
@property(nonatomic) SKLabelNode *GameWinNode;

@end

static const uint32_t ballCategory  = 0x1 << 0;
static const uint32_t goal1Category = 0x1 << 1;
static const uint32_t paddleCategory = 0x1 << 2;
static const uint32_t goal2Category = 0x1 << 3;

@implementation TwoPlayerScene
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:20.0f/255.0f
                                               green:160.0f/255.0f
                                                blue:120.0f/255.0f
                                               alpha:1.0f];
        
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        //setup physics body for scene
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
        //self.physicsBody.categoryBitMask = cornerCategory;
        //        NSLog(@"category %d",self.physicsBody.categoryBitMask);
        self.physicsBody.dynamic = NO;
        self.physicsBody.friction = 0.0;
        self.physicsBody.restitution = 1.0;
        
        //dimensions etc.
        CGFloat paddleWidth = kPaddle1Radius * 2.0;
        CGFloat paddleHeight = kPaddle1Radius * 2.0;
        CGFloat middleLineWidth = 4.0;
        CGFloat middleLineHeight = 20.0;
        
        //center circle
        CGFloat radius = 50;
        
//        SKShapeNode *shape = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
//        shape.name = @"circle";
//        shape.position =CGPointMake(size.width / 2.0, size.height / 2.0);
//        shape.strokeColor = [SKColor colorWithWhite:1.0 alpha:0.5];
//        [shape setLineWidth:5.0];
//        [self addChild:shape];
//        
        self.centerImage = [SKSpriteNode spriteNodeWithImageNamed:@"Bearcat.png"];
        self.centerImage.size = CGSizeMake(120, 100);
        self.centerImage.position = CGPointMake(size.width / 2.0, size.height / 2.0);
        [self addChild:self.centerImage];
        
        
        SKShapeNode *shape1 = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
        shape1.name = @"circle1";
        shape1.position =CGPointMake(0.0, size.height / 2.0);
        shape1.strokeColor = [SKColor colorWithWhite:1.0 alpha:0.5];
        [shape1 setLineWidth:5.0];
        [self addChild:shape1];
        
        
        SKShapeNode *shape2 = [SKShapeNode shapeNodeWithCircleOfRadius:radius];
        shape2.name = @"circle2";
        shape2.position =CGPointMake(size.width, size.height / 2.0);
        shape2.strokeColor = [SKColor colorWithWhite:1.0 alpha:0.5];
        [shape2 setLineWidth:5.0];
        [self addChild:shape2];
        
        
        //middle line
        NSInteger numberOfLines = size.height / (2*middleLineHeight);
        CGPoint linePosition = CGPointMake(size.width / 2.0, middleLineHeight * 1.5);
        for (NSInteger i = 0; i < numberOfLines; i++)
        {
            SKSpriteNode *lineNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:1.0 alpha:0.5] size:CGSizeMake(middleLineWidth, middleLineHeight)];
            lineNode.position = linePosition;
            linePosition.y += 2*middleLineHeight;
            [self addChild:lineNode];
        }
        
        //left border
        
            CGPoint linePosition1 = CGPointMake(0.0, size.height);
       
            SKSpriteNode *lineNode1 = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0.8 alpha:1.0] size:CGSizeMake(middleLineWidth+5, size.height*2)];
            lineNode1.position = linePosition1;
            [self addChild:lineNode1];
      
        //Right Border
        CGPoint linePosition2 = CGPointMake(size.width, size.height);
        
        SKSpriteNode *lineNode2 = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0.8 alpha:1.0] size:CGSizeMake(middleLineWidth+5, size.height*2)];
        lineNode1.position = linePosition2;
        [self addChild:lineNode2];
        
        
        //Goal 1 Post Line
        
        CGPoint goalPosition1 = CGPointMake(0 ,size.height / 2.0);
        
            self.goal1Node = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:1.0 alpha:0.5] size:CGSizeMake(10, 100)];
            self.goal1Node.position = goalPosition1;
            self.goal1Node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.goal1Node.size];
            self.goal1Node.physicsBody.categoryBitMask = goal1Category;
            self.goal1Node.physicsBody.dynamic = self.goal1Node.physicsBody.dynamic = NO;
            goalPosition1.y += 2*middleLineHeight;
            [self addChild:self.goal1Node];
        
        //Goal 2 Post Line
        
        CGPoint goalPosition2 = CGPointMake(size.width ,size.height / 2.0);
        
        self.goal2Node = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:1.0 alpha:0.5] size:CGSizeMake(10, 100)];
        self.goal2Node.position = goalPosition2;
        self.goal2Node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.goal2Node.size];
        self.goal2Node.physicsBody.categoryBitMask = goal2Category;
        self.goal2Node.physicsBody.dynamic = self.goal2Node.physicsBody.dynamic = NO;
        goalPosition2.y += 2*middleLineHeight;
        [self addChild:self.goal2Node];
        
        
        //paddles
        self.playerOnePaddleNode = [SKSpriteNode spriteNodeWithImageNamed:@"player1.png"];
        self.playerOnePaddleNode.size = CGSizeMake(paddleWidth, paddleHeight);
        self.playerOnePaddleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:25];
        self.playerOnePaddleNode.position = CGPointMake(self.playerOnePaddleNode.size.width, CGRectGetMidY(self.frame));
        self.playerOnePaddleNode.physicsBody.categoryBitMask = paddleCategory;
        
        self.playerTwoPaddleNode = [SKSpriteNode spriteNodeWithImageNamed:@"player2.png"];
        self.playerTwoPaddleNode.size = CGSizeMake(paddleWidth, paddleHeight);
        self.playerTwoPaddleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:25];
        self.playerTwoPaddleNode.position = CGPointMake(CGRectGetMaxX(self.frame) - self.playerTwoPaddleNode.size.width, CGRectGetMidY(self.frame));
        self.playerTwoPaddleNode.physicsBody.categoryBitMask = paddleCategory;
        

        
        self.playerOnePaddleNode.physicsBody.dynamic = self.playerTwoPaddleNode.physicsBody.dynamic = NO;
        [self addChild:self.playerOnePaddleNode];
        [self addChild:self.playerTwoPaddleNode];
        
        //score labels
        CGFloat scoreFontSize = kScoreFontSize;
        self.playerOneScoreNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.playerTwoScoreNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.playerOneScoreNode.fontColor = self.playerTwoScoreNode.fontColor = [SKColor whiteColor];
        self.playerOneScoreNode.fontSize = self.playerTwoScoreNode.fontSize = scoreFontSize;
        self.playerOneScoreNode.position = CGPointMake(size.width * 0.25, size.height - scoreFontSize * 2.0);
        self.playerTwoScoreNode.position = CGPointMake(size.width * 0.75, size.height - scoreFontSize * 2.0);
        [self addChild:self.playerOneScoreNode];
        [self addChild:self.playerTwoScoreNode];
        
        //restart
        CGFloat restartNodeWidthHeight = kRestartGameWidthHeight;
        self.restartGameNode = [SKSpriteNode spriteNodeWithImageNamed:@"restart1.png"];
        self.restartGameNode.size = CGSizeMake(restartNodeWidthHeight, restartNodeWidthHeight);
        self.restartGameNode.position = CGPointMake(size.width / 2.0, size.height - restartNodeWidthHeight);
        self.restartGameNode.hidden = YES;
        [self addChild:self.restartGameNode];
        
        //home
      //  CGFloat restartNodeWidthHeight = kRestartGameWidthHeight;
        self.homeGameNode = [SKSpriteNode spriteNodeWithImageNamed:@"home.png"];
        self.homeGameNode.size = CGSizeMake(restartNodeWidthHeight, restartNodeWidthHeight);
        self.homeGameNode.position = CGPointMake((size.width / 2.0) + 55.0, size.height - restartNodeWidthHeight);
        self.homeGameNode.hidden = YES;
        [self addChild:self.homeGameNode];

        //start game info node
        self.startGameInfoNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.startGameInfoNode.fontColor = [SKColor whiteColor];
        self.startGameInfoNode.fontSize = scoreFontSize;
        self.startGameInfoNode.position = CGPointMake(size.width / 2.0, size.height / 1.50);
        self.startGameInfoNode.text = @"Tap to start!";
        [self addChild:self.startGameInfoNode];

        //game win node
        self.GameWinNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        self.GameWinNode.fontColor = [SKColor whiteColor];
        self.GameWinNode.fontSize = 45;
       // self.GameWinNode.position = CGPointMake(size.width / 2.0, (size.height / 2.0) + 5.0);
        //self.GameWinNode.text = @"Win!";
        self.GameWinNode.hidden = YES;
        [self addChild:self.GameWinNode];

        
        //set scores to 0
        self.playerOneScore = 0;
        self.playerTwoScore = 0;
        [self updateScoreLabels];

        
        
    }
    return self;
}
-(void)willMoveFromView:(SKView *)view
{
    //reset timer
    [self.speedupTimer invalidate];
    self.speedupTimer = nil;
}

-(void)startPlayingTheGame
{
    self.isPlayingGame = YES;
    self.GameWinNode.hidden = YES;
    self.startGameInfoNode.hidden = YES;
    self.restartGameNode.hidden = NO;
    self.homeGameNode.hidden = NO;
    //
    CGFloat ballWidth = kBallRadius * 2.0;
    CGFloat ballHeight = kBallRadius * 2.0;
    CGFloat ballRadius = kBallRadius;
    //make the ball
    self.ballNode = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
    self.ballNode.size = CGSizeMake(ballWidth, ballHeight);
    self.ballNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ballRadius];
    self.ballNode.physicsBody.categoryBitMask = ballCategory;
    self.ballNode.physicsBody.contactTestBitMask = goal1Category | goal2Category | paddleCategory;
    self.ballNode.physicsBody.linearDamping = 0.0;
    self.ballNode.physicsBody.angularDamping = 0.0;
    self.ballNode.physicsBody.restitution = 1.0;
    self.ballNode.physicsBody.dynamic = YES;
    self.ballNode.physicsBody.friction = 0.0;
    self.ballNode.physicsBody.allowsRotation = NO;
    self.ballNode.position = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    
    [self addChild:self.ballNode];
    
    CGFloat startingVelocityX = kStartingVelocityX;
    CGFloat startingVelocityY = kStartingVelocityY;
    if (self.playerOneScore > self.playerTwoScore)
    {
        startingVelocityX = -startingVelocityX;
    }
    self.ballNode.physicsBody.velocity = CGVectorMake(startingVelocityX, startingVelocityY);
    
    //start the timer for speed-up
    self.speedupTimer = [NSTimer scheduledTimerWithTimeInterval:kSpeedupInterval
                                                         target:self
                                                       selector:@selector(speedUpTheBall)
                                                       userInfo:nil
                                                        repeats:YES];
}


-(void)updateScoreLabels
{
    self.playerOneScoreNode.text = [NSString stringWithFormat:@"%ld",(long)self.playerOneScore];
    self.playerTwoScoreNode.text = [NSString stringWithFormat:@"%ld",(long)self.playerTwoScore];
}


//restart the game when restart node is tapped
-(void)restartTheGame
{
    [self.ballNode removeFromParent];
    //reset timer
    [self.speedupTimer invalidate];
    self.speedupTimer = nil;
    //
    self.isPlayingGame = NO;
    self.startGameInfoNode.hidden = NO;
    self.restartGameNode.hidden = YES;
    self.homeGameNode.hidden = YES;
    //set scores to 0
    self.playerOneScore = 0;
    self.playerTwoScore = 0;
    //update score labels
    [self updateScoreLabels];
}


-(void)speedUpTheBall
{
    CGFloat velocityX = self.ballNode.physicsBody.velocity.dx * kVelocityMultFactor;
    CGFloat velocityY = self.ballNode.physicsBody.velocity.dy * kVelocityMultFactor;
    self.ballNode.physicsBody.velocity = CGVectorMake(velocityX, velocityY);
}
-(void)moveFirstPaddle
{
    CGPoint previousLocation = [self.playerOnePaddleControlTouch previousLocationInNode:self];
    CGPoint newLocation = [self.playerOnePaddleControlTouch locationInNode:self];
    if (newLocation.x > self.size.width / 2.0)
    {
        //finger is on the other player side
        return;
    }
    CGFloat x = self.playerOnePaddleNode.position.x + (newLocation.x - previousLocation.x) * kPaddleMoveMult;
    CGFloat y = self.playerOnePaddleNode.position.y + (newLocation.y - previousLocation.y) * kPaddleMoveMult;
    CGFloat yMax = self.size.height - self.playerOnePaddleNode.size.width/2.0 - self.playerOnePaddleNode.size.height/2.0;
    CGFloat yMin = self.playerOnePaddleNode.size.width/2.0 + self.playerOnePaddleNode.size.height/2.0;
    
    CGFloat xMax = self.size.width/2 - self.playerOnePaddleNode.size.width/2.0 - self.playerOnePaddleNode.size.height/2.0;
    CGFloat xMin = self.playerOnePaddleNode.size.width/2.0 + self.playerOnePaddleNode.size.height/2.0;
//    NSLog(@"xMax 1st paddle=== %f",xMax);
    if (y > yMax)
    {
        y = yMax;
    }
    else if(y < yMin)
    {
        y = yMin;
    }
    
    if (x > xMax)
    {
        x = xMax;
    }
    else if(x < xMin)
    {
        x = xMin;
    }
    self.playerOnePaddleNode.position = CGPointMake(x, y);
}



-(void)moveSecondPaddle
{
    CGPoint previousLocation = [self.playerTwoPaddleControlTouch previousLocationInNode:self];
    CGPoint newLocation = [self.playerTwoPaddleControlTouch locationInNode:self];
    if (newLocation.x < self.size.width / 2.0)
    {
        //finger is on the other player side
        return;
    }
    CGFloat x = self.playerTwoPaddleNode.position.x + (newLocation.x - previousLocation.x) * kPaddleMoveMult;
    CGFloat y = self.playerTwoPaddleNode.position.y + (newLocation.y - previousLocation.y) * kPaddleMoveMult;
    CGFloat yMax = self.size.height - self.playerTwoPaddleNode.size.width/2.0 - self.playerTwoPaddleNode.size.height/2.0;
    CGFloat yMin = self.playerTwoPaddleNode.size.width/2.0 + self.playerTwoPaddleNode.size.height/2.0;
    
    CGFloat xMax = self.size.width - self.playerTwoPaddleNode.size.width/2.0 - self.playerTwoPaddleNode.size.height/2.0;
    CGFloat xMin = 30 + self.size.width/2 - self.playerTwoPaddleNode.size.width/2.0 - self.playerTwoPaddleNode.size.height/2.0;
   // NSLog(@"xMin= %f",xMin);
    //   NSLog(@"xMax=== %f",xMax);
    
    
    if (y > yMax)
    {
        y = yMax;
    }
    else if(y < yMin)
    {
        y = yMin;
    }
    
    if (x > xMax)
    {
        x = xMax;
    }
    else if(x < xMin)
    {
        x = xMin;
    }
    
     self.playerTwoPaddleNode.position = CGPointMake(x, y);
}

-(void)didBeginContact:(SKPhysicsContact*)contact
{
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    //check if ball hits the goal
    //check if we have ball & corner contact
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == goal1Category)
    {
        NSLog(@"contact of ball and goal1");
        [self pointForPlayer:2];
    }

    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == goal2Category)
    {
        NSLog(@"contact of ball and goal2");
        [self pointForPlayer:1];
    }
    
    //check if we have ball & paddle contact
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleCategory)
    {
      //  NSLog(@"contact of ball and paddle");
        SKSpriteNode *paddleNode = (SKSpriteNode*)secondBody.node;
        CGPoint ballPosition = self.ballNode.position;
        CGFloat firstThird = (paddleNode.position.y - paddleNode.size.height / 2.0) + paddleNode.size.height * (1.0/3.0);
        CGFloat secondThird = (paddleNode.position.y - paddleNode.size.height / 2.0) + paddleNode.size.height * (2.0/3.0);
        CGFloat dx = self.ballNode.physicsBody.velocity.dx;
        CGFloat dy = self.ballNode.physicsBody.velocity.dy;
        //        NSLog(@"velocity poslije %f %f",dx,dy);
        if (ballPosition.y < firstThird) {
            //ball hits the left part
            if (dy > 0) {
                self.ballNode.physicsBody.velocity = CGVectorMake(dx, -dy);
            }
        }
        else if (ballPosition.y > secondThird) {
            //ball hits the left part
            if (dy < 0) {
                self.ballNode.physicsBody.velocity = CGVectorMake(dx, -dy);
            }
        }
    }
    
}

-(void)pointForPlayer:(NSInteger)player
{
    if(player==1)
    {
            //point for player no 1
            self.playerOneScore++;
            [self.ballNode removeFromParent];
            self.isPlayingGame = NO;
            self.startGameInfoNode.hidden = NO;
            self.restartGameNode.hidden = YES;
            self.homeGameNode.hidden = YES;
            //reset timer
            [self.speedupTimer invalidate];
            self.speedupTimer = nil;
        
    }
    else if(player == 2)
    {
            //point for player no 2
            self.playerTwoScore++;
            [self.ballNode removeFromParent];
            self.isPlayingGame = NO;
            self.startGameInfoNode.hidden = NO;
            self.restartGameNode.hidden = YES;
            self.homeGameNode.hidden = YES;
            //reset timer
            [self.speedupTimer invalidate];
            self.speedupTimer = nil;
    }
    [self updateScoreLabels];
    
    
    if(self.playerOneScore == 3)
    {
        self.startGameInfoNode.text= @"Tap To Restart";
        self.restartGameNode.hidden = NO;
        self.homeGameNode.hidden = NO;
        self.GameWinNode.position = CGPointMake(self.size.width / 3.5, self.size.height / 2.0);
        self.GameWinNode.text = @"Win!";
        self.GameWinNode.hidden = NO;
        NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
        SKEmitterNode *burstEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
        
        burstEmitter.position = CGPointMake(self.size.width / 3.5, self.size.height / 2.0);
        [self restartTheGame];
       // [self addChild:burstEmitter];
        
    }
    else if(self.playerTwoScore == 3)
    {
        self.startGameInfoNode.text= @"Tap To Restart";
        self.restartGameNode.hidden = NO;
        self.homeGameNode.hidden = NO;
        self.GameWinNode.position = CGPointMake(self.size.width / 1.25, self.size.height / 2.0);
        self.GameWinNode.text = @"Win!";
        self.GameWinNode.hidden = NO;
        NSString *burstPath = [[NSBundle mainBundle] pathForResource:@"Fire" ofType:@"sks"];
        SKEmitterNode *burstEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:burstPath];
        
        burstEmitter.position = CGPointMake(self.size.width / 1.25, self.size.height / 2.0);
        [self restartTheGame];
       // [self addChild:burstEmitter];
        
    }
    else{
        self.GameWinNode.hidden = YES;
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isPlayingGame) {
        for (UITouch *touch in touches)
        {
            CGPoint location = [touch locationInNode:self];
            
            if (CGRectContainsPoint(self.restartGameNode.frame, location))
            {
                [self restartTheGame];
                return;
            }
            
            if (CGRectContainsPoint(self.homeGameNode.frame, location))
            {
               // [self presentViewController:@"MainViewController" animated:YES completion:nil];
                
                //                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                //                MainViewController *myVC = (MainViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                //           [self.view.window.rootViewController.perform presentScene:nil];
     
                //      [self presentModalViewController:myNewVC animated:YES];
                
               // return;
               
            }
            
            if (self.playerOnePaddleControlTouch == nil)
            {
                if (location.x < self.size.width / 2.0)
                {
                    self.playerOnePaddleControlTouch = touch;
                }
            }
               if (self.playerTwoPaddleControlTouch == nil)
            {
                     if (location.x > self.size.width / 2.0)
                {
                           self.playerTwoPaddleControlTouch = touch;
                }
            }
        }
        return;
    }
    else
    {
        [self startPlayingTheGame];
        return;
    }
}

-(void)loadMainScreen{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MainViewController" object:nil];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if (touch == self.playerOnePaddleControlTouch)
        {
            [self moveFirstPaddle];
        }
         else if (touch == self.playerTwoPaddleControlTouch)
        {
               [self moveSecondPaddle];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"ended %d",touches.count);
    for (UITouch *touch in touches) {
        if (touch == self.playerOnePaddleControlTouch)
        {
            self.playerOnePaddleControlTouch = nil;
        }
         else if (touch == self.playerTwoPaddleControlTouch)
        {
             self.playerTwoPaddleControlTouch = nil;
        }
    }
}

@end
