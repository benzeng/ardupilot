//
//  GpsCollector.m
//  TestAPM
//
//  Created by dong on 15/11/8.
//  Copyright © 2015年 dong. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <stdio.h>
#import "MicroTime.h"
#import "GpsCollector.h"
#import "GpsData.h"
#import "CompassData.h"

// anonymous category
@interface GpsCollector()<CLLocationManagerDelegate>
{
    ViewController *mainViewController;
}

@property int seconds;
@property float distance;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *timer;

@property CLLocationDirection currentHeading;
@property CLLocationDirection currentCourse;
@property CLLocationSpeed     currentSpeed;
@property (nonatomic, strong) CLLocation* lastLocation;

@end



@implementation GpsCollector

-(void) startGpsUpdate:(ViewController*)viewController
{
    mainViewController = viewController;
    
    self.seconds = 0;
    self.distance = 0;
    
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"CLLocationManager: Location Service is not enabled");
    }
    
    // Create the location manager if this object does not already have one.
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc]init];
    }
    
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // Movement threshold for new events
    self.locationManager.distanceFilter = 1; // meters
    
    // degrees, will be notified of all heading updates.
    self.locationManager.headingFilter = kCLHeadingFilterNone;
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    if( authStatus ==  kCLAuthorizationStatusRestricted ||
       authStatus == kCLAuthorizationStatusDenied ||
       authStatus == kCLAuthorizationStatusNotDetermined )
        [self.locationManager requestWhenInUseAuthorization];
    
    // Debug: check status again
    authStatus = [CLLocationManager authorizationStatus];
    
    [self.locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable])
    {
        [self.locationManager startUpdatingHeading];
    }

}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *newLocation in locations)
    {
        //NSDate *eventDate = newLocation.timestamp;
        
        //NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        //if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20)
        {
            // update distance
            if (self.lastLocation != nil )
            {
                self.distance += [newLocation distanceFromLocation:self.lastLocation];
            }
            self.lastLocation = newLocation;
            
            
            // using dispatch_async_f, we should allocate a object
            // and will be freed when finished in PushGpsData.
            GPS_DATA_t Data = {0};
            
            // Collect GPS information
            Data.longitude = newLocation.coordinate.longitude * 10000000;
            Data.latitude = newLocation.coordinate.latitude * 10000000;
            Data.ground_speed_cm = newLocation.speed * 100;       // ground speed in cm/sec
            Data.ground_course_cd = newLocation.course * 100;     // ground course in 100ths of a degree
            Data.altitude_cm = newLocation.altitude * 100;        // altitude in cm
            
            if( newLocation.speed  < 0 )
                Data.ground_speed_cm = 0;
            if( newLocation.course < 0 )
                Data.ground_course_cd = 0;
            
            
            // Pass GPS data into APM flight controller
            //if( newLocation.speed > 0 && newLocation.course > 0 )
                Data.fix = FIX_3D;
            
            //NSData *gpsData = [NSData dataWithBytes:&Data length:sizeof(Data)];
            //SetGpsData( (GPS_DATA_t*)[gpsData bytes] );
            SetGpsData( &Data );
        }
    }
    
    self.lastLocation = [locations lastObject];
    self.currentCourse = [(CLLocation *)[locations lastObject] course];
    self.currentSpeed = [(CLLocation *)[locations lastObject] speed];
    
    // Update UI
    [mainViewController updateLocation:self.lastLocation];
}


/**
 NOTE:
 If location updates are also enabled, the location manager returns both true heading 
 and magnetic heading values. If location updates are not enabled, or the location of 
 the device is not yet known, the location manager returns only the magnetic heading 
 value and the true heading value returned by this call will be −1.
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    self.currentHeading = theHeading;
    //[self updateHeadingDisplays];
    
    COMPASS_DATA_t Data = {0};
    
    Data.healthy = true;
    Data.last_update = micros_time();
    Data.mag_x = newHeading.x;
    Data.mag_y = newHeading.y;
    Data.mag_z = newHeading.z;
    Data.magneticHeading = newHeading.magneticHeading;
    Data.trueHeading = newHeading.trueHeading;
    
    SetCompassData( &Data );

    [mainViewController updateHeading:newHeading];
}

// If calibrate heading is needed return YES
-(BOOL) locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    // You can call [manager dismissHeadingCalibrationDisplay] to cancel the calibration process
    return NO;
}

@end
