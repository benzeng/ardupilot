//
//  ViewController.h
//  TestAPM
//
//  Created by dong on 15/10/30.
//  Copyright © 2015年 dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController

-(void)updateHeading:(CLHeading *)newHeading;
-(void)updateLocation:(CLLocation *)newLocation;
-(void)updateGyro:(CMGyroData *)gyroData;
-(void)updateAccel:(CMAccelerometerData *)accelerometerData;
-(void)updateAltitude:(CMAltitudeData *)altitudeData;
-(void)updateDeviceMotion: (CMDeviceMotion *)motion;
-(void)updateMagnetometer:(CMMagnetometerData *)magnetometerData;
@end

