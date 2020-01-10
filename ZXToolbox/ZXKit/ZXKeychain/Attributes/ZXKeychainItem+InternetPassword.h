//
// ZXKeychainItem+InternetPassword.h
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

#import "ZXKeychainItem.h"

NS_ASSUME_NONNULL_BEGIN

/// Values you use with the kSecAttrProtocol attribute key.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrProtocol) {
    /// FTP protocol.
    ZXKeychainItemAttrProtocolFTP,
    /// A client side FTP account.
    ZXKeychainItemAttrProtocolFTPAccount,
    /// HTTP protocol.
    ZXKeychainItemAttrProtocolHTTP,
    /// IRC protocol.
    ZXKeychainItemAttrProtocolIRC,
    /// NNTP protocol.
    ZXKeychainItemAttrProtocolNNTP,
    /// POP3 protocol.
    ZXKeychainItemAttrProtocolPOP3,
    /// SMTP protocol.
    ZXKeychainItemAttrProtocolSMTP,
    /// SOCKS protocol.
    ZXKeychainItemAttrProtocolSOCKS,
    /// IMAP protocol.
    ZXKeychainItemAttrProtocolIMAP,
    /// LDAP protocol.
    ZXKeychainItemAttrProtocolLDAP,
    /// AFP over AppleTalk.
    ZXKeychainItemAttrProtocolAppleTalk,
    /// AFP over TCP.
    ZXKeychainItemAttrProtocolAFP,
    /// Telnet protocol.
    ZXKeychainItemAttrProtocolTelnet,
    /// SSH protocol.
    ZXKeychainItemAttrProtocolSSH,
    /// FTP over TLS/SSL.
    ZXKeychainItemAttrProtocolFTPS,
    /// HTTP over TLS/SSL.
    ZXKeychainItemAttrProtocolHTTPS,
    /// HTTP proxy.
    ZXKeychainItemAttrProtocolHTTPProxy,
    /// HTTPS proxy.
    ZXKeychainItemAttrProtocolHTTPSProxy,
    /// FTP proxy.
    ZXKeychainItemAttrProtocolFTPProxy,
    /// SMB protocol.
    ZXKeychainItemAttrProtocolSMB,
    /// RTSP protocol.
    ZXKeychainItemAttrProtocolRTSP,
    /// RTSP proxy.
    ZXKeychainItemAttrProtocolRTSPProxy,
    /// DAAP protocol.
    ZXKeychainItemAttrProtocolDAAP,
    /// Remote Apple Events.
    ZXKeychainItemAttrProtocolEPPC,
    /// IPP protocol.
    ZXKeychainItemAttrProtocolIPP,
    /// NNTP over TLS/SSL.
    ZXKeychainItemAttrProtocolNNTPS,
    /// LDAP over TLS/SSL.
    ZXKeychainItemAttrProtocolLDAPS,
    /// Telnet over TLS/SSL.
    ZXKeychainItemAttrProtocolTelnetS,
    /// IMAP over TLS/SSL.
    ZXKeychainItemAttrProtocolIMAPS,
    /// IRC over TLS/SSL.
    ZXKeychainItemAttrProtocolIRCS,
    /// POP3 over TLS/SSL.
    ZXKeychainItemAttrProtocolPOP3S,
    /// Unspecified
    ZXKeychainItemAttrProtocolUnspecified
};

/// Values you use with the kSecAttrAuthenticationType attribute key.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrAuthType) {
    /// Windows NT LAN Manager authentication.
    ZXKeychainItemAttrAuthTypeNTLM,
    /// Microsoft Network default authentication.
    ZXKeychainItemAttrAuthTypeMSN,
    /// Distributed Password authentication.
    ZXKeychainItemAttrAuthTypeDPA,
    /// Remote Password authentication.
    ZXKeychainItemAttrAuthTypeRPA,
    /// HTTP Basic authentication.
    ZXKeychainItemAttrAuthTypeHTTPBasic,
    /// HTTP Digest Access authentication.
    ZXKeychainItemAttrAuthTypeHTTPDigest,
    /// HTML form based authentication.
    ZXKeychainItemAttrAuthTypeHTMLForm,
    /// The default authentication type.
    ZXKeychainItemAttrAuthTypeDefault,
    /// Unspecified
    ZXKeychainItemAttrAuthTypeUnspecified
};

/**
 @see kSecClassInternetPassword
 
 @abstract
 The value that indicates an Internet password item.
 
 @discussion
 The following keychain item attributes apply to an item of this class:
 
 kSecAttrAccess (macOS only)
 
 kSecAttrAccessGroup (iOS; also macOS if kSecAttrSynchronizable specified)
 
 kSecAttrAccessible (iOS; also macOS if kSecAttrSynchronizable specified)
 
 kSecAttrCreationDate
 
 kSecAttrModificationDate
 
 kSecAttrDescription
 
 kSecAttrComment
 
 kSecAttrCreator
 
 kSecAttrType
 
 kSecAttrLabel
 
 kSecAttrIsInvisible
 
 kSecAttrIsNegative
 
 kSecAttrAccount
 
 kSecAttrSecurityDomain
 
 kSecAttrServer
 
 kSecAttrProtocol
 
 kSecAttrAuthenticationType
 
 kSecAttrPort
 
 kSecAttrPath
 
 kSecAttrSynchronizable
 */
@interface ZXKeychainItem (InternetPassword)

/**
 @see kSecAttrSecurityDomain
 
 @abstract
 A key whose value is a string indicating the item's security domain.
 
 @discussion
 The corresponding value is of type CFStringRef and represents the Internet security domain. Items of class kSecClassInternetPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSString *securityDomain;

/**
 @see kSecAttrServer
 
 @abstract
 A key whose value is a string indicating the item's server.
 
 @discussion
 The corresponding value is of type CFStringRef and contains the server's domain name or IP address. Items of class kSecClassInternetPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSString *server;

/**
 @see kSecAttrProtocol
 
 @abstract
 A key whose value indicates the item's protocol.
 
 @discussion
 The corresponding value is of type CFNumberRef and denotes the protocol for this item (see Protocol Values). Items of class kSecClassInternetPassword have this attribute.
 */
@property (nonatomic, assign) ZXKeychainItemAttrProtocol protocol;

/**
 @see kSecAttrAuthenticationType
 
 @abstract
 A key whose value indicates the item's authentication scheme.
 
 @discussion
 The corresponding value is of type CFNumberRef and denotes the authentication scheme for this item (see Authentication Type Values).
 */
@property (nonatomic, assign) ZXKeychainItemAttrAuthType authenticationType;

/**
 @see kSecAttrPort
 
 @abstract
 A key whose value indicates the item's port.
 
 @discussion
 The corresponding value is of type CFNumberRef and represents an Internet port number. Items of class kSecClassInternetPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSNumber *port;

/**
 @see kSecAttrPath
 
 @abstract
 A key whose value is a string indicating the item's path attribute.
 
 @discussion
 The corresponding value is of type CFStringRef and represents a path, typically the path component of the URL. Items of class kSecClassInternetPassword have this attribute.
 */
@property (nonatomic, strong, nullable) NSString *path;

@end

NS_ASSUME_NONNULL_END
