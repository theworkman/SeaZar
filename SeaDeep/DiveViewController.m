//
//  ViewController.m
//  SeaDeep
//
//  Created by Christopher Workman on 4/26/14.
//  Copyright (c) 2014 Christopher Workman. All rights reserved.
//

#import "DiveViewController.h"
#import <Parse/Parse.h>


#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define DEPTH 0x0C
#define TEMP 0x0B
#define PRESSURE 0x0D
#define THEME_COLOR [UIColor colorWithRed:0.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]

@interface DiveViewController ()
// get index of the current dive (ex: 1st dive of the day, 10th dive of the day, etc)
@property NSInteger currentDiveIndex;

// get the index of the current measurement (ex: 1st dive==>1st measurement, 1st dive==>4th measurement, etc)
@property NSInteger currentMeasurementIndex;

@property NSInteger recordingDuration;
@property NSInteger estimatedMaxDepth;
@property (nonatomic, strong)  NSString* missionName;
@end

@implementation DiveViewController

@synthesize locationManager;

@synthesize stillImageOutput, imagePreview, captureImage;

@synthesize ble;

int timeTick = 0;
NSTimer *timer;
NSTimer *dataCollectionTimer;
int maxTime = 139*60;
int noDecoTime;
int j = 0;  // vibration number
int k = 0;

- (void) setMaxDepth:(int) depth andMissionName:(NSString*) missionName{
    _estimatedMaxDepth = maxDepth;
    _missionName = missionName;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self prepareButtonBorders];
    
    timeLabel.text = @"0";
    
    locationManager=[[CLLocationManager alloc] init];
    
    captureImage.hidden = YES;
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    
    tempLabel.textColor = [UIColor colorWithRed:0 green:238 blue:235 alpha:1];
    depthLabel.textColor = [UIColor colorWithRed:0 green:238 blue:235 alpha:1];
    maxDepthLabel.textColor = [UIColor colorWithRed:0 green:238 blue:235 alpha:1];
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
    locationManager.delegate=self;
    //Start the compass updates.
    
    
    captureImage.alpha = 0.0f;
    imagePreview.alpha = 0.0f;
    
    
    [locationManager startUpdatingHeading];
    _currentDiveIndex = [self getCurrentDiveNumber];
    _currentMeasurementIndex = 0;
}

- (void) prepareButtonBorders{
    tempLabel.layer.cornerRadius = 1.0f;
    tempLabel.layer.borderColor = [THEME_COLOR CGColor];
    tempLabel.layer.borderWidth = 1.0f;

    btnConnect.layer.cornerRadius = 1.0f;
    btnConnect.layer.borderColor = [THEME_COLOR CGColor];
    btnConnect.layer.borderWidth = 1.0f;
    
    pressureLabel.layer.cornerRadius = 1.0f;
    pressureLabel.layer.borderColor = [THEME_COLOR CGColor];
    pressureLabel.layer.borderWidth = 1.0f;
    
    depthLabel.layer.cornerRadius = 1.0f;
    depthLabel.layer.borderColor = [THEME_COLOR CGColor];
    depthLabel.layer.borderWidth = 1.0f;
    
    maxDepthLabel.layer.cornerRadius = 1.0f;
    maxDepthLabel.layer.borderColor = [THEME_COLOR CGColor];
    maxDepthLabel.layer.borderWidth = 1.0f;
    
    noDecoLabel.layer.cornerRadius = 1.0f;
    noDecoLabel.layer.borderColor = [THEME_COLOR CGColor];
    noDecoLabel.layer.borderWidth = 1.0f;
    
    timeLabel.layer.cornerRadius = 1.0f;
    timeLabel.layer.borderColor = [THEME_COLOR CGColor];
    timeLabel.layer.borderWidth = 1.0f;
}

