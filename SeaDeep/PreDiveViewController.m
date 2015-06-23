//
//  PreDiveViewController.m
//  SeaDeep
//
//  Created by Julio Vasquez on 3/5/15.
//  Copyright (c) 2015 Christopher Workman. All rights reserved.
//

#import "PreDiveViewController.h"
#import "DiveViewController.h"

#define BLUR_TAG 113


@interface PreDiveViewController ()
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextField *maxDepthField;
@property (weak, nonatomic) IBOutlet UITextField *missionNameField;

@end

@implementation PreDiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the entered information to the dive view controller.
    DiveViewController* diveViewController = [segue destinationViewController];
    [diveViewController setMaxDepth:[_maxDepthField.text intValue] andMissionName:_missionNameField.text];
    
}
#pragma mark - textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];

    return YES;
}
- (void) textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect f = self.view.frame;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.alpha = 0.0f;
    visualEffectView.tag = BLUR_TAG;
    visualEffectView.frame = screenRect;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTextField)];
    tgr.numberOfTapsRequired = 1;
    [visualEffectView addGestureRecognizer:tgr];
    

    if ([_missionNameField isFirstResponder]){
        f.origin.y = -145.0f;
        [self.view insertSubview:visualEffectView belowSubview:_missionNameField];

    }else if ([_maxDepthField isFirstResponder]){
        f.origin.y = -45.0f;
        [self.view insertSubview:visualEffectView belowSubview:_maxDepthField];
    }
    

    [UIView animateWithDuration:0.3 animations:^{
        visualEffectView.alpha = 1.0f;

        self.view.frame = f;
        
        CGRect navFrame = self.navigationController.navigationBar.frame;
        navFrame.origin.y = -45.0f;
        
        self.navigationController.navigationBar.frame = navFrame;
        
    }completion:^(BOOL finished) {
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{

    UIVisualEffectView *visualEffectView = (UIVisualEffectView*) [self.view viewWithTag:BLUR_TAG];
    
    [UIView animateWithDuration:0.3 animations:^{

        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        
        self.view.frame = f;
        
        CGRect navFrame = self.navigationController.navigationBar.frame;
        navFrame.origin.y = 21.0f;
        
        self.navigationController.navigationBar.frame = navFrame;
        
        if (visualEffectView){
            visualEffectView.alpha = 0.0f;
        }
    }completion:^(BOOL finished) {
        if (visualEffectView){
            [visualEffectView removeFromSuperview];
        }
        [UIView animateWithDuration:.25 animations:^{
            if (_missionNameField.text.length > 0 && _maxDepthField.text.length > 0){
                [_goButton setAlpha:1.0f];
            }else{
                [_goButton setAlpha:0.0f];
            }
        }];
    }];
    

    
}

- (void) closeTextField{
    if ([_missionNameField isFirstResponder]){
        [_missionNameField resignFirstResponder];
    }else{
        [_maxDepthField resignFirstResponder];
    }
}


@end
