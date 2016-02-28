//
//  GcsIP.c
//  TestAPM
//
//  Created by dong on 15/11/27.
//  Copyright © 2015年 dong. All rights reserved.
//

#include "GcsIP.h"

extern int gExitApmLoop;

static char _gcsIp[32] = {0};

void SetExitApmAppFlag(void)
{
    gExitApmLoop = 1;
}

void SetGcsIP( const char* gcsIP )
{
    strncpy( _gcsIp, gcsIP, sizeof(_gcsIp)-1 );
}

char* GetGcsIP( void )
{
    if( strlen(_gcsIp) == 0 )
        return "127.0.0.1";
    return _gcsIp;
}
