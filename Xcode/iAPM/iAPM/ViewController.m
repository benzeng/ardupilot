//
//  ViewController.m
//  TestAPM
//
//  Created by dong on 15/10/30.
//  Copyright © 2015年 dong. All rights reserved.
//

#import "ViewController.h"

#import "GpsCollector.h"
#import "SensorCollector.h"
#import "GcsIP.h"

#include <pthread.h>
#include <assert.h>

extern  int apm_main (void);
extern void TestUdpSocket( void );
extern void InitGpsDataDispatchQueue( void );
extern void InitCompassDataDispatchQueue( void );
extern void InitBaroDataDispatchQueue( void );
extern void InitAccelDataDispatchQueue( void );


static BOOL apmExited = FALSE;
static void* PosixThreadMainRoutine(void* data)
{
    //TestUdpSocket();
    apm_main();
    
    apmExited = TRUE;
    return NULL;
}



static void LaunchAPMThread()
{
    // Create the thread using POSIX routines.
    pthread_attr_t  attr;
    pthread_t       posixThreadID;
    int             returnVal;
    
    returnVal = pthread_attr_init(&attr);
    assert(!returnVal);
    returnVal = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    assert(!returnVal);
    
    apmExited = FALSE;
    int     threadError = pthread_create(&posixThreadID, &attr, &PosixThreadMainRoutine, NULL);
    
    returnVal = pthread_attr_destroy(&attr);
    assert(!returnVal);
    if (threadError != 0)
    {
        // Report an error.
    }
}




@interface ViewController ()
{
    GpsCollector *gpsCollector;
    SensorCollector *sensorCollector;
}

@property (weak, nonatomic) IBOutlet UILabel *magLabelX;
@property (weak, nonatomic) IBOutlet UILabel *magLabelY;
@property (weak, nonatomic) IBOutlet UILabel *magLabelZ;

@property (weak, nonatomic) IBOutlet UILabel *headingLabelX;
@property (weak, nonatomic) IBOutlet UILabel *headingLabelY;
@property (weak, nonatomic) IBOutlet UILabel *headingLabelZ;


@property (weak, nonatomic) IBOutlet UIImageView *magIamge;
@property (weak, nonatomic) IBOutlet UILabel *trueHeadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *magHeadingLabel;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gpsVelLabel;
@property (weak, nonatomic) IBOutlet UILabel *gpsAltitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gpsCourseLabel;

@property (weak, nonatomic) IBOutlet UILabel *gyroLabelX;
@property (weak, nonatomic) IBOutlet UILabel *gyroLabelY;
@property (weak, nonatomic) IBOutlet UILabel *gyroLabelZ;

@property (weak, nonatomic) IBOutlet UILabel *accelLabelX;
@property (weak, nonatomic) IBOutlet UILabel *accelLabelY;
@property (weak, nonatomic) IBOutlet UILabel *accelLabelZ;

@property (weak, nonatomic) IBOutlet UILabel *pitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *rollLabel;
@property (weak, nonatomic) IBOutlet UILabel *yawLabel;

@property (weak, nonatomic) IBOutlet UILabel *gravityLabelX;
@property (weak, nonatomic) IBOutlet UILabel *gravityLabelY;
@property (weak, nonatomic) IBOutlet UILabel *gravityLabelZ;

@property (weak, nonatomic) IBOutlet UILabel *pressurelLabel;

- (IBAction)actionSetGcsIP:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *editGcsIP;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    InitGpsDataDispatchQueue();
    InitCompassDataDispatchQueue();
    InitBaroDataDispatchQueue();
    InitAccelDataDispatchQueue();
    
    gpsCollector = [[GpsCollector alloc] init];
    [gpsCollector startGpsUpdate:self];
    
    sensorCollector = [[SensorCollector alloc] init];
    [sensorCollector StartAllSensors:self];
    
    
    // Wait for all sensor ready before start APM thread
    dispatch_block_t block = ^{
        while( ![sensorCollector isAllSensorActive] )
        {
            usleep(1000);
        }
        LaunchAPMThread();
    };
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, block);
}

