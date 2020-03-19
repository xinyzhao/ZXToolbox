//
// ZXCommonCryptor.m
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

#import "ZXCommonCryptor.h"

@implementation NSData (ZXCommonCryptor)

- (NSString *)algorithmName:(CCAlgorithm)algorithm {
    NSArray *names = @[@"AES",
                       @"DES",
                       @"3DES",
                       @"CAST",
                       @"RC4",
                       @"RC2",
                       @"Blowfish"
    ];
    if (algorithm >= 0 && algorithm < kCCAlgorithmBlowfish) {
        return names[algorithm];
    }
    return nil;
}

- (BOOL)checkCryptorCipherMode:(CCMode)mode error:(NSError **_Nullable)error {
    NSArray *modes = @[@(kCCModeECB), @(kCCModeCBC), @(kCCModeCFB), @(kCCModeCTR), @(kCCModeOFB), @(kCCModeRC4), @(kCCModeCFB8)];
    if ([modes containsObject:@(mode)]) {
        return YES;
    }
    if (error) {
        id userInfo = @{NSLocalizedDescriptionKey:@"Invalid Mode"};
        *error = [NSError errorWithDomain:@"ZXCommonCryptor" code:-1 userInfo:userInfo];
    }
    return NO;
}

- (NSData *)copyData:(id)obj {
    NSData *data = nil;
    if ([obj isKindOfClass:[NSData class]]) {
        data = [obj copy];
    } else if ([obj isKindOfClass:[NSString class]]) {
        data = [[obj dataUsingEncoding:NSUTF8StringEncoding] copy];
    }
    return data;
}

- (NSInteger)keySize:(NSInteger)size forAlgorithm:(CCAlgorithm)algorithm {
    switch (algorithm) {
        case kCCAlgorithmAES:
            if (size <= kCCKeySizeAES128) {
                size = kCCKeySizeAES128;
            } else if (size <= kCCKeySizeAES192) {
                size = kCCKeySizeAES192;
            } else {
                size = kCCKeySizeAES256;
            }
            break;
        case kCCAlgorithmDES:
            size = kCCKeySizeDES;
            break;
        case kCCAlgorithm3DES:
            size = kCCKeySize3DES;
            break;
        case kCCAlgorithmCAST:
            if (size < kCCKeySizeMinCAST) {
                size = kCCKeySizeMinCAST;
            } else if (size > kCCKeySizeMaxCAST) {
                size = kCCKeySizeMaxCAST;
            }
            break;
        case kCCAlgorithmRC4:
            if (size < kCCKeySizeMinRC4) {
                size = kCCKeySizeMinRC4;
            } else if (size > kCCKeySizeMaxRC4) {
                size = kCCKeySizeMaxRC4;
            }
            break;
        case kCCAlgorithmRC2:
            if (size < kCCKeySizeMinRC2) {
                size = kCCKeySizeMinRC2;
            } else if (size > kCCKeySizeMaxRC2) {
                size = kCCKeySizeMaxRC2;
            }
            break;
        case kCCAlgorithmBlowfish:
            if (size < kCCKeySizeMinBlowfish) {
                size = kCCKeySizeMinBlowfish;
            } else if (size > kCCKeySizeMaxBlowfish) {
                size = kCCKeySizeMaxBlowfish;
            }
            break;
    }
    return size;
}

- (NSData *)keyData:(id)obj forAlgorithm:(CCAlgorithm)algorithm error:(NSError *_Nullable *_Nullable)error {
    NSData *data = [self copyData:obj];
    NSInteger size = [self keySize:data.length forAlgorithm:algorithm];
    if (data.length != size) {
        if (error) {
            id msg = [NSString stringWithFormat:@"Length of secret key should be %d for %d bits key size", (int)size, (int)size * 8];
            id userInfo = @{NSLocalizedDescriptionKey:msg};
            *error = [NSError errorWithDomain:@"ZXCommonCryptor" code:-1 userInfo:userInfo];
        }
        return nil;
    }
    return [data copy];
}

- (NSInteger)ivSize:(NSInteger)size forAlgorithm:(CCAlgorithm)algorithm {
    switch (algorithm) {
        case kCCAlgorithmAES:
            size = kCCBlockSizeAES128;
            break;
        case kCCAlgorithmDES:
            size = kCCBlockSizeDES;
            break;
        case kCCAlgorithm3DES:
            size = kCCBlockSize3DES;
            break;
        case kCCAlgorithmCAST:
            size = kCCBlockSizeCAST;
            break;
        case kCCAlgorithmRC4:
            size = 1;
            break;
        case kCCAlgorithmRC2:
            size = kCCBlockSizeRC2;
            break;
        case kCCAlgorithmBlowfish:
            size = kCCBlockSizeBlowfish;
            break;
    }
    return size;
}

