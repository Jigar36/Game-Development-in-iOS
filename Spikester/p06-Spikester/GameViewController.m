//
//  GameViewController.m
//  p06-Spikester
//
//  Created by Tejas Nadkarni on 15/03/16.
//  Copyright © 2016 tkale1. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()

@end

UIDynamicAnimator* _animator;
UIGravityBehavior* _gravity;
UICollisionBehavior* _collision; //setting boundaries of falling
NSTimer *bearcatMovement, *spikesCollison, *trophyCollison,*blink;
CGRect screenRect;
CGFloat screenWidth;
UILabel *scoreLable,*begin;
CGFloat screenHeight;
int flg = 0,scr_counter = 0;
int backgroundColorCount = 1;
int BearFlight;
UIImageView *paw,*paw2,*paw3;
int touchCount =0;
int trophyCount=0;
CAShapeLayer *circleLayer;
int checkSide = 0; //RIGHT side is 0 and LEFT side is 1
int p;

@implementation GameViewController
@synthesize bear,score,trophy;
@synthesize upspikes, downspikes, leftspikes, rightspikes;
@synthesize timer;
@synthesize FinalScore,trofyCount,trophyImageView,trophyImageView1;

- (void) jumpSoundPlay
{
    AudioServicesPlaySystemSound(jumpSound);
}

- (void) wallTouchSoundPlay
{
    AudioServicesPlaySystemSound(walltouchSound);
}

- (void) gameOverSoundPlay
{
    AudioServicesPlaySystemSound(gameoverSound);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    trophyCount=0;
    // Do any additional setup after loading the view, typically from a nib.
    //BACKGROUND COLOR
    self.view.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(210/255.0) blue:(210/255.0) alpha:1];
    
	//GAME SOUND
    NSURL *jumpUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jumpSound" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)jumpUrl,&jumpSound);
    NSURL *touchUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"touchSound" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)touchUrl,&walltouchSound);
    NSURL *gameOverUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"gameoverSound" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)gameOverUrl,&gameoverSound);
    
    //ARRAY INITIALIZATION
    upspikes = [NSMutableArray array];
    downspikes = [NSMutableArray array];
    leftspikes = [NSMutableArray array];
    rightspikes = [NSMutableArray array];
    
    //getting screen sizes
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    paw = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2 - 55, screenHeight/2 - 55, 15, 15)];
    paw2 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2 - 55, screenHeight/2 - 55, 15, 15)];
    paw3 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2 - 55, screenHeight/2 - 55, 15, 15)];
    
    //setting bear image
    // bear = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [paw setImage:[UIImage imageNamed:@"paws.gif"]];
    [paw2 setImage:[UIImage imageNamed:@"paws.gif"]];
    [paw3 setImage:[UIImage imageNamed:@"paws.gif"]];
    
    [self.view addSubview:paw];
    [self.view addSubview:paw2];
    [self.view addSubview:paw3];
    
    paw.hidden = YES;
    paw2.hidden = YES;
    paw3.hidden = YES;
    
    

    //score
    self.score = [[UIView alloc] initWithFrame:CGRectMake(10,20,100,100)];
    self.score.alpha = 0.5;
    self.score.layer.cornerRadius = 50;
    self.score.backgroundColor = [UIColor blueColor];
	
    //creating circle
    circleLayer = [CAShapeLayer layer];
    circleLayer.lineWidth = 3.0f;
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(screenWidth/2 - 100, screenHeight/2 - 100, 200, 200)] CGPath]];
    [circleLayer setStrokeColor:[[UIColor colorWithRed:(210/255.0) green:(210/255.0) blue:(210/255.0) alpha:1] CGColor]];
    [circleLayer setFillColor:[[UIColor whiteColor] CGColor]];
    [[self.view layer] addSublayer:circleLayer];
    
    //setting score
    scoreLable = [[UILabel alloc] init];
    [scoreLable setFrame:CGRectMake(screenWidth/2 - 40,screenHeight/2 - 40,80,80)];
    scoreLable.backgroundColor=[UIColor clearColor];
    scoreLable.textColor=[UIColor colorWithRed:(210/255.0) green:(210/255.0) blue:(210/255.0) alpha:1];
    scoreLable.userInteractionEnabled=YES;
    scoreLable.textAlignment = NSTextAlignmentCenter;
    [scoreLable setFont:[UIFont fontWithName:@"Courier-Bold" size:65]];
    [self.view addSubview:scoreLable];
    scoreLable.text= @"00";
    
    //Bearcat Generation
    bear = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/2, screenHeight/2, 50, 50)];
    bear.image=[UIImage imageNamed:@"bearcat.gif"];
    [self.view addSubview: bear];
    
    scoreLable.hidden = YES;
    
    
    //being label
    begin = [[UILabel alloc] init];
    [begin setFrame:CGRectMake(screenWidth/8, screenHeight/2+ 130, screenWidth - screenWidth/8, 90)];
    [begin setText:@"Tap to Begin"];
    [begin setFont:[UIFont fontWithName:@"chalkduster" size:40]];
    [begin setTextColor:[UIColor whiteColor]];
    [self.view addSubview:begin];
    
    
    blink = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(toggleLabelAlpha) userInfo:nil repeats:YES];
    
    [self bearcatAnimation];
    
    
    //Generate spikes around
    [self generatingSpikes];
    
}