- (void) checkIfFolderExists:(NSString*) folderPath{
    //Check if folder exists, if not create folder
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

- (NSInteger) getCurrentDiveNumber{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *diverDataFolder = [documentsDirectory stringByAppendingPathComponent:@"Diver Data"];
    [self checkIfFolderExists:diverDataFolder];

    NSString *missionFolder = [diverDataFolder stringByAppendingPathComponent:_missionName];
    [self checkIfFolderExists:missionFolder];
    
    NSArray *missionDivesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:missionFolder error:NULL];
    return missionDivesArray.count + 1;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (IBAction)startCamera:(id)sender {
    
    captureImage.alpha = 1.0f;
    imagePreview.alpha = 1.0f;
    
    [self initializeCamera];
    
    moveButton.transform = CGAffineTransformMakeTranslation(900, 0);
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //NSLog(@"New magnetic heading: %f", newHeading.magneticHeading);
    //NSLog(@"New true heading: %f", newHeading.trueHeading);
    
    float oldRad = -manager.heading.trueHeading * M_PI / 180.0f;
    float newRad = -newHeading.trueHeading * M_PI / 180.0f;
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	theAnimation.fromValue = [NSNumber numberWithFloat:oldRad];
	theAnimation.toValue=[NSNumber numberWithFloat:newRad];
	theAnimation.duration = 0.5f;
	[_compassNeedle.layer addAnimation:theAnimation forKey:@"animateMyRotation"];
	_compassNeedle.transform = CGAffineTransformMakeRotation(newRad);
	//NSLog(@"%f (%f) => %f (%f)", manager.heading.trueHeading, oldRad, newHeading.trueHeading, newRad);
    
    
    int headingDegree = newHeading.trueHeading - 90; // prepare for label
    
    if (headingDegree <= 0) {
        headingDegree = headingDegree + 360;  // remove negative numbers
    }
    
    
    compassLabel.text = [NSString stringWithFormat:@"%iº", headingDegree];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.2
}


NSTimer *rssiTimer;
UInt16 maxDepth = 0;

-(void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    btnConnect.titleLabel.font = [UIFont systemFontOfSize:39];
    [btnConnect setTitle:@"DIVE" forState:UIControlStateNormal];
    [bluetoothButton setAlpha:1.0f];
    [indConnecting stopAnimating];
    
    tempLabel.enabled = false;
    //RSSILabel.text = @"---";
    
    [rssiTimer invalidate];
}

-(void) bleDidUpdateRSSI:(NSNumber *)rssi
{
    //RSSILabel.text = rssi.stringValue;
}

-(void) readRSSITimer:(NSTimer *)timer
{
    [ble readRSSI];
}

-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    [btnConnect setAlpha:1.0f];
    [bluetoothButton setAlpha:1.0f];
    [indConnecting stopAnimating];
    
    [self startTimer];
    
    tempLabel.enabled = true;
    
    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

- (IBAction)endDive:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)startRecordingData:(id)sender {
    if (!dataCollectionTimer){
        _recordingDuration = 60;
        _currentMeasurementIndex++;
        dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readAndSaveData:) userInfo:nil repeats:YES];
        [btnConnect setTitle:@"60s" forState:UIControlStateNormal];
    }else{
        [dataCollectionTimer invalidate];
        dataCollectionTimer = nil;
        [btnConnect setTitle:@"DIVE" forState:UIControlStateNormal];
        [self uploadDataToCloud];
    }
}

- (void) readAndSaveData:(NSTimer*) timer{
    //this gets called every second so we will increment our timer, and save the data throughout this period.
    _recordingDuration--;
    if (_recordingDuration < 0){
        [dataCollectionTimer invalidate];
        dataCollectionTimer = nil;
        [btnConnect setTitle:@"DIVE" forState:UIControlStateNormal];
        [self uploadDataToCloud];
    }else{
        // here we save our data...
        [btnConnect setTitle:[NSString stringWithFormat:@"%is", _recordingDuration] forState:UIControlStateNormal];
        [self saveCurrentData];
    }
}

