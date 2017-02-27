#import "DTSIntroViewController.h"
#import "DTSGameViewController.h"

#pragma mark Private Interface
@interface DTSIntroViewController ()

#pragma mark - Private Properties
//! A writable version of the public property.
@property (nullable) DTSGameViewController *gameController;

@end

#pragma mark -
@implementation DTSIntroViewController

#pragma mark - View Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    self.multiplayerToggle.titles = @[@"Human", @"AI"];
    self.multiplayerToggle.titleFont = [UIFont fontWithName:@"Avenir-HeavyOblique" size:16.0];
}

#pragma mark - Actions
- (IBAction)playGame:(UIButton *)sender
{
    CGSize dimensions;
    switch (sender.tag) {
        case 1:
            dimensions = CGSizeMake(5, 5);
            break;

        case 2:
            dimensions = CGSizeMake(6, 6);
            break;

        case 3:
            dimensions = CGSizeMake(7, 7);
            break;

        default:
            dimensions = CGSizeMake(4, 4);
            break;
    }

    self.gameController = [self.storyboard instantiateViewControllerWithIdentifier:@"DTSGameViewController"];
    [self.gameController setUpGameWithBoardDimensions:dimensions playingAgainstAI:self.multiplayerToggle.index != 0];
    self.gameController.title = [NSString stringWithFormat:@"%@ Game", sender.titleLabel.text];

    [self.navigationController pushViewController:self.gameController animated:YES];
}

@end
