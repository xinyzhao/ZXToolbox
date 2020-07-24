//
// ZXDownloadTask.h
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

NS_ASSUME_NONNULL_BEGIN

/// ZXDownloadTask
@interface ZXDownloadTask : NSObject <NSURLSessionDataDelegate>

/// The unique identifier for task
@property (nonatomic, readonly) NSURL *URL;

/// The unique identifier for task
@property (nonatomic, readonly) NSString *taskIdentifier;

/// The current state of the task—active, suspended, in the process of being canceled, or completed.
@property (nonatomic, readonly) NSURLSessionTaskState state;

/// Location of the downloaded file
@property (nonatomic, readonly) NSString *filePath;

/// Total bytes written
@property (nonatomic, readonly) int64_t totalBytesWritten;

/// Total bytes expected to write
@property (nonatomic, readonly) int64_t totalBytesExpectedToWrite;

/// Init
/// @param URL The download URL
/// @param path The local path of download
/// @param session The URL session
- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path session:(NSURLSession *)session;

/// Init
/// @param URL The download URL
/// @param path The local path of download
/// @param session The URL session
/// @param resumeBroken Resume broken download or not
- (instancetype)initWithURL:(NSURL *)URL path:(NSString *)path session:(NSURLSession *)session resumeBroken:(BOOL)resumeBroken;

/// Add observer
/// @param observer The observer
/// @param state A block object to be executed when the download state changed.
/// @param progress  A block object to be executed when the download progress changed.
- (void)addObserver:(id)observer
              state:(void(^_Nullable)(NSURLSessionTaskState state, NSString *_Nullable filePath, NSError *_Nullable error))state
           progress:(void(^_Nullable)(int64_t receivedSize, int64_t expectedSize, float progress))progress;

/// Remove observer
/// @param observer observer The observer
- (void)removeObserver:(id)observer;

/// Cancel the task
- (void)cancel;

/// Suspend the task
- (void)suspend;

/// Resume the task. If the destination file exists, will be issued by state observer a NSFileWriteFileExistsError error
- (void)resume;

@end

@interface NSURL (ZXDownloadTask)

/// An unique identifier for URL
- (nullable NSString *)taskIdentifier;

@end

@interface NSURLSessionTask (ZXDownloadTask)

/// The URL of task
- (nullable NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