- (void) saveCurrentData{
    int temperature = [tempLabel.text intValue];
    int depth = [depthLabel.text intValue];
    int pressure = [pressureLabel.text intValue];
    
    NSDate *currentDate = [NSDate date];
    
    //Documetns
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //Diver Data
    NSString *diverDataFolder = [documentsDirectory stringByAppendingPathComponent:@"Diver Data"];
    [self checkIfFolderExists:diverDataFolder];
    
    //"Mission"
    NSString *missionFolder = [diverDataFolder stringByAppendingPathComponent:_missionName];
    [self checkIfFolderExists:missionFolder];
    
    //Dive #
    NSString *diveNumber;
    if (_currentDiveIndex < 10){
        diveNumber = [NSString stringWithFormat:@"00%lu", (unsigned long)_currentDiveIndex];
    }else{
        diveNumber = [NSString stringWithFormat:@"0%lu", (unsigned long)_currentDiveIndex];
    }
    NSString *diveIndexFolder = [missionFolder stringByAppendingPathComponent:diveNumber];
    [self checkIfFolderExists:diveIndexFolder];
    
    //Measurement #
    NSString *dataNumber;
    if (_currentMeasurementIndex < 10){
        dataNumber = [NSString stringWithFormat:@"00%lu", (unsigned long)_currentMeasurementIndex];
    }else{
        dataNumber = [NSString stringWithFormat:@"0%lu", (unsigned long)_currentMeasurementIndex];
    }
    NSString *dataIndexFolder = [diveIndexFolder stringByAppendingPathComponent:dataNumber];
    [self checkIfFolderExists:dataIndexFolder];
    
    
    //here we finally create the output path for our dictionary file
    NSArray *diverDataPointsList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataIndexFolder error:NULL];
    //the next index for the file#
    NSUInteger dataPointIndex = [diverDataPointsList count] + 1;
    
    NSString *dictionaryFileName;
    if (dataPointIndex < 10){
        dictionaryFileName = [NSString stringWithFormat:@"00%lu.plist", (unsigned long)dataPointIndex];
    }else{
        dictionaryFileName = [NSString stringWithFormat:@"0%lu.plist", (unsigned long)dataPointIndex];
    }
    
    NSString *outputFilePath = [dataIndexFolder stringByAppendingPathComponent:dictionaryFileName];
    
    NSDictionary* clipInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @(temperature),    @"temperature",
                                        @(pressure),       @"pressure",
                                        @(depth),          @"depth",
                                        currentDate,       @"date",
                                        0,                 @"pH",
                                        0,                 @"salinity",
                                        nil];
    
    [clipInfoDictionary writeToFile:outputFilePath atomically:NO];
}

