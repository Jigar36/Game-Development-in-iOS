//
//  DifficultyLevelsViewController.h
//  Duet
//
//  Created by Jigar Panchal on 5/15/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *MYGlobalVariable;

@interface DifficultyLevelsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *EasyLevel;
@property (strong, nonatomic) IBOutlet UIButton *MediumLevel;
@property (strong, nonatomic) IBOutlet UIButton *HardLevel;

@property (strong, nonatomic) IBOutlet UIButton *InsaneLevel;
@property (strong, nonatomic) IBOutlet UIButton *BackBtn;

@end
