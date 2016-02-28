//
//  BaroData.c
//  TestAPM
//
//  Created by dong on 15/11/14.
//  Copyright © 2015年 dong. All rights reserved.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dispatch/dispatch.h>
#include "BaroData.h"

static dispatch_queue_t queueBaroData;
static boolean_t bInit = false;

static BARO_DATA_t bufferBaroData[1];

void InitBaroDataDispatchQueue( void )
{
    memset( &bufferBaroData[0], 0, sizeof(bufferBaroData) );
    queueBaroData = dispatch_queue_create("com.dispatch.baro.serial", DISPATCH_QUEUE_SERIAL);
    bInit = true;
}

// typedef void (*dispatch_function_t)(void *);
static void PushBaroData( void *pThis )
{
    BARO_DATA_t *pData = (BARO_DATA_t*)pThis;
    
    memcpy( &bufferBaroData[0], pData, sizeof(BARO_DATA_t) );
}

static void PopBaroData( void *pThis )
{
    BARO_DATA_t *pData = (BARO_DATA_t*)pThis;
    
    memcpy( pData, &bufferBaroData[0], sizeof(BARO_DATA_t) );
}


void SetBaroData( BARO_DATA_t *pData )
{
    if( !bInit )
    {
        InitBaroDataDispatchQueue();
    }

    dispatch_sync_f( queueBaroData, pData, PushBaroData );
}

void GetBaroData( BARO_DATA_t *pData )
{
    if( !bInit )
    {
        InitBaroDataDispatchQueue();
    }
    
    dispatch_sync_f( queueBaroData, pData, PopBaroData );
}