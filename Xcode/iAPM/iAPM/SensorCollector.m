//
//  SensorCollector.m
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#import "SensorCollector.h"
#import "CompassData.h"
#import "MicroTime.h"
#import "BaroData.h"
#import "AccelData.h"
#import "GyroData.h"

@interface SensorCollector()
{
    ViewController *mainViewController;
    
    CMMotionManager *motionManager;
    
    CMAltimeter *altMeter;
    NSOperationQueue *queueBarometer;
    
    NSOperationQueue *queueGyrometer;
    NSOperationQueue *queueAccelerometer;
    NSOperationQueue *queueMagnetometer;
    
    
    //CMMagneticField magnetField;
    //CMAltitudeData *altitudeData;
    
    BOOL bBarometerActive;
    BOOL bGyrometerActive;
    BOOL bAccelerometerActive;
}

@end


@implementation SensorCollector

-(BOOL)isAllSensorActive
{
    return bBarometerActive && bGyrometerActive && bAccelerometerActive;
}


-(void)magnetometerDataForAPM:(CMMagnetometerData *)magnetometerData
{
    COMPASS_DATA_t Data = {0};
    
    Data.healthy = true;
    Data.last_update = micros_time();
    Data.mag_x = magnetometerData.magneticField.x;
    Data.mag_y = magnetometerData.magneticField.y;
    Data.mag_z = magnetometerData.magneticField.z;

    SetCompassData( &Data );
    
    [mainViewController updateMagnetometer:magnetometerData];
}

-(void)altitudeDataForAPM:(CMAltitudeData *)altitudeData
{
    BARO_DATA_t Data = {0};
    
    // ToDo: How to figure out current temperature from iPhone ?
    Data._temperature = 25.0/100.0; // 0.01 C, Assume 25 C
    //1 hPa = 100 Pa = 1 mb 1 atm(大气压) = 101325 Pa(帕) = 1013.25 hPa(百帕) = 1013.25 mb(毫巴)
    // = 760 mmHg(毫米汞柱) 1 mmHg =4/3 hPa = 4/3 mb = 133.322 Pa 1 hPa = 1 mb = 3/4 mmhg
    // 1bar = 1000 mbar = 100 kPa
    // 1kPa = 10 mbar = 10hPa, 1 hPa = 1 mbar
    Data._pressure = [altitudeData.pressure floatValue];
    Data._pressure = (Data._pressure*10.0)*100.0;
    Data._last_update = micros_time()/1000;
    
    SetBaroData( &Data );
    
    [mainViewController updateAltitude:altitudeData];
}

-(void)accelerometerDataForAPM: (CMAccelerometerData *)accelerometerData
{
    ACCEL_DATA_t Data = {0};

    Data._timestamp = micros_time();
    Data.x = [accelerometerData acceleration].x;
    Data.y = [accelerometerData acceleration].y;
    Data.z = [accelerometerData acceleration].z;
    
    SetAccelData( &Data );
    
    [mainViewController updateAccel:accelerometerData];
}

-(void)gyroDataForAPM:(CMGyroData *)gyroData
{
    GYRO_DATA_t Data = {0};
    
    Data._timestamp = micros_time();
    Data.x = [gyroData rotationRate].x;
    Data.y = [gyroData rotationRate].y;
    Data.z = [gyroData rotationRate].z;
    
    SetGyroData( &Data );
    
    [mainViewController updateGyro:gyroData];
}

-(void)StartAllSensors:(ViewController*)viewController
{
    bBarometerActive = false;
    bGyrometerActive = false;
    bAccelerometerActive = false;
    
    mainViewController = viewController;
    
    motionManager = [[CMMotionManager alloc]init];
    
    // 1. Start Barometer for raw data
    if ([CMAltimeter isRelativeAltitudeAvailable])
    {
        CMAltitudeHandler AltitudeHandler = ^(CMAltitudeData *altitudeData, NSError *error)
        {
            bBarometerActive = true;
            [self altitudeDataForAPM: altitudeData];
        };
        
        altMeter = [[CMAltimeter alloc]init];
        //queueBarometer = [[NSOperationQueue alloc]init];
        [altMeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:AltitudeHandler];
    }
    
    // 2. Start gyro for raw data
    if ([motionManager isGyroAvailable])
    {
        CMGyroHandler GyroHandler = ^(CMGyroData *gyroData, NSError *error)
        {
            bGyrometerActive = true;
            [self gyroDataForAPM: gyroData];
        };
        
        motionManager.gyroUpdateInterval = 1/400; // 400HZ
        // ToDo: Too slow ...., any setting need to be done for NSOperationQueue created by myself ?
        //queueGyrometer = [[NSOperationQueue alloc]init];
        [motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:GyroHandler];
    }
    
    // 3. Start Accelerometer for raw data
    if ([motionManager isAccelerometerAvailable])
    {
        CMAccelerometerHandler AccelHandler = ^(CMAccelerometerData *accelerometerData, NSError *error)
        {
            bAccelerometerActive = true;
            [self accelerometerDataForAPM:accelerometerData];
        };
        
        motionManager.accelerometerUpdateInterval = 1/400; //400HZ
        //queueAccelerometer = [[NSOperationQueue alloc]init];
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:AccelHandler];
    }
    
/*
    // 4. Start Magnetometer for raw data
    //    It's difference from raw value for the geomagnetism measured in the x-axis.
    //    We should use value in CLHeading for APM.
    if ([motionManager isMagnetometerAvailable])
    {
        CMMagnetometerHandler MagnetHandler = ^(CMMagnetometerData *magnetometerData, NSError *error)
        {
            [self magnetometerDataForAPM: magnetometerData];
        };
        
        motionManager.magnetometerUpdateInterval = 1/400; //100HZ
        //queueMagnetometer = [[NSOperationQueue alloc]init];
        [motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:MagnetHandler];
    }
*/
    // 5. Start Motion update for
    // attitude, rotation rate, and acceleration
    if ([motionManager isDeviceMotionAvailable])
    {
        CMDeviceMotionHandler DeviceMotionHandler = ^(CMDeviceMotion * __nullable motion, NSError * __nullable error)
        {
            //...
            
            [mainViewController updateDeviceMotion:motion];
        };

        motionManager.deviceMotionUpdateInterval = 1/50; //50HZ
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:DeviceMotionHandler];
    }
}


-(void)StopAllSensors
{
    [altMeter stopRelativeAltitudeUpdates];
    [motionManager stopAccelerometerUpdates];
    [motionManager stopDeviceMotionUpdates];
    [motionManager stopMagnetometerUpdates];
    [motionManager stopGyroUpdates];
}

@end
