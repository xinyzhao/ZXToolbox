//
// ZXNetworkTrafficMonitor.m
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

#import "ZXNetworkTrafficMonitor.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

@interface ZXNetworkTrafficData : NSObject
@property (nonatomic, assign) int64_t WiFiSent;
@property (nonatomic, assign) int64_t WiFiReceived;
@property (nonatomic, assign) int64_t WWANSent;
@property (nonatomic, assign) int64_t WWANReceived;

@end

@implementation ZXNetworkTrafficData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _WiFiSent = 0;
        _WiFiReceived = 0;
        _WWANSent = 0;
        _WWANReceived = 0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ZXNetworkTrafficData *obj = [[[self class] allocWithZone:zone] init];
    obj.WiFiSent = _WiFiSent;
    obj.WiFiReceived = _WiFiReceived;
    obj.WWANSent = _WWANSent;
    obj.WWANReceived = _WWANReceived;
    return obj;
}

@end

@interface ZXNetworkTrafficMonitor ()
@property (nonatomic, copy) void(^trafficBlock)(ZXNetworkTrafficModel *WiFiSent, ZXNetworkTrafficModel *WiFiReceived, ZXNetworkTrafficModel *WWANSent, ZXNetworkTrafficModel *WWANReceived);

@property (nonatomic, strong) ZXNetworkTrafficData *trafficData;
@property (nonatomic, strong) NSTimer *trafficTimer;
@property (nonatomic, assign) int64_t trafficTimes;

@property (nonatomic, strong) ZXNetworkTrafficModel *WiFiSent;
@property (nonatomic, strong) ZXNetworkTrafficModel *WiFiReceived;
@property (nonatomic, strong) ZXNetworkTrafficModel *WWANSent;
@property (nonatomic, strong) ZXNetworkTrafficModel *WWANReceived;

@end

@implementation ZXNetworkTrafficMonitor

- (void)startMonitoring:(NSTimeInterval)timeInterval
                traffic:(void(^)(ZXNetworkTrafficModel *WiFiSent, ZXNetworkTrafficModel *WiFiReceived, ZXNetworkTrafficModel *WWANSent, ZXNetworkTrafficModel *WWANReceived))trafficBlock {
    if (!self.isMonitoring) {
        _trafficBlock = [trafficBlock copy];
        _trafficTimes = 0;
        //
        _WiFiSent = [[ZXNetworkTrafficModel alloc] init];
        _WiFiReceived = [[ZXNetworkTrafficModel alloc] init];
        _WWANSent = [[ZXNetworkTrafficModel alloc] init];
        _WWANReceived = [[ZXNetworkTrafficModel alloc] init];
        //
        self.trafficTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.trafficTimer forMode:NSRunLoopCommonModes];
        [self.trafficTimer fire];
    }
}

- (BOOL)isMonitoring {
    return [self.trafficTimer isValid];
}

- (void)stopMonitoring {
    if ([self.trafficTimer isValid]) {
        [self.trafficTimer invalidate];
    }
    self.trafficTimer = nil;
    self.trafficBlock = nil;
}

- (void)onTimer:(id)sender {
    ZXNetworkTrafficData *trafficData = [self getTrafficData];
    //
    if (_trafficTimes > 0) {
        int64_t WiFiSent = trafficData.WiFiSent - _trafficData.WiFiSent;
        int64_t WiFiReceived = trafficData.WiFiReceived - _trafficData.WiFiReceived;
        int64_t WWANSent = trafficData.WWANSent - _trafficData.WWANSent;
        int64_t WWANReceived = trafficData.WWANReceived - _trafficData.WWANReceived;
        //
        [self setTrafficModel:_WiFiSent forBytes:WiFiSent];
        [self setTrafficModel:_WiFiReceived forBytes:WiFiReceived];
        [self setTrafficModel:_WWANSent forBytes:WWANSent];
        [self setTrafficModel:_WWANReceived forBytes:WWANReceived];
        //
        if (_trafficBlock) {
            _trafficBlock(_WiFiSent, _WiFiReceived, _WWANSent, _WWANReceived);
        }
    }
    //
    self.trafficData = trafficData;
    _trafficTimes++;
}

/**
 Reference http://stackoverflow.com/questions/7946699/iphone-data-usage-tracking-monitoring
 */
- (ZXNetworkTrafficData *)getTrafficData {
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    //
    u_int32_t WiFiSent = 0;
    u_int32_t WiFiReceived = 0;
    u_int32_t WWANSent = 0;
    u_int32_t WWANReceived = 0;
    //
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WiFiSent += ifa_data->ifi_obytes;
                        WiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"]) {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WWANSent += ifa_data->ifi_obytes;
                        WWANReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    //
    ZXNetworkTrafficData *trafficData = [[ZXNetworkTrafficData alloc] init];
    trafficData.WiFiSent = WiFiSent;
    trafficData.WiFiReceived = WiFiReceived;
    trafficData.WWANSent = WWANSent;
    trafficData.WWANReceived = WWANReceived;
    return trafficData;
}

- (void)setTrafficModel:(ZXNetworkTrafficModel *)model forBytes:(int64_t)bytes {
    model.range = bytes - model.bytes;
    model.bytes = bytes;
    model.total += ABS(model.range);
    model.count++;
}

@end

@implementation ZXNetworkTrafficModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bytes = 0;
        _range = 0;
        _total = 0;
        _count = 0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ZXNetworkTrafficModel *obj = [[[self class] allocWithZone:zone] init];
    obj.bytes = _bytes;
    obj.range = _range;
    obj.total = _total;
    obj.count = _count;
    return obj;
}

@end

