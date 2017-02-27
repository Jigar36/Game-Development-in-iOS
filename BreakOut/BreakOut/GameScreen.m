//
//  GameScreen.m
//  BreakOut
//
//  Created by Jigs on 2/13/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//


#import "GameScreen.h"

@interface GameScreen ()
@property (assign) SystemSoundID sound;
@end

@implementation GameScreen
@synthesize paddle, ball, brick1,brick2,brick3,brick4,brick5;
@synthesize timer;
@synthesize bricks;

int ScoreCount = 0;


-(void)createPlayField
{

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    bricks = [NSMutableArray array];

    int y = 50;
    int height = 25;
    for(int k=0; k<7; k ++){
   // bricks = [[NSMutableArray alloc] init];
        for (int i=0;i<7;i++){
            UILabel *brick;
            int x = (screenWidth/8)*i;
            brick= [[UILabel alloc] initWithFrame:CGRectMake(x, y, screenWidth/8, height)];
            if(k==0)
            {
            [brick setBackgroundColor:[UIColor colorWithRed:20.0f/255.0f
                                                              green:120.0f/255.0f
                                                               blue:120.0f/255.0f
                                                              alpha:1.0f]];
            brick.layer.borderColor = [UIColor blackColor].CGColor;
            brick.layer.borderWidth = 2;
            }
            
            if(k==1)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:20.0f/255.0f
                                                          green:160.0f/255.0f
                                                           blue:120.0f/255.0f
                                                          alpha:1.0f]];
                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
            if(k==2)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:20.0f/255.0f
                                                          green:160.0f/255.0f
                                                           blue:60.0f/255.0f
                                                          alpha:1.0f]];
                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
            if(k==3)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f
                                                          green:160.0f/255.0f
                                                           blue:60.0f/255.0f
                                                          alpha:1.0f]];
                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
            if(k==4)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:80.0f/255.0f
                                                          green:120.0f/255.0f
                                                           blue:60.0f/255.0f
                                                          alpha:1.0f]];
                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
            if(k==5)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:140.0f/255.0f
                                                          green:70.0f/255.0f
                                                           blue:60.0f/255.0f
                                                          alpha:1.0f]];
                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
            if(k==6)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:170.0f/255.0f
                                                          green:30.0f/255.0f
                                                           blue:60.0f/255.0f
                                                          alpha:1.0f]];

                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
            if(k==7)
            {
                [brick setBackgroundColor:[UIColor colorWithRed:220.0f/255.0f
                                                          green:30.0f/255.0f
                                                           blue:30.0f/255.0f
                                                          alpha:1.0f]];
                
                brick.layer.borderColor = [UIColor blackColor].CGColor;
                brick.layer.borderWidth = 2;
            }
                [self addSubview:brick];
       [bricks addObject:brick ];
        }
       y = y + height;
    }
  
    _brickGameOver = [[UIView alloc] initWithFrame:CGRectMake(05, 620, screenWidth, 25)];
    [self addSubview:_brickGameOver];
 //   [_brickGameOver setBackgroundColor:[UIColor lightGrayColor]];
    
    
    paddle = [[UIView alloc] initWithFrame:CGRectMake(110, 600, 70, 10)];
    [self addSubview:paddle];
    [paddle setBackgroundColor:[UIColor colorWithRed:20.0f/255.0f
                                               green:120.0f/255.0f
                                                blue:120.0f/255.0f
                                               alpha:1.0f]];
    
    brick1 = [[UIView alloc] initWithFrame:CGRectMake(100, 600, 10, 10)];
    [self addSubview:brick1];
    [brick1 setBackgroundColor:[UIColor redColor]];
    
    brick2 = [[UIView alloc] initWithFrame:CGRectMake(180, 600, 10, 10)];
    [self addSubview:brick2];
    [brick2 setBackgroundColor:[UIColor redColor]];
    
    
    
    
    ball = [[UIView alloc] initWithFrame:CGRectMake(200,420,20,20)];
  //  ball.alpha = 0.5;
    ball.layer.cornerRadius = 10;
    ball.backgroundColor =  [UIColor colorWithRed: 1.0 green: 0.0 blue: 0.5 alpha:1.0];
    [self addSubview:ball];
    
    dx = 10;
    dy = 10;
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches)
    {
        
        CGPoint p = [t locationInView:self];
        CGPoint q = [t locationInView:self];
        CGPoint r = [t locationInView:self];
        p.y=600;
        q.y=600;
        r.y=600;
        
        q.x-= 40;
        r.x+=40;
        
        [paddle setCenter:p];
        [brick1 setCenter:q];
        [brick2 setCenter:r];
        
        
    }
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [self touchesBegan:touches withEvent:event];
}


-(IBAction)startAnimation:(id)sender
{
    timer = [NSTimer scheduledTimerWithTimeInterval:.1	target:self selector:@selector(timerEvent:) userInfo:nil repeats:YES];
}

-(IBAction)stopAnimation:(id)sender
{
    [timer invalidate];
}

-(void)timerEvent:(id)sender
{
    CGRect bounds = [self bounds];

    CGPoint p = [ball center];
    
    if ((p.x + dx) < 0)
        dx = -dx;
    
    if ((p.y + dy) < 0)
        dy = -dy;
    
    if ((p.x + dx) > bounds.size.width)
        dx = -dx;
    
    if ((p.y + dy) > bounds.size.height)
        dy = -dy;
    
    p.x += dx;
    p.y += dy;
    [ball setCenter:p];

    if (CGRectIntersectsRect([ball frame], [brick1 frame]))
    {
        dy = -dy;
        dx= -dx;
        p.y += 2*dy;
        p.x += 2*dx;
        [ball setCenter:p];    }
    
    if (CGRectIntersectsRect([ball frame], [brick2 frame]))
    {
        dy = -dy;
        dx= -dx;
        p.y += 2*dy;
        p.x += 2*dx;
        [ball setCenter:p];
    }
    
    
    if (CGRectIntersectsRect([ball frame], [paddle frame]))
    {
        dy = -dy;
        p.y += 2*dy;
        [ball setCenter:p];
    }

    NSUInteger arraySize = [bricks count];
    for(int j=0; j<arraySize; j++){
        UILabel *x =[bricks objectAtIndex:j];
        if (CGRectIntersectsRect([ball frame], [x frame]))
        {
            if(!x.isHidden){
   
                //sound
                NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"aiff"];
                NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_sound);
                AudioServicesPlaySystemSound(self.sound);
                dy = -dy;
                x.hidden = YES;
                ScoreCount += 1;
                _Score.text= [NSString stringWithFormat:@"%d", ScoreCount];
            }
        }

    }
    
    int count=0;
    for(int k=0;k<arraySize;k++)
    {
        UILabel *x =[bricks objectAtIndex:k];
        if(x.isHidden)
        {
            count++;
        }
    }
    if(count == arraySize)
    {
        NSString *soundPath1 = [[NSBundle mainBundle] pathForResource:@"snap" ofType:@"aif"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath1];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_sound);
        AudioServicesPlaySystemSound(self.sound);
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GAME Win" message:@"Yes you did it..." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
        [alert show];
        [timer invalidate];   
    }

    if (CGRectIntersectsRect([ball frame], [_brickGameOver frame]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GAME OVER" message:@"Click on Play Again..." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
        [alert show];
        [timer invalidate];
    }
    
}

@end