/*
 Even if you've done everything correctly, in a large iOS app, you may simply run out of memory. 
 When that situation occurs, the system dispatches a low-memory notification to your app — and it’s 
 something you must pay attention to. If you don’t, it’s a reliable recipe for disaster. UIKit 
 provides several ways for you to set up your app so that you receive timely low-memory notifications:
 
 1. Override the didReceiveMemoryWarning methods in your custom UIViwComtroller subclass.
 
 2. Implement the applicationDidReceiveMemoryWarning: method of your application delegate.
 
 3. Register to receive the UIApplicationDidReceiveMemoryWarningNotification: notification.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"Warning: didReceiveMemoryWarning get called");
    
    /*
     [[NSNotificationCenter defaultCenter] addObserverForName:
     UIApplicationDidReceiveMemoryWarningNotification
     object:[UIApplication sharedApplication] queue:nil
     usingBlock:^(NSNotification *notif) {
     //your code here
     }];
     */
}

-(void)updateHeading:(CLHeading *)newHeading
{
    self.headingLabelX.text = [NSString stringWithFormat:@"%.2f", newHeading.x];
    self.headingLabelY.text = [NSString stringWithFormat:@"%.2f", newHeading.y];
    self.headingLabelZ.text = [NSString stringWithFormat:@"%.2f", newHeading.z];
    
    self.trueHeadingLabel.text = [NSString stringWithFormat:@"%.2f", newHeading.trueHeading];
    self.magHeadingLabel.text = [NSString stringWithFormat:@"%.2f", newHeading.magneticHeading];
    
    float heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
    self.magIamge.transform = CGAffineTransformMakeRotation(heading);
}

-(void)updateLocation:(CLLocation *)newLocation
{
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.2f", newLocation.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.2f", newLocation.coordinate.longitude];
    self.gpsVelLabel.text = [NSString stringWithFormat:@"%.2f", newLocation.speed];
    self.gpsAltitudeLabel.text = [NSString stringWithFormat:@"%.2f", newLocation.altitude];
    self.gpsCourseLabel.text = [NSString stringWithFormat:@"%.2f", newLocation.course];
}

-(void)updateGyro:(CMGyroData *)gyroData
{
    self.gyroLabelX.text = [NSString stringWithFormat:@"%f", [gyroData rotationRate].x];
    self.gyroLabelY.text = [NSString stringWithFormat:@"%f", [gyroData rotationRate].y];
    self.gyroLabelZ.text = [NSString stringWithFormat:@"%f", [gyroData rotationRate].z];
}

-(void)updateAccel:(CMAccelerometerData *)accelerometerData
{
    self.accelLabelX.text = [NSString stringWithFormat:@"%f", [accelerometerData acceleration].x];
    self.accelLabelY.text = [NSString stringWithFormat:@"%f", [accelerometerData acceleration].y];
    self.accelLabelZ.text = [NSString stringWithFormat:@"%f", [accelerometerData acceleration].z];
}

-(void)updateAltitude:(CMAltitudeData *)altitudeData
{
    self.pressurelLabel.text = [NSString stringWithFormat:@"%f",  [altitudeData.pressure floatValue]];
}

-(void)updateDeviceMotion: (CMDeviceMotion *)motion
{
    self.rollLabel.text = [NSString stringWithFormat:@"%.2f", motion.attitude.roll];
    self.pitchLabel.text = [NSString stringWithFormat:@"%.2f", motion.attitude.pitch];
    self.yawLabel.text = [NSString stringWithFormat:@"%.2f", motion.attitude.yaw];
    
    self.gravityLabelX.text = [NSString stringWithFormat:@"%.2f", motion.gravity.x];
    self.gravityLabelY.text = [NSString stringWithFormat:@"%.2f", motion.gravity.y];
    self.gravityLabelZ.text = [NSString stringWithFormat:@"%.2f", motion.gravity.z];
}

-(void)updateMagnetometer:(CMMagnetometerData *)magnetometerData
{
    self.magLabelX.text = [NSString stringWithFormat:@"%.2f", magnetometerData.magneticField.x];
    self.magLabelY.text = [NSString stringWithFormat:@"%.2f", magnetometerData.magneticField.x];
    self.magLabelZ.text = [NSString stringWithFormat:@"%.2f", magnetometerData.magneticField.x];
}

void SetExitApmAppFlag(void);
- (IBAction)actionSetGcsIP:(id)sender
{
    NSString *gcsIP = self.editGcsIP.text;
    SetGcsIP( [gcsIP UTF8String] );
    
    SetExitApmAppFlag();
    
    // Wait for APM thread exit
    dispatch_block_t block = ^{
        while( !apmExited )
        {
            usleep(1000);
        }
        LaunchAPMThread();
    };
    dispatch_queue_t globalConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalConcurrentQueue, block);
}
@end
