//
// ZXKeychainItem+Return.m
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

#import "ZXKeychainItem+Return.h"

@implementation ZXKeychainItem (Return)

- (void)setReturnData:(BOOL)returnData {
    CFBooleanRef ref = returnData ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecReturnData];
}

- (BOOL)returnData {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecReturnData];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setReturnAttributes:(BOOL)returnAttributes {
    CFBooleanRef ref = returnAttributes ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecReturnAttributes];
}

- (BOOL)returnAttributes {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecReturnAttributes];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setReturnRef:(BOOL)returnRef {
    CFBooleanRef ref = returnRef ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecReturnRef];
}

- (BOOL)returnRef {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecReturnRef];
    return ref ? CFBooleanGetValue(ref) : false;
}

- (void)setReturnPersistentRef:(BOOL)returnPersistentRef {
    CFBooleanRef ref = returnPersistentRef ? kCFBooleanTrue : kCFBooleanFalse;
    [self setObject:(__bridge id)ref forKey:(__bridge id)kSecReturnPersistentRef];
}

- (BOOL)returnPersistentRef {
    CFBooleanRef ref = (__bridge CFBooleanRef)[self objectForKey:(__bridge id)kSecReturnPersistentRef];
    return ref ? CFBooleanGetValue(ref) : false;
}

@end
