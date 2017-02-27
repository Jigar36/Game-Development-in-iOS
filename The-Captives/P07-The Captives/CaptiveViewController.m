//
//  CaptiveViewController.m
//  P07-The Captives
//
//  Created by Tanmay Kale on 4/5/16.
//  Copyright © 2016 Jigar. All rights reserved.
//

#import "CaptiveViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CaptiveViewController ()

@end

@implementation CaptiveViewController

@synthesize bricks;
@synthesize title1;
@synthesize ScoreLabel;
@synthesize ScoreName;
@synthesize HomeButton;

int currentScore=0;
int r=0,redpoint=0;
int x=10;
int redpos[]={30,31,32,39,40,41,48,49,50};
int firstFlag = 0;

-(void) updateScore{
    currentScore += 1;
    ScoreLabel.text= [NSString stringWithFormat:@"%d", currentScore];
}

- (void)animateImages
{
    static int count = 0;
    NSArray *animationImages = @[[UIImage imageNamed:@"header"], [UIImage imageNamed:@"trashbox.regular"]];
    UIImage *image = [animationImages objectAtIndex:(count % [animationImages count])];
    
    [UIView transitionWithView:self.title1
                      duration:1.0f // animation duration
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.title1.image = image; // change to other image
                    } completion:^(BOOL finished) {
                        [self animateImages]; // once finished, repeat again
                        count++; // this is to keep the reference of which image should be loaded next
                    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentScore=0;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
    
    //adding image to the main screen
    if(firstFlag == 0){
        title1 = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth/4-50, screenHeight/6-50, screenWidth-100, 100)];
        title1.image=[UIImage imageNamed:@"header.png"];
        [self.view addSubview: title1];
        [self animateImages];
    
    
    //Adding Score Labels and Home Button
    ScoreName = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-180, screenHeight/4+60, 80, 15)];
    ScoreName.font = [UIFont fontWithName:@"chalkduster" size:(20.0)];
    ScoreName.text=@"Score : ";
    ScoreName.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview: ScoreName];
    
    ScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-100, screenHeight/4+60, 80, 15)];
    ScoreLabel.text= [NSString stringWithFormat:@"%d", currentScore];
    ScoreLabel.textAlignment = NSTextAlignmentCenter;
    ScoreLabel.font = [UIFont fontWithName:@"chalkduster" size:(20.0)];
    [self.view addSubview: ScoreLabel];
    }
     ScoreLabel.text= @"0";
    
    //firstFlag=1;
    //Logic for adding all the block, naming them and game logic.
    bricks = [NSMutableArray array];

    int y = 360;
    int height = 32;
    for(int k=0; k<9; k ++)
    {
        for (int i=0;i<9;i++){
            UILabel *brick;
            int x = (screenWidth/11)*i;
            if(k%2==0)
            {
                brick= [[UILabel alloc] initWithFrame:CGRectMake(x+20, y, 36, 36)];
                brick.layer.masksToBounds = YES;
                brick.layer.cornerRadius = 18;
                brick.backgroundColor = [UIColor grayColor];
            }
            else{
                x+=20;
                brick= [[UILabel alloc] initWithFrame:CGRectMake(x+20, y, 36, 36)];
                brick.layer.masksToBounds = YES;
                brick.layer.cornerRadius = 18;
                brick.backgroundColor = [UIColor grayColor];
                
            }
            [self.view addSubview:brick];
            [bricks addObject:brick];
            
            brick.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLabelWithGesture:)];
            [brick addGestureRecognizer:tapGesture];
           // [tapGesture release];
        }
        y = y + height;
    }
    UILabel *x;
    // For randomly generating red circle in the center.
    redpoint = arc4random_uniform(8);
    x =[bricks objectAtIndex:redpos[redpoint]];
    if(x.backgroundColor == [UIColor grayColor])
    {
        x.backgroundColor = [UIColor redColor];
    }
    
    NSLog(@"redpoint= %d",r);
    NSLog(@"redpoint [x]= %d",redpos[r]);
    
    // For randomly generating 9 intital blue circles.
    
    for(int j=0; j<9; j++){
        r = arc4random_uniform(81);
        
        if(r==redpoint)
        {
            r = arc4random_uniform(81);
        }
        
        else if(x.backgroundColor == [UIColor blueColor])
        {
            r = arc4random_uniform(81);
        }
        x =[bricks objectAtIndex:r];
        //        if(x.backgroundColor == [UIColor grayColor])
        //        {
        //            x.backgroundColor = [UIColor blueColor];
        //        }
        //        else if(x.backgroundColor == [UIColor blueColor] || r==redpoint)
        //        {
        //            j--;
        //        }
        x.backgroundColor = [UIColor blueColor];
        NSLog(@"r= %d",r);
    }
    x =[bricks objectAtIndex:redpos[redpoint]];
    if(x.backgroundColor == [UIColor grayColor])
    {
        x.backgroundColor = [UIColor redColor];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTapLabelWithGesture:(UITapGestureRecognizer *)tapGesture {
    // ...
    UILabel *theTappedView = (UILabel *)tapGesture.view;
    if(theTappedView.backgroundColor == [UIColor grayColor])
    {
        theTappedView.backgroundColor = [UIColor blueColor];
        UILabel *redDot;
        
        int j =0;
        for(j=0; j<81; j++)
        {
             redDot =[bricks objectAtIndex:j];
            if(redDot.backgroundColor == [UIColor redColor]){
                break;
            }
        }
        int line = 0;
        int count = 0;
        //find the line for hexagon
        for(int i=0; i<9; i++){
            for(int k=0;k<9; k++)
            {
                //NSLog(@"jCount: %d", j);
                
                if(count==j)
                {
                    //NSLog(@"lineCount: %d %d", count, i);
                    line = i;
                    //break;
                }
                count++;
            }
        }
        
        NSMutableArray *paths = [NSMutableArray array];
        
        //for(int i=0; i<9; i++){
            for(int k=0; k< 81;k++){
                
               redDot =[bricks objectAtIndex:k];
                if(redDot.backgroundColor == [UIColor redColor]){
                    bool left = [self checkLeft: k];
                    bool right = [self checkRight: k];
                    if((k-10) > 0 && (k-9)>0 && (k-8)>0 && (k-8) < 81 && (k-9) <81 && (k+10) < 81 && left && right){
                        UILabel *first, *second, *third, *forth, *fifth, *sixth;
                        
                        if(line%2 == 0){
                            first = [bricks objectAtIndex:(k-10)];
                            second = [bricks objectAtIndex:(k-9)];
                            third = [bricks objectAtIndex:(k-1)];
                            forth = [bricks objectAtIndex:(k+1)];
                            fifth = [bricks objectAtIndex:(k+8)];
                            sixth = [bricks objectAtIndex:(k+9)];
                        }else{
                            first = [bricks objectAtIndex:(k-9)];
                            second = [bricks objectAtIndex:(k-8)];
                            third = [bricks objectAtIndex:(k-1)];
                            forth = [bricks objectAtIndex:(k+1)];
                            fifth = [bricks objectAtIndex:(k+9)];
                            sixth = [bricks objectAtIndex:(k+10)];
                        }
                        
                        int firstPath=0, secondPath=0, thirdPath=0, forthPath=0, fifthPath=0, sixthPath=0;
                        if([first.backgroundColor isEqual:[UIColor grayColor]]){
                            firstPath = [self getFirstShortestPath:line:k];
                            
                            //redDot.backgroundColor = [UIColor grayColor];
                            //first.backgroundColor = [UIColor redColor];
                            //break;
                        }
                        
                        if([second.backgroundColor isEqual:[UIColor grayColor]]){
                            secondPath = [self getSecondShortestPath:line:k];
                            
                            //redDot.backgroundColor = [UIColor grayColor];
                            //second.backgroundColor = [UIColor redColor];
                            //break;
                        }
                        
                        if([third.backgroundColor isEqual:[UIColor grayColor]]){
                            thirdPath = [self getThirdShortestPath:line:k];
                            
                            //redDot.backgroundColor = [UIColor grayColor];
                            //third.backgroundColor = [UIColor redColor];
                            //break;
                        }
                        
                        if([forth.backgroundColor isEqual:[UIColor grayColor]]){
                            forthPath = [self getForthShortestPath:line:k];
                            
                            //redDot.backgroundColor = [UIColor grayColor];
                            //forth.backgroundColor = [UIColor redColor];
                            //break;
                        }
                        
                        if([fifth.backgroundColor isEqual:[UIColor grayColor]]){
                            fifthPath = [self getFifthShortestPath:line:k];
                           
                            //redDot.backgroundColor = [UIColor grayColor];
                            //fifth.backgroundColor = [UIColor redColor];
                            //break;
                        }
                        
                        if([sixth.backgroundColor isEqual:[UIColor grayColor]]){
                            sixthPath = [self getSixthShortestPath:line:k];
                            
                            //redDot.backgroundColor = [UIColor grayColor];
                            //sixth.backgroundColor = [UIColor redColor];
                           // break;
                        }
                        
                        [paths addObject:[NSNumber numberWithInt:firstPath]];
                        [paths addObject:[NSNumber numberWithInt:secondPath]];
                        [paths addObject:[NSNumber numberWithInt:thirdPath]];
                        [paths addObject:[NSNumber numberWithInt:forthPath]];
                        [paths addObject:[NSNumber numberWithInt:fifthPath]];
                        [paths addObject:[NSNumber numberWithInt:sixthPath]];
                        
                        NSLog(@"path: %d,%d, %d, %d, %d, %d", firstPath, secondPath, thirdPath, forthPath, fifthPath, sixthPath);
                        if(firstPath == 0 && secondPath == 0 && thirdPath == 0 && forthPath == 0 &fifthPath == 0 && sixthPath == 0){
                            [self gameWon];
                        }else{
                            int minVal = [self findShortestNumber:paths];
                            NSLog(@"minVal: %d", minVal);
                            int direction = 0;
                            //finding the index
                            for(int j=0; j<[paths count]; j++)
                            {
                                int x =[[paths objectAtIndex:j] intValue];
                                if(x == minVal){
                                    direction = j;
                                    break;
                                }
                            }
                            
                            //change red dot.
                            redDot.backgroundColor = [UIColor grayColor];
                            NSLog(@"Dir: %d", direction);
                            switch (direction) {
                                case 0:
                                    first.backgroundColor = [UIColor redColor];
                                    break;
                                case 1:
                                    second.backgroundColor = [UIColor redColor];
                                    break;
                                case 2:
                                    third.backgroundColor = [UIColor redColor];
                                    break;
                                case 3:
                                    forth.backgroundColor = [UIColor redColor];
                                    break;
                                case 4:
                                    fifth.backgroundColor = [UIColor redColor];
                                    break;
                                case 5:
                                    sixth.backgroundColor = [UIColor redColor];
                                    break;
                                    
                                default:
                                    break;
                            }
                              [self updateScore];
                            break;
                        }
                        
                    }else{
                        redDot.backgroundColor = [UIColor grayColor];
                    }
                    
                }
            }
        
        for(j=0; j<81; j++)
            
        {
            
            redDot =[bricks objectAtIndex:j];
            
            if(redDot.backgroundColor == [UIColor redColor]){
                
                break;
                
            }
            
        }
        
        if(j==81)
            
        {
            [self gameLost];
            //add your alert box here
            //GameOverLabel.hidden = NO;
            //and call view did from alert box again
            
        }
        //}
    }
    
    //theTappedView.backgroundColor = [UIColor blueColor];
}

-(void) gameWon {
    NSLog(@"Game Won");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Won" message:@"Congratulations!!!" delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles:nil];
    [alert show];

}

-(void) gameLost{
    NSLog(@"Game Lost");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:@"Sorry Bad Luck!!!" delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles:nil];
    [alert show];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //delete it
        firstFlag=1;
        [self viewDidLoad];
    }
}
-(bool) checkLeft:(int) value{
    if(value == 8 || value == 17 || value == 26 || value == 35 || value==44 || value==53|| value==62 || value==71 || value==81 )
    {
        return false;
    }else{
        return true;
    }
}

