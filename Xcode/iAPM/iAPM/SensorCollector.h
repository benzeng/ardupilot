//
//  SensorCollector.h
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ViewController.h"


@interface SensorCollector : NSObject

-(void)StartAllSensors:(ViewController*)viewController;

-(void)StopAllSensors;

-(BOOL)isAllSensorActive;

@end
