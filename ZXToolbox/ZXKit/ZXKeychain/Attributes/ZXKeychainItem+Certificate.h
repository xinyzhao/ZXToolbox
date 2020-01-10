//
// ZXKeychainItem+Certificate.h
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

/**
@see kSecClassCertificate

@abstract
The value that indicates a certificate item.

@discussion
The following keychain item attributes apply to an item of this class:

kSecAttrAccess (macOS only)

kSecAttrAccessGroup (iOS only)

kSecAttrAccessible (iOS only)

kSecAttrCertificateType

kSecAttrCertificateEncoding

kSecAttrLabel

kSecAttrSubject

kSecAttrIssuer

kSecAttrSerialNumber

kSecAttrSubjectKeyID

kSecAttrPublicKeyHash
*/
@interface ZXKeychainItem (Certificate)

/**
 @see kSecAttrCertificateType
 
 @abstract
 A key whose value indicates the item's certificate type.
 
 @discussion
 The corresponding value is of type CFNumberRef and denotes the certificate type (see the CSSM_CERT_TYPE enumeration in cssmtype.h). Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSNumber *certificateType;

/**
 @see kSecAttrCertificateEncoding
 
 @abstract
 A key whose value indicates the item's certificate encoding.
 
 @discussion
 The corresponding value is of type CFNumberRef and denotes the certificate encoding (see the CSSM_CERT_ENCODING enumeration in cssmtype.h). Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSNumber *certificateEncoding;

/**
 @see kSecAttrSubject
 
 @abstract
 A key whose value indicates the item's subject name.
 
 @discussion
 The corresponding value is of type CFDataRef and contains the X.500 subject name of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSData *subject;

/**
 @see kSecAttrIssuer
 
 @abstract
 A key whose value indicates the item's issuer.
 
 @discussion
 The corresponding value is of type CFDataRef and contains the X.500 issuer name of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSData *issuer;

/**
 @see kSecAttrSerialNumber
 
 @abstract
 A key whose value indicates the item's serial number.
 
 @discussion
 The corresponding value is of type CFDataRef and contains the serial number data of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSData *serialNumber;

/**
 @see kSecAttrSubjectKeyID
 
 @abstract
 A key whose value indicates the item's subject key ID.
 
 @discussion
 The corresponding value is of type CFDataRef and contains the subject key ID of a certificate. Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSData *subjectKeyID;

/**
 @see kSecAttrPublicKeyHash
 
 @abstract
 A key whose value indicates the item's public key hash.
 
 @discussion
 The corresponding value is of type CFDataRef and contains the hash of a certificate's public key. Items of class kSecClassCertificate have this attribute. Read only.
 */
@property (nonatomic, readonly, nullable) NSData *publicKeyHash;

@end

NS_ASSUME_NONNULL_END
