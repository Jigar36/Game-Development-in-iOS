//
//  DifficultyLevelsViewController.m
//  Duet
//
//  Created by Jigar Panchal on 5/15/16.
//  Copyright © 2016 Jigar Panchal. All rights reserved.
//

#import "DifficultyLevelsViewController.h"
//#import "GameViewController.h"


@interface DifficultyLevelsViewController ()

@end

@implementation DifficultyLevelsViewController
@synthesize EasyLevel,MediumLevel,HardLevel,InsaneLevel,BackBtn;

NSString *MYGlobalVariable;

- (IBAction)EasyLevel:(id)sender {
    MYGlobalVariable = [sender currentTitle];
    
}
- (IBAction)MediumLevel:(id)sender {
    MYGlobalVariable = [sender currentTitle];

}
- (IBAction)HardLevel:(id)sender {
    MYGlobalVariable = [sender currentTitle];

}
- (IBAction)InsaneLevel:(id)sender {
    MYGlobalVariable = [sender currentTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    EasyLevel.layer.cornerRadius = 5.0;
    EasyLevel.layer.shadowOpacity = 3.0;
    EasyLevel.alpha = 0.9;
    
    [EasyLevel setBackgroundColor:[UIColor orangeColor]];

    MediumLevel.layer.cornerRadius = 5.0;
    MediumLevel.layer.shadowOpacity = 3.0;
    MediumLevel.alpha = 0.9;
    [MediumLevel setBackgroundColor:[UIColor orangeColor]];

    
    HardLevel.layer.cornerRadius = 5.0;
    HardLevel.layer.shadowOpacity = 3.0;
    HardLevel.alpha = 0.9;
    [HardLevel setBackgroundColor:[UIColor orangeColor]];

    
    InsaneLevel.layer.cornerRadius = 5.0;
    InsaneLevel.layer.shadowOpacity = 3.0;
    InsaneLevel.alpha = 0.9;
    [InsaneLevel setBackgroundColor:[UIColor orangeColor]];

    
    BackBtn.layer.cornerRadius = 5.0;
    [BackBtn.layer setBorderColor:[[UIColor blueColor] CGColor]];
    BackBtn.alpha = 0.9;
    [BackBtn setBackgroundColor:[UIColor redColor]];
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
