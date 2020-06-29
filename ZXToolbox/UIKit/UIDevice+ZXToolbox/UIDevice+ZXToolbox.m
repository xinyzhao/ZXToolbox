//
// UIDevice+ZXToolbox.m
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

#import "UIDevice+ZXToolbox.h"
#import "ZXCommonCrypto.h"
#import "ZXKeychain.h"
#import "ZXToolbox+Macros.h"
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>

@interface UIDevice ()
@property (nonatomic, weak) id proximityStateDidChangeObserver;

@end

@implementation UIDevice (ZXToolbox)

- (NSString *)modelType {
    static NSString *modelType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_IPHONE_SIMULATOR
        // 获取模拟器所对应的 device model
        modelType = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
#else
        // 获取真机设备的 device model
        struct utsname systemInfo;
        uname(&systemInfo);
        modelType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
#endif
    });
    return modelType;
}

- (NSString *)modelName {
    static NSString *modelName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *file = ZXToolboxBundleFile(@"UIDevice+ZXToolbox.bundle", @"UIDevice+ZXToolbox.plist");
        if (file) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
            modelName = [dict objectForKey:self.modelType];
        } else {
            modelName = nil;
        }
    });
    return modelName;
}

- (NSString *)UDIDString {
    NSString *key = @"ZXToolboxUniqueDeviceIdentifierKey";
    NSString *udid = [[ZXKeychain defaultKeychain] stringForKey:key];
    if (udid == nil) {
        udid = [[[NSUUID UUID].UUIDString SHA1String] lowercaseString];
        [[ZXKeychain defaultKeychain] setString:udid forKey:key];
    }
    return udid;
}

- (int64_t)fileSystemSize {
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error == nil) {
        int64_t size =  [[attributes objectForKey:NSFileSystemSize] longLongValue];
        if (size < 0) {
            size = 0;
        }
        return size;
    }
    return 0;
}

- (int64_t)fileSystemFreeSize {
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error == nil) {
        int64_t size =  [[attributes objectForKey:NSFileSystemFreeSize] longLongValue];
        if (size < 0) {
            size = 0;
        }
        return size;
    }
    return 0;
}

- (int64_t)fileSystemUsedSize {
    return self.fileSystemSize - self.fileSystemFreeSize;
}

- (int)cpuBits {
    return sizeof(void *) * 8;
}

- (int)cpuType {
    cpu_type_t type;
    size_t size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);
    return type;
}

#pragma mark Proximity State

- (void)setProximityStateDidChange:(void (^)(BOOL))proximityStateDidChange {
    objc_setAssociatedObject(self, @selector(proximityStateDidChange), proximityStateDidChange, OBJC_ASSOCIATION_COPY);
    // Add observer
    if (self.proximityStateDidChangeObserver == nil) {
        __weak typeof(self) weakSelf = self;
        self.proximityStateDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceProximityStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            UIDevice *device = note.object;
            if (weakSelf.proximityStateDidChange) {
                weakSelf.proximityStateDidChange(device.proximityState);
            }
        }];
    }
}

- (void (^)(BOOL))proximityStateDidChange {
    return objc_getAssociatedObject(self, @selector(proximityStateDidChange));
}

- (void)setProximityStateDidChangeObserver:(id)proximityStateDidChangeObserver {
    objc_setAssociatedObject(self, @selector(proximityStateDidChangeObserver), proximityStateDidChangeObserver, OBJC_ASSOCIATION_ASSIGN);
}

- (id)proximityStateDidChangeObserver {
    return objc_getAssociatedObject(self, @selector(proximityStateDidChangeObserver));
}

- (void)dealloc
{
    if (self.proximityStateDidChangeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.proximityStateDidChangeObserver];
        self.proximityStateDidChangeObserver = nil;
    }
}

@end

