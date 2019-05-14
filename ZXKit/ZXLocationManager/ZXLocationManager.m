//
// ZXLocationManager.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
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

#import "ZXLocationManager.h"

@implementation ZXLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (NSString *)province {
    return _placemark.administrativeArea ? _placemark.administrativeArea : _placemark.locality;
}

#pragma mark Location Service

- (void)requestAuthorization:(void(^)(CLAuthorizationStatus status))completion {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                if (@available(iOS 8.0, *)) {
                    if (_alwaysAuthorization) {
                        [self.locationManager requestAlwaysAuthorization];
                    } else {
                        [self.locationManager requestWhenInUseAuthorization];
                    }
                } else {
                    if (completion) {
                        completion(status);
                    }
                }
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                if (completion) {
                    completion(status);
                }
                break;
            default:
                break;
        }
    }
}

- (void)requestLocation {
    [self requestAuthorization:^(CLAuthorizationStatus status) {
        if (status == kCLAuthorizationStatusAuthorizedAlways ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.locationManager requestLocation];
        }
    }];
}

- (void)startUpdatingLocation {
    [self requestAuthorization:^(CLAuthorizationStatus status) {
        if (status == kCLAuthorizationStatusAuthorizedAlways ||
            status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [self.locationManager startUpdatingLocation];
        }
    }];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // location
    _location = [locations firstObject];
    // geocoder
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:_location completionHandler:^(NSArray *array, NSError *error){
        CLPlacemark *placemark = [array firstObject];
        if (placemark) {
            [self setValue:placemark forKey:@"placemark"];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        //
        if (self.didUpdateLocation) {
            self.didUpdateLocation(self.location, self.placemark, self.province);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
        default:
            break;
    }
}

@end