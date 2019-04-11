//
// ZXHTTPSecurity.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
//
// Reference AFSecurityPolicy in AFNetworking
// https://github.com/AFNetworking/AFNetworking
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
#import <Security/Security.h>

/**
 ZXHTTPSecurity
 */
@interface ZXHTTPSecurity : NSObject <NSURLSessionDelegate>

/**
 The certificates used to validate servers.
 */
@property (nonatomic, strong) NSSet<NSData *> *pinnedCertificates;

/**
 Whether or not to trust servers with an invalid or expired SSL certificates. Defaults to `YES`.
 */
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 Whether or not to validate the domain name in the certificate's CN field. Defaults to `NO`.
 */
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 Whether or not to validate host certificates against pinned certificates. Defaults to `NO`.
 Requirement specified .cer file in the project.
 */
@property (nonatomic, assign) BOOL validatesCertificates;

/**
 Whether or not to validate host certificates against public keys of pinned certificates. Defaults to `NO`.
 Requirement specified .cer file in the project, and target devices trust the installed .der files if needed.
 */
@property (nonatomic, assign) BOOL validatesPublicKeys;

/**
 Returns any certificates included in the bundle
 
 @param bundle The given bundle
 @return The certificates included in the given bundle.
 */
+ (NSSet *)certificatesInBundle:(NSBundle *)bundle;

@end

