//
// ZXCommonHMAC.m
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

#import "ZXCommonHMAC.h"

@implementation NSData (ZXCommonHMAC)

// Ref https://github.com/Gurpartap/AESCrypt-ObjC/blob/master/NSData+CommonCrypto.m
- (NSData *)dataUsingHmacAlgorithm:(CCHmacAlgorithm)algorithm forKey:(id)key {
    NSData *data = nil;
    if (key == nil || [key isKindOfClass:NSData.class] || [key isKindOfClass:NSString.class]) {
        NSData *keyData = nil;
        if ([key isKindOfClass:NSString.class]) {
            keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([key isKindOfClass:NSData.class]) {
            keyData = key;
        }
        if (keyData) {
            // this could be either CC_SHA1_DIGEST_LENGTH or CC_MD5_DIGEST_LENGTH. SHA1 is larger.
            int len = (algorithm == kCCHmacAlgMD5 ? CC_MD5_DIGEST_LENGTH : CC_SHA1_DIGEST_LENGTH);
            unsigned char *buf = malloc(len);
            CCHmac(algorithm, keyData.bytes, keyData.length, self.bytes, self.length, buf);
            data = [NSData dataWithBytes:buf length:len];
            free(buf);
        }
    }
    return data;
}

- (NSString *)stringUsingHmacAlgorithm:(CCHmacAlgorithm)algorithm forKey:(id)key {
    NSMutableString *str = [[NSMutableString alloc] init];
    NSData *data = [self dataUsingHmacAlgorithm:algorithm forKey:key];
    if (data) {
        unsigned char *bytes = (unsigned char *)data.bytes;
        for(int i = 0; i < data.length; i++) {
            [str appendFormat:@"%02X", bytes[i]];
        }
    }
    return [str copy];
}

@end

@implementation NSString (ZXCommonHMAC)

- (NSData *)dataUsingHmacAlgorithm:(CCHmacAlgorithm)algorithm forKey:(id)key {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data dataUsingHmacAlgorithm:algorithm forKey:key];
}

- (NSString *)stringUsingHmacAlgorithm:(CCHmacAlgorithm)algorithm forKey:(id)key {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data stringUsingHmacAlgorithm:algorithm forKey:key];
}

@end