-(bool) checkRight: (int) value{
    if(value== 9 || value == 18 || value == 27 || value == 36 || value==45 || value==54|| value==63 || value==72 )
    {
        return false;
    }else{
        return true;
    }
}


- (int)getFirstShortestPath: (int) line: (int) index {
    
    int pathSize = 0;
    while(index>0){
        if(line%2!=0){
            index=index-9;
            pathSize++;
            
        }else{
            index=index-10;
            pathSize++;
        }
        line++;
    }
    return pathSize-1;
    
}

- (int)getSecondShortestPath: (int) line: (int) index {
    int pathSize = 0;
    while(index>0){
        if(line%2!=0){
            index=index-8;
            pathSize++;
        }else{
            index=index-9;
            pathSize++;
        }
        line++;
    }
    return pathSize-1;
}

- (int)getThirdShortestPath: (int) line: (int) index {
    int pathSize = 0;
    NSLog(@"Index: %d", (index%9)-1);
    while(((index%9)-1)>0){
        NSLog(@"Index: %d",((index%9)-1));
        index=index-1;
        pathSize++;
        
    }
    return pathSize+1;
}

- (int)getForthShortestPath: (int) line: (int) index {
    int pathSize = 0;
    while(((index%9)+1)<9){
        index=index+1;
        pathSize++;
    }
    return pathSize;
}

