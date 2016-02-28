//
//  GpsData.c
//  MoonRunner
//
//  Created by dong on 15/11/8.
//  Copyright © 2015年 dong. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dispatch/dispatch.h>
#include "GpsData.h"

static dispatch_queue_t queueGpsData;
static boolean_t bInit = false;

static GPS_DATA_t bufferGpsData[1];

void InitGpsDataDispatchQueue( void )
{
    memset( &bufferGpsData[0], 0, sizeof(bufferGpsData) );
    queueGpsData = dispatch_queue_create("com.dispatch.gps.serial", DISPATCH_QUEUE_SERIAL);
    bInit = true;
}

// typedef void (*dispatch_function_t)(void *);
static void PushGpsData( void *pThis )
{
    GPS_DATA_t *pData = (GPS_DATA_t*)pThis;
    
    memcpy( &bufferGpsData[0], pData, sizeof(GPS_DATA_t) );
}

static void PopGpsData( void *pThis )
{
    GPS_DATA_t *pData = (GPS_DATA_t*)pThis;
    
    memcpy( pData, &bufferGpsData[0], sizeof(GPS_DATA_t) );
}


void SetGpsData( GPS_DATA_t *pData )
{
    if( !bInit )
    {
        InitGpsDataDispatchQueue();
    }
    
    dispatch_sync_f( queueGpsData, pData, PushGpsData );
}

void GetGpsData( GPS_DATA_t *pData )
{
    if( !bInit )
    {
        InitGpsDataDispatchQueue();
    }

    dispatch_sync_f( queueGpsData, pData, PopGpsData );
}


