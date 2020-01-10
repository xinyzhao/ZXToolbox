//
// ZXKeychainItem+InternetPassword.m
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

#import "ZXKeychainItem+InternetPassword.h"

@implementation ZXKeychainItem (InternetPassword)

- (void)setSecurityDomain:(NSString *)securityDomain {
    [self setObject:securityDomain forKey:(__bridge id)kSecAttrSecurityDomain];
}

- (NSString *)securityDomain {
    return [self objectForKey:(__bridge id)kSecAttrSecurityDomain];
}

- (void)setServer:(NSString *)server {
    [self setObject:server forKey:(__bridge id)kSecAttrServer];
}

- (NSString *)server {
    return [self objectForKey:(__bridge id)kSecAttrServer];
}

- (void)setProtocol:(ZXKeychainItemAttrProtocol)protocol {
    id obj = nil;
    switch (protocol) {
        case ZXKeychainItemAttrProtocolFTP:
            obj = (__bridge id)kSecAttrProtocolFTP;
            break;
        case ZXKeychainItemAttrProtocolFTPAccount:
            obj = (__bridge id)kSecAttrProtocolFTPAccount;
            break;
        case ZXKeychainItemAttrProtocolHTTP:
            obj = (__bridge id)kSecAttrProtocolHTTP;
            break;
        case ZXKeychainItemAttrProtocolIRC:
            obj = (__bridge id)kSecAttrProtocolIRC;
            break;
        case ZXKeychainItemAttrProtocolNNTP:
            obj = (__bridge id)kSecAttrProtocolNNTP;
            break;
        case ZXKeychainItemAttrProtocolPOP3:
            obj = (__bridge id)kSecAttrProtocolPOP3;
            break;
        case ZXKeychainItemAttrProtocolSMTP:
            obj = (__bridge id)kSecAttrProtocolSMTP;
            break;
        case ZXKeychainItemAttrProtocolSOCKS:
            obj = (__bridge id)kSecAttrProtocolSOCKS;
            break;
        case ZXKeychainItemAttrProtocolIMAP:
            obj = (__bridge id)kSecAttrProtocolIMAP;
            break;
        case ZXKeychainItemAttrProtocolLDAP:
            obj = (__bridge id)kSecAttrProtocolLDAP;
            break;
        case ZXKeychainItemAttrProtocolAppleTalk:
            obj = (__bridge id)kSecAttrProtocolAppleTalk;
            break;
        case ZXKeychainItemAttrProtocolAFP:
            obj = (__bridge id)kSecAttrProtocolAFP;
            break;
        case ZXKeychainItemAttrProtocolTelnet:
            obj = (__bridge id)kSecAttrProtocolTelnet;
            break;
        case ZXKeychainItemAttrProtocolSSH:
            obj = (__bridge id)kSecAttrProtocolSSH;
            break;
        case ZXKeychainItemAttrProtocolFTPS:
            obj = (__bridge id)kSecAttrProtocolFTPS;
            break;
        case ZXKeychainItemAttrProtocolHTTPS:
            obj = (__bridge id)kSecAttrProtocolHTTPS;
            break;
        case ZXKeychainItemAttrProtocolHTTPProxy:
            obj = (__bridge id)kSecAttrProtocolHTTPProxy;
            break;
        case ZXKeychainItemAttrProtocolHTTPSProxy:
            obj = (__bridge id)kSecAttrProtocolHTTPSProxy;
            break;
        case ZXKeychainItemAttrProtocolFTPProxy:
            obj = (__bridge id)kSecAttrProtocolFTPProxy;
            break;
        case ZXKeychainItemAttrProtocolSMB:
            obj = (__bridge id)kSecAttrProtocolSMB;
            break;
        case ZXKeychainItemAttrProtocolRTSP:
            obj = (__bridge id)kSecAttrProtocolRTSP;
            break;
        case ZXKeychainItemAttrProtocolRTSPProxy:
            obj = (__bridge id)kSecAttrProtocolRTSPProxy;
            break;
        case ZXKeychainItemAttrProtocolDAAP:
            obj = (__bridge id)kSecAttrProtocolDAAP;
            break;
        case ZXKeychainItemAttrProtocolEPPC:
            obj = (__bridge id)kSecAttrProtocolEPPC;
            break;
        case ZXKeychainItemAttrProtocolIPP:
            obj = (__bridge id)kSecAttrProtocolIPP;
            break;
        case ZXKeychainItemAttrProtocolNNTPS:
            obj = (__bridge id)kSecAttrProtocolNNTPS;
            break;
        case ZXKeychainItemAttrProtocolLDAPS:
            obj = (__bridge id)kSecAttrProtocolLDAPS;
            break;
        case ZXKeychainItemAttrProtocolTelnetS:
            obj = (__bridge id)kSecAttrProtocolTelnetS;
            break;
        case ZXKeychainItemAttrProtocolIMAPS:
            obj = (__bridge id)kSecAttrProtocolIMAPS;
            break;
        case ZXKeychainItemAttrProtocolIRCS:
            obj = (__bridge id)kSecAttrProtocolIRCS;
            break;
        case ZXKeychainItemAttrProtocolPOP3S:
            obj = (__bridge id)kSecAttrProtocolPOP3S;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrProtocol];
}

