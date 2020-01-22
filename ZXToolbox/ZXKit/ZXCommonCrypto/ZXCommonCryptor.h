//
// ZXCommonCryptor.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

/// Symmetric encryption
@protocol ZXCommonCryptor <NSObject>

/// Create an encrypted NSData from an NSData or UTF-8 encoded NSString using the given options.
/// @param algorithm CCAlgorithm, kCCAlgorithmAES etc.
/// @param mode Cipher Modes
/// @param padding Padding for Block Ciphers
/// @param key raw Key material
/// @param iv  Initialization vector
/// @param error Error of encryption
/// @return Encrypted data if no error.
- (NSData *)encryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error;

/// Create a decrypted NSData from an NSData or UTF-8 encoded NSString using the given options.
/// @param algorithm Encryption algorithms implemented by this module.
/// @param mode Cipher Modes
/// @param padding Padding for Block Ciphers
/// @param key Raw key material
/// @param iv  Initialization vector
/// @param error Error of decryption
/// @return Decrypted data if no error.
- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error;

@end

@interface NSData (ZXCommonCryptor) <ZXCommonCryptor>

@end

@interface NSString (ZXCommonCryptor) <ZXCommonCryptor>

@end

NS_ASSUME_NONNULL_END