- (NSData *)ivData:(id)obj forAlgorithm:(CCAlgorithm)algorithm error:(NSError *_Nullable *_Nullable)error {
    NSData *data = [self copyData:obj];
    NSInteger size = [self ivSize:data.length forAlgorithm:algorithm];
    if (data.length != size) {
        if (error) {
            id alg = [self algorithmName:algorithm];
            id msg = [NSString stringWithFormat:@"Length of initialization vector must be %d with %@.", (int)size, alg];
            id userInfo = @{NSLocalizedDescriptionKey:msg};
            *error = [NSError errorWithDomain:@"ZXCommonCryptor" code:-1 userInfo:userInfo];
        }
        return nil;
    }
    return [data copy];
}

- (BOOL)checkCryptorStatus:(CCCryptorStatus)status error:(NSError *_Nullable *_Nullable)error {
    if (status != kCCSuccess) {
        if (error) {
            *error = [self errorWithCryptorStatus:status];
        }
        return NO;
    }
    return YES;
}

- (NSError *)errorWithCryptorStatus:(CCCryptorStatus)status {
    NSString *desc = nil;
    switch (status) {
        case kCCSuccess:
            desc = @"Success";
            break;
        case kCCParamError:
            desc = @"Param error";
            break;
        case kCCBufferTooSmall:
            desc = @"Buffer too small";
            break;
        case kCCMemoryFailure:
            desc = @"Memory failure";
            break;
        case kCCAlignmentError:
            desc = @"Alignment error";
            break;
        case kCCDecodeError:
            desc = @"Decode error";
            break;
        case kCCUnimplemented:
            desc = @"Unimplemented";
            break;
        case kCCOverflow:
            desc = @"Overflow";
            break;
        case kCCRNGFailure:
            desc = @"RNG Failure";
            break;
        case kCCUnspecifiedError:
            desc = @"Unspecified error";
            break;
        case kCCCallSequenceError:
            desc = @"Call sequence error";
            break;
        case kCCKeySizeError:
            desc = @"Key size error";
            break;
        case kCCInvalidKey:
            desc = @"Invalid key";
            break;
        default:
            desc = @"Unkown error";
            break;
    }
    return [NSError errorWithDomain:@"ZXCommonCryptor" code:status userInfo:@{NSLocalizedDescriptionKey:desc}];
}

- (NSData *)cryptWithOperation:(CCOperation)operation algorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    // Check Mode
    if (![self checkCryptorCipherMode:mode error:error]) {
        return nil;
    }
    // Check Key length
    NSData *keyData = [self keyData:key forAlgorithm:algorithm error:error];
    if (keyData == nil) {
        return nil;
    }
    // Check IV length
    NSData *ivData = [self ivData:iv forAlgorithm:algorithm error:error];
    if (iv && ivData == nil) {
        return nil;
    }
    // Create cryptor
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = CCCryptorCreateWithMode(operation, mode, algorithm, padding, ivData.bytes, keyData.bytes, keyData.length, NULL, 0, 0, 0, &cryptor);
    if (![self checkCryptorStatus:status error:error]) {
        return nil;
    }
    // Update cryptor
    size_t updateLen, finalLen;
    const void *dataIn = [self bytes];
    size_t dataInLength = [self length];
    size_t dataOutAvailable = CCCryptorGetOutputLength(cryptor, dataInLength, true);
    void *dataOut = malloc(dataOutAvailable);
    status = CCCryptorUpdate(cryptor, dataIn, dataInLength, dataOut, dataOutAvailable, &updateLen);
    if (![self checkCryptorStatus:status error:error]) {
        free(dataOut);
        CCCryptorRelease(cryptor);
        return nil;
    }
    // Final cryptor
    status = CCCryptorFinal(cryptor, dataOut + updateLen, dataOutAvailable - updateLen, &finalLen);
    if (![self checkCryptorStatus:status error:error]) {
        free(dataOut);
        CCCryptorRelease(cryptor);
        return nil;
    }
    // Release cryptor
    CCCryptorRelease(cryptor);
    // Return data
    return [NSData dataWithBytesNoCopy:dataOut length:updateLen + finalLen];
}

- (NSData *)encryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    return [self cryptWithOperation:kCCEncrypt algorithm:algorithm mode:mode padding:padding key:key iv:iv error:error];
}

- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    return [self cryptWithOperation:kCCDecrypt algorithm:algorithm mode:mode padding:padding key:key iv:iv error:error];
}

@end

@implementation NSString (ZXCommonCryptor)

- (NSData *)encryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data encryptedDataUsingAlgorithm:algorithm mode:mode padding:padding key:key iv:iv error:error];
}

- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data decryptedDataUsingAlgorithm:algorithm mode:mode padding:padding key:key iv:iv error:error];
}

@end
