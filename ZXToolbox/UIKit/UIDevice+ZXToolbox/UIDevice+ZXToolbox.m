//
// UIDevice+ZXToolbox.m
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

#import "UIDevice+ZXToolbox.h"
#import <sys/utsname.h>

@implementation UIDevice (ZXToolbox)

+ (NSString *)modelType {
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

+ (NSString *)modelName {
    static NSString *modelName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *bundlePath = [mainBundle pathForResource:@"UIDevice+ZXToolbox" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *file = [bundle pathForResource:@"UIDevice+ZXToolbox" ofType:@"plist"];
        if (file) {
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
            modelName = [dict objectForKey:UIDevice.modelType];
        } else {
            modelName = nil;
        }
    });
    return modelName;
}

@end

