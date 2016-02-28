//
//  GyroData.h
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#ifndef GyroData_h
#define GyroData_h

#include <stdio.h>
#include <sys/types.h>

#pragma pack(1)
typedef struct GYRO_DATA
{
    uint64_t _timestamp;
    
    double x; // X-axis rotation rate in radians/second. The sign follows the right hand rule
    double y; // Y-axis rotation rate in radians/second. The sign follows the right hand rule
    double z; // Z-axis rotation rate in radians/second. The sign follows the right hand rule
    
}GYRO_DATA_t;
#pragma pack()

extern void SetGyroData( GYRO_DATA_t *pData );
extern void GetGyroData( GYRO_DATA_t *pData );


#endif /* GyroData_h */