- (void)toggleLabelAlpha {
    
    [begin setHidden:(!begin.hidden)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)GameOverView{
    _gameOver.hidden=NO;
    trophy.hidden=YES;
    circleLayer.hidden=YES;
    scoreLable.hidden=YES;
    [self.view bringSubviewToFront:_gameOver];
    
    //rounded curves
    [_goHome.layer setCornerRadius:8];
    [[_goHome layer] setMasksToBounds:YES];
    
    trophyImageView1.image=[UIImage imageNamed:@"trophy.png"];
    trofyCount.text=[NSString stringWithFormat:@"%d",trophyCount];
    FinalScore.text=[NSString stringWithFormat:@"%d",scr_counter];
}
-(void)spikesCollision{
	
    //code for intersection
    NSUInteger arraySize = [downspikes count];
    for(int j=0; j<arraySize; j++){
        //for(UIImageView *image in downspikes) {
        UIImageView *x =[downspikes objectAtIndex:j];
        if (CGRectIntersectsRect(bear.frame, x.frame))
        {
            
           // [bear setFrame:CGRectMake(bear.center.x - 23, bear.center.y - 35, 50, 50)];
            [bearcatMovement invalidate];
            [spikesCollison invalidate];
            [self rotateImage];
            [self GameOverView];
        }
    }
    
    //upside
    NSUInteger arraySize3 = [upspikes count];
  //  NSLog(@"count :- %lu",(unsigned long)arraySize);
    for(int j=0; j<arraySize3; j++){
        //for(UIImageView *image in downspikes) {
        UIImageView *x =[upspikes objectAtIndex:j];
        if (CGRectIntersectsRect(bear.frame, x.frame))
        {
            //[bear setFrame:CGRectMake(bear.center.x - 23, bear.center.y - 35, 50, 50)];
            [bearcatMovement invalidate];
            [spikesCollison invalidate];
            [self rotateImage];
            [self GameOverView];
        }
    }
    
    
    //right side
    NSUInteger arraySize1 = [rightspikes count];
  //  NSLog(@"count :- %lu",(unsigned long)arraySize);
    for(int j=0; j<arraySize1; j++){
        //for(UIImageView *image in downspikes) {
        UIImageView *x =[rightspikes objectAtIndex:j];
        
        if(x.hidden == NO)
        {
            if (CGRectIntersectsRect(bear.frame, x.frame))
            {
                //[bear setFrame:CGRectMake(bear.center.x - 23, bear.center.y - 35, 50, 50)];
                [bearcatMovement invalidate];
                [spikesCollison invalidate];
                [self rotateImage];
                [self GameOverView];
            }
        }
    }
    
    
    //left side
    NSUInteger arraySize2 = [leftspikes count];
    //NSLog(@"count :- %lu",(unsigned long)arraySize);
    for(int j=0; j<arraySize2; j++){
        //for(UIImageView *image in downspikes) {
        UIImageView *x =[leftspikes objectAtIndex:j];
        
        if(x.hidden == NO)
        {
            if (CGRectIntersectsRect(bear.frame, x.frame))
            {
                //[bear setFrame:CGRectMake(bear.center.x - 23, bear.center.y - 35, 50, 50)];
                [bearcatMovement invalidate];
                [spikesCollison invalidate];
                [self rotateImage];
                [self GameOverView];
            }
        }
    }
}


-(void)trophyCollison
{
    if (CGRectIntersectsRect(bear.frame, trophy.frame))
    {
        trophy.hidden=true;
        trophyCount+=1;
        [self addTrophy];
    }
}

-(void)addTrophy{

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    //random trophy generation for bearcat
    int xValue = (arc4random() % (int) (screenWidth-200));
    int yValue = (arc4random() % (int) (screenHeight-200));

    trophy = [[UIImageView alloc] initWithFrame:CGRectMake(xValue + 60, yValue + 60, 30, 30)];
    trophy.image = [UIImage imageNamed:@"trophy.png"];

    //add the view to the main view
    [self.view addSubview:trophy];
    
    [self trophyAnimation];
	
}

-(void)bearcatMovement{
    
	//LEFT AND RIGHT WALL ON TOUCH
    if ((bear.center.x - 22) < 10) {
        flg = 1;
        scr_counter++;
        
        //animation for text changing
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.75;
        [scoreLable.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        //This will fade:
        [scoreLable setText:[NSString stringWithFormat:@"%02d",scr_counter]];
        [bear setImage:[UIImage imageNamed:@"bearcat1.gif"]];
        p = 1;
        [self randomSpikes];
        [self wallTouchSoundPlay];
        
        if(scr_counter%2 == 0)
        {
            [self colorBackgroundChange];
        }
    }
    if ((bear.center.x + 22) >= screenWidth)
    {
        flg = 0;
        //bear.center = CGPointMake(bear.center.x - 10, bear.center.y - BearFlight);
        scr_counter++;
        //animation for text changing
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.75;
        [scoreLable.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        // This will fade:
        [scoreLable setText:[NSString stringWithFormat:@"%02d",scr_counter]];
        [bear setImage:[UIImage imageNamed:@"bearcat.gif"]];
        p = 0;
        [self randomSpikes];
        //play touch wall sound
        [self wallTouchSoundPlay];
        
        if(scr_counter%2 == 0)
        {
            [self colorBackgroundChange];
        }
    }
    
    
    if(flg == 1)
    {
        bear.center = CGPointMake(bear.center.x + 10, bear.center.y - BearFlight);
    }
    else
    {
        bear.center = CGPointMake(bear.center.x - 10, bear.center.y - BearFlight);
       
    }
    BearFlight = BearFlight - 5;
	
}

// SPIKES GENERATION FOR UP DOWN LEFT AND RIGHT
- (void) generatingSpikes {
	CGRect screenBound = [[UIScreen mainScreen] bounds];
	CGSize screenSize = screenBound.size;
	CGFloat screenWidth = screenSize.width;
	CGFloat screenHeight = screenSize.height;
	
	int widthspikes = screenWidth/8;
    
	//DOWN SPIKES
	int x=0;
	int y=screenHeight - widthspikes;
	// Do any additional setup after loading the view.
	for(int i =0;i < 8; i++)
	{
		//You need to specify the frame of the view
		UIView *spikeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, widthspikes, widthspikes)];
		
		UIImage *spikeImage = [UIImage imageNamed:@"spike.png"];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:spikeImage];
		
		//specify the frame of the imageView in the superview , here it will fill the superview
		imageView.frame = spikeView.bounds;
		
		// add the imageview to the superview
		[spikeView addSubview:imageView];
		
		//add the view to the main view
		[self.view addSubview:spikeView];
        
        //add spikes to array
        [downspikes addObject:spikeView];
		
		x += widthspikes + 2;
	}
	
	//UP SPIKES
	x = 0; y =0;
	//int spikesnum = screenWidth/8;
	// Do any additional setup after loading the view.
	for(int i =0;i < 8; i++)
	{
		//You need to specify the frame of the view
		UIView *spikeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, widthspikes, widthspikes)];
		
		UIImage *spikeImage = [UIImage imageNamed:@"spike.png"];
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:spikeImage];
		
		imageView.transform = CGAffineTransformMakeRotation(3.14);
		
		//specify the frame of the imageView in the superview , here it will fill the superview
		imageView.frame = spikeView.bounds;
		
		// add the imageview to the superview
		[spikeView addSubview:imageView];
		
		//add the view to the main view
		[self.view addSubview:spikeView];
        
         //add spikes to array
        [upspikes addObject:spikeView];
		
		x += widthspikes + 2;
	}
	
	//LEFT SPIKES
	x = 0; y =0;
	int x1 = screenHeight/widthspikes;
	for(int i =0;i < x1; i++)
	{
		int hlength = (screenHeight - 3*(widthspikes));
		if(y >= hlength)
		{
			break;
		}
		
		//You need to specify the frame of the view
		UIView *spikeView = [[UIView alloc] initWithFrame:CGRectMake(x-10, (y + widthspikes + 20), widthspikes, widthspikes)];
		
		UIImage *spikeImage = [UIImage imageNamed:@"spike.png"];
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:spikeImage];
		
		imageView.transform = CGAffineTransformMakeRotation(3.14/2);
		
        //specify the frame of the imageView in the superview , here it will fill the superview
        imageView.frame = spikeView.bounds;
        
        // add the imageview to the superview
        [spikeView addSubview:imageView];
        
        //add the view to the main view
        [self.view addSubview:spikeView];
        
        //add spikes to array
        [leftspikes addObject:spikeView];
        
        //[imageView release];
		
		y += widthspikes + 3;
	}
	
	//RIGHT SPIKES
	x = screenWidth; y =0;
	for(int i =0;i < x1; i++)
	{
		int hlength = (screenHeight - 3*(widthspikes));
		if(y >= hlength)
		{
			break;
		}
		
		//You need to specify the frame of the view
		UIView *spikeView = [[UIView alloc] initWithFrame:CGRectMake((x - widthspikes + 10), (y + widthspikes + 20), widthspikes, widthspikes)];
		
		UIImage *spikeImage = [UIImage imageNamed:@"spike.png"];
		
		UIImageView *imageView = [[UIImageView alloc] initWithImage:spikeImage];
		
		imageView.transform = CGAffineTransformMakeRotation(3.14 * 3/2);
		
		//specify the frame of the imageView in the superview , here it will fill the superview
		imageView.frame = spikeView.bounds;
		
		// add the imageview to the superview
		[spikeView addSubview:imageView];
		
		//add the view to the main view
		[self.view addSubview:spikeView];
        
        //add spikes to array
        [rightspikes addObject:spikeView];
		
		y += widthspikes + 3;
	}
    
    
    //hiding left/right side spikes
    for(int k=0; k<11; k++)
    {
        
        //hiding right side spikes
        UILabel *x =[rightspikes objectAtIndex:k];
        x.hidden = YES;
        //hiding left side spikes
        x =[leftspikes objectAtIndex:k];
        x.hidden = YES;
    }
}

