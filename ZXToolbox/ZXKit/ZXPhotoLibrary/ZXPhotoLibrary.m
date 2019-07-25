//
// ZXPhotoLibrary.m
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

#import "ZXPhotoLibrary.h"

@interface ZXPhotoLibrary () <PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *changeObservers;

@end

@interface ZXPhotoGroup ()
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) PHAssetCollection *assetCollection NS_AVAILABLE_IOS(8_0);

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup;
- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection NS_AVAILABLE_IOS(8_0);

@end

@interface ZXPhotoAsset ()
@property (nonatomic, strong) ALAsset *alAsset;
@property (nonatomic, strong) PHAsset *phAsset NS_AVAILABLE_IOS(8_0);

- (instancetype)initWithALAsset:(ALAsset *)asset;
- (instancetype)initWithPHAsset:(PHAsset *)asset NS_AVAILABLE_IOS(8_0);

@end

#pragma mark - ZXPhotoLibrary

@implementation ZXPhotoLibrary

static ZXPhotoLibrary *_defaultLibrary = nil;

+ (ZXPhotoLibrary *)defaultLibrary {
    if (_defaultLibrary == nil) {
        _defaultLibrary = [[ZXPhotoLibrary alloc] init];
    }
    return _defaultLibrary;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (@available(iOS 8.0, *)) {
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        } else {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPhotoLibraryChanged:) name:ALAssetsLibraryChangedNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    if (@available(iOS 8.0, *)) {
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark Funcitons

- (void)requestAuthorization:(void(^)(ZXAuthorizationStatus status))completion {
    if (@available(iOS 8.0, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status)
        {
            case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            completion((NSInteger)status);
                        }
                    });
                }];
                break;
            }
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusAuthorized:
            default:
            {
                if (completion) {
                    completion((NSInteger)status);
                }
                break;
            }
        }
        
    } else {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (completion) {
            completion((NSInteger)status);
        }
    }
}

- (void)fetchGroupsWithAllAlbums:(BOOL)allAlbums completion:(void(^)(NSArray<ZXPhotoGroup *> *results))completion {
    NSMutableArray<ZXPhotoGroup *> *groups = [NSMutableArray array];
    //
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            PHFetchResult<PHAssetCollection *> *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            [smartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZXPhotoGroup *group = [[ZXPhotoGroup alloc] initWithAssetCollection:obj];
                if (allAlbums) {
                    [groups addObject:group];
                } else if (group.numberOfAssets > 0 && obj.assetCollectionSubtype != 1000000201) {
                    [groups addObject:group];
                }
            }];
            //
            PHFetchResult<PHAssetCollection *> *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZXPhotoGroup *group = [[ZXPhotoGroup alloc] initWithAssetCollection:obj];
                if (allAlbums) {
                    [groups addObject:group];
                } else if (group.numberOfAssets > 0) {
                    [groups addObject:group];
                }
            }];
            //
            if (completion) {
                completion(groups);
            }
            
        } else {
            if (self.assetsLibrary == nil) {
                self.assetsLibrary = [[ALAssetsLibrary alloc] init];
            }
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    ZXPhotoGroup *obj = [[ZXPhotoGroup alloc] initWithAssetsGroup:group];
                    if (allAlbums) {
                        [groups addObject:obj];
                    } else if (obj.numberOfAssets > 0) {
                        [groups addObject:obj];
                    }
                } else if (completion) {
                    completion(groups);
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"%s %@", __func__, error.localizedDescription);
            }];
        }
    }
}

- (void)fetchAssetsWithAscending:(BOOL)ascending completion:(void(^)(NSArray<ZXPhotoAsset *> *results))completion {
    NSMutableArray<ZXPhotoAsset *> *assets = [NSMutableArray array];
    //
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
            PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZXPhotoAsset *asset = [[ZXPhotoAsset alloc] initWithPHAsset:obj];
                if (asset.mediaType == ZXAssetMediaTypeImage || asset.mediaType == ZXAssetMediaTypeVideo) {
                    [assets addObject:asset];
                }
            }];
            //
            if (completion) {
                completion(assets);
            }
            
        } else {
            [self fetchGroupsWithAllAlbums:NO completion:^(NSArray<ZXPhotoGroup *> *groups) {
                [groups enumerateObjectsUsingBlock:^(ZXPhotoGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj fetchAssetsWithAscending:ascending completion:^(NSArray<ZXPhotoAsset *> *results) {
                        [assets addObjectsFromArray:results];
                    }];
                }];
                //
                if (completion) {
                    completion(assets);
                }
            }];
            
        }
    }
}

#pragma mark ZXPhotoLibraryChangeObserver

- (void)registerChangeObserver:(id<ZXPhotoLibraryChangeObserver>)observer {
    if (self.changeObservers == nil) {
        self.changeObservers = [NSMutableArray array];
    }
    if (observer) {
        [self.changeObservers addObject:observer];
    }
}

- (void)unregisterChangeObserver:(id<ZXPhotoLibraryChangeObserver>)observer {
    if (observer) {
        [self.changeObservers removeObject:observer];
    }
}