- (void) uploadDataToCloud{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *diverDataFolder = [documentsDirectory stringByAppendingPathComponent:@"Diver Data"];
    NSString *missionFolder = [diverDataFolder stringByAppendingPathComponent:_missionName];
    NSString *diveNumber;
    if (_currentDiveIndex < 10){
        diveNumber = [NSString stringWithFormat:@"00%lu", (unsigned long)_currentDiveIndex];
    }else{
        diveNumber = [NSString stringWithFormat:@"0%lu", (unsigned long)_currentDiveIndex];
    }
    NSString *diveIndexFolder = [missionFolder stringByAppendingPathComponent:diveNumber];
    
    
    NSArray *diverMeasurementsList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:diveIndexFolder error:NULL];
    for (int i = 0; i < diverMeasurementsList.count; i++){
        
        NSString *currentMeasurementItem = [diverMeasurementsList objectAtIndex:i];
        NSString *measurementFolder = [diveIndexFolder stringByAppendingPathComponent:currentMeasurementItem];
        
        NSArray *diverDataPointsList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:measurementFolder error:NULL];
        
        for (int i = 1; i < diverDataPointsList.count; i++){
            NSString *currentDataPointItem = [diverDataPointsList objectAtIndex:i];
            NSString *dataPointPath = [measurementFolder stringByAppendingPathComponent:currentDataPointItem];
            
            NSDictionary *dictFromFile = [NSDictionary dictionaryWithContentsOfFile:dataPointPath];
            
            NSDate *date = [dictFromFile valueForKey:@"date"];
            int pH = [[dictFromFile valueForKey:@"pH"] intValue];
            int salinity = [[dictFromFile valueForKey:@"salinity"] intValue];
            int pressure = [[dictFromFile valueForKey:@"pressure"] intValue];
            int temperature = [[dictFromFile valueForKey:@"temperature"] intValue];
            int depth = [[dictFromFile valueForKey:@"depth"] intValue];


            PFObject *dataObject = [PFObject objectWithClassName:@"DiverData"];
            dataObject[@"timeOfDataCollection"] = date;
            dataObject[@"pH"] = @(pH);
            dataObject[@"salinity"] = @(salinity);
            dataObject[@"pressure"] = @(pressure);
            dataObject[@"depth"] = @(depth);
            dataObject[@"temperature"] = @(temperature);

            [dataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error){
                    //if there is no error then delete the data from the internal storage to free up memory
                    
                }else{
                    // there is an error...
                    NSLog(@"Error: %@", error);
                }
            }];
        }
        
        
    }
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
     //NSLog(@"Length: %d", length);
    
     for (int i = 0; i < length; i+=3)
     {
         //NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
         
         if (data[i] == TEMP)
         {
             UInt16 Value;
             
             Value = data[i+2] | data[i+1] << 8;
             tempLabel.text = [NSString stringWithFormat:@"%d", Value];
         }
         if (data[i] == DEPTH) {
             UInt16 Value2;
             
             Value2 = data[i+2] | data[i+1] << 8;
             depthLabel.text = [NSString stringWithFormat:@"%d", Value2];
             
             if (Value2 > maxDepth) {
                 maxDepth = Value2;
             }
             maxDepthLabel.text = [NSString stringWithFormat:@"%d", maxDepth];
         }
         if (data[i] == PRESSURE) {
             UInt16 Value3;
             
             Value3 = data[i+2] | data[i+1] << 8;
             pressureLabel.text = [NSString stringWithFormat:@"%d", Value3];
             
             if (Value3 <= 300 && j < 5) {
                 j++;
                 AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
             }
             
         }
     }
    
    if (maxDepth <= 35) {
        maxTime = 139*60;  // time in seconds
    }
    else if (maxDepth <= 40) {
        maxTime = 104*60;
    }
    else if (maxDepth <= 50) {
        maxTime = 63*60;
    }
    else if (maxDepth <= 60) {
        maxTime = 47*60;
    }
    else if (maxDepth <= 70) {
        maxTime = 33*60;
    }
    else if (maxDepth <= 80) {
        maxTime = 25*60;
    }
    else if (maxDepth <= 90) {
        maxTime = 21*60;
    }
    else if (maxDepth > 90) {
        maxTime = 3*60;
    }
    
}

#pragma mark - Actions

// Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender
{
    maxTime = 139*60;
    noDecoLabel.text = [[NSString alloc] initWithFormat:@"%d", 0];
    
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            btnConnect.titleLabel.font = [UIFont systemFontOfSize:39];
            [btnConnect setTitle:@"DIVE" forState:UIControlStateNormal];
            timerOn = NO;
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [btnConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    
    [bluetoothButton setAlpha:0.0f];
    [indConnecting setFrame:bluetoothButton.frame];
    [indConnecting setAlpha:1.0f];
    //[btnConnect setAlpha:0.0f];
    [indConnecting startAnimating];

}

-(void) connectionTimer:(NSTimer *)timer
{
    [btnConnect setEnabled:true];
    btnConnect.titleLabel.font = [UIFont systemFontOfSize:23];
    [btnConnect setTitle:@"DIVE" forState:UIControlStateNormal];
    timerOn = YES;
    timeTick = 0;
    maxDepth = 0;
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
         btnConnect.titleLabel.font = [UIFont systemFontOfSize:39];
        [btnConnect setTitle:@"DIVE" forState:UIControlStateNormal];
        timerOn = NO;
        [bluetoothButton setAlpha:1.0f];
        [indConnecting stopAnimating];
    }
}


