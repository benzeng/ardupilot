//
//  CompassData.c
//  TestAPM
//
//  Created by dong on 15/11/12.
//  Copyright © 2015年 dong. All rights reserved.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dispatch/dispatch.h>
#include "CompassData.h"



static dispatch_queue_t queueCompassData;
static boolean_t bInit = false;

static COMPASS_DATA_t bufferCompassData[1];

void InitCompassDataDispatchQueue( void )
{
    memset( &bufferCompassData[0], 0, sizeof(bufferCompassData) );
    queueCompassData = dispatch_queue_create("com.dispatch.compass.serial", DISPATCH_QUEUE_SERIAL);
    bInit = true;
}

// typedef void (*dispatch_function_t)(void *);
static void PushCompassData( void *pThis )
{
    COMPASS_DATA_t *pData = (COMPASS_DATA_t*)pThis;
    
    memcpy( &bufferCompassData[0], pData, sizeof(COMPASS_DATA_t) );
}

static void PopCompassData( void *pThis )
{
    COMPASS_DATA_t *pData = (COMPASS_DATA_t*)pThis;
    
    memcpy( pData, &bufferCompassData[0], sizeof(COMPASS_DATA_t) );
}


void SetCompassData( COMPASS_DATA_t *pData )
{
    if( !bInit )
    {
        InitCompassDataDispatchQueue();
    }
    
    dispatch_sync_f( queueCompassData, pData, PushCompassData );
}

void GetCompassData( COMPASS_DATA_t *pData )
{
    if( !bInit )
    {
        InitCompassDataDispatchQueue();
    }
    
    dispatch_sync_f( queueCompassData, pData, PopCompassData );
}