#pragma mark ALAssetsLibraryChangedNotification

- (void)onPhotoLibraryChanged:(NSNotification *)notification {
    [self.changeObservers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(photoLibraryDidChange:)]) {
            [obj photoLibraryDidChange:notification];
        }
    }];
}

#pragma mark <PHPhotoLibraryChangeObserver>

- (void)photoLibraryDidChange:(PHChange *)changeInstance __IOS_AVAILABLE(8_0) {
    [self.changeObservers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(photoLibraryDidChange:)]) {
            [obj photoLibraryDidChange:changeInstance];
        }
    }];
}

#pragma mark UIImageWriteToSavedPhotosAlbum

typedef void (^_saveImageBlock)(NSError *error);

- (void)saveImage:(UIImage *)image toPhotoAlbum:(void (^)(NSError *error))completion {
    //
    static dispatch_queue_t saveQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveQueue = dispatch_queue_create("photo.library.save.queue", NULL);
    });
    //
    if (@available(iOS 9.0, *)) {
        void (^completionHandler)(NSError *error) = ^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(error);
                }
            });
        };
        //
        dispatch_async(saveQueue, ^{
            __block PHAssetCollection *assetCollection = nil;
            // 获得相簿
            NSString *title = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
            PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            [result enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.localizedTitle isEqualToString:title]) {
                    assetCollection = obj;
                    *stop = YES;
                }
            }];
            // 创建相簿
            NSError *error = nil;
            if (assetCollection == nil) {
                __block NSString *identifier = nil;
                //
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    identifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
                } error:&error];
                //
                if (error == nil) {
                    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[identifier] options:nil];
                    assetCollection = result.firstObject;
                }
            }
            // 保存图片
            if (assetCollection) {
                __block  NSString *identifier;
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    identifier = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].lastObject;
                            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                            [request addAssets:@[asset]];
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            completionHandler(success ? nil : error);
                        }];
                    } else {
                        completionHandler(error);
                    }
                }];
            } else {
                completionHandler(error);
            };
        });
        
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(saveQueue, ^{
            UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)completion);
        });
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        _saveImageBlock completion = (__bridge _saveImageBlock)contextInfo;
        if (completion) {
            completion(error);
        }
    });
}

@end

#pragma mark - ZXPhotoGroup

@implementation ZXPhotoGroup

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (self) {
        self.assetsGroup = assetsGroup;
    }
    return self;
}

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection {
    self = [super init];
    if (self) {
        self.assetCollection = assetCollection;
    }
    return self;
}

- (NSString *)groupName {
    if (@available(iOS 8.0, *)) {
        return self.assetCollection.localizedTitle;
    } else {
        return [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    }
}

- (UIImage *)posterImage {
    __block UIImage *image = nil;
    //
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.mediaType == PHAssetMediaTypeImage || obj.mediaType == PHAssetMediaTypeVideo) {
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    options.synchronous = YES;
                    [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeZero contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        image = result;
                    }];
                    *stop = YES;
                }
            }];
            
        } else {
            CGImageRef imageRef = [self.assetsGroup posterImage];
            if (imageRef) {
                image = [UIImage imageWithCGImage:[self.assetsGroup posterImage]];
            }
        }
    }
    //
    return image;
}

- (NSUInteger)numberOfAssetsWithMediaType:(ZXAssetMediaType)type {
    NSUInteger count = 0;
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            if (self.assetCollection) {
                PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:nil];
                count = [assets countOfAssetsWithMediaType:(NSInteger)type];
            }

        } else {
            ALAssetsFilter *filter = nil;
            if (type == ZXAssetMediaTypeImage) {
                filter = [ALAssetsFilter allPhotos];
            } else if (type == ZXAssetMediaTypeVideo) {
                filter = [ALAssetsFilter allVideos];
            }
            if (filter) {
                [self.assetsGroup setAssetsFilter:filter];
                count = [self.assetsGroup numberOfAssets];
            }
        }
    }
    return count;
}

- (void)fetchAssetsWithAscending:(BOOL)ascending completion:(void(^)(NSArray<ZXPhotoAsset *> *results))completion {
    NSMutableArray<ZXPhotoAsset *> *assets = [NSMutableArray array];
    //
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
            [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZXPhotoAsset *asset = [[ZXPhotoAsset alloc] initWithPHAsset:obj];
                if (asset.mediaType == ZXAssetMediaTypeImage || asset.mediaType == ZXAssetMediaTypeVideo) {
                    [assets addObject:asset];
                }
            }];
            
        } else {
            [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
            if (ascending) {
                [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        ZXPhotoAsset *asset = [[ZXPhotoAsset alloc] initWithALAsset:result];
                        if (asset.mediaType == ZXAssetMediaTypeImage || asset.mediaType == ZXAssetMediaTypeVideo) {
                            [assets addObject:asset];
                        }
                    }
                }];
            } else {
                [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                        ZXPhotoAsset *asset = [[ZXPhotoAsset alloc] initWithALAsset:result];
                        if (asset.mediaType == ZXAssetMediaTypeImage || asset.mediaType == ZXAssetMediaTypeVideo) {
                            [assets addObject:asset];
                        }
                    }
                }];
            }
            
        }
    }
    //
    if (completion) {
        completion(assets);
    }
}

