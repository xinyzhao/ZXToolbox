//
// ZXPhotoLibrary.h
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

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>

@class ZXPhotoGroup;
@class ZXPhotoAsset;

/**
 ZXAuthorizationStatus
 */
typedef NS_ENUM(NSInteger, ZXAuthorizationStatus) {
    ZXAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    ZXAuthorizationStatusRestricted,        // This application is not authorized to access photo data.
                                            // The user cannot change this application’s status, possibly due to active restrictions
                                            //   such as parental controls being in place.
    ZXAuthorizationStatusDenied,            // User has explicitly denied this application access to photos data.
    ZXAuthorizationStatusAuthorized         // User has authorized this application to access photos data.
} NS_AVAILABLE_IOS(7_0);

/**
 ZXAssetMediaType
 */
typedef NS_ENUM(NSInteger, ZXAssetMediaType) {
    ZXAssetMediaTypeUnknown = 0,
    ZXAssetMediaTypeImage   = 1,
    ZXAssetMediaTypeVideo   = 2,
    ZXAssetMediaTypeAudio   = 3,
} NS_ENUM_AVAILABLE_IOS(7_0);

/**
 ZXPhotoLibraryChangeObserver
 */
@protocol ZXPhotoLibraryChangeObserver <NSObject>
/**
 This callback is invoked on an arbitrary serial queue. If you need this to be handled on a specific queue, you should redispatch appropriately

 @param sender PHChange object in iOS 8 and later, otherwise is NSNotifation object
 */
- (void)photoLibraryDidChange:(id)sender;
@end

/**
 ZXPhotoLibrary
 */
@interface ZXPhotoLibrary : NSObject

/**
 The default instance

 @return ZXPhotoLibrary
 */
+ (ZXPhotoLibrary *)defaultLibrary;

/**
 Request authorization

 @param completion response block
 */
- (void)requestAuthorization:(void(^)(ZXAuthorizationStatus status))completion;

/**
 Get photo groups

 @param allAlbums all albums or usually albums
 @param completion results block
 */
- (void)fetchGroupsWithAllAlbums:(BOOL)allAlbums completion:(void(^)(NSArray<ZXPhotoGroup *> *results))completion;

/**
 Get sorted assets
 
 @param ascending sort for creation date
 @param completion results block
 */
- (void)fetchAssetsWithAscending:(BOOL)ascending completion:(void(^)(NSArray<ZXPhotoAsset *> *results))completion;

/**
 Save image to photo album

 @param image the UIImage
 @param completion result block
 */
- (void)saveImage:(UIImage *)image toPhotoAlbum:(void(^)(NSError *error))completion;

/**
 Register change observer, use unregisterChangeObserver: to unregister

 @param observer Observer
 */
- (void)registerChangeObserver:(id<ZXPhotoLibraryChangeObserver>)observer;

/**
 Unregister change observer

 @param observer Observer
 */
- (void)unregisterChangeObserver:(id<ZXPhotoLibraryChangeObserver>)observer;

@end

/**
 ZXPhotoGroup
 */
@interface ZXPhotoGroup : NSObject
/**
 The group name
 */
@property (nonatomic, assign, readonly) NSString *groupName;
/**
 The Poster image
 */
@property (nonatomic, assign, readonly) UIImage *posterImage;
/**
 Number of assets
 */
@property (nonatomic, assign, readonly) NSUInteger numberOfAssets;

/**
 Get number of media type

 @param mediaType Media type, see ZXAssetMediaType
 @return NSUInteger
 */
- (NSUInteger)numberOfAssetsWithMediaType:(ZXAssetMediaType)mediaType;

/**
 Get sorted assets

 @param ascending sort for creation date
 @param completion completion block
 */
- (void)fetchAssetsWithAscending:(BOOL)ascending completion:(void(^)(NSArray<ZXPhotoAsset *> *results))completion;

@end

/**
 ZXPhotoAsset
 */
@interface ZXPhotoAsset : NSObject
/**
 The media type, see ZXAssetMediaType
 */
@property (nonatomic, assign, readonly) ZXAssetMediaType mediaType;
/**
 The media size with scale size
 */
@property (nonatomic, assign, readonly) CGSize mediaSize;
/**
 The pixel size, out scale size
 */
@property (nonatomic, assign, readonly) CGSize pixelSize;
/**
 Number of bytes
 */
@property (nonatomic, assign, readonly) NSUInteger numberOfBytes;
/**
 Image orientation
 */
@property (nonatomic, assign, readonly) UIImageOrientation orientation;

/**
 Get image data

 @return NSData
 */
- (NSData *)imageData;

/**
 Get UIImage with specified size and mode

 @param aspectFill Aspect Fill(YES) or Aspect Fit(NO)
 @param targetSize Target image size
 @return UIImage
 */
- (UIImage *)imageForAspectFill:(BOOL)aspectFill targetSize:(CGSize)targetSize;

@end