- (ZXKeychainItemAttrProtocol)protocol {
    ZXKeychainItemAttrProtocol protocol = ZXKeychainItemAttrProtocolUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecAttrProtocol];
    if (obj == (__bridge id)kSecAttrProtocolFTP) {
        protocol = ZXKeychainItemAttrProtocolFTP;
    } else if (obj == (__bridge id)kSecAttrProtocolFTPAccount) {
        protocol = ZXKeychainItemAttrProtocolFTPAccount;
    } else if (obj == (__bridge id)kSecAttrProtocolHTTP) {
        protocol = ZXKeychainItemAttrProtocolHTTP;
    } else if (obj == (__bridge id)kSecAttrProtocolIRC) {
        protocol = ZXKeychainItemAttrProtocolIRC;
    } else if (obj == (__bridge id)kSecAttrProtocolNNTP) {
        protocol = ZXKeychainItemAttrProtocolNNTP;
    } else if (obj == (__bridge id)kSecAttrProtocolPOP3) {
        protocol = ZXKeychainItemAttrProtocolPOP3;
    } else if (obj == (__bridge id)kSecAttrProtocolSMTP) {
        protocol = ZXKeychainItemAttrProtocolSMTP;
    } else if (obj == (__bridge id)kSecAttrProtocolSOCKS) {
        protocol = ZXKeychainItemAttrProtocolSOCKS;
    } else if (obj == (__bridge id)kSecAttrProtocolIMAP) {
        protocol = ZXKeychainItemAttrProtocolIMAP;
    } else if (obj == (__bridge id)kSecAttrProtocolLDAP) {
        protocol = ZXKeychainItemAttrProtocolLDAP;
    } else if (obj == (__bridge id)kSecAttrProtocolAppleTalk) {
        protocol = ZXKeychainItemAttrProtocolAppleTalk;
    } else if (obj == (__bridge id)kSecAttrProtocolAFP) {
        protocol = ZXKeychainItemAttrProtocolAFP;
    } else if (obj == (__bridge id)kSecAttrProtocolTelnet) {
        protocol = ZXKeychainItemAttrProtocolTelnet;
    } else if (obj == (__bridge id)kSecAttrProtocolSSH) {
        protocol = ZXKeychainItemAttrProtocolSSH;
    } else if (obj == (__bridge id)kSecAttrProtocolFTPS) {
        protocol = ZXKeychainItemAttrProtocolFTPS;
    } else if (obj == (__bridge id)kSecAttrProtocolHTTPS) {
        protocol = ZXKeychainItemAttrProtocolHTTPS;
    } else if (obj == (__bridge id)kSecAttrProtocolHTTPProxy) {
        protocol = ZXKeychainItemAttrProtocolHTTPProxy;
    } else if (obj == (__bridge id)kSecAttrProtocolHTTPSProxy) {
        protocol = ZXKeychainItemAttrProtocolHTTPSProxy;
    } else if (obj == (__bridge id)kSecAttrProtocolFTPProxy) {
        protocol = ZXKeychainItemAttrProtocolFTPProxy;
    } else if (obj == (__bridge id)kSecAttrProtocolSMB) {
        protocol = ZXKeychainItemAttrProtocolSMB;
    } else if (obj == (__bridge id)kSecAttrProtocolRTSP) {
        protocol = ZXKeychainItemAttrProtocolRTSP;
    } else if (obj == (__bridge id)kSecAttrProtocolRTSPProxy) {
        protocol = ZXKeychainItemAttrProtocolRTSPProxy;
    } else if (obj == (__bridge id)kSecAttrProtocolDAAP) {
        protocol = ZXKeychainItemAttrProtocolDAAP;
    } else if (obj == (__bridge id)kSecAttrProtocolEPPC) {
        protocol = ZXKeychainItemAttrProtocolEPPC;
    } else if (obj == (__bridge id)kSecAttrProtocolIPP) {
        protocol = ZXKeychainItemAttrProtocolIPP;
    } else if (obj == (__bridge id)kSecAttrProtocolNNTPS) {
        protocol = ZXKeychainItemAttrProtocolNNTPS;
    } else if (obj == (__bridge id)kSecAttrProtocolLDAPS) {
        protocol = ZXKeychainItemAttrProtocolLDAPS;
    } else if (obj == (__bridge id)kSecAttrProtocolTelnetS) {
        protocol = ZXKeychainItemAttrProtocolTelnetS;
    } else if (obj == (__bridge id)kSecAttrProtocolIMAPS) {
        protocol = ZXKeychainItemAttrProtocolIMAPS;
    } else if (obj == (__bridge id)kSecAttrProtocolIRCS) {
        protocol = ZXKeychainItemAttrProtocolIRCS;
    } else if (obj == (__bridge id)kSecAttrProtocolPOP3S) {
        protocol = ZXKeychainItemAttrProtocolPOP3S;
    }
    return protocol;
}

