//
// ZXHTTPSecurity.m
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

#import "ZXHTTPSecurity.h"

@interface ZXHTTPSecurity () <NSURLSessionTaskDelegate>
@property (readwrite, nonatomic, strong) NSSet *pinnedPublicKeys;

/**
 Whether or not the specified server trust should be accepted, based on the security policy.
 
 This method should be used when responding to an authentication challenge from a server.
 
 @param serverTrust The X.509 certificate trust of the server.
 @param domain The domain of serverTrust. If `nil`, the domain will not be validated.
 
 @return Whether or not to trust the server.
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(nullable NSString *)domain;

@end

#pragma mark -

@implementation ZXHTTPSecurity

+ (NSSet *)certificatesInBundle:(NSBundle *)bundle {
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
    //
    NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
    for (NSString *path in paths) {
        NSData *certificateData = [NSData dataWithContentsOfFile:path];
        [certificates addObject:certificateData];
    }
    //
    return [NSSet setWithSet:certificates];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pinnedCertificates = [ZXHTTPSecurity certificatesInBundle:[NSBundle mainBundle]];
        self.allowInvalidCertificates = YES;
        self.validatesDomainName = NO;
        self.validatesCertificates = NO;
        self.validatesPublicKeys = NO;
    }
    return self;
}

- (void)setPinnedCertificates:(NSSet *)pinnedCertificates {
    _pinnedCertificates = pinnedCertificates;
    
    if (self.pinnedCertificates) {
        NSMutableSet *publicKeys = [NSMutableSet setWithCapacity:[self.pinnedCertificates count]];
        for (NSData *certificate in self.pinnedCertificates) {
            id publicKey = [self publicKeyForCertificate:certificate];
            if (publicKey) {
                [publicKeys addObject:publicKey];
            }
        }
        self.pinnedPublicKeys = [NSSet setWithSet:publicKeys];
    } else {
        self.pinnedPublicKeys = nil;
    }
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    if (domain && self.allowInvalidCertificates && self.validatesDomainName && (!self.validatesCertificates || self.pinnedCertificates.count == 0)) {
        // https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/OverridingSSLChainValidationCorrectly.html
        //  According to the docs, you should only trust your provided certs for evaluation.
        //  Pinned certificates are added to the trust. Without pinned certificates,
        //  there is nothing to evaluate against.
        //
        //  From Apple Docs:
        //          "Do not implicitly trust self-signed certificates as anchors (kSecTrustOptionImplicitAnchors).
        //           Instead, add your own (self-signed) CA certificate to the list of trusted anchors."
        NSLog(@"In order to validate a domain name for self signed certificates, you MUST use pinning.");
        return NO;
    }
    //
    NSMutableArray *policies = [NSMutableArray array];
    if (self.validatesDomainName) {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    //
    if (!self.validatesCertificates) {
        return self.allowInvalidCertificates || [self evaluateServerTrust:serverTrust];
    } else if (![self evaluateServerTrust:serverTrust] && !self.allowInvalidCertificates) {
        return NO;
    }
    //
    if (self.validatesCertificates) {
        //
        if (self.validatesPublicKeys) {
            NSUInteger trustedPublicKeyCount = 0;
            NSArray *publicKeys = [self publicKeyTrustChainForServerTrust:serverTrust];
            for (id trustChainPublicKey in publicKeys) {
                for (id pinnedPublicKey in self.pinnedPublicKeys) {
                    if ([trustChainPublicKey isEqual:pinnedPublicKey]) {
                        trustedPublicKeyCount += 1;
                    }
                }
            }
            //
            return trustedPublicKeyCount > 0;
            
        } else {
            //
            NSMutableArray *pinnedCertificates = [NSMutableArray array];
            for (NSData *certificateData in self.pinnedCertificates) {
                [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
            }
            SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
            //
            if ([self evaluateServerTrust:serverTrust]) {
                // obtain the chain after being validated, which *should* contain the pinned certificate in the last position (if it's the Root CA)
                NSArray *serverCertificates = [self certificateTrustChainForServerTrust:serverTrust];
                for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
                    if ([self.pinnedCertificates containsObject:trustChainCertificate]) {
                        return YES;
                    }
                }
            }
        }
    }
    //
    return NO;
}

#pragma mark Private

- (id)publicKeyForCertificate:(NSData *)certificate {
    id allowedPublicKey = nil;
    SecCertificateRef allowedCertificate;
    SecCertificateRef allowedCertificates[1];
    CFArrayRef tempCertificates = nil;
    SecPolicyRef policy = nil;
    SecTrustRef allowedTrust = nil;
    SecTrustResultType result;
    //
    allowedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificate);
    if (allowedCertificate) {
        allowedCertificates[0] = allowedCertificate;
        tempCertificates = CFArrayCreate(NULL, (const void **)allowedCertificates, 1, NULL);
        //
        policy = SecPolicyCreateBasicX509();
        if (SecTrustCreateWithCertificates(tempCertificates, policy, &allowedTrust) == errSecSuccess) {
            if (SecTrustEvaluate(allowedTrust, &result) == errSecSuccess) {
                allowedPublicKey = (__bridge_transfer id)SecTrustCopyPublicKey(allowedTrust);
            }
        }
    }
    //
    if (allowedTrust) {
        CFRelease(allowedTrust);
    }
    if (policy) {
        CFRelease(policy);
    }
    if (tempCertificates) {
        CFRelease(tempCertificates);
    }
    if (allowedCertificate) {
        CFRelease(allowedCertificate);
    }
    //
    return allowedPublicKey;
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust {
    BOOL isValid = NO;
    SecTrustResultType result;
    if (SecTrustEvaluate(serverTrust, &result) == errSecSuccess) {
        isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    }
    return isValid;
}

- (NSArray *)certificateTrustChainForServerTrust:(SecTrustRef)serverTrust {
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
    }
    
    return [NSArray arrayWithArray:trustChain];
}

- (NSArray *)publicKeyTrustChainForServerTrust:(SecTrustRef)serverTrust {
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        //
        SecCertificateRef someCertificates[] = {certificate};
        CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);
        //
        SecTrustRef trust;
        if (SecTrustCreateWithCertificates(certificates, policy, &trust) == errSecSuccess) {
            SecTrustResultType result;
            if (SecTrustEvaluate(trust, &result) == errSecSuccess) {
                [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];
            }
        }
        //
        if (trust) {
            CFRelease(trust);
        }
        if (certificates) {
            CFRelease(certificates);
        }
    }
    CFRelease(policy);
    //
    return [NSArray arrayWithArray:trustChain];
}

#pragma mark <NSURLSessionDelegate>

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            if (credential) {
                disposition = NSURLSessionAuthChallengeUseCredential;
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

#pragma mark <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

@end
