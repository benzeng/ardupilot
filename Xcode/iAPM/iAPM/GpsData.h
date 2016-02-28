//
//  GpsData.h
//  MoonRunner
//
//  Created by dong on 15/11/8.
//  Copyright © 2015年 dong. All rights reserved.
//

#ifndef GpsData_h
#define GpsData_h
#include <sys/types.h>


/// Fix status codes
///
enum Fix_Status {
    FIX_NONE = 0,           ///< No fix
    FIX_2D = 2,             ///< 2d fix
    FIX_3D = 3,             ///< 3d fix
};

// Ref: APM/ardupilot/libraries/AP_GPS/GPS.h
// #define PACKED __attribute__((__packed__))
// struct PACKED ubx_nav_velned
#pragma pack(1)
typedef struct GPS_DATA
{
    uint32_t time_week_ms;              ///< GPS time (milliseconds from start of GPS week)
    uint16_t time_week;                 ///< GPS week number
    int32_t latitude;                   ///< latitude in degrees * 10,000,000
    int32_t longitude;                  ///< longitude in degrees * 10,000,000
    int32_t altitude_cm;                ///< altitude in cm
    uint32_t ground_speed_cm;           ///< ground speed in cm/sec
    int32_t ground_course_cd;           ///< ground course in 100ths of a degree
    int32_t speed_3d_cm;                ///< 3D speed in cm/sec (not always available)
    int16_t hdop;                       ///< horizontal dilution of precision in cm
    uint8_t num_sats;                   ///< Number of visible satelites

    // velocities in cm/s if available from the GPS
    int32_t _vel_north;
    int32_t _vel_east;
    int32_t _vel_down;
    
    enum Fix_Status fix;
    
}GPS_DATA_t;
#pragma pack()

extern void SetGpsData( GPS_DATA_t *pData );
extern void GetGpsData( GPS_DATA_t *pData );




#endif /* GpsData_h */
