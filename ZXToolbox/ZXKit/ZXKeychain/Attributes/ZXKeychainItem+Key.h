//
// ZXKeychainItem+Key.h
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

/// Values you use with the kSecAttrKeyClass attribute key.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrKeyClass) {
    /// A public key of a public-private pair.
    ZXKeychainItemAttrKeyClassPublic,
    /// A private key of a public-private pair.
    ZXKeychainItemAttrKeyClassPrivate,
    /// A private key used for symmetric-key encryption and decryption.
    ZXKeychainItemAttrKeyClassSymmetric,
    /// Unspecified
    ZXKeychainItemAttrKeyClassUnspecified
};

/// Values you use with the kSecAttrKeyType attribute key.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrKeyType) {
    /// RSA algorithm.
    ZXKeychainItemAttrKeyTypeRSA,
    /// DSA algorithm.
    ZXKeychainItemAttrKeyTypeDSA API_AVAILABLE(macos(10.7), ios(NA)),
    /// AES algorithm.
    ZXKeychainItemAttrKeyTypeAES API_AVAILABLE(macos(10.7), ios(NA)),
    /// DES algorithm.
    ZXKeychainItemAttrKeyTypeDES API_AVAILABLE(macos(10.7), ios(NA)),
    /// 3DES algorithm.
    ZXKeychainItemAttrKeyType3DES API_AVAILABLE(macos(10.7), ios(NA)),
    /// RC4 algorithm.
    ZXKeychainItemAttrKeyTypeRC4 API_AVAILABLE(macos(10.7), ios(NA)),
    /// RC2 algorithm.
    ZXKeychainItemAttrKeyTypeRC2 API_AVAILABLE(macos(10.7), ios(NA)),
    /// CAST algorithm.
    ZXKeychainItemAttrKeyTypeCAST API_AVAILABLE(macos(10.7), ios(NA)),
    /// Elliptic curve DSA algorithm.
    ZXKeychainItemAttrKeyTypeECDSA API_AVAILABLE(macos(10.7), ios(NA)),
    /// Elliptic curve algorithm.
    ZXKeychainItemAttrKeyTypeEC API_AVAILABLE(macos(10.9), ios(NA)),
    /// Elliptic curve algorithm.
    ZXKeychainItemAttrKeyTypeECSECPrimeRandom API_AVAILABLE(macos(10.12), ios(10.0)),
    /// Unspecified
    ZXKeychainItemAttrKeyTypeUnspecified
};

API_AVAILABLE_BEGIN(macos(10.7), ios(NA))
/// Values you use with the kSecAttrPRF attribute key to indicate the item's pseudorandom function.
typedef NS_ENUM(NSInteger, ZXKeychainItemAttrPRF) {
    /// Use the SHA1 algorithm.
    ZXKeychainItemAttrPRFHmacAlgSHA1,
    /// Use the SHA224 algorithm.
    ZXKeychainItemAttrPRFHmacAlgSHA224,
    /// Use the SHA256 algorithm.
    ZXKeychainItemAttrPRFHmacAlgSHA256,
    /// Use the SHA384 algorithm.
    ZXKeychainItemAttrPRFHmacAlgSHA384,
    /// Use the SHA512 algorithm.
    ZXKeychainItemAttrPRFHmacAlgSHA512,
    /// Unspecified
    ZXKeychainItemAttrPRFUnspecified
};
API_AVAILABLE_END

/**
@see kSecClassKey

@abstract
The value that indicates a cryptographic key item.

@discussion
The following keychain item attributes apply to an item of this class:

kSecAttrAccess (macOS only)

kSecAttrAccessGroup (iOS only)

kSecAttrAccessible (iOS only)

kSecAttrKeyClass

kSecAttrLabel

kSecAttrApplicationLabel

kSecAttrIsPermanent

kSecAttrApplicationTag

kSecAttrKeyType

kSecAttrPRF

kSecAttrSalt

kSecAttrRounds

kSecAttrKeySizeInBits

kSecAttrEffectiveKeySize

kSecAttrCanEncrypt

kSecAttrCanDecrypt

kSecAttrCanDerive

kSecAttrCanSign

kSecAttrCanVerify

kSecAttrCanWrap

kSecAttrCanUnwrap
*/
@interface ZXKeychainItem (Key)

/**
 @see kSecAttrKeyClass
 
 @abstract
 A key whose value indicates the item's cryptographic key class.

 @discussion
 The corresponding value is of type CFTypeRef and specifies a type of cryptographic key. Possible values are listed in Key Class Values. Read only.

 Note

 Don't confuse this attribute with the more general kSecClass attribute that indicates an item's class (for example password, certificate, or cryptographic key). The kSecAttrKeyClass attribute described here applies only to items of class kSecClassKey, indicating what category a cryptographic key fits into (for example, public, private, or symmetric).
 */
@property (nonatomic, assign) ZXKeychainItemAttrKeyClass keyClass;

