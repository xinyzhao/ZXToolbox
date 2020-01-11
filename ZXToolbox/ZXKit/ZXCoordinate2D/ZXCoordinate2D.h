//
// ZXCoordinate2D.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2020 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#ifndef ZXCOORDINATE2D_H
#define ZXCOORDINATE2D_H

#include <stdio.h>
#include <stdbool.h>

#ifdef __cplusplus
#define ZXC2D_EXTERN        extern "C" __attribute__((visibility ("default")))
#else
#define ZXC2D_EXTERN        extern __attribute__((visibility ("default")))
#endif

/// Earth radius
#define kEarthRadiusMeters          6378137.f
/// Equatorial radius of earth
#define kEquatorialRadiusKilometers (kEarthRadiusMeters / 1000.f)
/// Latitudes per kilometer
#define kLatitudesPerKilometer      ((kEquatorialRadiusKilometers * M_PI) / 180.f)
/// Latitudes of meters
#define latitudesOfMeters(m)        ((m / 1000.f) / kLatitudesPerKilometer)
/// Longitudes of meters
#define longitudesOfMeters(m, lat)  (cos(lat) * latitudesOfMeters(m))

/**
 A structure that contains a geographical coordinate.
 
 Fields:
   latitude: The latitude in degrees.
   longitude: The longitude in degrees.
 */
struct ZXCoordinate2D {
    union {
        double lat;
        double latitude;
    };
    union {
        double lng;
        double longitude;
    };
};
typedef struct ZXCoordinate2D ZXCoordinate2D;

/// Returns a new ZXCoordinate2D at the given latitude and longitude
/// @param lat latitude
/// @param lng longitude
/// @return The ZXCoordinate2D
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DMake(double lat, double lng);

/// Transform WGS-84 coordinate of world to GCJ-02 coordinate of china
/// @param world The WGS-84 coordinate of world
/// @return The GCJ-02 coordinate of china
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DWorldToChina(ZXCoordinate2D world);

/// Transform GCJ-02 coordinate of china to WGS-84 coordinate of world
/// @param china The GCJ-02 coordinate of china
/// @return The WGS-84 coordinate of world
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DChinaToWorld(ZXCoordinate2D china);

/// Transform GCJ-02 coordinate of china to BD-09 coordinate of baidu
/// @param china The GCJ-02 coordinate of china
/// @return The BD-09 coordinate of baidu
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DChinaToBaidu(ZXCoordinate2D china);

/// Transform BD-09 coordinate of baidu to GCJ-02 coordinate of china
/// @param baidu The BD-09 coordinate of baidu
/// @return The GCJ-02 coordinate of china
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DBaiduToChina(ZXCoordinate2D baidu);

/// Transform WGS-84 coordinate of world to BD-09 coordinate of baidu
/// @param world The WGS-84 coordinate of world
/// @return The BD-09 coordinate of baidu
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DWorldToBaidu(ZXCoordinate2D world);

/// Transform BD-09 coordinate of baidu to WGS-84 coordinate of world
/// @param baidu The BD-09 coordinate of baidu
/// @return The WGS-84 coordinate of world
ZXC2D_EXTERN ZXCoordinate2D ZXCoordinate2DBaiduToWorld(ZXCoordinate2D baidu);

/// Determine whether the coordinates are outside China
/// @param coord The coordinate
/// @return True be out of china.
ZXC2D_EXTERN bool ZXCoordinate2DOutOfChina(ZXCoordinate2D coord);

/// Distance calculate the distance between coordinate a and b, unit in meter.
/// @param a The coordinate a
/// @param b The coordinate b
/// @return The distance between two coordinates in meters.
ZXC2D_EXTERN double ZXCoordinate2DDistanceMeters(ZXCoordinate2D a, ZXCoordinate2D b);

#endif /* ZXCOORDINATE2D_H */
