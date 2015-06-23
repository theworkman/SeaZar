//
//  ProfileViewController.m
//  SeaDeep
//
//  Created by Maria Bocanegra on 3/29/15.
//  Copyright (c) 2015 Christopher Workman. All rights reserved.
//


#import "ProfileViewController.h"
#define THEME_COLOR [UIColor colorWithRed:0.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIButton *directoryButton;
@property (weak, nonatomic) IBOutlet UIButton *numberButton;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self prepareButtons];
    // Do any additional setup after loading the view.
}

- (void) prepareButtons{
   
    _directoryButton.layer.cornerRadius = 1;
    _directoryButton.layer.borderWidth = 1.5f;
    _directoryButton.layer.borderColor = [THEME_COLOR CGColor];
    
    _numberButton.layer.cornerRadius = 1;
    _numberButton.layer.borderWidth = 1.5f;
    _numberButton.layer.borderColor = [THEME_COLOR CGColor];
    
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

