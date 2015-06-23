//
//  MainMenuViewController.m
//  SeaDeep
//
//  Created by Julio Vasquez on 3/5/15.
//  Copyright (c) 2015 Christopher Workman. All rights reserved.
//

#import "MainMenuViewController.h"
#define THEME_COLOR [UIColor colorWithRed:0.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

@interface MainMenuViewController ()
@property (weak, nonatomic) IBOutlet UIButton *diveButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *missionButton;
@property (weak, nonatomic) IBOutlet UIButton *atmosphereButton;

@property (weak, nonatomic) IBOutlet UIButton *directoryButton;
@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self prepareButtons];
    // Do any additional setup after loading the view.
}

- (void) prepareButtons{
    _diveButton.layer.cornerRadius = _diveButton.frame.size.height/2;
    _diveButton.layer.borderWidth = 2.0f;
    _diveButton.layer.borderColor = [THEME_COLOR CGColor];
    
    _missionButton.layer.cornerRadius = 1;
    _missionButton.layer.borderWidth = 2.0f;
    _missionButton.layer.borderColor = [THEME_COLOR CGColor];
    
    _profileButton.layer.cornerRadius = 1;
    _profileButton.layer.borderWidth = 2.0f;
    _profileButton.layer.borderColor = [THEME_COLOR CGColor];
    _atmosphereButton.layer.cornerRadius = 1;
    _atmosphereButton.layer.borderWidth = 2.0f;
    _atmosphereButton.layer.borderColor = [THEME_COLOR CGColor];
    
    }

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return NO;
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
