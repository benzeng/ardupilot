//
//  MicroTime.c
//  TestAPM
//
//  Created by dong on 15/11/12.
//  Copyright © 2015年 dong. All rights reserved.
//
#include <mach/mach_time.h>
#include <inttypes.h>
#include "MicroTime.h"
#include <dispatch/dispatch.h>

typedef uint64_t	hrt_abstime;
static hrt_abstime px4_timestart = 0;
static double px4_timebase = 0.0;

static dispatch_queue_t queueGetMicros;
static bool bInit = false;


static void GetMicros( void *pValue )
{
    uint32_t *pnMicors = (uint32_t*)pValue;
    
    if (!px4_timestart)
    {
        mach_timebase_info_data_t tb = { 0 };
        mach_timebase_info(&tb);
        px4_timebase = tb.numer;
        px4_timebase /= tb.denom;
        px4_timestart = mach_absolute_time();
    }
    
    *pnMicors = (uint32_t)((mach_absolute_time()-px4_timestart)*px4_timebase/1000);
}

// 1/(1000*1000) second(usec)
uint32_t micros_time( void )
{
    uint32_t nMicors = 0;
    
    if (!bInit)
    {
        queueGetMicros = dispatch_queue_create("com.dispatch.micors.serial", DISPATCH_QUEUE_SERIAL);
        bInit = true;
    }
    
    dispatch_sync_f( queueGetMicros, &nMicors, GetMicros );
    return nMicors;
    
//    if (!px4_timestart)
//    {
//        mach_timebase_info_data_t tb = { 0 };
//        mach_timebase_info(&tb);
//        px4_timebase = tb.numer;
//        px4_timebase /= tb.denom;
//        px4_timestart = mach_absolute_time();
//    }
//    
//    return (uint32_t)((mach_absolute_time()-px4_timestart)*px4_timebase/1000);
}