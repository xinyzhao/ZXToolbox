//
// NSURL+ZXToolbox.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2022 Zhao Xin
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

@interface NSURL (ZXToolbox)

/// Creates and returns an NSURL object initialized with a provided URL string and components.
/// @param URLString The URL string with which to initialize the NSURL object. Must be a URL that conforms to RFC 2396. This method parses URLString according to RFCs 1738 and 1808.
/// @param scheme The scheme URL component, or nil if not present.
/// Attempting to set the scheme with an invalid scheme string will cause an exception.
/// For example, in the URL http://www.example.com/index.html, the scheme is http.
/// @param user The username URL subcomponent, or nil if not present.
/// For example, in the URL http://username:password@www.example.com/index.html, the user is username.
/// @param password The password URL subcomponent, or nil if not present.
/// For example, in the URL http://username:password@www.example.com/index.html, the password is password.
/// @param host The host URL subcomponent, or nil if not present.
/// For example, in the URL http://www.example.com/index.html, the host is www.example.com.
/// @param port The port number URL component, or nil if not present.
/// Attempting to set a negative port number will cause an exception.
/// For example, in the URL http://www.example.com:8080/index.php, the port number is 8080.
/// @param path The path URL component, or nil if not present.
/// For example, in the URL http://www.example.com/index.html, the path is /index.html.
/// @param query The query URL component as a string or NSDictionary<NSString *, NSString*>, or nil if not present.
/// For example, in the URL http://www.example.com/index.php?key1=value1&key2=value2, the query string is key1=value1&key2=value2.
/// @param fragment The fragment URL component (the part after a # symbol), or nil if not present.
/// For example, in the URL http://www.example.com/index.html#jumpLocation, the fragment is jumpLocation.
/// @Attention If the components has an authority component (user, password, host or port) and a path component, then the path must either begin with "/" or be an empty string. If the components does not have an authority component (user, password, host or port) and has a path component, the path component must not start with "//". If those requirements are not met, nil is returned.
+ (nullable instancetype)URLWithString:(NSString *)URLString scheme:(nullable NSString *)scheme user:(nullable NSString *)user password:(nullable NSString *)password host:(nullable NSString *)host port:(nullable NSNumber *)port path:(nullable NSString *)path query:(nullable id)query fragment:(nullable NSString *)fragment;

/// Creates and returns an NSURL object initialized with a provided URL string and components.
/// @param URLString The URL string with which to initialize the NSURL object. Must be a URL that conforms to RFC 2396. This method parses URLString according to RFCs 1738 and 1808.
/// @param path The path URL component, or nil if not present.
/// For example, in the URL http://www.example.com/index.html, the path is /index.html.
/// @param query The query URL component as a string or NSDictionary<NSString *, NSString*>, or nil if not present.
/// For example, in the URL http://www.example.com/index.php?key1=value1&key2=value2, the query string is key1=value1&key2=value2.
+ (nullable instancetype)URLWithString:(NSString *)URLString path:(nullable NSString *)path query:(nullable id)query;

/// Creates and returns an NSURL object initialized with a provided URL string and components.
/// @param URLString The URL string with which to initialize the NSURL object. Must be a URL that conforms to RFC 2396. This method parses URLString according to RFCs 1738 and 1808.
/// @param path The path URL component, or nil if not present.
/// For example, in the URL http://www.example.com/index.html, the path is /index.html.
+ (nullable instancetype)URLWithString:(NSString *)URLString path:(nullable NSString *)path;

/// Creates and returns an NSURL object initialized with a provided URL string and components.
/// @param URLString The URL string with which to initialize the NSURL object. Must be a URL that conforms to RFC 2396. This method parses URLString according to RFCs 1738 and 1808.
/// @param query The query URL component as a string or NSDictionary<NSString *, NSString*>, or nil if not present.
/// For example, in the URL http://www.example.com/index.php?key1=value1&key2=value2, the query string is key1=value1&key2=value2.
+ (nullable instancetype)URLWithString:(NSString *)URLString query:(nullable id)query;

/// An object that parses URLs
@property (nullable, readonly, copy) NSURLComponents *URLComponents;

/// A URL derived from the components object, in string form.
@property (nullable, readonly, copy) NSString *URLString;

/// A URL derived from the components object, in string form.
@property (nullable, readonly, copy) NSDictionary<NSString *, NSString *> *queryItems;

@end

NS_ASSUME_NONNULL_END