-(void)randomSpikes
{
    int max=11,min=0;
    
    if(checkSide == 0)
    {
        //show right side spikes
        for (int i=0;i< 3; i++)
        {
            int randNum = rand() % (max - min) + min; //create the random number.
            for(int k=0; k<11; k++)
            {
                if(randNum == k)
                {
                    UIImageView *x =[rightspikes objectAtIndex:k];
                    //x.hidden = NO;
                    [self showSpikesAnimate:x];
                }
            }
        }
        
        //HIDE LEFT SPIKES
        for(int k=0; k<11; k++)
        {
            UIImageView *x =[leftspikes objectAtIndex:k];
            
            //x.hidden = YES;
            [self hideSpikesAnimate:x];
        }
        checkSide = 1;
        
    }else{
        //show left side spikes
        for (int i=0;i< 3; i++)
        {
            int randNum = rand() % (max - min) + min; //create the random number.
            for(int k=0; k<11; k++)
            {
                if(randNum == k)
                {
                    UIImageView *x =[leftspikes objectAtIndex:k];
                    //x.hidden = NO;
                    [self showSpikesAnimate:x];
                }
            }
        }
        
        //HIDE RIGHT SPIKES
        for(int k=0; k<11; k++)
        {
            UIImageView *x =[rightspikes objectAtIndex:k];
            
            //x.hidden = YES;
            [self hideSpikesAnimate:x];
        }
        checkSide = 0;
    }
}

