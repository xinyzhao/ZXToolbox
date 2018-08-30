//
// ZXURLProtocol.h
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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
#import <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ZXURLProtocol : NSURLProtocol

/**
 Register schemes for custom protocol

 @param schemes usually @[@"http", @"https"].
 @param customRequest YES if the protocol can handle the given request, NO if not.
 @param canonicalRequest The canonical form of the given request.
 @param startLoading Starts protocol-specific loading of a request.
 @param stopLoading Stops protocol-specific loading of a request.
 */
+ (void)registerSchemes:(NSArray *)schemes customRequest:(BOOL (^)(NSURLRequest *request))customRequest canonicalRequest:(NSURLRequest * (^)(NSURLRequest *request))canonicalRequest startLoading:(void (^)(ZXURLProtocol *protocol))startLoading stopLoading:(void (^)(ZXURLProtocol *protocol))stopLoading;

/**
 Unregister schemes
 */
+ (void)unregisterSchemes;

/**
 Get mimetype with file extension

 @param extension The file extension
 @return The mime type
 */
+ (NSString *)mimeTypeWithExtension:(NSString *)extension;

/**
 Load data with local path

 @param path The local path for URL.
 @param policy The NSURLCacheStoragePolicy the protocol
 has determined should be used for the given response if the
 response is to be stored in a cache.
 */
- (void)loadDataWithPath:(NSString *)path cacheStoragePolicy:(NSURLCacheStoragePolicy)policy;

@end