- (int)getFifthShortestPath: (int) line: (int) index {
    int pathSize = 0;
    while(index<81){
        if(line%2!=0){
            index=index+9;
            pathSize++;
        }else{
            index=index+10;
            pathSize++;
        }
        line++;
    }
    return pathSize-1;
}

- (int)getSixthShortestPath: (int) line: (int) index {
    int pathSize = 1;
    if(line%2!=0)
        pathSize=1;
    
    while(index<81){
        if(line%2!=0){
            index=index+10;
            pathSize++;
        }else{
            index=index+11;
            pathSize++;
        }
        line++;
    }
    return pathSize-1;
}

- (int)findShortestNumber: (NSMutableArray *)paths {
    int minVal = 0;
    for(int i=0;i<[paths count];i++){
        if([[paths objectAtIndex: i] intValue] !=0 )
        {
            minVal = [[paths objectAtIndex: i] intValue];
            break;
        }
    }
    for(int i=1;i<[paths count];i++){
        
        if(minVal > [[paths objectAtIndex:i] intValue] && [[paths objectAtIndex:i] intValue] != 0){
            minVal = [[paths objectAtIndex:i] intValue];
        }
    }
    return minVal;
}

-(NSArray *)bubbleSort:(NSMutableArray *)unsortedDataArray
{
    long count = unsortedDataArray.count;
    int i;
    bool swapped = TRUE;
    while (swapped){
        swapped = FALSE;
        for (i=1; i<count;i++)
        {
            if ([unsortedDataArray objectAtIndex:(i-1)] > [unsortedDataArray objectAtIndex:i])
            {
                [unsortedDataArray exchangeObjectAtIndex:(i-1) withObjectAtIndex:i];
                swapped = TRUE;
            }
            //bubbleSortCount ++; //Increment the count everytime a switch is done, this line is not required in the production implementation.
        }
    }
    return unsortedDataArray;
}

@end

