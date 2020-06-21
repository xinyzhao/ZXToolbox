//
// ZXCoordinate2D.m
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

#include "ZXCoordinate2D.h"
#include <math.h>

double const X_EE = 0.00669342162296594323;

double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

ZXCoordinate2D ZXCoordinate2DMake(double lat, double lng)
{
    ZXCoordinate2D coord;
    coord.latitude = lat;
    coord.longitude = lng;
    return coord;
}

ZXCoordinate2D ZXCoordinate2DWorldToChina(ZXCoordinate2D world)
{
    if (ZXCoordinate2DOutOfChina(world)) {
        return world;
    }
    ZXCoordinate2D coord = world;
    coord.latitude = transformLat(world.longitude - 105.0, world.latitude - 35.0);
    coord.longitude = transformLon(world.longitude - 105.0, world.latitude - 35.0);
    double radLat = world.latitude / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - X_EE * magic * magic;
    double sqrtMagic = sqrt(magic);
    coord.latitude = (coord.latitude * 180.0) / ((kEarthRadiusMeters * (1 - X_EE)) / (magic * sqrtMagic) * M_PI);
    coord.longitude = (coord.longitude * 180.0) / (kEarthRadiusMeters / sqrtMagic * cos(radLat) * M_PI);
    coord.latitude += world.latitude;
    coord.longitude += world.longitude;
    return coord;
}

ZXCoordinate2D ZXCoordinate2DChinaToWorld(ZXCoordinate2D china)
{
    if (ZXCoordinate2DOutOfChina(china)) {
        return china;
    }
    ZXCoordinate2D coord = ZXCoordinate2DWorldToChina(china);
    coord.latitude -= china.latitude;
    coord.longitude -= china.longitude;
    coord.latitude = china.latitude - coord.latitude;
    coord.longitude = china.longitude - coord.longitude;
    return coord;
}

ZXCoordinate2D ZXCoordinate2DChinaToBaidu(ZXCoordinate2D china)
{
    if (ZXCoordinate2DOutOfChina(china)) {
        return china;
    }
    double x = china.longitude;
    double y = china.latitude;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    double lat = z * sin(theta) + 0.006;
    double lng = z * cos(theta) + 0.0065;
    return ZXCoordinate2DMake(lat, lng);
}

ZXCoordinate2D ZXCoordinate2DBaiduToChina(ZXCoordinate2D baidu)
{
    if (ZXCoordinate2DOutOfChina(baidu)) {
        return baidu;
    }
    double x = baidu.longitude - 0.0065;
    double y = baidu.latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    double lat = z * sin(theta);
    double lng = z * cos(theta);
    return ZXCoordinate2DMake(lat, lng);
}

ZXCoordinate2D ZXCoordinate2DWorldToBaidu(ZXCoordinate2D world)
{
    if (ZXCoordinate2DOutOfChina(world)) {
        return world;
    }
    ZXCoordinate2D coord = ZXCoordinate2DWorldToChina(world);
    return ZXCoordinate2DChinaToBaidu(coord);
}

ZXCoordinate2D ZXCoordinate2DBaiduToWorld(ZXCoordinate2D baidu)
{
    if (ZXCoordinate2DOutOfChina(baidu)) {
        return baidu;
    }
    ZXCoordinate2D coord = ZXCoordinate2DBaiduToChina(baidu);
    return ZXCoordinate2DChinaToWorld(coord);
}

bool ZXCoordinate2DOutOfChina(ZXCoordinate2D coord)
{
    if (coord.longitude < 72.004 || coord.longitude > 137.8347) {
        return true;
    }
    if (coord.latitude < 0.8293 || coord.latitude > 55.8271) {
        return true;
    }
    return false;
}

double ZXCoordinate2DDistanceMeters(ZXCoordinate2D a, ZXCoordinate2D b) {
    double arcA = a.lat * M_PI / 180.0;
    double arcB = b.lat * M_PI / 180.0;
    double x = cos(arcA) * cos(arcB) * cos((a.lng - b.lng) * M_PI / 180.0);
    double y = sin(arcA) * sin(arcB);
    double z = x + y;
    if (z > 1.0) {
        z = 1.0;
    } else if (z < -1.0) {
        z = -1.0;
    }
    return acos(z) * kEarthRadiusMeters;
}