- (void)setAuthenticationType:(ZXKeychainItemAttrAuthType)authenticationType {
    id obj = nil;
    switch (authenticationType) {
        case ZXKeychainItemAttrAuthTypeNTLM:
            obj = (__bridge id)kSecAttrAuthenticationTypeNTLM;
            break;
        case ZXKeychainItemAttrAuthTypeMSN:
            obj = (__bridge id)kSecAttrAuthenticationTypeMSN;
            break;
        case ZXKeychainItemAttrAuthTypeDPA:
            obj = (__bridge id)kSecAttrAuthenticationTypeDPA;
            break;
        case ZXKeychainItemAttrAuthTypeRPA:
            obj = (__bridge id)kSecAttrAuthenticationTypeRPA;
            break;
        case ZXKeychainItemAttrAuthTypeHTTPBasic:
            obj = (__bridge id)kSecAttrAuthenticationTypeHTTPBasic;
            break;
        case ZXKeychainItemAttrAuthTypeHTTPDigest:
            obj = (__bridge id)kSecAttrAuthenticationTypeHTTPDigest;
            break;
        case ZXKeychainItemAttrAuthTypeHTMLForm:
            obj = (__bridge id)kSecAttrAuthenticationTypeHTMLForm;
            break;
        case ZXKeychainItemAttrAuthTypeDefault:
            obj = (__bridge id)kSecAttrAuthenticationTypeDefault;
            break;
        default:
            break;
    }
    [self setObject:obj forKey:(__bridge id)kSecAttrAuthenticationType];
}

- (ZXKeychainItemAttrAuthType)authenticationType {
    ZXKeychainItemAttrAuthType authenticationType = ZXKeychainItemAttrAuthTypeUnspecified;
    id obj = [self objectForKey:(__bridge id)kSecAttrAuthenticationType];
    if (obj == (__bridge id)kSecAttrAuthenticationTypeNTLM) {
        authenticationType = ZXKeychainItemAttrAuthTypeNTLM;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeMSN) {
        authenticationType = ZXKeychainItemAttrAuthTypeMSN;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeDPA) {
        authenticationType = ZXKeychainItemAttrAuthTypeDPA;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeRPA) {
        authenticationType = ZXKeychainItemAttrAuthTypeRPA;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeHTTPBasic) {
        authenticationType = ZXKeychainItemAttrAuthTypeHTTPBasic;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeHTTPDigest) {
        authenticationType = ZXKeychainItemAttrAuthTypeHTTPDigest;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeHTMLForm) {
        authenticationType = ZXKeychainItemAttrAuthTypeHTMLForm;
    } else if (obj == (__bridge id)kSecAttrAuthenticationTypeDefault) {
        authenticationType = ZXKeychainItemAttrAuthTypeDefault;
    }
    return authenticationType;
}

- (void)setPort:(NSNumber *)port {
    [self setObject:port forKey:(__bridge id)kSecAttrPort];
}

- (NSNumber *)port {
    return [self objectForKey:(__bridge id)kSecAttrPort];
}

- (void)setPath:(NSString *)path {
    [self setObject:path forKey:(__bridge id)kSecAttrPath];
}

- (NSString *)path {
    return [self objectForKey:(__bridge id)kSecAttrPath];
}

@end
