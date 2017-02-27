//
//  main.m
//  Asteroids
//
//  Created by Franklin Yu on 2016/2/17.
//  Copyright © 2016年 Franklin Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
	srand48(time(NULL));

	@autoreleasepool {
		return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
	}
}
