//
//  CompassData.h
//  TestAPM
//
//  Created by dong on 15/11/12.
//  Copyright © 2015年 dong. All rights reserved.
//

#ifndef CompassData_h
#define CompassData_h

#include <stdio.h>
#include <sys/types.h>

#ifndef bool
typedef unsigned char bool;
#endif

#pragma pack(1)
typedef struct COMPASS_DATA
{
    int16_t mag_x;                      ///< magnetic field strength along the X axis
    int16_t mag_y;                      ///< magnetic field strength along the Y axis
    int16_t mag_z;                      ///< magnetic field strength along the Z axis
    uint32_t last_update;               ///< micros() time of last update
    bool healthy;                       ///< true if last read OK
    
    double magneticHeading;
    double trueHeading;
    
}COMPASS_DATA_t;
#pragma pack()


extern void SetCompassData( COMPASS_DATA_t *pData );
extern void GetCompassData( COMPASS_DATA_t *pData );

#endif /* CompassData_h */