// HIDE SPIKES WITH ANIMATION
- (void)hideSpikesAnimate:(UIImageView *)imageView
{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [imageView.layer addAnimation:transition forKey:nil];
    imageView.hidden = YES;
}

// SHOW SPIKES WITH ANIMATION
- (void)showSpikesAnimate:(UIImageView *)imageView
{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [imageView.layer addAnimation:transition forKey:nil];
    imageView.hidden = NO;
}

//code to rotate image on game over
-(void)rotateImage{
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: 3.14 * 2.0 /* full rotation*/ * 5 * 0.1 ];
    rotationAnimation.duration = 0.2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 27;
    
    [bear.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView animateWithDuration:5.0f animations:^{
        //Move the image view to 100, 100 over 10 seconds.
        bear.frame = CGRectMake(bear.center.x, screenHeight - screenHeight/15 - screenHeight/15, bear.frame.size.width, bear.frame.size.height);
    }];
    
    [self gameOverSoundPlay];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if(touchCount == 0)
    {
        begin.hidden = YES;
        [blink invalidate];
        scoreLable.hidden = NO;
        [bear.layer removeAllAnimations];
        //Add tropy random generation
        [self addTrophy];
        //timer
        bearcatMovement = [NSTimer scheduledTimerWithTimeInterval:0.09 target:self selector:@selector(bearcatMovement) userInfo:nil repeats:YES];
        
        spikesCollison = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(spikesCollision) userInfo:nil repeats:YES];
        
        trophyCollison = [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(trophyCollison) userInfo:nil repeats:YES];
    }
    touchCount++;
    //play jump sound on touch
    [self jumpSoundPlay];
    
    BearFlight = 20;
    [self showPictures];
}

