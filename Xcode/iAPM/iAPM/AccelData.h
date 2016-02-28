//
//  AccelData.h
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#ifndef AccelData_h
#define AccelData_h

#include <stdio.h>
#include <sys/types.h>

#pragma pack(1)
typedef struct ACCEL_DATA
{
    uint64_t _timestamp;

    double x; //X-axis acceleration in G's.
    double y; //Y-axis acceleration in G's.
    double z; //Z-axis acceleration in G's.
    
}ACCEL_DATA_t;
#pragma pack()

extern void SetAccelData( ACCEL_DATA_t *pData );
extern void GetAccelData( ACCEL_DATA_t *pData );

#endif /* AccelData_h */
