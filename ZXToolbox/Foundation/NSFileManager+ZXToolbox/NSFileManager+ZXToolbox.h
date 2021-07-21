//
// NSFileManager+ZXToolbox.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (ZXToolbox)

// Bundle
+ (nullable NSString *)bundleFile:(NSString*)file;

// Caches
+ (nullable NSString *)cachesDirectory;
+ (nullable NSString *)cachesDirectory:(NSString *)subpath;
+ (nullable NSString *)cachesFile:(NSString *)file;
+ (nullable NSString *)cachesFile:(NSString *)file inDirectory:(NSString *)subpath;

// Documents
+ (nullable NSString *)documentDirectory;
+ (nullable NSString *)documentDirectory:(NSString *)subpath;
+ (nullable NSString *)documentFile:(NSString *)file;
+ (nullable NSString *)documentFile:(NSString *)file inDirectory:(NSString *)subpath;

// Temporary
+ (nullable NSString *)temporaryDirectory;
+ (nullable NSString *)temporaryDirectory:(NSString *)subpath;
+ (nullable NSString *)temporaryFile:(NSString *)file;
+ (nullable NSString *)temporaryFile:(NSString *)file inDirectory:(NSString *)subpath;

// File size
+ (uint64_t)fileSizeAtPath:(NSString *)path;

// Create && Remove
- (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError **)error;
- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error exclude:(NSArray * _Nullable)exclusions;

@end

NS_ASSUME_NONNULL_END
