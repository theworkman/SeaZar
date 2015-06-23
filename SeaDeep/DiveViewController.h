//
//  ViewController.h
//  SeaDeep
//
//  Created by Christopher Workman on 4/26/14.
//  Copyright (c) 2014 Christopher Workman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "BLE.h"
#import <QuartzCore/QuartzCore.h>

@interface DiveViewController : UIViewController <CLLocationManagerDelegate, BLEDelegate> {
    
    CGFloat compassAngle;
    __weak IBOutlet UIButton *btnConnect;
    
    __weak IBOutlet UILabel *tempLabel;
    __weak IBOutlet UILabel *depthLabel;
    __weak IBOutlet UILabel *maxDepthLabel;
    __weak IBOutlet UILabel *pressureLabel;
    
    __weak IBOutlet UIButton *bluetoothButton;
    __weak IBOutlet UIActivityIndicatorView *indConnecting;
    
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UILabel *noDecoLabel;
    
    __weak IBOutlet UILabel *compassLabel; // Change heading

    BOOL timerOn;
    
    __weak IBOutlet UIButton *closeButton;
    BOOL haveImage;

    IBOutlet UIButton *moveButton;
}
- (IBAction)endDive:(id)sender;

- (IBAction)startRecordingData:(id)sender;

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@property (weak, nonatomic) IBOutlet UIView *imagePreview;


- (IBAction)snapImage:(id)sender;
- (IBAction)startCamera:(id)sender;


@property (weak, nonatomic) IBOutlet UIImageView *captureImage;


@property (nonatomic, retain) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UIImageView *compassNeedle;

@property (strong, nonatomic) BLE *ble;

- (void) setMaxDepth:(int) depth andMissionName:(NSString*) missionName;
@end
