//
//  BaroData.h
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#ifndef BaroData_h
#define BaroData_h

#include <stdio.h>
#include <sys/types.h>

#pragma pack(1)
typedef struct BARO_DATA
{
    uint32_t _last_update;
    float _temperature;
    float _pressure;
    
}BARO_DATA_t;
#pragma pack()

extern void SetBaroData( BARO_DATA_t *pData );
extern void GetBaroData( BARO_DATA_t *pData );


#endif /* BaroData_h */