- (void)showPictures
{
    if(p == 1)
    {
        paw.hidden = NO;
        [paw setImage:[UIImage imageNamed:@"paws.gif"]];
        [paw setFrame:CGRectMake(bear.center.x - 35, bear.center.y - 25, 50, 50)];
        [self.view bringSubviewToFront:paw];
        // [self.view addSubview:paw];
//        paw2.hidden = NO;
//        [paw2 setFrame:CGRectMake(bear.center.x - 30, bear.center.y, 15, 15)];
//        
//        paw3.hidden = NO;
//        [paw3 setFrame:CGRectMake(bear.center.x - 45, bear.center.y + 15, 15, 15)];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hidePictures) userInfo:nil repeats:NO];
    }
    else{
        paw.hidden = NO;
        [paw setImage:[UIImage imageNamed:@"paws1.gif"]];
        [paw setFrame:CGRectMake(bear.center.x, bear.center.y + 15, 50, 50)];
        [self.view bringSubviewToFront:paw];
   //     paw2.hidden = NO;
     //   [paw2 setFrame:CGRectMake(bear.center.x + 30, bear.center.y+30, 15, 15)];
      //  paw3.hidden = NO;
       // [paw3 setFrame:CGRectMake(bear.center.x + 45, bear.center.y + 45, 15, 15)];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(hidePictures) userInfo:nil repeats:NO];
    }
}

- (void)hidePictures
{
    paw.hidden = YES;
    paw2.hidden = YES;
    paw3.hidden = YES;
    
}


//REMOVE PHONE TOOLBAR
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

//JUMPING BEARCAT
- (void)bearcatAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.4;
    animation.repeatCount = 1000;
    animation.fromValue = [NSValue valueWithCGPoint:bear.center];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(bear.center.x, bear.center.y-30)];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    [bear.layer addAnimation:animation forKey:@"position"];
}

//JUMPING TROPHY
- (void)trophyAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.4;
    animation.repeatCount = 1000;
    animation.fromValue = [NSValue valueWithCGPoint:trophy.center];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(trophy.center.x, trophy.center.y-20)];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    [trophy.layer addAnimation:animation forKey:@"position"];
}

//GAME OVER
- (IBAction)GameOver:(id)sender {
    [bearcatMovement invalidate];
    [spikesCollison invalidate];
    [trophyCollison invalidate];
    touchCount = 0;
    scr_counter=0;
    trophyCount=0;
    flg = 0;
   [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)colorBackgroundChange{
    int red = 210, green = 210, blue = 210;
    
    switch (backgroundColorCount) {
        case 1:
            green = 250;
            blue = 255;
            break;
        case 2:
            green = 255;
            break;
        case 3:
            blue = 255;
            break;
        case 4:
            red = 250;
            green = 255;
            break;
        case 5:
            backgroundColorCount = 1;
            break;
    }
    backgroundColorCount++;
    self.view.backgroundColor = [UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1];
    [circleLayer setStrokeColor:[[UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1] CGColor]];
    scoreLable.textColor=[UIColor colorWithRed:(red/255.0) green:(green/255.0) blue:(blue/255.0) alpha:1];
}

@end
