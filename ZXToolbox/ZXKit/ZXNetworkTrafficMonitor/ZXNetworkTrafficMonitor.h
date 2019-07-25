//
// ZXNetworkTrafficMonitor.h
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

#import <Foundation/Foundation.h>

@class ZXNetworkTrafficModel;

/**
 ZXNetworkTrafficMonitor
 */
@interface ZXNetworkTrafficMonitor : NSObject
/**
 Whether or not is monitoring
 */
@property (nonatomic, readonly) BOOL isMonitoring;

/**
 Start Monitoring
 
 @param timeInterval Monitoring interval
 @param trafficBlock Traffic block
*/
- (void)startMonitoring:(NSTimeInterval)timeInterval
                traffic:(void(^)(ZXNetworkTrafficModel *WiFiSent, ZXNetworkTrafficModel *WiFiReceived, ZXNetworkTrafficModel *WWANSent, ZXNetworkTrafficModel *WWANReceived))trafficBlock;

/**
 Stop Monitoring
 */
- (void)stopMonitoring;

@end

/**
 ZXNetworkTrafficModel
 */
@interface ZXNetworkTrafficModel : NSObject
/**
 Traffic bytes
 */
@property (nonatomic, assign) int64_t bytes;
/**
 True range
 */
@property (nonatomic, assign) int64_t range;
/**
 Sum of range
 */
@property (nonatomic, assign) int64_t total;
/**
 Range count
 */
@property (nonatomic, assign) int64_t count;

@end

