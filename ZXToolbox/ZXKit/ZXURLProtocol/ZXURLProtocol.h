//
// ZXURLProtocol.h
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
#import <CoreFoundation/CoreFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

/**
 Be careful, this class use the private api + [WKBrowsingContextController registerSchemeForCustomProtocol:],
 And will be lost the post body data for request
 */
@interface ZXURLProtocol : NSURLProtocol

/**
 Register schemes for custom protocol

 @param schemes usually @[@"http", @"https"].
 @param customRequest YES if the protocol can handle the given request, NO if not.
 @param canonicalRequest The canonical form of the given request.
 @param startLoading Starts protocol-specific loading of a request.
 @param stopLoading Stops protocol-specific loading of a request.
 */
+ (void)registerSchemes:(NSArray *)schemes customRequest:(BOOL (^)(NSURLRequest *request))customRequest canonicalRequest:(NSURLRequest * (^)(NSURLRequest *request))canonicalRequest startLoading:(void (^)(ZXURLProtocol *protocol))startLoading stopLoading:(void (^)(ZXURLProtocol *protocol))stopLoading NS_AVAILABLE_IOS(8_0);

/**
 Unregister schemes
 */
+ (void)unregisterSchemes NS_AVAILABLE_IOS(8_0);

/**
 Get mimetype with file extension

 @param extension The file extension
 @return The mime type
 */
+ (NSString *)mimeTypeWithExtension:(NSString *)extension;

/**
 Load data with local file at path

 @param path The local path for URL.
 @param policy The NSURLCacheStoragePolicy the protocol
 has determined should be used for the given response if the
 response is to be stored in a cache.
 */
- (void)loadDataWithFile:(NSString *)path cacheStoragePolicy:(NSURLCacheStoragePolicy)policy NS_AVAILABLE_IOS(8_0);

@end
