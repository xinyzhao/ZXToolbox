//
// ZXDownloadManager.h
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

#import "ZXDownloadTask.h"

/**
 ZXDownloadManager
 */
@interface ZXDownloadManager : NSObject

/**
 The shared instance of ZXDownloadManager

 @return ZXDownloadManager
 */
+ (instancetype _Nonnull)sharedManager;

/**
 Default directory where the downloaded files are saved.
 */
@property (nonatomic, copy, nonnull) NSString *localPath;

/**
 Maximum number of concurrent downloads, default is 0 which means no limit.
 */
@property (nonatomic, assign) NSInteger maximumConcurrent;

/**
 Resume broken download enabled or not, default is YES, maybe not work!
 */
@property (nonatomic, assign) BOOL resumeBrokenEnabled;

/**
 Enable to allow untrusted SSL certificates, default YES.
 */
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 The credential that should be used for authentication.
 */
@property (nonatomic, strong) NSURLCredential * _Nullable credential;

/**
 Create or got exist download task with URL

 @param URL The URL
 @return ZXDownloadTask
 */
- (ZXDownloadTask *_Nullable)downloadTaskWithURL:(NSURL *_Nonnull)URL;

/**
 Create or got exist download task with URL
 
 @param URL The URL
 @param path The save directory, Ignore localPath if setted.
 @param backgroundMode Downloads in background or not.
 @return ZXDownloadTask
 */
- (ZXDownloadTask *_Nullable)downloadTaskWithURL:(NSURL *_Nonnull)URL inDirectory:(NSString *_Nullable)path inBackground:(BOOL)backgroundMode;

/**
 Suspend the download task for URL

 @param URL The URL
 */
- (void)suspendTaskForURL:(NSURL *_Nonnull)URL;

/**
 Suspend the download task

 @param task The task
 */
- (void)suspendTask:(ZXDownloadTask *_Nonnull)task;

/**
 Suspend all download tasks
 */
- (void)suspendAllTasks;

/**
 Resume or start the download task for URL

 @param URL The URL
 */
- (void)resumeTaskForURL:(NSURL *_Nonnull)URL;

/**
 Resume or start the download task

 @param task The task
 @return True resume success
 */
- (BOOL)resumeTask:(ZXDownloadTask *_Nonnull)task;

/**
 Resume or start all download tasks
 */
- (void)resumeAllTasks;

/**
 Cancel the download task for URL

 @param URL URL
 */
- (void)cancelTaskForURL:(NSURL *_Nonnull)URL;

/**
 Cancel the download task

 @param task The task
 */
- (void)cancelTask:(ZXDownloadTask *_Nonnull)task;

/**
 Cancel all download tasks
 */
- (void)cancelAllTasks;

@end
