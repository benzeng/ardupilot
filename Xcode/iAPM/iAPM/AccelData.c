//
//  AccelData.c
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dispatch/dispatch.h>
#include "AccelData.h"

static dispatch_queue_t queueAccelData;
static boolean_t bInit = false;

static ACCEL_DATA_t bufferAccelData[1];

void InitAccelDataDispatchQueue( void )
{
    memset( &bufferAccelData[0], 0, sizeof(bufferAccelData) );
    queueAccelData = dispatch_queue_create("com.dispatch.accel.serial", DISPATCH_QUEUE_SERIAL);
    bInit = true;
}

// typedef void (*dispatch_function_t)(void *);
static void PushAccelData( void *pThis )
{
    ACCEL_DATA_t *pData = (ACCEL_DATA_t*)pThis;
    
    memcpy( &bufferAccelData[0], pData, sizeof(ACCEL_DATA_t) );
}

static void PopAccelData( void *pThis )
{
    ACCEL_DATA_t *pData = (ACCEL_DATA_t*)pThis;
    
    memcpy( pData, &bufferAccelData[0], sizeof(ACCEL_DATA_t) );
}


void SetAccelData( ACCEL_DATA_t *pData )
{
    if( !bInit )
    {
        InitAccelDataDispatchQueue();
    }
    
    dispatch_sync_f( queueAccelData, pData, PushAccelData );
}

void GetAccelData( ACCEL_DATA_t *pData )
{
    if( !bInit )
    {
        InitAccelDataDispatchQueue();
    }
    
    dispatch_sync_f( queueAccelData, pData, PopAccelData );
}
