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

- (NSData *)encryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    return [self dataWithOperation:kCCEncrypt algorithm:algorithm mode:mode padding:padding key:key iv:iv error:error];
}

- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {
    return [self dataWithOperation:kCCDecrypt algorithm:algorithm mode:mode padding:padding key:key iv:iv error:error];
}

- (NSData *)dataWithOperation:(CCOperation)operation algorithm:(CCAlgorithm)algorithm mode:(CCMode)mode padding:(CCPadding)padding key:(id)key iv:(id _Nullable)iv error:(NSError **_Nullable)error {

    if (![self checkMode:mode error:error]) {
        return nil;
    }
    
    NSMutableData *keyData = [self copyMutableData:key];
    NSMutableData *ivData = [self copyMutableData:iv];
    [self setLengthForKey:keyData iv:ivData withAlgorithm:algorithm];
    
    NSData *data = nil;
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;

    status = CCCryptorCreateWithMode(operation, mode, algorithm, padding, ivData.bytes, keyData.bytes, keyData.length, NULL, 0, 0, 0, &cryptor);
    
    if (status == kCCSuccess) {
        BOOL isPadding = padding != ccNoPadding && algorithm != kCCAlgorithmRC4;
        data = [self cryptor:cryptor final:isPadding status:&status];
    }
    
    if (status != kCCSuccess && error) {
        *error = [self errorWithCryptorStatus:status];
    }
    
    CCCryptorRelease(cryptor);
    
    return data;
}

- (BOOL)checkMode:(CCMode)mode error:(NSError **_Nullable)error {
    NSArray *modes = @[@(kCCModeECB), @(kCCModeCBC), @(kCCModeCFB), @(kCCModeCTR), @(kCCModeOFB), @(kCCModeRC4), @(kCCModeCFB8)];
    if ([modes containsObject:@(mode)]) {
        return YES;
    }
    if (error) {
        *error = [NSError errorWithDomain:@"ZXCommonCryptor" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Mode error"}];
    }
    return NO;
}

- (NSMutableData *)copyMutableData:(id)value {
    NSMutableData *data = nil;
    if ([value isKindOfClass:[NSData class]]) {
        data = (NSMutableData *)[value mutableCopy];
    } else if ([value isKindOfClass:[NSString class]]) {
        data = [[value dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    return data;
}

- (void)setLengthForKey:(NSMutableData *)key iv:(NSMutableData *)iv withAlgorithm:(CCAlgorithm)alg {
    NSInteger len = [key length];
    switch (alg) {
        case kCCAlgorithmAES:
            if (len < kCCKeySizeAES128) {
                len = kCCKeySizeAES128;
            } else if (len < kCCKeySizeAES192) {
                len = kCCKeySizeAES192;
            } else {
                len = kCCKeySizeAES256;
            }
            break;
        case kCCAlgorithmDES:
            len = kCCKeySizeDES;
            break;
        case kCCAlgorithm3DES:
            len = kCCKeySize3DES;
            break;
        case kCCAlgorithmCAST:
            if (len < kCCKeySizeMinCAST) {
                len = kCCKeySizeMinCAST;
            } else if (len > kCCKeySizeMaxCAST) {
                len = kCCKeySizeMaxCAST;
            }
            break;
        case kCCAlgorithmRC4:
            if (len < kCCKeySizeMinRC4) {
                len = kCCKeySizeMinRC4;
            } else if (len > kCCKeySizeMaxRC4) {
                len = kCCKeySizeMaxRC4;
            }
            break;
        case kCCAlgorithmRC2:
            if (len < kCCKeySizeMinRC2) {
                len = kCCKeySizeMinRC2;
            } else if (len > kCCKeySizeMaxRC2) {
                len = kCCKeySizeMaxRC2;
            }
            break;
        case kCCAlgorithmBlowfish:
            if (len < kCCKeySizeMinBlowfish) {
                len = kCCKeySizeMinBlowfish;
            } else if (len > kCCKeySizeMaxBlowfish) {
                len = kCCKeySizeMaxBlowfish;
            }
            break;
    }
    key.length = len;
    iv.length = len;
}

- (NSData *)cryptor:(CCCryptorRef)cryptor final:(BOOL)final status:(CCCryptorStatus *)status {
    size_t offset = 0;
    size_t length = CCCryptorGetOutputLength(cryptor, [self length], final);
    void *buffer = malloc(length);
    // Update
    *status = CCCryptorUpdate(cryptor, [self bytes], [self length], buffer, length, &offset);
    if (*status != kCCSuccess) {
        free(buffer);
        return nil;
    }
    // Final
    if (final) {
        *status = CCCryptorFinal(cryptor, buffer + offset, length - offset, &offset);
        if (*status != kCCSuccess) {
            free(buffer);
            return nil;
        }
    }
    // Return
    return [NSData dataWithBytesNoCopy:buffer length:length];
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
