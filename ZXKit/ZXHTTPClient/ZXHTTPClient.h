//
// ZXHTTPClient.h
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

#import "ZXHTTPSecurity.h"

@class ZXHTTPFormData;

#pragma mark - ZXHTTPClient

/**
 ZXHTTPClient
 */
@interface ZXHTTPClient : NSObject

#pragma mark HTTP Security

/**
 Returns the default security policy.
 
 @return The default security policy.
 */
+ (ZXHTTPSecurity *)securityPolicy;

#pragma mark HTTP Request

/**
 HTTP Request

 @param URLString The request URL string
 @param method The HTTP method
 @param params The query string with key value pairs
 @param body The HTTP body data
 @param requestHandler The request handler
 @param completionHandler The completion handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params body:(NSData *)body requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler;

/**
 HTTP Request with "multipart/form-data"
 
 @param URLString The request URL string
 @param method The HTTP method
 @param params The query string with key value pairs
 @param formData The form data for HTTP body
 @param requestHandler The request handler
 @param completionHandler The completion handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler;

/**
 HTTP Request with "application/json"
 
 @param URLString The request URL string
 @param method The HTTP method
 @param params The query string with key value pairs
 @param jsonObject The JSON object for HTTP body
 @param requestHandler The request handler
 @param completionHandler The completion handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params jsonObject:(id)jsonObject requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler;

#pragma mark HTTP Methods

/**
 HTTP Request with GET method
 
 @param URLString The request URL string
 @param params The query string with key value pairs
 @param requestHandler The request handler
 @param completionHandler The completion handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString params:(NSDictionary *)params requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler;

/**
 HTTP Request with POST method
 
 @param URLString The request URL string
 @param params The query string with key value pairs
 @param formData The form data for HTTP body
 @param requestHandler The request handler
 @param completionHandler The completion handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler;

/**
 HTTP Request with POST method
 
 @param URLString The request URL string
 @param params The query string with key value pairs
 @param jsonObject The JSON object for HTTP body
 @param requestHandler The request handler
 @param completionHandler The completion handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params jsonObject:(id)jsonObject requestHandler:(void(^)(NSMutableURLRequest *request))requestHandler completionHandler:(void(^)(NSURLSessionDataTask *task, NSData *data, NSError *error))completionHandler;

@end

#pragma mark - ZXHTTPFormData

/**
 ZXHTTPFormData
 */
@interface ZXHTTPFormData : NSObject
/**
 Required, The form data
 */
@property (nonatomic, strong) NSData *data;
/**
 Required, Name for data
 */
@property (nonatomic, strong) NSString *name;
/**
 Optional, File name for data
 */
@property (nonatomic, strong) NSString *fileName;
/**
 Optional, MIME type for data
 */
@property (nonatomic, strong) NSString *mimeType;

/**
 Initializes with data
 
 @param data The form data
 @param name Name for data
 @return Instance
 */
- (instancetype)initWithData:(NSData *)data name:(NSString *)name;

/**
 Initializes with file
 
 @param data The form data
 @param name Name for data
 @param fileName File name for data
 @param mimeType MIME type for data
 @return Instance
 */
- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end
