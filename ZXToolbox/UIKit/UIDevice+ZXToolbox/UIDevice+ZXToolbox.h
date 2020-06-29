//
// UIDevice+ZXToolbox.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

#import <UIKit/UIKit.h>
#import <mach/machine.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (ZXToolbox)

/// The  model type of device, e.g. "iPhone12,3"
@property (nonatomic, readonly, nullable) NSString *modelType;

/// The  model name of device, e.g. "iPhone 11 Pro", supported iPhone/iPad/iPod touch series.
@property (nonatomic, readonly, nullable) NSString *modelName;

/// The Unique Device Identifier with UUIDString store in Keychain
@property (nonatomic, readonly) NSString *UDIDString;

/// The size of the file system in bytes.
@property (nonatomic, readonly) int64_t fileSystemSize;

/// The amount of free space on the file system in bytes.
@property (nonatomic, readonly) int64_t fileSystemFreeSize;

/// The amount of used space on the file system in bytes.
@property (nonatomic, readonly) int64_t fileSystemUsedSize;

/// The CPU bits, the value is 32/64 etc.
@property (nonatomic, readonly) int cpuBits;

/// The CPU type, the value is CPU_TYPE_ARM / CPU_TYPE_ARM64 etc.
@property (nonatomic, readonly) int cpuType;

/// Proximity state observer block
@property (nonatomic, copy) void (^proximityStateDidChange)(BOOL proximityState);

@end

NS_ASSUME_NONNULL_END