- (NSUInteger)numberOfAssets {
    NSInteger count = 0;
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            if (self.assetCollection) {
                PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:nil];
                count = assets.count;
            }

        } else {
            [self.assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
            count = self.assetsGroup.numberOfAssets;
        }
    }
    return count;
}

@end

#pragma mark - ZXPhotoAsset

@implementation ZXPhotoAsset

- (instancetype)initWithALAsset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        self.alAsset = asset;
    }
    return self;
}

- (instancetype)initWithPHAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.phAsset = asset;
    }
    return self;
}

- (ZXAssetMediaType)mediaType {
    if (@available(iOS 8.0, *)) {
        return (NSInteger)self.phAsset.mediaType;
    } else {
        NSString *type = [self.alAsset valueForProperty:ALAssetPropertyType];
        if ([type isEqualToString:ALAssetTypePhoto]) {
            return ZXAssetMediaTypeImage;
        } else if ([type isEqualToString:ALAssetTypeVideo]) {
            return ZXAssetMediaTypeVideo;
        } else {
            return ZXAssetMediaTypeUnknown;
        }
    }
}

- (CGSize)mediaSize {
    CGSize size = [self pixelSize];
    size.width /= [UIScreen mainScreen].scale;
    size.height /= [UIScreen mainScreen].scale;
    return size;
}

- (CGSize)pixelSize {
    CGSize size = CGSizeZero;
    if (@available(iOS 8.0, *)) {
        size.width = self.phAsset.pixelWidth;
        size.height = self.phAsset.pixelHeight;
    } else {
        size = [self.alAsset defaultRepresentation].dimensions;
    }
    return size;
}

- (NSUInteger)numberOfBytes {
    NSUInteger bytes = 0;
    if (@available(iOS 8.0, *)) {
        bytes = self.imageData.length;
    } else {
        bytes = [NSNumber numberWithLongLong:[self.alAsset defaultRepresentation].size].unsignedIntegerValue;
    }
    return bytes;
}

- (UIImageOrientation)orientation {
    UIImageOrientation orientation = UIImageOrientationUp;
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            if (self.phAsset) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:self.phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    orientation = orientation;
                }];
            }
        } else {
            orientation = (NSInteger)[self.alAsset defaultRepresentation].orientation;
        }
    }
    return orientation;
}

- (NSData *)imageData {
    __block NSData *data = nil;
    //
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            if (self.phAsset) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:self.phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    data = imageData;
                }];
            }
            
        } else {
            ALAssetRepresentation *rep = [self.alAsset defaultRepresentation];
            NSUInteger bytes = [NSNumber numberWithLongLong:rep.size].unsignedIntegerValue;
            uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t) * bytes);
            if (buffer != NULL) {
                NSError *error = nil;
                NSUInteger length = [rep getBytes:buffer fromOffset:0 length:bytes error:&error];
                data = [NSData dataWithBytes:buffer length:length];
                free(buffer);
            }
        }
    }
    //
    return data;
}

- (UIImage *)imageForAspectFill:(BOOL)aspectFill targetSize:(CGSize)targetSize {
    __block UIImage *image = nil;
    //
    CGSize imageSize = self.pixelSize;
    CGSize thumbSize = targetSize;
    thumbSize.width *= [UIScreen mainScreen].scale;
    thumbSize.height *= [UIScreen mainScreen].scale;
    //
    if (aspectFill) {
        CGFloat x = thumbSize.width / imageSize.width;
        CGFloat y = thumbSize.height / imageSize.height;
        if (x < y) {
            thumbSize.width = imageSize.width * y;
        } else {
            thumbSize.height = imageSize.height * x;
        }
    }
    //
    @autoreleasepool {
        if (@available(iOS 8.0, *)) {
            if (self.phAsset) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeExact;
                //
                [[PHImageManager defaultManager] requestImageForAsset:self.phAsset targetSize:thumbSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    image = result;
                }];
            }
            
        } else {
            NSData *imageData = self.imageData;
            if (imageData) {
                CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
                if (sourceRef) {
                    CGFloat maxPixelSize = MAX(thumbSize.width, thumbSize.height);
                    NSDictionary *options = @{(id)kCGImageSourceCreateThumbnailFromImageAlways:(id)kCFBooleanTrue,
                                              (id)kCGImageSourceThumbnailMaxPixelSize:@(maxPixelSize)
                                              };
                    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (CFDictionaryRef)options);
                    image = [[UIImage alloc] initWithCGImage:imageRef
                                                       scale:[UIScreen mainScreen].scale
                                                 orientation:self.orientation];
                    CGImageRelease(imageRef);
                    CFRelease(sourceRef);
                }
            }
        }
    }
    //
    return image;
}

@end
