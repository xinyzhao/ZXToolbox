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

@interface ZXLocationManager ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) void (^statusBlock)(CLAuthorizationStatus status);

@end

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

#pragma mark Location Service

- (void)requestAuthorization:(void(^)(CLAuthorizationStatus status))completion {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                if (@available(iOS 8.0, *)) {
                    self.statusBlock = [completion copy];
                    //
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
            default:
                if (completion) {
                    completion(status);
                }
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (_statusBlock) {
        _statusBlock(status);
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // location
    self.location = [locations lastObject];
    // geocoder
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:_location completionHandler:^(NSArray *array, NSError *error){
        CLPlacemark *placemark = [array lastObject];
        if (placemark) {
            self.placemark = placemark;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        //
        if (self.didUpdateLocation) {
            self.didUpdateLocation(self.location, self.placemark);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}

@end

@implementation CLPlacemark (ZXLocationManager)

- (NSString *)province {
    return self.administrativeArea ? self.administrativeArea : self.locality;
}

- (NSString *)city {
    return self.locality;
}

- (NSString *)district {
    return self.subLocality;
}

- (NSString *)street {
    return self.thoroughfare;
}

- (NSString *)streetNumber {
    return self.subThoroughfare;
}

- (NSString *)address {
    return self.addressDictionary[@"FormattedAddressLines"];
}

@end
