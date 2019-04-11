//
// ZXDownloadTask.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
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

/**
 ZXDownloadState
 */
typedef NS_ENUM(NSInteger, ZXDownloadState) {
    ZXDownloadStateUnknown,
    ZXDownloadStateWaiting,
    ZXDownloadStateRunning,
    ZXDownloadStateSuspended,
    ZXDownloadStateCancelled,
    ZXDownloadStateCompleted,
};

/**
 ZXDownloadTask
 */
@interface ZXDownloadTask : NSObject <NSURLSessionDataDelegate>

/**
 The URL of this task
 */
@property (nonatomic, readonly, nonnull) NSURL *taskURL;

/**
 Identifier for this task
 */
@property (nonatomic, readonly, nonnull) NSString *taskIdentifier;

/**
 The local file path for this task
 */
@property (nonatomic, readonly, nonnull) NSString *localFilePath;

/**
 The current state of the task
 */
@property (nonatomic, assign) ZXDownloadState state;

/**
 The download data task
 */
@property (nonatomic, strong, nullable) NSURLSessionDataTask *dataTask;

/**
 Total bytes written
 */
@property (nonatomic, assign) int64_t totalBytesWritten;

/**
 Total bytes expected to write
 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

/**
 Init with URL

 @param URL The URL of download
 @return ZXDownloadTask
 */
- (instancetype _Nonnull)initWithURL:(NSURL *_Nonnull)URL;

/**
 Init with URL, save path

 @param URL The URL of download
 @param path The local path of download
 @return ZXDownloadTask
 */
- (instancetype _Nonnull)initWithURL:(NSURL *_Nonnull)URL path:(NSString *_Nullable)path;

/**
 Add observer

 @param observer The observer
 @param state A block object to be executed when the download state changed.
 @param progress A block object to be executed when the download progress changed.
 */
- (void)addObserver:(NSObject *_Nonnull)observer
              state:(void(^_Nullable)(ZXDownloadState state, NSString *_Nullable localFilePath, NSError *_Nullable error))state
           progress:(void(^_Nullable)(int64_t receivedSize, int64_t expectedSize, CGFloat progress))progress;

/**
 Remove observer

 @param observer The observer
 */
- (void)removeObserver:(NSObject *_Nonnull)observer;

@end
