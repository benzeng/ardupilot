//
//  GyroData.c
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dispatch/dispatch.h>
#include "GyroData.h"

static dispatch_queue_t queueGyroData;
static boolean_t bInit = false;

static GYRO_DATA_t bufferGyroData[1];

void InitGyroDataDispatchQueue( void )
{
    memset( &bufferGyroData[0], 0, sizeof(bufferGyroData) );
    queueGyroData = dispatch_queue_create("com.dispatch.gyro.serial", DISPATCH_QUEUE_SERIAL);
    bInit = true;
}

// typedef void (*dispatch_function_t)(void *);
static void PushGyroData( void *pThis )
{
    GYRO_DATA_t *pData = (GYRO_DATA_t*)pThis;
    
    memcpy( &bufferGyroData[0], pData, sizeof(GYRO_DATA_t) );
}

static void PopGyroData( void *pThis )
{
    GYRO_DATA_t *pData = (GYRO_DATA_t*)pThis;
    
    memcpy( pData, &bufferGyroData[0], sizeof(GYRO_DATA_t) );
}


void SetGyroData( GYRO_DATA_t *pData )
{
    if( !bInit )
    {
        InitGyroDataDispatchQueue();
    }

    dispatch_sync_f( queueGyroData, pData, PushGyroData );
}

void GetGyroData( GYRO_DATA_t *pData )
{
    if( !bInit )
    {
        InitGyroDataDispatchQueue();
    }
    
    dispatch_sync_f( queueGyroData, pData, PopGyroData );
}