/**
 @see kSecAttrApplicationLabel
 
 @abstract
 A key whose value indicates the item's application label.

 @discussion
 The corresponding value is of type CFStringRef and contains a label for this item. This attribute is different from the kSecAttrLabel attribute, which is intended to be human-readable. Instead, this attribute is used to look up a key programmatically; in particular, for keys of class kSecAttrKeyClassPublic and kSecAttrKeyClassPrivate, the value of this attribute is the hash of the public key.
 */
@property (nonatomic, strong, nullable) NSString *applicationLabel;

/**
 @see kSecAttrIsPermanent
 
 @abstract
 A key whose value indicates the item's permanence.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether or not this cryptographic key or key pair should be stored in the default keychain at creation time.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanFalse.
 */
@property (nonatomic, assign) BOOL isPermanent;

/**
 @see kSecAttrApplicationTag
 
 @abstract
 A key whose value indicates the item's private tag.
 
 @discussion
 The corresponding value is of type CFDataRef and contains private tag data.

 On key creation, if not explicitly specified, this attribute defaults to NULL.
 */
@property (nonatomic, strong, nullable) NSData *applicationTag;

/**
 @see kSecAttrKeyType
 
 @abstract
 A key whose value indicates the item's algorithm.
 
 @discussion
 The corresponding value is of type CFNumberRef and indicates the algorithm associated with this cryptographic key. See Key Type Values for a list of valid values.
 */
@property (nonatomic, assign) ZXKeychainItemAttrKeyType keyType;

/**
 @see kSecAttrPRF
 
 @abstract
 A key whose value indicates the item's pseudorandom function.
 
 @discussion
 The corresponding value is of type CFStringRef and indicates the pseudorandom function associated with this cryptographic key. See Pseudorandom Function Values for a list of valid values.
 */
@property (nonatomic, assign) ZXKeychainItemAttrPRF PRF API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecAttrSalt
 
 @abstract
 A key whose value indicates the salt to use for this item.
 
 @discussion
 The corresponding value is of type CFDataRef that indicates the salt to use with this cryptographic key.
 */
@property (nonatomic, strong, nullable) NSData *salt API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecAttrRounds
 
 @abstract
 A key whose value indicates the number of rounds to run the pseudorandom function.
 
 @discussion
 The corresponding value is of type CFNumberRef and indicates the number of rounds to run the pseudorandom function specified by kSecAttrPRF for a cryptographic key.
 */
@property (nonatomic, strong, nullable) NSData *rounds API_AVAILABLE(macos(10.7), ios(NA));

/**
 @see kSecAttrKeySizeInBits
 
 @abstract
 A key whose value indicates the number of bits in a cryptographic key.
 
 @discussion
 The corresponding value is of type CFNumberRef and indicates the total number of bits in this cryptographic key.
 */
@property (nonatomic, strong, nullable) NSNumber *keySizeInBits;

/**
 @see kSecAttrEffectiveKeySize
 
 @abstract
 A key whose value indicates the effective number of bits in a cryptographic key.
 
 @discussion
 The corresponding value is of type CFNumberRef and indicates the effective number of bits in this cryptographic key. For example, a DES key has a kSecAttrKeySizeInBits of 64, but a kSecAttrEffectiveKeySize of 56 bits.
 */
@property (nonatomic, strong, nullable) NSNumber *effectiveKeySize;

/**
 @see kSecAttrCanEncrypt
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for encryption.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to encrypt data.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanFalse for private keys and kCFBooleanTrue for public keys.
 */
@property (nonatomic, assign) BOOL canEncrypt;

/**
 @see kSecAttrCanDecrypt
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for decryption.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to decrypt data.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanTrue for private keys and kCFBooleanFalse for public keys.
 */
@property (nonatomic, assign) BOOL canDecrypt;

/**
 @see kSecAttrCanDerive
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for derivation.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to derive another key.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanTrue.
 */
@property (nonatomic, assign) BOOL canDerive;

/**
 @see kSecAttrCanSign
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for digital signing.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to create a digital signature.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanTrue for private keys and kCFBooleanFalse for public keys.
 */
@property (nonatomic, assign) BOOL canSign;

/**
 @see kSecAttrCanVerify
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for signature verification.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to verify a digital signature.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanFalse for private keys and kCFBooleanTrue for public keys.
 */
@property (nonatomic, assign) BOOL canVerify;

/**
 @see kSecAttrCanWrap
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for wrapping.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to wrap another key.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanFalse for private keys and kCFBooleanTrue for public keys.
 */
@property (nonatomic, assign) BOOL canWrap;

/**
 @see kSecAttrCanUnwrap
 
 @abstract
 A key whose value is a Boolean that indicates whether the cryptographic key can be used for unwrapping.
 
 @discussion
 The corresponding value is of type CFBooleanRef and indicates whether this cryptographic key can be used to unwrap another key.

 On key creation, if not explicitly specified, this attribute defaults to kCFBooleanTrue for private keys and kCFBooleanFalse for public keys.
 */
@property (nonatomic, assign) BOOL canUnwrap;

@end

NS_ASSUME_NONNULL_END
