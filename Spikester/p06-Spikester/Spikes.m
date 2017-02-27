//
//  Spikes.m
//  p06-Spikester
//
//  Created by Tejas Nadkarni on 15/03/16.
//  Copyright © 2016 tkale1. All rights reserved.
//

#import "Spikes.h"

@interface Spikes ()

@end

@implementation Spikes

@synthesize spikes;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        
        y += widthspikes + 3;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