- (void)startTimer {
    if (timerOn == YES) {
        //timerOn = YES;
        timeTick = 0;
    }
//    else if (timerOn == YES) {
//        timerOn = NO;
//    }
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    
}

-(void)tick{

    if (timerOn == YES) {
        timeTick++;
        
        int timeTickHours = timeTick / 3600;
        int timeTickMinutes = timeTick / 60 - 60 * timeTickHours;
        int timeTickSeconds =  timeTick % 60;
        NSString *timeTickHrLabel = [[NSString alloc] initWithFormat:@"%d", timeTickHours];
        NSString *timeTickMinLabel = [[NSString alloc] initWithFormat:@":%d", timeTickMinutes];
        NSString *timeTickSecLabel = [[NSString alloc] initWithFormat:@":%d", timeTickSeconds];
        NSString *timeTickLabelMinSec = [timeTickMinLabel stringByAppendingString:timeTickSecLabel];
        NSString *timeString = [timeTickHrLabel stringByAppendingString:timeTickLabelMinSec];

        timeLabel.text = timeString;
    }
    
    noDecoTime = maxTime - timeTick;
    
    int noDecoHours = noDecoTime / 3600;
    int noDecoMinutes = noDecoTime / 60 - 60 * noDecoHours;
    int noDecoSeconds = noDecoTime % 60;
    NSString *noDecoHrLabel = [[NSString alloc] initWithFormat:@"%d", noDecoHours];
    NSString *noDecoMinLabel = [[NSString alloc] initWithFormat:@":%d", noDecoMinutes];
    NSString *noDecoSecLabel = [[NSString alloc] initWithFormat:@":%d", noDecoSeconds];
    NSString *noDecoLabelMinSec = [noDecoMinLabel stringByAppendingString:noDecoSecLabel];
    NSString *noDecoLabelText = [noDecoHrLabel stringByAppendingString:noDecoLabelMinSec];
    
    noDecoLabel.text = noDecoLabelText;
    
    if (noDecoTime < 25 * 60 && k < 5) {
        k++;
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
    
}





- (IBAction)snapImage:(id)sender {
    
    moveButton.transform = CGAffineTransformMakeTranslation(-900, 0);
    
    
    if (!haveImage) {
        captureImage.image = nil; //remove old image from view
        captureImage.hidden = NO; //show the captured image view
        imagePreview.hidden = YES; //hide the live video feed
        [self capImage];
    }
    else {
        captureImage.hidden = YES;
        imagePreview.hidden = NO;
        haveImage = NO;
    }
    
}





//AVCaptureSession to show live video feed in view
- (void) initializeCamera {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetPhoto;
	
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
	captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    imagePreview.transform = CGAffineTransformMakeRotation(M_PI/2);
    
	[self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
	
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
	
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
	[session startRunning];
}




- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            [self processImage:[UIImage imageWithData:imageData]];
        }
    }];
}



- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
    haveImage = YES;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) { //Device is ipad
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(768, 1022));
        [image drawInRect: CGRectMake(0, 0, 768, 1022)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 130, 768, 768);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        //or use the UIImage wherever you like
        
        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];
        
        CGImageRelease(imageRef);
        
    }else{ //Device is iphone
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(320, 426));
        [image drawInRect: CGRectMake(0, 0, 320, 426)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGRect cropRect = CGRectMake(0, 55, 320, 320);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        
        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];
        captureImage.transform = CGAffineTransformMakeRotation(M_PI/2);
        UIImageWriteToSavedPhotosAlbum(captureImage.image, nil, nil, nil);
        CGImageRelease(imageRef);
    }
    
    //adjust image orientation based on device orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"landscape left image");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        NSLog(@"landscape right");
        
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"upside down");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        [UIView commitAnimations];
        
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        NSLog(@"upside upright");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }
}



@end





