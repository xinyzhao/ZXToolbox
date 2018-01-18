//
// ZXHashValue.m
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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

#import "ZXHashValue.h"
#import <CommonCrypto/CommonDigest.h>

@interface ZXHashValue ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;

@end

@implementation ZXHashValue

#define ZXHashValueBufferSize   4096

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        self.data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (instancetype)initWithFileAtPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.url = [NSURL fileURLWithPath:path];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        self.url = URL;
    }
    return self;
}

- (void)inputStreamWithURL:(NSURL *)URL
                readLength:(NSInteger)readLength
                readBuffer:(void(^)(const char *buffer, NSInteger length))readBuffer
                completion:(void(^)(NSError *error))completion {
    if (URL && readLength > 0) {
        NSInputStream *stream = [NSInputStream inputStreamWithURL:URL];
        [stream open];
        uint8_t buffer[readLength];
        NSError *error = nil;
        BOOL eof = NO;
        while (!eof) {
            NSInteger bytes = [stream read:buffer maxLength:readLength];
            if (bytes < 0) {
                error = stream.streamError;
                break;
            } else if (bytes == 0) {
                eof = YES;
            } else {
                if (readBuffer) {
                    readBuffer((const void *)buffer, bytes);
                }
            }
        }
        [stream close];
        //
        if (completion) {
            completion(error);
        }
    }
}

- (NSData *)MD5Data {
    __block NSData *data = nil;
    if (_data) {
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(_data.bytes, (CC_LONG)_data.length, digest);
        data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    } else if (_url) {
        __block CC_MD5_CTX object;
        CC_MD5_Init(&object);
        [self inputStreamWithURL:_url readLength:ZXHashValueBufferSize readBuffer:^(const char *buffer, NSInteger length) {
            CC_MD5_Update(&object, buffer, (CC_LONG)length);
        } completion:^(NSError *error) {
            if (error == nil) {
                unsigned char digest[CC_MD5_DIGEST_LENGTH];
                CC_MD5_Final(digest, &object);
                data = [NSData dataWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
            }
        }];
    }
    return data;
}

- (NSString *)MD5String {
    __block NSMutableString *str = nil;
    if (_data) {
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5(_data.bytes, (CC_LONG)_data.length, digest);
        str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [str appendFormat:@"%02X", digest[i]];
        }
    } else if (_url) {
        __block CC_MD5_CTX object;
        CC_MD5_Init(&object);
        [self inputStreamWithURL:_url readLength:ZXHashValueBufferSize readBuffer:^(const char *buffer, NSInteger length) {
            CC_MD5_Update(&object, buffer, (CC_LONG)length);
        } completion:^(NSError *error) {
            if (error == nil) {
                unsigned char digest[CC_MD5_DIGEST_LENGTH];
                CC_MD5_Final(digest, &object);
                //
                str = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
                for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
                    [str appendFormat:@"%02X", digest[i]];
                }
            }
        }];
    }
    return [str copy];
}

- (NSData *)SHA1Data {
    __block NSData *data = nil;
    if (_data) {
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(_data.bytes, (CC_LONG)_data.length, digest);
        data = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    } else if (_url) {
        __block CC_SHA1_CTX object;
        CC_SHA1_Init(&object);
        [self inputStreamWithURL:_url readLength:ZXHashValueBufferSize readBuffer:^(const char *buffer, NSInteger length) {
            CC_SHA1_Update(&object, (const void *)buffer, (CC_LONG)length);
        } completion:^(NSError *error) {
            if (error == nil) {
                unsigned char digest[CC_SHA1_DIGEST_LENGTH];
                CC_SHA1_Final(digest, &object);
                data = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
            }
        }];
    }
    return data;
}

- (NSString *)SHA1String {
    __block NSMutableString *str = nil;
    if (_data) {
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(_data.bytes, (CC_LONG)_data.length, digest);
        str = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [str appendFormat:@"%02X", digest[i]];
        }
    } else if (_url) {
        __block CC_SHA1_CTX object;
        CC_SHA1_Init(&object);
        [self inputStreamWithURL:_url readLength:ZXHashValueBufferSize readBuffer:^(const char *buffer, NSInteger length) {
            CC_SHA1_Update(&object, (const void *)buffer, (CC_LONG)length);
        } completion:^(NSError *error) {
            if (error == nil) {
                unsigned char digest[CC_SHA1_DIGEST_LENGTH];
                CC_SHA1_Final(digest, &object);
                //
                str = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
                for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
                    [str appendFormat:@"%02X", digest[i]];
                }
            }
        }];
    }
    return [str copy];
}

@end
